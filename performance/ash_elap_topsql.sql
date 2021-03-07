
set lines 400
col module format a50
col parsing_schema format a20

select * from (
select sql_id,sql_type,module,parsing_schema,
       count(sql_plan_hash_value) distinct_phv,
                count(*) exec_count,
        round(avg(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) elap_avg ,
        round(min(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) elap_min ,
        round(max(EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60
                    + EXTRACT(SECOND FROM run_time)),2) elap_max,
                    round(avg(pct_cpu),0) pct_cpu,
                    round(avg(pct_wait),0) pct_wait,
                    round(avg(pct_io),0) pct_io,                    
                    round(max(temp)/1024/1024,2) max_temp_mb,
                    round(max(pga)/1024/1024,2) max_pga_mb,
                    round(max(rbytes)/1024/1024,2) max_read_mb,
                    round(max(wbytes)/1024/1024,2) max_write_mb,
                    max(riops) max_riops,
                    max(wiops) max_wiops
from  (
        select
                       ash.sql_id sql_id,
                       aud.name sql_type, 
                       ash.module module,
                       pschema.username parsing_schema,
                       ash.sql_exec_id sql_exec_id,
                       ash.sql_plan_hash_value sql_plan_hash_value,
                       max(ash.sql_exec_start) sql_exec_start,
                       max(ash.sample_time - ash.sql_exec_start) run_time,
                       max(ash.TEMP_SPACE_ALLOCATED) temp,
                       max(ash.PGA_ALLOCATED) pga,
                       max(ash.DELTA_READ_IO_BYTES) rbytes,
                       max(ash.DELTA_READ_IO_REQUESTS) riops,
                       max(ash.DELTA_WRITE_IO_BYTES) wbytes,
                       max(ash.DELTA_WRITE_IO_REQUESTS) wiops,
                       round(sum(decode(ash.session_state,'ON CPU',1,0))/sum(decode(ash.session_state,'ON CPU',1,1)),2)*100 pct_cpu,
                       round((sum(decode(ash.session_state,'WAITING',1,0)) - sum(decode(ash.session_state,'WAITING', decode(ash.wait_class, 'User I/O',1,0),0)))/sum(decode(ash.session_state,'ON CPU',1,1)),2)*100 pct_wait,
                       round((sum(decode(ash.session_state,'WAITING', decode(ash.wait_class, 'User I/O',1,0),0)))/sum(decode(ash.session_state,'ON CPU',1,1)),2)*100 pct_io
        from
               dba_hist_active_sess_history ash, audit_actions aud, all_users pschema
        where
               ash.sql_exec_start is not null
               and ash.sql_opcode=aud.action
               and ash.user_id = pschema.user_id 
--               and sql_id = '0nx0wbcfa71gf'
--               and pschema.username not in ('SYS','SYSTEM','DBSNMP','SYSMAN','AUDSYS','MDSYS','ORDSYS','XDB','APEX_PUBLIC_USER','ORACLE_OCM','APEX_050100','GSMADMIN_INTERNAL','ORDS_METADATA','XFILES','MYDBA','XDBEXT')
        group by ash.sql_id,aud.name,ash.module,pschema.username,ash.sql_exec_id,ash.sql_plan_hash_value
       )
--where pct_cpu > 90
--where pct_io > 90
--where pct_wait > 90
group by sql_id,sql_type,module,parsing_schema
order by elap_max desc nulls last
--order by max_read_mb desc nulls last
)
where rownum < 51;

