# MIMIC-IV Vocabulary Integration with OMOP CDM

## Overview

**MIMIC-IV** (Medical Information Mart for Intensive Care IV) is a publicly available critical care database developed by the MIT Laboratory for Computational Physiology. It contains de-identified clinical data associated with over 60,000 ICU admissions. Integration with the **OMOP Common Data Model (CDM)** enables its use in large-scale observational research, allowing comparisons with other OMOP-compatible datasets.

Previous efforts have mapped subsets of MIMIC-IV data to OMOP CDM, such as those by Odysseus, PhysioNet collaborators, and academic contributors. This work expands on those efforts and supports the **NIH Bridge2AI Clinical Care CHoRUS Project**, where high-quality, semantically interoperable data is a core objective.

---

## Sources Utilized

The mapping and vocabulary enrichment effort integrated multiple authoritative and community-curated sources:

- [MIMIC-IV v3.1](https://physionet.org/content/mimiciv/3.1/)
- [MIMIC-IV Demo v2.2](https://physionet.org/content/mimic-iv-demo/2.2/#files-panel)
- [MIMIC-IV Waveform Database v0.1.0](https://www.physionet.org/content/mimic4wdb/0.1.0/)
- [OHDSI GitHub: Custom MIMIC Mapping Files](https://github.com/OHDSI/MIMIC/tree/main/custom_mapping_csv)
- MIMIC-IV code counts provided by Tufts CTSI

### Mapping Sources

- **Manual curation** (Polina Talapova)
- **Candidate maps** derived from:
  - MIMIC-IV v1.0 (Tom Pollard)
  - MIMIC-IV v2.0 (Abdulrahman Chahin)
  - MIMIC-IV v2.0 (Odysseus Vocabulary Team)
  - MIMIC-IV Waveform DB 0.1.0 (Manlik Kwong)
---

## Transformation Workflow

1. **Initial Data Collection**  
   MIMIC-IV codes were manually extracted from multiple structured and semi-structured files (CSV format).

2. **Database Integration**  
   All source codes and metadata were imported into a PostgreSQL instance, where they were unified into a table using the [SSSOM](https://mapping-commons.github.io/sssom/) format for mapping metadata.

3. **Mapping Environment**  
   Mappings were curated, validated, and edited using Google Sheets (hereinafter referred to as a `source mapping table`), chosen for:
   - Collaborative editing
   - Familiarity across teams
   - Easy integration with Apps Script

4. **Automation & Version Control**  
   - Apps Scripts push mapping changes to GitHub.
   - GitHub Actions trigger a pipeline to:
     - Ingest mappings into PostgreSQL
     - Perform syntactic QC
     - Detect and stage deltas vs. latest OMOP vocabularies
     - Assign `concept_id` values > 2 billion
     - Write vocabulary delta tables back to GitHub for validation or OHDSI integration

5. **Infrastructure**  
   - Azure ContainerApp for GitHub self-hosted runner execution
   - Azure Flexible PostgreSQL server with vocabulary constraints and indexes

---
# Vocabulary and Mapping Specification

## Concept IDs
### `SOURCE_CONCEPT_ID` in the `source mapping table`
Source concept IDs are initially set to 0 in the `source mapping table`. During the transformation workflow, stable IDs greater than 2 billion are automatically generated to align with OHDSI conventions for custom vocabulary concepts. These IDs are persistent, once assigned to a source_code, they do not change, and can be found in the vocabulary delta tables to ensure traceability and reproducibility. 

## Concept Names

### `SOURCE_DESCRIPTION` in the `source mapping table`
Concept names mirror original MIMIC descriptions. Where needed, semantic enrichment was applied:
- Concatenation using pipes: e.g., `Glucose|Urine|Chemistry`
- Drug codes (e.g., CPT4, HCPCS) resolved using OHDSI Athena via `source_code` matching.
- Duplicate concept names with different source_code values have the source_code appended in brackets for disambiguation (e.g. `Glucose|Blood|Chemistry (50931)` and `Glucose|Blood|Chemistry (52569)`)

## Domains
### `SOURCE_DOMAIN` in the `source mapping table`

### Domain Inference

- **Codes with `Maps to` relationships**: Inherit domain from the target OMOP concept
- **Codes without `Maps to` relationships**: Domains are assigned semi-automatically based on OMOP domain definitions, existing concept hierarchies, and subject-matter expertise.

| Source Domain | Count |
|--------|-------|
| Drug | 2579 |
| Measurement | 2365 |
| Procedure | 2319 |
| Observation | 1695 |
| Unit | 427 |
| Spec Anatomic Site | 382 |
| Meas Value | 126 |
| Specimen | 113 |
| Route | 77 |
| Device | 34 |
| Race | 30 |
| Condition | 16 |
| Ethnicity | 1 |
| Note | 1 |

### Domain Special Cases

| Source Table / Concept Class | Target Domain | Example (`source_description`→ `target_concept_id \| target_concept_name)` | 
|-|-|-| 
| admission-class | Observation | `SURGICAL SAME DAY ADMISSION` → `46271037 \| Admission to same day surgery center` | 
| bodysite | Spec Anatomic Site | `L Hand` → `4309650 \| Structure of left hand` | 
| d-items | Measurement | `Minute Volume` → `4353621 \| Minute volume` |
| d-items | Observation | `Temperature Site` → `3024265 \| Body temperature measurement site` | 
| d-items | Procedure | `Invasive Ventilation` → `37158404 \| Invasive mechanical ventilation`<br>ETL logic: If concept has positive value/answer in source data, populate modifier_concept_id/modifier_source_value in the procedure_occurrence table. | 
| d-items | Condition | `Pneumothorax` → `253796 \| Pneumothorax`<br>ETL logic: If concept has positive value/answer in source data, create a record in the condition_occurrence table. | 
| d-items | Note | `Blood Transfusion Consent` → `36304120 \| Blood or blood product transfusion consent Document` | 
| d-labitems | Measurement | `CD3 \%\|Blood\|Hematology` → `3022533 \| CD3 cells/100 cells in Blood` |
| d-labitems | Meas Value | `Voided Specimen` → `42530744 \| Sample could not be processed`<br>ETL logic: Exclude from event tables as no meaningful info, or populate Observation table if needed (e.g., 4264983 | Specimen observable). | 
| mimic-hcpcs-cd | Procedure | `Open treatment of lunate dislocation` → `4003681 \| Open reduction of lunate dislocation` | 
| mimic-hcpcs-cd | Measurement | `Monitoring of interstitial fluid pressure... in detection of muscle compartment syndrome` → `4238690 \| Measurement of interstitial fluid pressure in muscle compartment` 
| mimic-lab-fluid | Specimen | `Joint Fluid` → `4331823 \| Joint fluid specimen` 
| mimic-medication-formulary-drug-cd | Drug | `Acebutolol HCl 200 mg Cap` → `40223169 \| acebutolol 200 MG Oral Capsule` | 
| mimic-medication-frequency | Meas Value | `Q4HWA` → `4288393 \| Every four hours while awake` | 
| mimic-medication-frequency | Observation | `2X` → `4226923 \| Twice` | 
| mimic-medication-icu | Drug | `Insulin - Humalog 75/25` → `2920266 \| insulin lispro 25 UNT/ML / insulin lispro protamine, human 75 UNT/ML Pen Injector [Humalog]` | 
| mimic-medication-icu | Device | `Glucerna 1.5 (Full)` → `44923157 \| GLUCERNA 1.5 CAL LIQUID` | 
| mimic-medication-icu | Measurement | `OR Packed RBC Intake` → `3040494 \| Transfuse packed erythrocytes units [#]` | 
| mimic-medication-icu | Observation | `PO Intake` → `3656010 \| Oral intake` | 
| mimic-medication-route | Route | `SUBCUT` → `4142048 \| Subcutaneous` | 
| mimic-medication-site | Spec Anatomic Site | `left lower back` → `44795036 \| Left lower back structure` | 
| mimic-microbiology-antibiotic | Drug | `CIPROFLOXACIN` → `1797513 \| ciprofloxacin` |
| mimic-microbiology-organism | Observation | `SHIGELLA FLEXNERI` → `4311807 \| Shigella flexneri` | 
| mimic-microbiology-organism | Meas Value | `NO GROWTH` → `4139623 \| No growth` | 
| mimic-microbiology-organism | Measurement | `ABIOTROPHIA/GRANULICATELLA SPECIES` → `46274109 \| Abiotrophia species or Granulicatella species` | 
| mimic-microbiology-test | Measurement | `Cipro Resistant Screen (90224)` → `3023143 \| Ciprofloxacin [Susceptibility]` |
| mimic-microbiology-test | Procedure | `POTASSIUM HYDROXIDE PREPARATION` → `4099465 \| KOH preparation` | 
| mimic-microbiology-test | Observation | `CRYPTOCOCCAL ANTIGEN` → `4012262 \| Cryptococcus antigen` | 
| mimic-race | Race | `ASIAN - KOREAN` → `38003585 \| Korean` |
| mimic-race | Observation | `MULTIPLE RACE/ETHNICITY` → `44814659 \| Multiple race` | 
| mimic-race | Ethnicity | `HISPANIC OR LATINO` → `38003563 \| Hispanic or Latino` |
| mimic-spec-type-desc | Specimen | `Stem Cell - Blood Culture` → `37164572 \| Stem cell specimen` | 
| mimic-units | Unit | `mm/hr` → `8752 \| millimeter per hour` | 
| mimic4wdb | Measurement | `HR [BPM]` → `3027018 \| Heart rate` |

## Vocabulary ID
### `SOURCE_VOCABULARY_ID` in the `source mapping table`
All terms are assigned the `MIMIC4` vocabulary ID. This vocabulary is introduced as a new entity via the `CONCEPT_DELTA` and `VOCABULARY_DELTA` tables.

## Concept Classes
### `SOURCE_CODE_SET` in the `source mapping table`

Concept Class is derived from the MIMIC source table (captured in the source_code_set field). As part of the integration, 18 new concept classes are introduced and registered through the CONCEPT_DELTA and CONCEPT_CLASS_DELTA tables.

| Concept Class | Count |
|---------------|-------|
| mimic-medication-formulary-drug-cd | 2314 |
| mimic-hcpcs-cd | 2201 |
| d-items | 1631 |
| d-labitems | 1388 |
| mimic-microbiology-organism | 636 |
| mimic-units | 427 |
| mimic4wdb | 368 |
| mimic-medication-site | 302 |
| mimic-medication-icu | 283 |
| mimic-microbiology-test | 168 |
| mimic-medication-frequency | 108 |
| mimic-spec-type-desc | 103 |
| bodysite | 80 |
| mimic-medication-route | 77 |
| mimic-race | 33 |
| mimic-microbiology-antibiotic | 27 |
| mimic-lab-fluid | 10 |
| admission-class | 9 |
| Total | 10165 |

---

## Standard Concepts Logic

*No specific field in the `source mapping table`; assigned during transformation.*

- **Standard concepts (`standard_concept = 'S'`)**:  
  MIMIC-IV codes that do **not** have a valid mapping to a Standard OMOP concept are designated as **Standard** within the custom vocabulary. These typically represent novel or local source concepts without a direct OMOP equivalent but are still meaningful for analytical use. In the `concept_relationship` table, these codes have a `"Maps to"` relationship that points **back to their own `concept_id`** (i.e., self-mapping).

    -  **Special Case:**  
In the `source mapping table`, there are **three instances** where source terms are mapped to **non-standard but valid OMOP concepts.** All three originate from the `mimic-race` table:

| source_description            | relationship_id | predicate_id      | confidence | target_concept_id | target_concept_name       | target_vocabulary_id | target_domain_id |
|-------------------------------|-----------------|-------------------|------------|-------------------|---------------------------|----------------------|------------------|
| MULTIPLE RACE/ETHNICITY       | Maps to         | skos:exactMatch   | 1          | 44814659          | Multiple race             | PCORNet              | Observation      |
| PATIENT DECLINED TO ANSWER    | Maps to         | skos:exactMatch   | 1          | 44814660          | Refuse to answer          | PCORNet              | Observation      |
| UNKNOWN                       | Maps to         | skos:exactMatch   | 1          | 45431577          | RACE: Unknown             | Read                 | Race             |

According to **THEMIS recommendations**, these mappings are valid for ETL implementation. However, when constructing delta tables, and following the **standard OMOP logic of concept assignment, these source terms are expected to become Standard MIMIC-IV concepts with self-mapping.** 

- **Non-standard concepts (`standard_concept IS NULL`)**:  
  MIMIC-IV codes that are mapped to existing Standard OMOP concepts are classified as **Non-standard**. Their `"Maps to"` relationship in the `concept_relationship` table links to the appropriate Standard OMOP concept and can be:
  - **1-to-1** (direct mapping)
  - **1-to-many** (applicable to the Drug domain in MIMIC-IV)

- **Invalid/junk concepts**:  
  MIMIC-IV codes with `target_concept_id = -1` are classified as **Non-standard**. These represent ambiguous or uninterpretable codes and are **excluded** from the custom ontology as potential Standard concepts.

---
## Concept Codes
### `SOURCE_CODE` in the `source mapping table`  

Source codes in MIMIC-IV are heterogeneous: some are original numeric `itemid` values, others are alphanumeric (e.g., drug codes), and in certain cases, the source code **duplicates** the `source_description` field where no distinct `source_code` was provided initially.

To prevent **duplicate source codes within a single vocabulary** (which violates OMOP conventions), the following transformations were applied to ensure uniqueness:

- In two cases, an additional identifier was added in brackets to distinguish source codes:  
  - `[AS]` in `mimic4wdb`  
  - `[IU]` in `mimic-units`

- For **CPT4 codes** (from `mimic-hcpcs-cd`), the original code system was prefixed for clarity and uniqueness:  
  - e.g., `CPT4:50961`  
  - This was applied to **51 codes** that conflicted with codes in `d-labitems`.

## Concept Synonyms

### `SOURCE_DESCRIPTION_SYNONYM` in the `source mapping table`
This column captures:
1. Expanded abbreviations
2. Drug synonyms (e.g., `Tacrolimus` for `FK506`)
3. Clarified specimen terms (e.g., `Specimen for THROAT CULTURE`)
4. Source category + name concatenation for additional semantic detail
   
## Valid Start and End Dates
*No specific field in the `source mapping table`; assigned during transformation.*

In OMOP vocabularies, the `valid_start_date` and `valid_end_date` fields define the **period of validity** for each concept and its relationships. Maintaining accurate validity windows is critical for ensuring the **temporal integrity** of mappings, especially in environments with ongoing vocabulary updates or longitudinal analyses.

- **For active concepts and mappings:**  
  - Set `valid_start_date` to the **current date** corresponding to the start of the transformation or vocabulary refresh process (e.g., the date when the delta is generated or published).  
  - Set `valid_end_date` to a **distant future date** (typically `2099-12-31`) to indicate the concept or mapping remains valid **until explicitly deprecated or updated.**

- **For deprecated or updated concepts and mappings:**  
  - When deprecating or replacing a concept/mapping, update the existing record by setting `valid_end_date` to the **current date** (i.e., the date of the change).  
  - If replacing, also insert a **new record** with an updated mapping and a `valid_start_date` equal to the same current date, creating a **clean historical audit trail**.

## Invalid Reason
*No specific field in the `source mapping table`; assigned during transformation.*

- **Active concepts and mappings:**  
  All active concepts in the `CONCEPT` table and their mappings in the `CONCEPT_RELATIONSHIP` table have `invalid_reason = NULL`, indicating they are currently valid and in use.

- **Deprecating concepts:**  
  If a MIMIC-IV term is **deleted from the `source mapping table`**, it must be deprecated by:  
  - Updating the corresponding row in the `CONCEPT` table with `invalid_reason = 'D'` (deprecated).  
  - Deprecating all of its related mappings in the `CONCEPT_RELATIONSHIP` table by setting `invalid_reason = 'D'`.  
  - **Important:** Always review and update **hierarchical and other dependencies** (e.g., `Is a`, `Subsumes`) to prevent orphaned relationships or broken hierarchies.

- **Deprecating mappings only:**  
  If a mapping is **removed (without replacement)** from the `source mapping table`, deprecate the specific mapping in the `CONCEPT_RELATIONSHIP` table (`invalid_reason = 'D'`).  
  - After deprecation, verify the **standardness** of the source concept in the `CONCEPT` table, if it no longer maps to any Standard concept, its `standard_concept` designation may need to be updated accordingly.

- **Changing mappings:**  
  If a mapping is **replaced** (e.g., remapped to a different target concept), the old mapping must be **deprecated** (`invalid_reason = 'D'`), and a new valid mapping inserted with `invalid_reason = NULL` and updated dates.

---

## Concept Relationships
### `RELATIONSHIP_ID` in the `source mapping table`  

Three types of relationships are modeled:

- **Mapping**: e.g., `"Maps to"`, `"Maps to value"`
- **Hierarchical**: `"Is a"`, `"Subsumes"`
- **Attributive**: `"Has measurement"`, `"Has relat context"`, etc.

| Relationship Type | Count | Predicate ID | Type |
|-------------------|--------|-----------|-----------|
| Maps to | 8 338 | skos:exactMatch / skos:closeMatch | Mapping |
| Maps to value | 6 | skos:closeMatchValue | Mapping |
| Is a | 795| skos:broadMatch | Hierarchical | Hierarchical |
| Subsumes | 323 | skos:narrowMatch | Hierarchical |
| Has relat context | 837 | skos:relatedMatch | Attributive |
| Has measurement | 232 | skos:relatedMatch | Attributive |
| Has asso proc | 264 | skos:relatedMatch | Attributive |
| Has asso finding | 77 | skos:relatedMatch | Attributive |
| Has asso visit | 7 | skos:relatedMatch | Attributive |
| `[No relationship]` | 114 | skos:noMatch | Candidate or Junk concept |
| Total | 10993 |||

## Hierarchy

MIMIC-IV has no native hierarchical structure. However:

- `"Is a"` used to define child-to-parent relations
- `"Subsumes"` used for parent-to-child cases (limited by potential hierarchy break risk)
- `CONCEPT_ANCESTOR` table is populated only for relationships involving standard concepts
- Non-standard concepts are excluded from ancestor chains

---

## ETL Guidance

Best practices for integrating MIMIC-IV source values into your OMOP CDM instance using the provided vocabulary mappings are outlined below. These steps ensure accurate and standards-compliant transformation.

### 1. **Extract**

Retrieve source values using:  
- MIMIC-IV source table  
- `source_code` (the specific code to be mapped, e.g., `itemid`)  
- `source_description` (the human-readable name of the source code)
These three fields together form the **minimal key set** required for joining with the custom vocabulary. Including `source_description` ensures robust validation, facilitates fallback mapping (e.g., `concept_name` joins), and provides semantic clarity during ETL processing.

### 2. **Join and Filter**

A **multi-pass join strategy with contextual filtering** ensures mapping completeness and accuracy:

1. **First pass (primary join on `concept_code`):**  
   - Join source data with the vocabulary on `concept_code`.  
   - Apply filters by `domain_id` and/or `concept_class_id` (reflecting the MIMIC source table being processed) to ensure contextually correct matches.  
   - Resolves the majority of mappings where codes are unique and well-defined.

2. **Second pass (fallback join on `concept_name`):**  
   - For remaining unmapped records, join on `concept_name`.  
   - Continue filtering by `domain_id` and/or `concept_class_id` to avoid incorrect matches (e.g., between similarly named drugs and measurements).  
   - Useful when source codes are missing or duplicated.

3. **Third pass (expanded search using `concept_synonym_name`):**  
   - For any residual unmapped cases, join on `concept_synonym_name`.  
   - Captures synonyms, abbreviations, and alternative labels curated to support mapping.

4. **Final filtering:**  
   - After joining, retain only mappings with a valid `target_concept_id` (i.e., successfully mapped concepts).  
   - Optionally apply additional filters to limit the dataset to specific domains (e.g., `Measurement`, `Condition`, `Drug`) or source categories, depending on your ETL requirements.

5. **Handling remaining gaps:**  
   - Compile any still-unmapped items into a gap list.  
   - Submit the list for review to determine whether new concepts need to be added or manual corrections are required.

### 4. **Transform**

Apply `"Maps to"` and `"Maps to value"` relationships to standardize source data, ensuring that each record links to the appropriate Standard OMOP concept.  
Where applicable:

### 5. **Load**

Insert transformed data into the appropriate OMOP CDM tables, such as:

- `MEASUREMENT`
- `CONDITION_OCCURRENCE`
- `DRUG_EXPOSURE`
- `PROCEDURE_OCCURRENCE`
- `OBSERVATION`
- (Others as needed)

Ensure that all required OMOP CDM fields are populated according to the specification (e.g., `value_as_number`, `unit_concept_id`).

### Additional Considerations

- **Version alignment:** Verify that the vocabulary version used in ETL matches the version used for mapping to avoid misalignment.
- **Audit trail:** Log all mapping steps and retain mapping metadata to maintain traceability and reproducibility.
- **Quality control:** Include validation checks to catch nulls, domain mismatches, or invalid units before loading data.

---
## Gaps and Limitations

While the current MIMIC-IV vocabulary mapping offers robust coverage and is ready for production use, several known limitations and blind spots remain. These should be considered during implementation and may serve as targets for future enhancement.

### Provenance Tagging

Provenance tagging is **supported and implemented** using SSSOM metadata fields such as `author_id`, `author_label`, `reviewer_id`, and `reviewer_label`, along with additional `mapping_metadata` captured at the ontology level. This infrastructure provides the capacity to trace the origin, authorship, and review status of each mapping.

However, **not all mappings have undergone formal review by a designated reviewer**, and in some cases, provenance fields (particularly `reviewer_label`) may be missing. As a result, while the technical framework for provenance is in place, full **coverage and consistency across all mappings are still in progress.**

*Improvement opportunity:* Complete reviewer assignments for all mappings and establish routine audits to ensure that provenance metadata remains comprehensive and up to date.

### Confidence Scoring and Inter-Rater Reliability

Confidence scores (on a 0–1 scale) are included in the mapping metadata, reflecting the **initial certainty** of each mapping. However, these scores are **not yet validated through multi-reviewer consensus** or inter-rater reliability processes. As a result, some confidence values may reflect individual curator judgment rather than consensus-based validation.

*Improvement opportunity:* Implement a peer review or Delphi-like process to standardize and validate confidence scores across multiple subject-matter experts.

### Ambiguous `Maps to` Relationships

Certain mappings rely on **ambiguous or broad target concepts** that may require **additional context** for precise interpretation. For example, generic mappings where multiple OMOP concepts could apply based on finer clinical detail may lead to semantic drift in downstream analyses.

*Improvement opportunity:* Establish a **context disambiguation protocol** or flag ambiguous mappings for special handling in ETL pipelines, with clear guidance for implementers.

### Incomplete Qualification of Units and Specimens

Not all mapping rows are fully **qualified by associated units or specimen types.** In cases where the original source code is underspecified, there is a risk that mapped concepts may be **misclassified or misinterpreted,** especially for laboratory tests or microbiology results.

*Improvement opportunity:* Enhance mapping granularity by explicitly associating each mapping with validated `unit_concept_id` and `specimen_concept_id` values where applicable.

---

## Recommendations and Next Steps

- Ensure **complete and consistent population** of provenance metadata (e.g., `author_label`, `reviewer_label`) across all mappings to enhance traceability, accountability, and transparency.
- Expand **validation layers** to include more robust checks for mapping accuracy and hierarchical integrity.
- Broaden **mapping coverage** to address remaining gaps and ensure comprehensive representation of all relevant MIMIC-IV source concepts.
- Continuously enhance **mapping quality** through iterative review, expert validation, and refinement of ambiguous mappings.
- Integrate **new standard concepts** with the Critical Care ontology to strengthen semantic alignment and improve interoperability for intensive care research.
