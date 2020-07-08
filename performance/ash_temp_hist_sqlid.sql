alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
alter session set nls_timestamp_format='YYYY/MM/DD HH24:MI:SS';

set lines 300

 
col PGA_ALLOCATED_GB format 999999999
col TEMP_ALLOCATED_GB format 999999999
select sql_id,sql_plan_hash_value,TOP_LEVEL_SQL_ID,
      starting_time,
      end_time,
 (EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)) run_time_sec,
      READ_IO_BYTES,
      PGA_ALLOCATED/1024/1024 PGA_ALLOCATED_MB,
      TEMP_ALLOCATED/1024/1024 TEMP_ALLOCATED_MB
from  (
select
       sql_id,sql_plan_hash_value,TOP_LEVEL_SQL_ID,
       max(sample_time - sql_exec_start) run_time,
       max(sample_time) end_time,
       sql_exec_start starting_time,
       sum(DELTA_READ_IO_BYTES) READ_IO_BYTES,
       sum(DELTA_PGA) PGA_ALLOCATED,
       sum(DELTA_TEMP) TEMP_ALLOCATED
       from
       (
       select sql_id, 
       sql_plan_hash_value,
       TOP_LEVEL_SQL_ID,
       sample_time,
       sql_exec_start,
       DELTA_READ_IO_BYTES,
       sql_exec_id,
       greatest(PGA_ALLOCATED - first_value(PGA_ALLOCATED) over (partition by sql_id,sql_exec_id order by sample_time rows 1 preceding),0) DELTA_PGA,
       greatest(TEMP_SPACE_ALLOCATED - first_value(TEMP_SPACE_ALLOCATED) over (partition by sql_id,sql_exec_id order by sample_time rows 1 preceding),0) DELTA_TEMP
       from
       dba_hist_active_sess_history
       where
       -- sample_time >= to_date ('2018/10/01 00:00:00','YYYY/MM/DD HH24:MI:SS')
       -- and sample_time < to_date ('2018/10/16 03:10:00','YYYY/MM/DD HH24:MI:SS')
       sql_exec_start is not null
       and IS_SQLID_CURRENT='Y'
       )
group by sql_id,sql_plan_hash_value,TOP_LEVEL_SQL_ID,SQL_EXEC_ID,sql_exec_start
)
where sql_id = '&sql_id'
order by 3 asc;

