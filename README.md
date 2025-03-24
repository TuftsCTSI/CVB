# CVB
CVB, or Custom Vocabulary Builder, is designed to interface with SSSOM-based mappings hosted in GoogleSheets together with self-hosted runners in the Tufts Azure environment to create custom representations of semantic concepts with ID assignments in OMOP CDM format.

## Reserved Ranges
Studies and projects that want to disseminate custom concept_ids can reserve a block in the two-bil concept_ids (max: 2.147b).
| Project Name | Block Range Start (bil) | Block Range End (bil) |
|--------------|-------------------------|-----------------------|
| ...          |                         |                       |
| OHDSI GIS    | 2.05150                 | 2.05250               |
| MIMIC4       | 2.06150                 | 2.06250               |
| PSYCHIATRY   | 2.07150                 | 2.07250               |
| ...          |                         |                       |
