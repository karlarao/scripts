set verify off
col parsing_schema format a8
col created format a20
col sql_handle format a25
col sql_text format a35
col origin format a8
SELECT parsing_schema_name parsing_schema, TO_CHAR(created,'MM/DD/YY HH24:MI:SS') created, plan_name, sql_handle, substr(sql_text,1,35) sql_text, optimizer_cost, enabled, accepted, fixed, reproduced, origin 
FROM dba_sql_plan_baselines 
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like '%from v$sql where sql_text like nvl(%'
and signature like nvl('&exact_matching_signature',signature)
order by 2,4 asc;

