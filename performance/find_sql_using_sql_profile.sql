set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a41
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99

select address, sql_id, child_number, executions execs, 
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, sql_profile, 
sql_text
from v$sql s, dba_users u
where upper(sql_text) like upper(nvl('&sql_text',sql_text))
and sql_text not like '%from v$sql where sql_text like nvl(%'
and address like nvl('&address',address)
and sql_id like nvl('&sql_id',sql_id)
and u.user_id = s.parsing_user_id
and sql_profile is not null
/
