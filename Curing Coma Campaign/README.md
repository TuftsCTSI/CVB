# Curing Coma Campaign (CCC) Custom Vocabulary

## Overview
This package implements the **Curing Coma Campaign (CCC) Custom Vocabulary** using the **Custom Vocabulary Builder (CVB)** workflow. The vocabulary represents CCC **Variables (CRF Items / Questions)** and **Values (Answer Options)** as OMOP-style concepts and provides **SSSOM-formatted mappings** to OMOP Standard Concepts where available.

**Design goals**
- Provide **stable CCC identifiers** for CRF questions and answer options.
- Map to **OMOP Standard Concepts** where clinically and semantically appropriate.
- When a suitable OMOP Standard Concept does not exist, create CCC concepts and mark them as **standard within CCC** to support consistent ETL and analytics.
- Publish mappings as **SSSOM** to ensure traceability, portability, and reproducibility of the mapping set.

---

## What this vocabulary contains

### 1) CCC Questions
CRF variables/questions describing *what is collected* (e.g., "Location for Core Temperature Measurement").
- `domain_id`: commonly `Observation` (or another domain if dictated by the target OMOP concept)

### 2) CCC Answers
Permissible categorical values/answer options used to populate Variables (e.g., "Bladder").
- `domain_id`: commonly `Meas Value` (or another domain if dictated by the target OMOP concept)

### 3) CCC → OMOP mappings (SSSOM)
Mappings are distributed as an **SSSOM mapping set** with explicit predicates (e.g., `skos:exactMatch`, `skos:closeMatch`) and supporting metadata (provenance, confidence, review status as applicable).
