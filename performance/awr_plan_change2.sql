compute sum of execs etime_delta on report
compute sum of etime_delta execs on total_execs
break on total_execs skip 1 on report
set lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col etime_delta for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
-- break on plan_hash_value on startup_time skip 1
select ss.snap_id, 
-- ss.instance_number node, 
begin_interval_time, sql_id, plan_hash_value,
executions_total total_execs,
nvl(executions_delta,0) execs,
elapsed_time_delta/1000000 etime_delta,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,decode(nvl(executions_delta,0),0,1,executions_delta))) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = nvl('&sql_id','gf5nnx0pyfqq2')
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number 
order by 1, 2, 3
/
