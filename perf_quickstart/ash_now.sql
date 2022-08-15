


select TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') current_time from dual;

COL username FORMAT A20
COL wait_class FORMAT A20
COL program FORMAT A45


PRO ##############################
PRO high level snapper
PRO ##############################
@@snapper ash 5 1 all@*


PRO ##############################
PRO high level wait class and event
PRO ##############################
@@ashtop wait_class,event session_type='FOREGROUND' sysdate-5/24/60 sysdate


PRO ##############################
PRO high level per node, wait class and event
PRO ##############################
@@ashtop inst_id,wait_class,event,username,sql_id session_type='FOREGROUND' sysdate-5/24/60 sysdate


PRO ##############################
PRO session and sqls
PRO ##############################
@@ashtop inst_id,session_id,username,program,sql_id,sql_plan_hash_value,plsql_entry_object_id,blocking_session,event session_type='FOREGROUND' sysdate-5/24/60 sysdate


PRO ##############################
PRO ash get what part of the execution plan the SQL is spending most of its time 
PRO ##############################
col object_name format a20
@@ashtop inst_id,session_id,username,program,sql_id,sql_plan_hash_value,plsql_entry_object_id,sql_plan_operation,sql_plan_options,sql_plan_line_id,o.object_name session_type='FOREGROUND' sysdate-5/24/60 sysdate


PRO ##############################
PRO ash by plan hash value and current_obj 
PRO ##############################
@@ashtop inst_id,session_id,sql_plan_hash_value,plsql_entry_object_id,sql_plan_operation,sql_plan_options,sql_plan_line_id,o.object_name session_type='FOREGROUND' sysdate-5/24/60 sysdate


PRO ##############################
PRO ash by plan hash value and current_obj
PRO ##############################
DEF x_slices = '20';
COL current_object FOR A60;
COL line_id FOR 9999999;
WITH
events AS (
SELECT /*+ MATERIALIZE */
       h.inst_id inst_id, 
       h.session_id session_id,
       h.sql_plan_hash_value plan_hash_value,
       NVL(h.sql_plan_line_id, 0) line_id,
       SUBSTR(h.sql_plan_operation||' '||h.sql_plan_options, 1, 50) operation,
       CASE h.session_state WHEN 'ON CPU' THEN -1 ELSE h.current_obj# END current_obj#,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM gv$active_session_history h
  where sample_time > sysdate-5/24/60 
 GROUP BY
       h.inst_id, 
       h.session_id,
       h.sql_plan_hash_value,
       h.sql_plan_line_id,
       h.sql_plan_operation,
       h.sql_plan_options,
       CASE h.session_state WHEN 'ON CPU' THEN -1 ELSE h.current_obj# END,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END
 ORDER BY
       6 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&x_slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       e.inst_id,
       e.session_id,
       e.plan_hash_value,
       e.line_id,
       e.operation,
       SUBSTR(e.current_obj# || ' ' || TRIM(NVL(
       (SELECT ' '||o.owner||'.'||o.object_name||' ('||o.object_type||')' FROM dba_objects o WHERE o.object_id = e.current_obj# AND ROWNUM = 1),  
       (SELECT ' '||o.owner||'.'||o.object_name||' ('||o.object_type||')' FROM dba_objects o WHERE o.data_object_id = e.current_obj# AND ROWNUM = 1) 
       )), 1, 60) current_object,
       e.timed_event
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT others samples,
       ROUND(100 * others / samples, 1) percent,
       TO_NUMBER(NULL) inst_id,
       TO_NUMBER(NULL) session_id,
       TO_NUMBER(NULL) plan_hash_value, 
       TO_NUMBER(NULL) id, 
       NULL operation, 
       NULL current_object,
       'Others' timed_event
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
   ORDER BY 1 DESC 
/


PRO ##############################
PRO row lock
PRO ##############################

set lines 500 
set pagesize 66 
col inst format 99
col object_name format a20
col spid format a6
col type format a4
col machine format a30
col owner format a20
SELECT TO_CHAR(SYSDATE,'MM/DD/YY HH24:MI:SS') TM, u.username owner, o.object_name object_name, lid.*
  FROM (SELECT
               s.inst_id inst, s.SID, s.serial#, p.spid, s.blocking_session blocking_sid, s.machine, s.username, NVL (s.sql_id, 0) sqlid, s.sql_hash_value sqlhv,
               DECODE (l.TYPE,
                       'TM', l.id1,
                       'TX', DECODE (l.request,
                                     0, NVL (lo.object_id, -1),
                                     s.row_wait_obj#
                                    ),
                       -1
                      ) AS object_id,
                 l.TYPE type,
               DECODE (l.lmode,
                       0, 'NONE',
                       1, 'NULL',
                       2, 'ROW SHARE',
                       3, 'ROW EXCLUSIVE',
                       4, 'SHARE',
                       5, 'SHARE ROW EXCLUSIVE',
                       6, 'EXCLUSIVE',
                       '?'
                      ) mode_held,
               DECODE (l.request,
                       0, 'NONE',
                       1, 'NULL',
                       2, 'ROW SHARE',
                      3, 'ROW EXCLUSIVE',
                       4, 'SHARE',
                       5, 'SHARE ROW EXCLUSIVE',
                       6, 'EXCLUSIVE',
                       '?'
                      ) mode_requested,
               l.id1, l.id2, l.ctime time_in_mode,s.row_wait_obj#, s.row_wait_block#,
               s.row_wait_row#, s.row_wait_file#
          FROM gv$lock l,
               gv$session s,
               gv$process p,
               (SELECT object_id, session_id, xidsqn
                  FROM gv$locked_object
                 WHERE xidsqn > 0) lo
         WHERE l.inst_id = s.inst_id
           AND s.inst_id = p.inst_id
           AND s.SID = l.SID
           AND p.addr = s.paddr
           AND l.SID = lo.session_id(+)
           AND l.id2 = lo.xidsqn(+)) lid,
       dba_objects o,
       dba_users u
WHERE o.object_id(+) = lid.object_id
AND o.owner = u.username(+)
AND o.object_id <> -1
/

PRO ##############################
PRO row lock from ash past 1 min
PRO ##############################

  set lines 300
  col program format a40
  col module format a20
  col event format a30
  select * from 
  (
  select count(*), session_id, program, module, CLIENT_ID, sql_id, event, mod(p1,16) as lock_mode, BLOCKING_SESSION from 
  v$active_Session_history
  where SAMPLE_TIME > sysdate - 1/1440
  group by session_id, program, module, CLIENT_ID, sql_id, event, mod(p1,16), BLOCKING_SESSION
  order by 1 desc
  )
  where rownum < 11; 

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
PRO longops
PRO ##############################

set lines 500
col opname format a35
col target format a10
col units format a10
select * from (
      select
      inst_id, sid, serial#, sql_id,
      opname, target, sofar, totalwork, round(sofar/totalwork, 4)*100 pct, units, round(elapsed_seconds/60,2) elap_min, round(time_remaining/60,2) remaining_min
      , sql_plan_hash_value, sql_plan_operation, sql_plan_options, sql_plan_line_id,  TO_CHAR(sql_exec_start, 'YYYY-MM-DD HH24:MI:SS') sql_exec_start
      ,message
      from gv$session_longops
      WHERE sofar < totalwork
      order by start_time desc)
/


@sqlmon 
