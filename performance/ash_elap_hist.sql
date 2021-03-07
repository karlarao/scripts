PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY - ash_elap by exec (recent)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
set lines 300
col sql_exec_start format a30
col run_time_timestamp format a30
select * from 
(
select sql_id,
       sql_exec_id,
       sql_plan_hash_value,
           CAST(sql_exec_start AS TIMESTAMP) sql_exec_start,
       run_time run_time_timestamp,
 (EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)) run_time_sec
from  (
select
       sql_id,
       sql_exec_id,
       sql_plan_hash_value,
       max(sql_exec_start) sql_exec_start,
       max(sample_time - sql_exec_start) run_time
from
       dba_hist_active_sess_history
where sql_exec_start is not null
group by sql_id,sql_exec_id,sql_plan_hash_value
order by sql_exec_start desc
)
where rownum < 1000
)
where run_time_sec > &run_time_sec
order by sql_exec_start asc
/
PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY - ash_elap exec avg min max
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
select sql_plan_hash_value,
                count(*),
        round(avg(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) avg ,
        round(min(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) min ,
        round(max(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) max
from  (
        select
                       sql_id,
                       sql_exec_id,
                       sql_plan_hash_value,
                       max(sql_exec_start) sql_exec_start,
               max(sample_time - sql_exec_start) run_time
        from
               dba_hist_active_sess_history
        where
               sql_exec_start is not null
               and sql_id = '&&sql_id.'
        group by sql_id,sql_exec_id,sql_plan_hash_value
       )
group by sql_plan_hash_value
union all
select  null,
                count(*),
        round(avg(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) avg ,
        round(min(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) min ,
        round(max(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) max
from  (
        select
                       sql_id,
                       sql_exec_id,
                       sql_plan_hash_value,
                       max(sql_exec_start) sql_exec_start,
               max(sample_time - sql_exec_start) run_time
        from
               dba_hist_active_sess_history
        where
               sql_exec_start is not null
               and sql_id = '&&sql_id.'
        group by sql_id,sql_exec_id,sql_plan_hash_value
       )
/


