set search_path to vocab;
with tbl as (SELECT table_schema, table_name
             FROM information_schema.tables
             where table_name not like 'pg_%'
               and table_schema in ('vocab', 'temp')
               and table_name in ('source_to_concept_map',
                                  'concept_s_staging',
                                  'concept_ns_staging',
                                  'concept_rel_s_staging',
                                  'concept_rel_ns_staging',
                                  'concept_anc_s_staging',
                                  's2c_map_staging',
                                  'mapping_to_update',
                                  'mapping_to_deprecate',
                                  'parent_to_update',
                                  'parent_to_deprecate'))
select table_schema,
       table_name,
       (xpath('/row/c/text()',
              query_to_xml(format('select count(*) as c from %I.%I', table_schema, table_name), false, true,
                           '')))[1]::text::int as rows_n
from tbl
ORDER BY 3 DESC;