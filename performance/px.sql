
/*
SELECT table_name
FROM dict
WHERE table_name LIKE 'V%PQ%'
OR table_name like 'V%PX%';

TABLE_NAME
------------------------------
V$PQ_SESSTAT
V$PQ_SYSSTAT
V$PQ_SLAVE
V$PQ_TQSTAT
V$PX_BUFFER_ADVICE
V$PX_SESSION
V$PX_SESSTAT
V$PX_PROCESS
V$PX_PROCESS_SYSSTAT
*/

col value format 9999999999
-- Script to monitor parallel queries Note 457857.1
-- shows the if a slave is waiting and for what event it waits..
-- This out shows 2 queries. 1 is running with degree 4 and the other with degree 8. Is shows also that all slaves are currently waiting.
col username for a12
col "QC SID" for A6
col "SID" for A6
col "QC/Slave" for A8
col "Req. DOP" for 9999
col "Actual DOP" for 9999
col "Group" for A6
col "Slaveset" for A8
col "Slave INST" for A9
col "QC INST" for A6
set pages 300 lines 300
col wait_event format a30
select
decode(px.qcinst_id,NULL,username,
' - '||lower(substr(pp.SERVER_NAME,
length(pp.SERVER_NAME)-4,4) ) )"Username",
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
to_char( px.server_group) "Group",
to_char( px.server_set) "SlaveSet",
to_char(s.sid) "SID",
to_char(px.inst_id) "Slave INST",
decode(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) as STATE,
case  sw.state WHEN 'WAITING' THEN substr(sw.event,1,30) ELSE NULL end as wait_event ,
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
to_char(px.qcinst_id) "QC INST",
px.req_degree "Req. DOP",
px.degree "Actual DOP",
s.sql_id "SQL_ID"
from gv$px_session px,
gv$session s ,
gv$px_process pp,
gv$session_wait sw
where px.sid=s.sid (+)
and px.serial#=s.serial#(+)
and px.inst_id = s.inst_id(+)
and px.sid = pp.sid (+)
and px.serial#=pp.serial#(+)
and sw.sid = s.sid
and sw.inst_id = s.inst_id
order by
  decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
  px.QCSID,
  decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
  px.SERVER_SET,
  px.INST_ID
/

-- shows for long running processes what are the slaves do
set pages 300 lines 300
col "Group" for 9999
col "Username" for a12
col "QC/Slave" for A8
col "Slaveset" for A8
col "Slave INST" for A9
col "QC SID" for A6
col "QC INST" for A6
col "operation_name" for A30
col "target" for A30

select
decode(px.qcinst_id,NULL,username,
' - '||lower(substr(pp.SERVER_NAME,
length(pp.SERVER_NAME)-4,4) ) )"Username",
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
to_char( px.server_set) "SlaveSet",
to_char(px.inst_id) "Slave INST",
substr(opname,1,30)  operation_name,
substr(target,1,30) target,
sofar,
totalwork,
round((sofar/NULLIF(nvl(totalwork,0),0))*100, 2) pct,
units,
start_time,
timestamp,
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
to_char(px.qcinst_id) "QC INST"
from gv$px_session px,
gv$px_process pp,
gv$session_longops s
where px.sid=s.sid
and px.serial#=s.serial#
and px.inst_id = s.inst_id
and px.sid = pp.sid (+)
and px.serial#=pp.serial#(+)
order by
  decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
  px.QCSID,
  decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
  px.SERVER_SET,
  px.INST_ID
/

/*
-- What event are the consumer slaves waiting on?
set linesize 150
col "Wait Event" format a30

select s.sql_id,
       px.INST_ID "Inst",
       px.SERVER_GROUP "Group",
       px.SERVER_SET "Set",
       px.DEGREE "Degree",
       px.REQ_DEGREE "Req Degree",
       w.event "Wait Event"
from GV$SESSION s, GV$PX_SESSION px, GV$PROCESS p, GV$SESSION_WAIT w
where s.sid (+) = px.sid and
      s.inst_id (+) = px.inst_id and
      s.sid = w.sid (+) and
      s.inst_id = w.inst_id (+) and
      s.paddr = p.addr (+) and
      s.inst_id = p.inst_id (+)
ORDER BY decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
         px.QCSID,
         decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
         px.SERVER_SET,
         px.INST_ID;
*/

-- shows for the PX Deq events the processes that are exchange data
set pages 300 lines 300
col wait_event format a30
select
  sw.SID as RCVSID,
  decode(pp.server_name,
         NULL, 'A QC',
         pp.server_name) as RCVR,
  sw.inst_id as RCVRINST,
case  sw.state WHEN 'WAITING' THEN substr(sw.event,1,30) ELSE NULL end as wait_event ,
  decode(bitand(p1, 65535),
         65535, 'QC',
         'P'||to_char(bitand(p1, 65535),'fm000')) as SNDR,
  bitand(p1, 16711680) - 65535 as SNDRINST,
  decode(bitand(p1, 65535),
         65535, ps.qcsid,
         (select
            sid
          from
            gv$px_process
          where
            server_name = 'P'||to_char(bitand(sw.p1, 65535),'fm000') and
            inst_id = bitand(sw.p1, 16711680) - 65535)
        ) as SNDRSID,
   decode(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) as STATE
from
  gv$session_wait sw,
  gv$px_process pp,
  gv$px_session ps
where
  sw.sid = pp.sid (+) and
  sw.inst_id = pp.inst_id (+) and
  sw.sid = ps.sid (+) and
  sw.inst_id = ps.inst_id (+) and
  p1text  = 'sleeptime/senderid' and
  bitand(p1, 268435456) = 268435456
order by
  decode(ps.QCINST_ID,  NULL, ps.INST_ID,  ps.QCINST_ID),
  ps.QCSID,
  decode(ps.SERVER_GROUP, NULL, 0, ps.SERVER_GROUP),
  ps.SERVER_SET,
  ps.INST_ID
/


SELECT dfo_number, tq_id, server_type, process, num_rows
FROM gV$PQ_TQSTAT ORDER BY dfo_number DESC, tq_id, server_type, process;

col SID format 999999
SELECT QCSID, SID, INST_ID "Inst", SERVER_GROUP "Group", SERVER_SET "Set",
  DEGREE "Degree", REQ_DEGREE "Req Degree"
FROM GV$PX_SESSION ORDER BY QCSID, QCINST_ID, SERVER_GROUP, SERVER_SET;


SELECT * FROM gV$PX_PROCESS order by 1;

col statistic format a50
select * from gV$PX_PROCESS_SYSSTAT order by 1,2;


SELECT INST_ID, NAME, VALUE FROM GV$SYSSTAT
WHERE UPPER (NAME) LIKE '%PARALLEL OPERATIONS%'
OR UPPER (NAME) LIKE '%PARALLELIZED%' OR UPPER (NAME) LIKE '%PX%' order by 1,2;


SELECT px.SID "SID", p.PID, p.SPID "SPID", px.INST_ID "Inst",
       px.SERVER_GROUP "Group", px.SERVER_SET "Set",
       px.DEGREE "Degree", px.REQ_DEGREE "Req Degree", w.event "Wait Event"
FROM GV$SESSION s, GV$PX_SESSION px, GV$PROCESS p, GV$SESSION_WAIT w
WHERE s.sid (+) = px.sid AND s.inst_id (+) = px.inst_id AND
      s.sid = w.sid (+) AND s.inst_id = w.inst_id (+) AND
      s.paddr = p.addr (+) AND s.inst_id = p.inst_id (+)
ORDER BY DECODE(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID), px.QCSID,
DECODE(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP), px.SERVER_SET, px.INST_ID;

