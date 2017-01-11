-- query long operations
set lines 200
col opname format a35
col target format a10
col units format a10
select * from (
            select 
            sid, serial#, sql_id,
            opname, target, sofar, totalwork, round(sofar/totalwork, 4)*100 pct, units, elapsed_seconds, time_remaining time_remaining_sec, round(time_remaining/60,2) min
            ,sql_hash_value
        --  ,message
            from v$session_longops 
            WHERE sofar < totalwork
            order by start_time desc);