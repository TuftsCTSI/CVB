# CVB
CVB, or Custom Vocabulary Builder, is designed to interface with SSSOM-based mappings hosted in GoogleSheets together with self-hosted runners in the Tufts Azure environment to create custom representations of semantic concepts with ID assignments in [OMOP Common Data Model (CDM)](https://www.ohdsi.org/data-standardization/).

## Reserved Ranges
Studies and projects that want to disseminate custom concept_ids can reserve a block in the two-bil concept_ids (max: 2.147b).
| Project Name | Block Range Start (bil) | Block Range End (bil) |
|--------------|-------------------------|-----------------------|
| ...          |                         |                       |
| OHDSI GIS    | 2.05150                 | 2.05250               |
| MIMIC4       | 2.06150                 | 2.06250               |
| PSYCHIATRY   | 2.07150                 | 2.07250               |
| ...          |                         |                       |

## Repository Structure

This repository is organized into modular components for each Custom Vocabulary, enabling streamlined mapping, ontology management, and automated workflows. Below is a description of the main folders and key files for each vocabulary package.

---

### Folder Contents

**1. Builder**  
Contains scripts and logic to automate the build and deployment process:  
- `sql/` - SQL scripts for schema management and data transformation.  
- `execute-pipeline.sh` - Shell script to run the full vocabulary build pipeline.  
- `git-integration.js` - Script to sync mappings and deltas with GitHub.  
- `revert-db.sh` - Utility script to revert the database to a previous state.

**2. Mappings**  
Stores the main mapping file aligning source concepts to OMOP standard concepts derived from the Google Sheets for collaborative work on mappings.

**3. Ontology**  
Contains vocabulary `delta files` (so-called `delta tables`) and supporting ontology data:  
-  `concept_ancestor_delta.csv` - Establishes hierarchical ancestries, enabling reasoning across categorical groupings and broader taxonomies.
-  `concept_class_delta.csv` - Definitions of source concept classes.  
-  `concept_delta.csv`- Defines standard and non-standard concepts, incorporating new domains, classes, or source codes. 
-  `concept_relationship_delta.csv` - Encodes semantic relationships (e.g., `Maps to`, `Is a`, `Subsumes`) that link concepts to each other and to OMOP standards.  
-  `concept_synonym_delta.csv` - Supports flexible querying through synonyms, alternative labels, and abbreviations.
-  `domain_delta.csv` - Source domain definitions or adjustments.  
-  `mapping_metadata.csv` - Captures provenance, authorship, and review metadata, ensuring traceability and compliance with best practices ([SSSOM](https://mapping-commons.github.io/sssom/)-aligned).
-  `relationship_delta.csv` - Relationship types for extending the vocabulary.  
-  `restore.sql` - SQL snapshot for restoring the last known good state.  
-  `source_to_concept_map.csv` - Source mapping snapshot used for ETL.  
-  `update_log.csv` - Tracks update history and versioning.  
-  `vocabulary_delta.csv` - Source vocabulary list for OMOP integration.

**4. Utilities**  
Supporting scripts and helper tools:  
- `daily-update.gs` - Google Apps Script for automating daily updates.  
- `readme.md` - Utility-specific documentation.

---

## Ontology Definition in Context

In general, an **ontology** is a structured framework that represents knowledge within a domain as a set of concepts and the relationships between them. Ontologies enable formal semantics, reasoning, and integration across diverse datasets by providing consistent definitions, hierarchical organization, and relational mappings.

Within the Custom Vocabulary Builder (CVB) framework, the **Ontology folder** organizes, extends, and systematizes domain-specific vocabularies - whether for critical care, psychiatry, environmental health, or other fields - using the language and structure of the OMOP CDM. It provides the essential "delta tables" that expand or update the OMOP vocabulary to accommodate new concepts, mappings, and hierarchies while maintaining full compliance with OMOP’s relational architecture. The Ontology framework integrates collaborative term curation, semantic standardization (leveraging SSSOM predicates), and automated deployment pipelines to construct modular, versioned vocabularies. This infrastructure ensures consistent and extensible vocabulary management across diverse domains, enhancing the OMOP CDM’s utility for real-world evidence generation and cross-domain research.

---

### Architecture and Workflow

Each ontology package is constructed and maintained through the following key components and processes:

- **Source Definition Layer:**  
  Concepts and mappings are curated in a structured Google Spreadsheet format. This spreadsheet captures validated fields such as `source_vocabulary`, `source_code`, `source_domain`, `source_description`, `relationship_id`, `predicate_id`, `confidence` and others. **Google Apps Scripts** enforce collaborative workflows, semantic protections, and row-level editability to ensure data integrity.

- **Version-Controlled Vocabulary Pipeline:**  
  Approved mappings are automatically synchronized from Google Sheets to GitHub via scheduled Apps Script tasks. This workflow maintains a persistent, auditable version history while preparing the mapping data for downstream processing.

- **Ontology Transformation Pipeline:**  
  A GitHub Action orchestrates the multi-step workflow to convert spreadsheet-based mappings into relational OMOP-compatible delta tables. This includes:
    - **1. Ingestion** of mapping rows into a **PostgreSQL instance** hosted in Azure.
    - **2. Syntactic validation** of concepts, metadata, and predicate consistency.
    - **3. Differencing logic** to identify new or modified concepts relative to the baseline OMOP vocabularies.
    - **4. Construction of staging tables,** generating new records for `concept`, `concept_relationship`, and `concept_synonym`, with assigned `concept_id`s in the reserved range (>2,000,000,000).
    - **5. Insertion of validated concepts** into the target schema’s constrained tables.
    - **6. Export of delta tables** back to GitHub for downstream integration into ETL workflows.

Automation is supported by two Azure-hosted components: a **Container App** functioning as a virtual GitHub runner, and a **Flexible Postgres Server** that stores and manages the relational ontology data securely and reproducibly.

---

### Ontological Table Structure

The ontology is materialized through a suite of relational **delta tables** that mirror the OMOP vocabulary schema. These tables are modular and domain-agnostic, allowing the framework to support a variety of specialized vocabularies. These tables collectively instantiate an **ontology graph** within a relational schema, enabling semantic linkage between OMOP-standard concepts and custom extensions across any domain of interest.

---

## Additional Notes

- Each vocabulary folder follows a **consistent architecture** to enable modular builds and updates.
- All delta files follow OMOP CDM standards and are **automatically integrated** into the vocabulary build pipeline.
- Provenance metadata (e.g., `mapping_metadata.csv`) ensures traceability of authorship, review, and mapping context. 
---
