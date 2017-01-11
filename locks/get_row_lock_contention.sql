
-- see more explanations here https://sites.google.com/site/embtdbo/wait-event-documentation/oracle-enqueues

-- QUERY TX MODE from ASH
col program format a40
col module format a20
col event format a30
select TO_CHAR(sample_time,'MM/DD/YY HH24:MI:SS') TM, inst_id, session_id, BLOCKING_SESSION, machine, substr(module,1,20) module, sql_id, event, mod(p1,16) as lock_mode from 
gv$active_session_history
where sample_time > sysdate - 1 /( 60*24)
and event like 'enq: T%';

-- RAC user locks tree
set lines 500 
set pagesize 66 
col inst format 99
col object_name format a20
col spid format a6
col type format a4
col machine format a30
SELECT TO_CHAR(SYSDATE,'MM/DD/YY HH24:MI:SS') TM, o.name object_name, u.name owner, lid.*
  FROM (SELECT
               s.inst_id inst, s.SID, s.serial#, p.spid, s.blocking_session blocking_sid, s.machine, NVL (s.sql_id, 0) sqlid, s.sql_hash_value sqlhv,
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
       SYS.obj$ o,
       SYS.user$ u
WHERE o.obj#(+) = lid.object_id
AND o.owner# = u.user#(+)
AND object_id <> -1
/
