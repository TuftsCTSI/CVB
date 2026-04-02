# Human Phenotype Ontology (HPO) Integration with OMOP CDM in CVB

>This README provides technical implementation guidance only and is not legal advice; nothing in this repository documentation alters, expands, or replaces the rights and obligations defined by the applicable HPO and upstream source licenses, and any acquisition, redistribution, or downstream use of HPO-derived content must remain within those licenses and any required institutional legal review.

## Overview

The Human Phenotype Ontology (HPO) is a standardized ontology for representing human phenotypic abnormalities. Unlike flat source vocabularies, HPO is a structured ontology organized as a directed acyclic graph (DAG) with transitive `is-a` relationships, and it also includes additional subontologies for inheritance, clinical modifiers, onset/clinical course, mortality/aging, and frequency. This makes HPO useful not only for term normalization, but also for phenotype-oriented semantic organization.

The February 2026 OHDSI vocabulary release introduced HPO into Athena as a community contribution.

In parallel, this HPO integration into the Custom Vocabulary Builder (CVB) enables controlled reuse of reviewed mappings with SSSOM metadata into existing OMOP concepts where such mappings are semantically defensible. In operational terms, this build is intended to support vocabulary engineering, ETL implementation, and phenotype harmonization workflows while keeping a clear boundary between the ontology layer, mapping layer, and patient-level data layer. HPO itself is an ontology resource; disease annotations and gene/phenotype association files are related but separate resources and should not be conflated with patient-level ETL.

## Sources Utilized

The HPO vocabulary build draws from the official ontology distribution and related authoritative artifacts. HPO is distributed through the official project website and OBO Foundry, with release artifacts available in OBO, OWL, and JSON variants, including hp-base, hp-full, and internationalized editions. OBO Foundry also lists associated annotation artifacts such as phenotype.hpoa, phenotype_to_genes.txt, and genes_to_phenotype.txt. These sources must be treated differently in the build: ontology files define terms and ontology structure, while annotation files describe disease-level or gene-level associations and are not patient-level observations.

## Mapping Sources

The current mapping release incorporates the following reviewed sources of candidate and curated mappings:

- Tiffany J Callahan mappings (PhD-related work)
- Alexander Davydov mappings (OHDSI community contribution)
- Polina Talapova mappings (Tufts CTSI for the CHoRUS Bridge2AI project, inspired by Dr. Andrew Williams)

Volunteer review support was provided by OHDSI community collaborator Tetiana Nesmiaan (SciForce).

The mapping metadata layer is implemented using SSSOM. SSSOM is a community standard for exchanging ontology mappings and associated metadata, including mapping predicates, provenance, and derivation details.

## Transformation Workflow
1. **Initial Source Acquisition**

The workflow begins with acquisition of the official HPO ontology artifacts from the authoritative distribution points. Officially available release variants and annotation files are published through OBO Foundry and the HPO documentation/download infrastructure.

2. **Parsing and Normalization of Ontology Artifacts**

Ontology artifacts are parsed into a staging representation.

3. **Loading into Staging / Database Environment**

Normalized source content and mapping records are loaded into a database-backed staging environment. The current project uses a source mapping table model with HPO source identifiers, labels, proposed OMOP targets, domain decisions, and SSSOM metadata stored in a curated working layer. SSSOM fields are preserved in staging to represent the full richness of ontology mapping provenance, justification, and predicate detail.

4. **Mapping and Semantic Harmonization**

Only one-to-one `Maps to` relationships that were manually reviewed by subject-matter experts are released at the current stage of the project (6K+). Ambiguous, many-to-one, one-to-many, broad, narrow, or weakly justified mappings are intentionally excluded from release at this stage even if they exist in upstream candidate files or SSSOM curation tables. Domain assignment for released HPO concepts is currently driven by the reviewed mappings. Where an HPO concept already exists in Athena, the existing OMOP concept_id is reused. Where the concept is absent from Athena, a stable local concept_id greater than 2 billion is assigned following OHDSI custom vocabulary conventions used in CVB-style workflows. The current release therefore mixes reuse of existing OMOP identifiers with controlled introduction of custom identifiers, while preserving HPO source identifiers as concept_code values for traceability. The introduction of HPO into Athena in February 2026 materially improves this reuse pathway, but it does not remove the need for local identifiers for concepts outside the Athena release content used by a given build.

5. **Version Control**

mapping release identifier: v1.2
generation date: 04-02-2026
delta output location(s): `/Ontology`

6. **Infrastructure / Execution Environment**

At the current stage, the HPO build is executed through SQL-based load-stage workflows. The implementation uses PostgreSQL 18.1, an OMOP Vocabulary instance with a dedicated development schema, and the February 2026 OHDSI Athena release, which was integrated to incorporate HPO content. Transformation and loading are performed through repository-managed SQL scripts, and the resulting delta tables are prepared for downstream use. No GitHub-driven workflows, Apps Script jobs, CI pipelines, or database-scheduled automation procedures have been implemented yet.

## Vocabulary and Mapping Specification
### Concept IDs
`SOURCE_CONCEPT_ID` in the source mapping table

HPO source identifiers such as HP_0000118 remain the ontology-native identifiers and are preserved as source-side identifiers throughout curation. They are not OMOP concept_id values and should never be confused with them. HPO documentation treats these identifiers as the stable ontology ID space for the terms themselves.

In the current CVB implementation, OMOP concept_id assignment follows a two-path policy:

- If an HPO concept already exists in Athena, the Athena concept_id is reused.
- If an HPO concept is absent from Athena, a stable local concept_id greater than 2 billion is assigned.

This design preserves compatibility with OHDSI vocabulary distribution where possible and maintains reproducibility for CVB-local content where Athena coverage is absent. Once assigned, local concept_id values must remain persistent for the same source concept_code across releases unless an explicit deprecation/replacement policy is applied.

### Concept Names
`SOURCE_DESCRIPTION` in the source mapping table

Concept names are derived from the preferred HPO label for the source term. HPO terms carry unique IDs, preferred labels, textual definitions, and synonyms, and the preferred label is the correct source for concept_name generation. Definitions inform semantic interpretation but should not overwrite the preferred label.

### Domains
`SOURCE_DOMAIN` in the source mapping table
#### Domain Inference
Domain assignment for HPO requires explicit policy because HPO is a phenotype ontology, whereas OMOP domains are event-model and analytic-model constructs. There is no universally correct one-size-fits-all rule for all HPO content. At the current release stage, the implemented rule is mapping-driven:
- released HPO concepts with a manually reviewed one-to-one `Maps to` relationship inherit the domain of the mapped OMOP target concept
- HPO concepts without a released reviewed mapping require explicit policy and should not be auto-assigned a domain solely by lexical similarity.

At the same time, there is an important policy tension. HPO as an ontology primarily represents phenotypic abnormalities, and many teams would regard an HPO-native representation as more naturally aligned to phenotype capture than to diagnosis coding. A preservation-first strategy would often tend to keep many HPO terms in an HPO-native pattern, frequently closer to Observation semantics. The current release instead prioritizes semantic interoperability with pre-existing OMOP standards by inheriting domains from reviewed one-to-one targets. This should be read as a release policy, not as a universal ontological truth.

#### Domain Special Cases
The following patterns should be expected conceptually, even if the exact examples depend on the released mapping tables. 
- An HPO phenotype concept may map to an OMOP Condition concept where the reviewed target is a diagnosis-like clinical abnormality already represented in OMOP standard vocabularies.
- An HPO phenotype concept may map to an OMOP Observation concept where the reviewed target represents a finding, descriptive feature, modifier, or assertion-like clinical characteristic.
- An HPO phenotype concept may map to an OMOP Measurement concept where the reviewed target is a measurable abnormality or result-oriented clinical concept.
- In addition, some reviewed mappings may land in domains outside the core phenotype-event pattern, such as Procedure, Meas Value, or Spec Anatomic Site, when the HPO term represents an intervention, a qualifier/value concept, laterality, or an anatomic location rather than a patient phenotype event itself.

| source_code | source_description | relationship_id | predicate_id | target_concept_id | target_concept_name | target_domain_id |
|---|---|---|---|---:|---|---|
| HP_0000003 | Multicystic kidney dysplasia | Maps to | skos:exactMatch | 42537890 | Multicystic renal dysplasia | Condition |
| HP_0011411 | Forceps delivery | Maps to | skos:exactMatch | 4114637 | Forceps delivery | Procedure |
| HP_0012169 | Self-biting | Maps to | skos:exactMatch | 4085350 | Biting self | Observation |
| HP_0012832 | Bilateral | Maps to | skos:exactMatch | 4197258 | Right and left | Meas Value |
| HP_0034779 | Perineal | Maps to | skos:exactMatch | 4304791 | Perineal structure | Spec Anatomic Site |
| HP_0500108 | Positive urine cocaine test | Maps to | skos:exactMatch | 44790263 | Urine cocaine positive | Measurement |

### Vocabulary ID

The vocabulary identifier for HPO-derived source concepts in this repository is `HPO`.

### Concept Classes

Released HPO concepts with a manually reviewed one-to-one `Maps to` relationship inherit the concept class of the mapped OMOP target concept.

### Standard Concepts Logic

HPO source concepts are non-standard and function as source-side or bridge concepts;

### Concept Codes

HPO identifiers (such as HP_0000118) are used as concept_code values for HPO-derived source concepts.

### Concept Synonyms

Ontology-provided synonyms populate concept_synonym. 

### Valid Start/End Dates and Invalid Reason

Validity dates reflect concepts and releationships lifecycle. Invalidation must distinguish ontology lifecycle events from mapping lifecycle events. Under the intended lifecycle policy, deprecated or obsolete HPO terms should be marked invalid according to the repository’s vocabulary-load rules once the source ontology declares them obsolete or a replacement policy is applied. Withdrawn or superseded mappings should invalidate the affected relationship rows. Replaced terms should preserve audit traceability to replacement targets where the source ontology provides this information. Retired synonyms or auxiliary metadata should be retired in their own layer.

At the current stage, the release output contains only valid concepts and valid relationships. Accordingly, invalid concepts, invalidated mappings, and retired synonym records are not yet distributed in the released tables. The invalidation rules described here therefore document the expected lifecycle policy for future refreshes rather than a fully materialized invalid-content layer in the present release.

### Concept Relationships

The currently supported released relationship surface is the manually reviewed one-to-one mapping layer. These mappings are represented in OMOP using the appropriate mapping relationships, typically `Maps to` for source-to-standard navigation and the corresponding reverse OMOP relationship (`Mapped from`) as produced by the load process. The decisive release criterion is not mere lexical similarity, but reviewed semantic equivalence or sufficiently strong one-to-one alignment. Because SSSOM is implemented, richer mapping metadata can exist in the curation layer than in the OMOP release tables. That includes provenance, authoring source, predicate detail, and reviewer context.

### Hierarchy

Official HPO documentation describes the ontology as a directed acyclic graph in which terms are connected by transitive `is-a` edges and may have multiple parents. This multi-parent DAG structure is essential to HPO semantics because a term can inherit meaning along more than one path. OBO Foundry likewise distributes the ontology as a formal ontology resource, not merely a flat term list.

In OMOP terms, a fully implemented hierarchy layer would require:
- conversion of HPO parent-child edges into OMOP-compatible hierarchical relationships
- population of CONCEPT_ANCESTOR with transitive closure
- explicit handling of multiple-parent inheritance
- policy for obsolete terms and redirected terms
- validation that ancestor closure remains stable across refreshes.

That has not been implemented at the current stage. CONCEPT_ANCESTOR is empty. Therefore:
- HPO descendant-based concept set expansion is not yet available through OMOP hierarchy mechanics
- analytic workflows that rely on ancestor-descendant rollup cannot yet use HPO hierarchy in the standard OMOP way
- secondary-parent logic and transitive closure are not preserved in deployable OMOP tables at this stage
- users must not assume that a higher-level HPO phenotype concept will automatically retrieve all more specific descendants in Atlas or SQL descendant logic.

This is the largest structural gap between source HPO semantics and the current released OMOP implementation.

### Gaps and Limitations
The current release is intentionally narrow and should be understood as such. 
- First, only manually reviewed one-to-one mappings are released. This improves precision but leaves substantial coverage outside the deployable mapping surface.
-  Second, hierarchy is not yet implemented. HPO is natively a DAG with transitive `is-a` semantics, but CONCEPT_ANCESTOR is empty in the current release. This prevents descendant-based querying and weakens ontology-native rollup behavior.
- Third, the release policy is mapping-driven. That is operationally useful, but it can compress native HPO phenotype semantics into pre-existing OMOP target concepts whose modeling assumptions differ from ontology-native phenotype representation.
- Fourth, synonym scope and auxiliary ontology semantics may be partially lost. 

### Recommendations and Next Steps
1. Implement hierarchy. Materialize HPO parent-child relationships into OMOP-compatible hierarchy tables and populate CONCEPT_ANCESTOR with validated transitive closure.
2. Expand reviewed mapping coverage. Continue SME review beyond the current one-to-one release surface, but keep release-quality criteria explicit.3. 
3. Separate ontology and annotation pipelines. If disease annotation or gene/phenotype resources are later integrated, document them as distinct pipelines rather than folding them implicitly into the ontology build.
4. Refine ETL guidance by use case. Add worked examples for registry ETL, structured EHR phenotype capture, and NLP-derived phenotype extraction.
5. Automate refresh comparison. Add differential validation for ontology release churn, obsolete terms, target concept drift, and mapping status changes across releases.
6. Add hierarchy-aware QA once hierarchy exists. After CONCEPT_ANCESTOR is implemented, validate parent preservation, multi-parent closure, and descendant retrieval behavior against source HPO structure.
