# Upload Instructions

## Delta Tables Format Summary

- **File type:** Text (CSV-style)
- **Encoding:** UTF-8
- **Date format:** `yyyy-MM-dd`
- **Field delimiter:** `,` (comma)
- **Quote character:** `"` (double quotes)
- **Quote escape:** `""` (duplicate)
- **Header included:** Yes

---

## Integrating the MIMIC Ontology into OMOP CDM

The MIMIC Ontology can be integrated into a local OMOP CDM instance by combining standard vocabulary files obtained from [Athena OHDSI](http://athena.ohdsi.org) with curated delta tables provided via GitHub.

---

## Required Tools and Access

To begin, ensure you have:

- An Athena OHDSI account to download standard vocabularies.
- SQL client (e.g., DBeaver, pgAdmin, psql) with **write access** to the OMOP CDM vocabulary schema.
- A PostgreSQL-compatible OMOP instance.
- MIMIC delta files from [Tufts CTSI GitHub](https://github.com/TuftsCTSI/CVB/tree/main/MIMIC/Ontology).
- Basic understanding of the OMOP CDM vocabulary structure.
- A dedicated development schema (e.g., `dev_mimic`) for testing integration before applying to production.

---

## Workspace Preparation

Ensure your OMOP vocabulary schema includes the following standard CDM tables:

- `concept`, `concept_ancestor`, `concept_class`, `concept_relationship`, `concept_synonym`
- `domain`, `relationship`, `vocabulary`, `drug_strength`

> Use the [DevV5_DDL.sql script](https://github.com/OHDSI/Vocabulary-v5.0/blob/master/working/DevV5_DDL.sql) if tables are missing.

Create delta tables using [delta-tables-ddl.sql](https://github.com/TuftsCTSI/CVB/tree/main/MIMIC/Builder/sql/delta-tables-ddl.sql).

---

## Download Standard OMOP Vocabularies (from Athena)

Select the following **vocabularies** from [Athena OHDSI Download](https://athena.ohdsi.org/vocabulary/list) section, ensuring any license-restricted vocabularies (e.g., **CPT4**) are only selected if your organization holds a valid license:

- CMS Place of Service  
- CPT4  
- CVX  
- Ethnicity  
- HCPCS  
- ICD10PCS  
- LOINC  
- Medicare Specialty  
- NDC  
- Nebraska Lexicon  
- OMOP Extension  
- PCORNet  
- PPI  
- Race  
- Read  
- RxNorm  
- RxNorm Extension  
- SNOMED  
- UCUM  
- UK Biobank  
- Visit  
- dm+d  

> **All vocabularies listed above are mandatory.** They are referenced in the delta tables and are essential for resolving mappings and relationships. Partial ingestion will result in structural or referential integrity errors.

After generating and downloading the vocabulary bundle (ZIP archive), unzip it locally and confirm that the following files are included:

### Expected Files in the Bundle

- `CONCEPT.csv`  
- `CONCEPT_ANCESTOR.csv`  
- `CONCEPT_CLASS.csv`  
- `CONCEPT_RELATIONSHIP.csv`  
- `CONCEPT_SYNONYM.csv`  
- `DOMAIN.csv`  
- `DRUG_STRENGTH.csv`  
- `RELATIONSHIP.csv`  
- `VOCABULARY.csv`  

###  Download MIMIC Delta Tables

Download the delta tables from the [MIMIC Vocabulary GitHub repository](https://github.com/TuftsCTSI/CVB/tree/main/MIMIC/Ontology). These include:

| Delta Table               |
|---------------------------|
| CONCEPT_DELTA.CSV         |
| CONCEPT_ANCESTOR_DELTA.CSV|
| CONCEPT_CLASS_DELTA.CSV   |
| CONCEPT_RELATIONSHIP_DELTA.CSV |
| CONCEPT_SYNONYM_DELTA.CSV |
| DOMAIN_DELTA.CSV          |
| RELATIONSHIP_DELTA.CSV    |
| VOCABULARY_DELTA.CSV      |
| MAPPING_METADATA.CSV      |
| SOURCE_TO_CONCEPT_MAP.CSV |

> **Note:** Files such as restore.sql and update_log.csv are not required for ingestion.

### 3.2.5. Ingest Standard Vocabularies (Athena → OMOP)

Import all downloaded Athena .csv files into the corresponding OMOP vocabulary tables using your preferred SQL client.

 **Recommended tools:** Use PostgreSQL COPY command via psql, or GUI tools such as DBeaver or pgAdmin for loading the files. You may also use other tools or languages (e.g., **R**, **Python**, **Scala**) to ingest files programmatically. Just ensure that:
 - The structure and constraints of OMOP CDM tables are respected.
 - Data types are correctly parsed.
 - Referential integrity is preserved.

Match the CSV files to OMOP tables as follows:

| Athena CSV File                   | → OMOP Table         |
|---------------------------|----------------------|
| CONCEPT.csv               | → CONCEPT            |
| CONCEPT_ANCESTOR.csv      | → CONCEPT_ANCESTOR   |
| CONCEPT_CLASS.csv         | → CONCEPT_CLASS      |
| CONCEPT_RELATIONSHIP.csv  | → CONCEPT_RELATIONSHIP |
| CONCEPT_SYNONYM.csv       | → CONCEPT_SYNONYM    |
| DOMAIN.csv                | → DOMAIN             |
| DRUG_STRENGTH.csv         | → DRUG_STRENGTH      |
| RELATIONSHIP.csv          | → RELATIONSHIP       |
| VOCABULARY.csv            | → VOCABULARY         |

### Ingest MIMIC Delta Content

Insert delta rows into the already existing delta tables.

### Integrate MIMIC Delta Tables Into Basic OMOP Vocabulary Tables

Insert data from the MIMIC delta files into the corresponding OMOP vocabulary tables. The mapping between each delta file and its target table is shown below:

| Delta File                   | → Target Table          |
|-----------------------------|-------------------------|
| concept_delta.csv           | → CONCEPT               |
| concept_ancestor_delta.csv  | → CONCEPT_ANCESTOR      |
| concept_class_delta.csv     | → CONCEPT_CLASS         |
| concept_relationship_delta.csv | → CONCEPT_RELATIONSHIP |
| concept_synonym_delta.csv   | → CONCEPT_SYNONYM       |
| domain_delta.csv            | → DOMAIN                |
| relationship_delta.csv      | → RELATIONSHIP          |
| vocabulary_delta.csv        | → VOCABULARY            |

The following tables are provided ready for use and do not require further transformation:
- mapping_metadata.csv 
- source_to_concept_map.csv 

> **Important:** Always validate your integration in a development schema before applying changes to a production vocabulary schema. Ensure referential integrity and uniqueness constraints are preserved.

### Validate Integration

Verify the successful application of the delta content. This includes validation of record counts, relationship integrity, and domain coverage.
