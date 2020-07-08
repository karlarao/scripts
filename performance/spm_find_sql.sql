set verify off
col exact_matching_signature format 999999999999999999999999999
col force_matching_signature format 999999999999999999999999999
select sql_id, child_number, plan_hash_value, exact_matching_signature, force_matching_signature, substr(sql_text,1,35) sql_text
from v$sql 
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like '%from v$sql where sql_text like nvl(%'
and sql_id like nvl('&sql_id',sql_id)
--where sql_text like 'select * from skew where skew%'
order by 1,2;
