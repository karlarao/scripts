ttitle left '*** GV$SQL_MONITOR ***' skip 1

-- with child address join
set pagesize 999
set lines 300
col status format a12
col inst format 99
col px1 format 999
col px2 format 999
col px3 format 999
col module format a20
col RMBs format 99999
col WMBs format 99999
col sql_exec_id format 9999999999
col username format a15
col sql_text format a70
col sid format 9999
col rm_group format a10
select
        a.status,
        decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'N','Y') Offload,
        decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'Y','N') InMemPX,
        b.EXECUTIONS exec,
        round(a.ELAPSED_TIME/1000000,2) ela_tm,
        round(a.CPU_TIME/1000000,2) cpu_tm,
        round(a.USER_IO_WAIT_TIME/1000000,2) io_tm,
        round((a.PHYSICAL_READ_BYTES/1024/1024)/NULLIF(nvl((a.ELAPSED_TIME/1000000),0),0),2) RMBs,
        round((a.PHYSICAL_WRITE_BYTES/1024/1024)/NULLIF(nvl((a.ELAPSED_TIME/1000000),0),0),2) WMBs,
        a.SID,
        substr (a.MODULE, 1,16) module,
        -- a.RM_CONSUMER_GROUP rm_group,  -- new in 11204
        a.SQL_ID,
        a.SQL_PLAN_HASH_VALUE PHV,
        a.sql_exec_id,
        a.INST_ID inst,
        a.USERNAME,
        CASE WHEN a.PX_SERVERS_ALLOCATED IS NULL THEN NULL WHEN a.PX_SERVERS_ALLOCATED = 0 THEN 1 ELSE a.PX_SERVERS_ALLOCATED END PX1,
        CASE WHEN a.PX_SERVER_SET IS NULL THEN NULL WHEN a.PX_SERVER_SET = 0 THEN 1 ELSE a.PX_SERVER_SET END PX2,
        CASE WHEN a.PX_SERVER# IS NULL THEN NULL WHEN a.PX_SERVER# = 0 THEN 1 ELSE a.PX_SERVER# END PX3,
        to_char(a.SQL_EXEC_START,'MMDDYY HH24:MI:SS') SQL_EXEC_START,
        -- to_char((a.SQL_EXEC_START + round(a.ELAPSED_TIME/1000000,2)/86400),'MMDDYY HH24:MI:SS') SQL_EXEC_END,
        substr(a.SQL_TEXT, 1,70) sql_text
from gv$sql_monitor a, gv$sql b
where a.sql_id = b.sql_id
and a.inst_id = b.inst_id
and a.sql_child_address = b.child_address
and a.status in ('QUEUED','EXECUTING')
-- and lower(a.module) like '%dynrole%'
-- a.SQL_ID in ('fjnfu5qn3krhn')
-- or a.status like '%ALL ROWS%'
-- or a.status like '%ERROR%'
order by a.status, a.SQL_EXEC_START, a.SQL_EXEC_ID, a.PX_SERVERS_ALLOCATED, a.PX_SERVER_SET, a.PX_SERVER# asc
/

ttitle left '*** GV$SESSION ***' skip 1

set pagesize 999
set lines 180
col inst for 9999
col username format a13
col prog format a10 trunc
col sql_text format a60 trunc
col sid format 9999
col child for 99999
col avg_etime for 999,999.99
break on sql_text
col sql_text format a30
col event format a20
col hours format 99999
select a.inst_id inst, sid, username, substr(program,1,19) prog, b.sql_id, child_number child, plan_hash_value, executions execs,
(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
substr(event,1,20) event,
substr(sql_text,1,30) sql_text,
LAST_CALL_ET/60/60 hours,
decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload,
decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,100*(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES-b.IO_INTERCONNECT_BYTES)
/decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) "IO_SAVED_%"
from gv$session a, gv$sql b
where status = 'ACTIVE'
and username is not null
and a.sql_id = b.sql_id
and a.inst_id = b.inst_id
and a.sql_child_number = b.child_number
and sql_text not like 'select a.inst_id inst, sid, substr(program,1,19) prog, b.sql_id, child_number child,%' -- don't show this query
and sql_text not like 'declare%' -- skip PL/SQL blocks
order by hours desc, sql_id, child
/

ttitle left '*** GV$SESSION sort by INST_ID ***' skip 1

set lines 32767
col terminal format a4
col machine format a4
col os_login format a15
col oracle_login format a15
col osuser format a4
col module format a5
col program format a20
col schemaname format a5
-- col state format a8
col client_info format a5
col status format a4
col sid format 99999
col serial# format 99999
col unix_pid format a8
col sql_text format a30
col action format a8
col event format a40
col hours format 99999
select /* usercheck */ s.INST_ID, s.sid sid, lpad(p.spid,7) unix_pid, s.username oracle_login, substr(s.program,1,20) program,
        s.sql_id,               -- remove in 817, 9i
        sa.plan_hash_value,     -- remove in 817, 9i
        substr(s.event,1,40) event,
        substr(sa.sql_text,1,30) sql_text,
        s.LAST_CALL_ET/60/60 hours
from gv$process p, gv$session s, gv$sqlarea sa
where p.addr=s.paddr
and   s.username is not null
and   s.sql_address=sa.address(+)
and   s.sql_hash_value=sa.hash_value(+)
and   sa.sql_text NOT LIKE '%usercheck%'
-- and   lower(sa.sql_text) LIKE '%grant%'
-- and s.username = 'APAC'
-- and s.schemaname = 'SYSADM'
-- and lower(s.program) like '%uscdcmta21%'
-- and s.sid=12
-- and p.spid  = 14967
-- and s.sql_hash_value = 3963449097
-- and s.sql_id = '5p6a4cpc38qg3'
-- and lower(s.client_info) like '%10036368%'
-- and s.module like 'PSNVS%'
-- and s.program like 'PSNVS%'
order by inst_id, sql_id
/
