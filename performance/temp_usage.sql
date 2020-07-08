

PRO ##############################
PRO '*** GV$SESSION ***' 
PRO ##############################

set pagesize 999
set lines 500
col p1text format a20
col p2text format a20
col p3text format a20
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
col mins format 999999
col machine format a30
col osuser format a10
select a.inst_id inst, a.LAST_CALL_ET/60 mins, sid, username, substr(program,1,19) prog, b.sql_id, child_number child, plan_hash_value, executions execs,
(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
substr(event,1,20) event,
p1text,p1,p2text,p2,p3text,p3 ,
substr(sql_text,1,30) sql_text,
decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload,
decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,100*(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES-b.IO_INTERCONNECT_BYTES)
/decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) "IO_SAVED_%", a.machine "machine", a.osuser osuser
from gv$session a, gv$sql b
where status = 'ACTIVE'
and username is not null
and a.sql_id = b.sql_id
and a.inst_id = b.inst_id
and a.sql_child_number = b.child_number
and sql_text not like 'select a.inst_id inst, sid, substr(program,1,19) prog, b.sql_id, child_number child,%' -- don't show this query
and sql_text not like 'declare%' -- skip PL/SQL blocks
order by mins desc, sql_id, child
/

  
PRO ##############################
PRO temp usage 
PRO ##############################

BREAK ON REPORT
COMPUTE SUM OF SPACE_MB ON REPORT

set lines 300
select   se.username
        ,se.sid
        ,se.serial#
        ,su.extents
        ,su.blocks * to_number(rtrim(p.value))/1024/1024 as SPACE_MB
        ,se.sql_id
        ,tablespace
        ,segtype
        ,se.osuser osuser
from     v$sort_usage su
        ,v$parameter  p
        ,v$session    se
where    p.name          = 'db_block_size'
and      su.session_addr = se.saddr
order by se.username, se.sid;

PRO ##############################
PRO undo 
PRO ##############################

select sid, serial#,s.status,username, terminal, osuser,
       t.start_time, r.name, (t.used_ublk*8192)/1024 USED_kb, t.used_ublk "ROLLB BLKS",
       decode(t.space, 'YES', 'SPACE TX',
          decode(t.recursive, 'YES', 'RECURSIVE TX',
             decode(t.noundo, 'YES', 'NO UNDO TX', t.status)
       )) status
from sys.v_$transaction t, sys.v_$rollname r, sys.v_$session s
where t.xidusn = r.usn
  and t.ses_addr = s.saddr;