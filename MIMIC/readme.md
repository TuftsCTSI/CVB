# MIMIC-IV Vocabulary Integration with OMOP CDM

## Overview

This folder contains the **MIMIC-IV** vocabulary integration package for loading curated
MIMIC source concepts and mappings into an **OMOP Common Data Model** vocabulary
schema.

MIMIC-IV is a publicly available critical care database developed by the MIT
Laboratory for Computational Physiology. Integrating MIMIC-IV source terms with
OMOP CDM vocabulary tables supports reproducible ICU research, cross-site
observational analytics, and downstream ETL into standard OMOP clinical event
tables.

This work extends earlier MIMIC-to-OMOP mapping efforts and supports the **NIH
Bridge2AI Clinical Care CHoRUS Project**, where semantically interoperable critical
care data is a core requirement.

## Current Package Snapshot

The current repository state represents a refreshed MIMIC4 vocabulary package.

| Item | Current value |
|---|---:|
| Source mapping rows in `Mappings/mimic_mapping.csv` | 26,916 |
| Distinct MIMIC4 source concept rows represented in mapping file | 24,394 |
| MIMIC4 concepts in `Ontology/concept_delta.csv` | 24,394 |
| Standard MIMIC4 concepts | 2,323 |
| Non-standard MIMIC4 concepts | 22,071 |
| Registered concept classes in `Ontology/concept_class_delta.csv` | 39 |
| Mapping metadata rows | 26,696 |
| Source-to-concept-map rows | 26,181 |
| Concept relationship delta rows, including inverse relationships | 58,038 |
| Concept synonym rows | 12,024 |
| MIMIC4 vocabulary version | 2026-05-28 |

Important interpretation notes:

- `Mappings/mimic_mapping.csv` is the full curation layer. It includes mapping,
  hierarchy, attribute, blank, and invalid or junk rows.
- `Ontology/source_to_concept_map.csv` is the ETL-facing mapping export. It keeps
  only `Maps to` and `Maps to value` rows.
- `Ontology/concept_relationship_delta.csv` includes forward and reverse
  relationship rows, so its count is intentionally larger than the curation
  mapping count.
- `Ontology/domain_delta.csv` and `Ontology/relationship_delta.csv` are
  header-only in this snapshot. No new OMOP domains or relationship types are
  introduced by those files.
- All active concept and relationship rows in this snapshot have
  `valid_end_date = 2099-12-31` and blank `invalid_reason`.

## Folder Contents

| Path | Purpose |
|---|---|
| `MIMIC/readme.md` | Top-level package documentation and current artifact summary. |
| `MIMIC/Mappings/mimic_mapping.csv` | Source mapping table used for curation, review, and generation of ontology deltas. |
| `MIMIC/Ontology/*.csv` | Generated vocabulary delta, metadata, and ETL mapping outputs. |
| `MIMIC/Ontology/readme.md` | Upload-oriented instructions for integrating delta tables into an OMOP vocabulary schema. |
| `MIMIC/Builder/sql/*.sql` | SQL scripts for staging, loading, comparing, updating, and reverting vocabulary deltas. |
| `MIMIC/Builder/execute-pipeline.sh` | Pipeline entry point for executing the vocabulary build workflow. |
| `MIMIC/Builder/revert-db.sh` | Revert helper for database state management. |
| `MIMIC/Builder/git-integration.js` | Git integration helper for automation. |
| `MIMIC/Utilities/daily-update.gs` | Google Apps Script utility used by the mapping workflow. |


## Sources Utilized

The mapping and vocabulary enrichment effort integrates authoritative,
community-curated, and manually reviewed inputs:

- [MIMIC-IV v3.1](https://physionet.org/content/mimiciv/3.1/)
- [MIMIC-IV Demo v2.2](https://physionet.org/content/mimic-iv-demo/2.2/#files-panel)
- [MIMIC-IV Waveform Database v0.1.0](https://www.physionet.org/content/mimic4wdb/0.1.0/)
- [OHDSI GitHub MIMIC custom mapping files](https://github.com/OHDSI/MIMIC/tree/main/custom_mapping_csv)
- MIMIC-IV code counts provided by Tufts CTSI
- Manual curation by Polina Talapova
- Candidate maps derived from prior MIMIC-IV and waveform mapping work,
  including contributions associated with Tom Pollard, Abdulrahman Chahin,
  the Odysseus Vocabulary Team, Manlik Kwong and SciForce Team.

### Mapping Sources

- **Manual curation** (Polina Talapova)
- **Candidate maps** derived from:
  - MIMIC-IV v1.0 (Tom Pollard)
  - MIMIC-IV v2.0 (Abdulrahman Chahin)
  - MIMIC-IV v2.0 (Odysseus Vocabulary Team)
  - MIMIC-IV Waveform DB 0.1.0 (Manlik Kwong)
  - MIMIC-IV v2.0 (SciForce Team)
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

## Mapping Source Table

`Mappings/mimic_mapping.csv` is the primary curation input.

Current curation-level relationship counts:

| Relationship | Rows |
|---|---:|
| Maps to | 22,654 |
| Is a | 1,319 |
| Maps to value | 1,204 |
| Has relat context | 762 |
| Subsumes | 297 |
| Blank relationship | 220 |
| Has asso proc | 201 |
| Has measurement | 191 |
| Has asso finding | 61 |
| Has asso visit | 7 |

Additional curation facts:

- Every row currently has a populated `source_concept_id`.
- 75 rows have `target_concept_id = -1`, representing potentially junk concepts.
- 220 rows have no populated `relationship_id`; these rows are not exported to
  `source_to_concept_map.csv`.
- All 26,916 rows have an `author_label`.
- 18,839 rows have a `reviewer_label` in the curation file.


# Vocabulary and Mapping Specification

## Concept IDs

MIMIC4 concepts use custom concept identifiers greater than 2 billion, following
OHDSI custom vocabulary conventions. Once assigned to a source code, a
`source_concept_id` should remain stable so mappings are traceable across
refreshes.

## Concept Names

Concept names preserve original MIMIC descriptions (`source_description` field) where possible. Semantic
enrichment is used when needed:

- Pipe-delimited context, such as analyte, specimen, or category.
- Drug name resolution from available MIMIC drug, NDC, formulary, and RxNorm
  context.
- Source code disambiguation when the same display name appears for distinct
  source codes.
- Expanded synonyms in 
  `source_description_synonym`.

  ### Vocabulary ID

All source concepts are assigned to the `MIMIC4` vocabulary. `MIMIC4` is
registered through `vocabulary_delta.csv`.

### Validity Dates and Invalid Reason

Current active rows use the following conventions:

| Field | Current convention |
|---|---|
| `valid_start_date` | `2025-05-07` or `2026-05-28`, depending on when the row entered the generated package. |
| `valid_end_date` | `2099-12-31` for all active concept and relationship rows. |
| `invalid_reason` | Blank for all active concept and relationship rows in the current delta files. |

## Domains
`source_domain` in `Mappings/mimic_mapping.csv` reflects the curation-layer
domain assignment.

Current source-domain row counts:

| Source domain | Mapping rows |
|---|---:|
| Drug | 12,370 |
| Observation | 7,430 |
| Measurement | 3,121 |
| Procedure | 2,757 |
| Unit | 396 |
| Device | 150 |
| Specimen | 146 |
| Condition | 120 |
| Route | 117 |
| Visit | 86 |
| Undefined | 74 |
| Waveform Metadata | 44 |
| Meas Value | 39 |
| Language | 23 |
| Race | 17 |
| Ethnicity | 17 |
| Type Concept | 8 |
| Note | 1 |

Domain assignment rules:

- Rows with valid `Maps to` relationships generally inherit the target OMOP
  domain where appropriate.
- Rows without a standard target are assigned domains using OMOP domain
  definitions, available hierarchy, source-table context, and clinical subject
  matter review.
- Some source categories legitimately split across domains. For example,
  MIMIC item labels can represent measurements, procedures, observations,
  conditions, notes, or device-related concepts depending on source semantics
  and downstream ETL use.

### Domain Special Cases

| Source Table / Concept Class | Target Domain | Example (`source_description` → `target_concept_id \| target_concept_name`) |
|---|---|---|
| `mimiciv_hosp.admissions.admission_type` | Visit | `SURGICAL SAME DAY ADMISSION` → `9201 \| Inpatient Visit` |
| `mimiciv_hosp.emar_detail.site` | Spec Anatomic Site | `L Hand` → `4309650 \| Structure of left hand` |
| `mimiciv_icu.chartevents.itemid` | Measurement | `Minute Volume` → `4353621 \| Minute volume` |
| `mimiciv_icu.chartevents.itemid` | Observation | `Temperature Site` → `3024265 \| Body temperature measurement site` |
| `mimiciv_icu.procedureevents.itemid` | Procedure | `Invasive Ventilation` → `37158404 \| Invasive mechanical ventilation`<br><br>**ETL logic:** If the concept has a positive value or answer in the source data, populate `modifier_concept_id` and `modifier_source_value` in the `PROCEDURE_OCCURRENCE` table. |
| `mimiciv_icu.procedureevents.itemid` | Condition | `Pneumothorax` → `253796 \| Pneumothorax`<br><br>**ETL logic:** If the concept has a positive value or answer in the source data, create a record in the `CONDITION_OCCURRENCE` table. |
| `mimiciv_icu.d_items.label` | Note | `Blood Transfusion Consent` → `36304120 \| Blood or blood product transfusion consent Document` |
| `mimiciv_hosp.d_labitems.itemid` | Measurement | `CD3 %\|Blood\|Hematology` → `3022533 \| CD3 cells/cells in Blood` |
| `mimiciv_hosp.d_labitems.itemid` | Undefined | `Voided Specimen (51806)` → `-1 \| No valid target concept`<br><br>**ETL logic:** Exclude from event tables unless a local ETL chooses to retain it as an unmapped source-quality flag. |
| `mimiciv_hosp.d_hcpcs.code` | Procedure | `Open treatment of lunate dislocation` → `4003681 \| Open reduction of lunate dislocation` |
| `mimiciv_hosp.d_hcpcs.code` | Measurement | `Monitoring of interstitial fluid pressure (includes insertion of device, eg, wick catheter technique, needle manometer technique) in detection of muscle compartment syndrome` → `4238690 \| Measurement of interstitial fluid pressure in muscle compartment` |
| `mimiciv_hosp.d_labitems.fluid` | Specimen | `Joint Fluid` → `4331823 \| Joint fluid specimen` |
| `mimiciv_hosp.prescriptions.formulary_drug_cd` | Drug | `Acebutolol HCl 200 mg Cap` → `40223169 \| acebutolol 200 MG Oral Capsule` |
| `mimiciv_hosp.pharmacy.frequency` | Meas Value | `Q4HWA` → `4288393 \| Every four hours while awake` |
| `mimiciv_hosp.pharmacy.frequency` | Observation | `2X` → `4226923 \| Twice` |
| `mimiciv_icu.inputevents.itemid` | Drug | `Insulin - Humalog 75/25` → `2920266 \| insulin lispro 25 UNT/ML / insulin lispro protamine, human 75 UNT/ML Pen Injector [Humalog]` |
| `mimiciv_icu.inputevents.itemid` | Device | `Glucerna 1.5 (Full)` → `44923157 \| GLUCERNA 1.5 CAL LIQUID` |
| `mimiciv_icu.inputevents.itemid` | Measurement | `OR Packed RBC Intake` → `3040494 \| Transfuse packed erythrocytes units [#]` |
| `mimiciv_icu.inputevents.itemid` | Observation | `PO Intake` → `3656010 \| Oral intake` |
| `mimiciv_hosp.prescriptions.route` | Route | `SUBCUT` → `4142048 \| Subcutaneous` |
| `mimiciv_hosp.emar_detail.site` | Spec Anatomic Site | `left lower back` → `44795036 \| Left lower back structure` |
| `mimiciv_hosp.microbiologyevents.ab_itemid` | Measurement | `CIPROFLOXACIN` → `3020153 \| Ciprofloxacin [Susceptibility] by Disk diffusion (KB)` |
| `mimiciv_hosp.microbiologyevents.org_itemid` | Observation | `SHIGELLA FLEXNERI` → `4311807 \| Shigella flexneri` |
| `mimiciv_hosp.microbiologyevents.org_itemid` | Meas Value | `NO GROWTH` → `4139623 \| No growth` |
| `mimiciv_hosp.microbiologyevents.org_itemid` | Measurement | `ABIOTROPHIA/GRANULICATELLA SPECIES` → `46274109 \| Abiotrophia species or Granulicatella species` |
| `mimiciv_hosp.microbiologyevents.test_itemid` | Measurement | `Cipro Resistant Screen (90224)` → `3023143 \| Ciprofloxacin [Susceptibility]` |
| `mimiciv_hosp.microbiologyevents.test_itemid` | Procedure | `POTASSIUM HYDROXIDE PREPARATION` → `4099465 \| KOH preparation` |
| `mimiciv_hosp.microbiologyevents.test_itemid` | Observation | `CRYPTOCOCCAL ANTIGEN` → `4012262 \| Cryptococcus antigen` |
| `mimiciv_hosp.admissions.race` | Race | `ASIAN - KOREAN` → `38003585 \| Korean` |
| `mimiciv_hosp.admissions.race` | Ethnicity | `MULTIPLE RACE/ETHNICITY` → `1546846 \| More than one ethnicity` |
| `mimiciv_hosp.admissions.race` | Ethnicity | `HISPANIC OR LATINO` → `38003563 \| Hispanic or Latino` |
| `mimiciv_hosp.microbiologyevents.spec_itemid` | Specimen | `Stem Cell - Blood Culture` → `37164572 \| Stem cell specimen` |
| `mimiciv_units` | Unit | `mm/hr` → `8752 \| millimeter per hour` |
| `mimic4wdb` | Measurement | `HR [BPM]` → `3027018 \| Heart rate` |

## Concept Classes

The current package registers 40 concept classes. Concept class identifiers now
use compact IDs such as `m4_lab_itemid` and `m4_rx_drug`, while
`concept_class_name` preserves the source table or source field.

| Concept class ID | Source field | Concept rows |
|---|---|---:|
| `gcpt_drug_ndc` | `gcpt_drug_ndc` | 1,297 |
| `m4_adm_location` | `mimiciv_hosp.admissions.admission_location` | 43 |
| `m4_adm_race` | `mimiciv_hosp.admissions.race` | 34 |
| `m4_adm_type` | `mimiciv_hosp.admissions.admission_type` | 9 |
| `m4_careunit` | `mimiciv_hosp.transfers.careunit` | 5 |
| `m4_chart_itemid` | `mimiciv_icu.chartevents.itemid` | 163 |
| `m4_chart_value` | `mimiciv_icu.chartevents.value` | 18 |
| `m4_curr_service` | `mimiciv_hosp.services.curr_service` | 19 |
| `m4_datetime_item` | `mimiciv_icu.datetimeevents.itemid` | 129 |
| `m4_discharge_loc` | `mimiciv_hosp.admissions.discharge_location` | 13 |
| `m4_ditem_label` | `mimiciv_icu.d_items.label` | 1,207 |
| `m4_drg_desc` | `mimiciv_hosp.drgcodes.description` | 900 |
| `m4_emar_site` | `mimiciv_hosp.emar_detail.site` | 301 |
| `m4_formulary_cd` | `mimiciv_hosp.prescriptions.formulary_drug_cd` | 2,311 |
| `m4_generated` | `mimiciv_mimic_generated` | 12 |
| `m4_hcpcs_code` | `mimiciv_hosp.d_hcpcs.code` | 2,201 |
| `m4_icd_dx_code` | `mimiciv_hosp.d_icd_diagnoses.icd_code` | 3,421 |
| `m4_icd_px_code` | `mimiciv_hosp.d_icd_procedures.icd_code` | 63 |
| `m4_input_itemid` | `mimiciv_icu.inputevents.itemid` | 283 |
| `m4_insurance` | `mimiciv_hosp.admissions.insurance` | 5 |
| `m4_lab_fluid` | `mimiciv_hosp.d_labitems.fluid` | 10 |
| `m4_lab_itemid` | `mimiciv_hosp.d_labitems.itemid` | 1,506 |
| `m4_language` | `mimiciv_hosp.admissions.language` | 23 |
| `m4_marital_status` | `mimiciv_hosp.admissions.marital_status` | 7 |
| `m4_meas_wf` | `mimiciv_meas_wf` | 33 |
| `m4_meas_wf_unit` | `mimiciv_meas_wf_unit` | 3 |
| `m4_micro_ab` | `mimiciv_hosp.microbiologyevents.ab_itemid` | 29 |
| `m4_micro_interp` | `mimiciv_hosp.microbiologyevents.interpretation` | 4 |
| `m4_micro_org` | `mimiciv_hosp.microbiologyevents.org_itemid` | 677 |
| `m4_micro_spec` | `mimiciv_hosp.microbiologyevents.spec_itemid` | 113 |
| `m4_micro_test` | `mimiciv_hosp.microbiologyevents.test_itemid` | 172 |
| `m4_output_itemid` | `mimiciv_icu.outputevents.itemid` | 67 |
| `m4_proc_itemid` | `mimiciv_icu.procedureevents.itemid` | 113 |
| `m4_rx_drug` | `mimiciv_hosp.prescriptions.drug` | 4,493 |
| `m4_rx_frequency` | `mimiciv_hosp.pharmacy.frequency` | 108 |
| `m4_rx_ndc` | `mimiciv_hosp.prescriptions.ndc` | 3,742 |
| `m4_rx_route` | `mimiciv_hosp.prescriptions.route` | 100 |
| `m4_units` | `mimiciv_units` | 392 |
| `mimic4wdb` | `mimic4wdb` | 368 |
---

## Standard Concepts Logic

MIMIC4 concepts follow this convention:

- MIMIC4 source concepts without a valid external standard target become
  standard MIMIC4 concepts with `standard_concept = S`.
- MIMIC4 source concepts with valid mappings to existing standard OMOP concepts
  remain non-standard source concepts.
- Self-mapping rows are used where a MIMIC4 concept is standard within the
  custom vocabulary.
- Rows with `target_concept_id = -1` represent invalid, ambiguous, or otherwise uninterpretable source terms. They are therefore classified as non-standard concepts, excluded from mapping relationships, and should not be used for ETL standardization.

---
## Concept Codes
### `SOURCE_CODE` in the `source mapping table`  

Source codes in MIMIC-IV are heterogeneous. They include original numeric `itemid` values, alphanumeric identifiers such as drug and procedure codes, and descriptive text where the source dataset does not provide a separate technical code. In the latter cases, source_code may duplicate source_description.

The OMOP `concept_code` field is limited to 50 characters. Plain truncation of longer MIMIC4 source codes (especially, DRG descriptions as codes) is not used because different values may share the same first 50 characters and consequently produce duplicate `concept_code` values. 

For long or duplicated codes, the generated value follows this pattern: `<shortened source-code prefix>_<source_concept_id>` Because `source_concept_id` is stable and unique for each MIMIC-IV source concept, this approach prevents collisions while preserving as much of the original source code as possible. It also ensures that concept codes remain reproducible across vocabulary builds.

> *Tip:* For DRG concepts, joining by `concept_name` is generally preferable to joining by `concept_code`, because DRG descriptions are used as source codes and can be shortened during the build; the join should also be constrained by `vocabulary_id` and `concept_class_id` to avoid ambiguous matches.

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
- **Attributive**: `"Has measurement"`, `"Has relat context"`, `"Has asso finding"`, `"Has asso visit"` etc.

| Relationship Type | Count | Predicate ID | Type |
|-------------------|--------|-----------|-----------|
| Maps to | 24,977 | skos:exactMatch / skos:closeMatch | Mapping |
| Maps to value | 1,204 | skos:closeMatchValue | Mapping |
| Is a | 1,616| skos:broadMatch | Hierarchical | Hierarchical |
| Subsumes | 1,616 | skos:narrowMatch | Hierarchical |
| Has relat context | 762 | skos:relatedMatch | Attributive |
| Has measurement | 191 | skos:relatedMatch | Attributive |
| Has asso proc | 201 | skos:relatedMatch | Attributive |
| Has asso finding | 61 | skos:relatedMatch | Attributive |
| Has asso visit | 7 | skos:relatedMatch | Attributive |
| Total (with reverse) | 57888 |||

## Hierarchy

MIMIC-IV has no native hierarchical structure. However:

- `"Is a"` used to define child-to-parent relations
- `"Subsumes"` used for parent-to-child cases (limited by potential hierarchy break risk)
- `CONCEPT_ANCESTOR` table is populated only for relationships involving standard concepts
- Non-standard concepts are excluded from ancestor chains

---
# Loading the Ontology Into OMOP
### Required Tools and Access

- Athena OHDSI account for downloading standard vocabularies.
- PostgreSQL-compatible OMOP vocabulary schema.
- SQL client or loader such as `psql`, DBeaver, pgAdmin, Python, R, or Scala.
- Write access to a development vocabulary schema.
- The MIMIC delta files in `MIMIC/Ontology`.
- The delta table DDL in `MIMIC/Builder/sql/delta-tables-ddl.sql`.

### Required Baseline Vocabularies

Download the required standard vocabularies from Athena before applying MIMIC4
deltas. The current mapping files reference these target vocabularies:

- CMS Place of Service
- CPT4
- CVX
- dm+d
- DRG
- Ethnicity
- HCPCS
- ICD10PCS
- LOINC
- NDC
- NUCC
- OMOP Extension
- PPI
- Race
- RxNorm
- RxNorm Extension
- SNOMED
- UCUM
- Visit

Also include standard OMOP vocabulary files required by your CDM installation,
including `CONCEPT`, `CONCEPT_ANCESTOR`, `CONCEPT_CLASS`,
`CONCEPT_RELATIONSHIP`, `CONCEPT_SYNONYM`, `DOMAIN`, `DRUG_STRENGTH`,
`RELATIONSHIP`, and `VOCABULARY`.

If your organization does not hold a license for a restricted vocabulary such as
CPT4, do not download or redistribute that vocabulary outside license terms.

### Load Sequence

1. Load baseline Athena vocabulary files into the OMOP vocabulary schema.
2. Create or truncate staging delta tables using
   `MIMIC/Builder/sql/delta-tables-ddl.sql`.
3. Load MIMIC delta CSV files into the corresponding staging delta tables.

## ETL Guidance

Best practices for integrating MIMIC-IV source values into your OMOP CDM instance using the provided vocabulary mappings are outlined below. These steps ensure accurate and standards-compliant transformation.

### 1. **Extract**

Retrieve source values using:  
- MIMIC-IV source table name  
- `source_code` (the specific code to be mapped, e.g., `itemid`)  
- `source_description` (the human-readable name of the source code)
These three fields together form the **minimal key set** required for joining with the custom vocabulary. Including `source_description` ensures robust validation, facilitates fallback mapping (e.g., `concept_name` joins), and provides semantic clarity during ETL processing.

### 2. **Join and Filter**

A **multi-pass join strategy with contextual filtering** ensures mapping completeness and accuracy:

1. **First pass (primary join on `concept_code`):**  
   - Join source data with the vocabulary on `concept_code`.  
   - Apply filters by `domain_id` and/or `concept_class_id` (reflecting the MIMIC source table being processed, see concept_class_delta.csv for more details) to ensure contextually correct matches.  
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
- `DEVICE_EXPOSURE`
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