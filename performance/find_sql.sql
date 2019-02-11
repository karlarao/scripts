set lines 500
set verify off
set pagesize 999
col username format a13
col prog format a22
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.999999
col avg_pio format 9,999,999.99
col avg_lio format 999,999,999
col etime format 9,999,999.99
col execs format 999,999,999

select sql_id, child_number, plan_hash_value plan_hash, executions execs, 
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, 
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio , substr(SQL_FULLTEXT,1,4000)
from gv$sql s
where upper(sql_fulltext) like upper(nvl('&sql_fulltext',sql_fulltext))
and sql_fulltext not like '%from gv$sql where sql_fulltext like nvl(%'
and sql_id like nvl('&sql_id',sql_id)
order by 1, 2, 3
/
