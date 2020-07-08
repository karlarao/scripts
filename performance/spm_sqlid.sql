set verify off
col parsing_schema format a8
col created format a10
SELECT parsing_schema_name parsing_schema, created, plan_name, sql_handle, sql_text, optimizer_cost, enabled, accepted, fixed, origin
FROM dba_sql_plan_baselines
WHERE signature IN (SELECT exact_matching_signature FROM v$sql WHERE sql_id like nvl('&sql_id',sql_id))
/

