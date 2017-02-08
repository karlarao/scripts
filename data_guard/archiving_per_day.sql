SET MARKUP HTML ON
spool archiving_per_day.html 

WITH
log AS (
SELECT /*+ MATERIALIZE NO_MERGE */ /* 2d.223 */
       DISTINCT
       thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM v$archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT /*+ MATERIALIZE NO_MERGE */ /* 2d.223 */
       thread#,
       TO_CHAR(TRUNC(first_time), 'YYYY-MM-DD') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), 'Dy') day,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '00', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '01', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '02', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '03', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '04', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '05', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '06', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '07', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '08', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '09', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '10', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '11', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '12', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '13', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '14', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '15', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '16', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '17', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '18', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '19', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '20', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '21', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '22', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '23', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(10,9), 1) TOT_GB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(10,9) / COUNT(*), 1) AVG_GB
  FROM log
 GROUP BY
       thread#,
       TRUNC(first_time)
 ORDER BY
       thread#,
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT /*+ MATERIALIZE NO_MERGE */ /* 2d.223 */
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT /*+ MATERIALIZE NO_MERGE */ /* 2d.223 */
       thread#,
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
 GROUP BY
       thread#
)
SELECT /*+ NO_MERGE */ /* 2d.223 */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.thread# = ms.thread#
   AND log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.thread#,
       log.yyyy_mm_dd DESC;


WITH
log AS (
SELECT /*+ MATERIALIZE NO_MERGE */ /* 2d.224 */
       DISTINCT
       thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM v$archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT /*+ MATERIALIZE NO_MERGE */ /* 2d.224 */
       TO_CHAR(TRUNC(first_time), 'YYYY-MM-DD') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), 'Dy') day,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '00', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '01', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '02', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '03', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '04', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '05', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '06', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '07', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '08', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '09', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '10', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '11', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '12', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '13', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '14', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '15', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '16', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '17', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '18', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '19', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '20', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '21', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '22', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '23', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(10,9), 1) TOT_GB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(10,9) / COUNT(*), 1) AVG_GB
  FROM log
 GROUP BY
       TRUNC(first_time)
 ORDER BY
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT /*+ MATERIALIZE NO_MERGE */ /* 2d.224 */
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT /*+ MATERIALIZE NO_MERGE */ /* 2d.224 */
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
)
SELECT /*+ NO_MERGE */ /* 2d.224 */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.yyyy_mm_dd DESC;


-- -- redo generation, per day & per hour.. V$LOG_HISTORY shows the logswitch regardless if you're in ARCHIVELOG MODE
-- SET LINESIZE 300
-- SET PAGESIZE 9999
-- SET VERIFY   off
-- COLUMN H00   FORMAT 999     HEADING '00'
-- COLUMN H01   FORMAT 999     HEADING '01'
-- COLUMN H02   FORMAT 999     HEADING '02'
-- COLUMN H03   FORMAT 999     HEADING '03'
-- COLUMN H04   FORMAT 999     HEADING '04'
-- COLUMN H05   FORMAT 999     HEADING '05'
-- COLUMN H06   FORMAT 999     HEADING '06'
-- COLUMN H07   FORMAT 999     HEADING '07'
-- COLUMN H08   FORMAT 999     HEADING '08'
-- COLUMN H09   FORMAT 999     HEADING '09'
-- COLUMN H10   FORMAT 999     HEADING '10'
-- COLUMN H11   FORMAT 999     HEADING '11'
-- COLUMN H12   FORMAT 999     HEADING '12'
-- COLUMN H13   FORMAT 999     HEADING '13'
-- COLUMN H14   FORMAT 999     HEADING '14'
-- COLUMN H15   FORMAT 999     HEADING '15'
-- COLUMN H16   FORMAT 999     HEADING '16'
-- COLUMN H17   FORMAT 999     HEADING '17'
-- COLUMN H18   FORMAT 999     HEADING '18'
-- COLUMN H19   FORMAT 999     HEADING '19'
-- COLUMN H20   FORMAT 999     HEADING '20'
-- COLUMN H21   FORMAT 999     HEADING '21'
-- COLUMN H22   FORMAT 999     HEADING '22'
-- COLUMN H23   FORMAT 999     HEADING '23'
-- COLUMN TOTAL FORMAT 999,999 HEADING 'Total'
-- SELECT
--     SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)                          DAY
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22
--   , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23
--   , COUNT(*)                                                                      TOTAL
-- FROM
--   v$log_history  a
-- GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
-- ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
-- /


-- Redo Generation Peak load
/*
Below queries are useful to calculate the required network bandwidth to send Redo changes to remote a site. Examples: Oracle Dataguard, Oracle Streams.
The First query will use v$archived_log to get the Redo Generation Peak load, for the last 30 days and for destination 1. Modify the values are required. 

COLUMN DATE FORMAT A20
SELECT TO_CHAR(b.first_time,'DD MON YYYY HH24:MI:SS') "Date",
a.blocks*a.block_size "Redo Kbytes",
ROUND((b.first_time - a.first_time)*24*60*60)"Time needed",
ROUND( (a.blocks*a.block_size*8/1000/1000)/(b.first_time - a.first_time)/(24*60*60)) "Redo Mbps"
FROM V$ARCHIVED_LOG a,V$ARCHIVED_LOG b
WHERE a.THREAD# = b.THREAD#
AND a.dest_id = b.dest_id
AND a.dest_id= 1
AND a.SEQUENCE# = b.SEQUENCE# -1
AND a.resetlogs_change# = b.resetlogs_change#
AND a.first_time > SYSDATE - 30
ORDER BY b.first_time
/

Note: remove the column heading and add commas. Spool the result to a file and you can load it into a spreadsheet to build a Chart. 

The second query will collect the Redo Generation Load based on AWR reports per Instance.


COLUMN "Start time" format a25
COLUMN "Interval" format a25
COLUMN "Redo Size" format 99999999
SET LINESIZE 999
SELECT a.snap_id "snap_id",
b.STARTUP_TIME  "Start time",  b.BEGIN_INTERVAL_TIME  "Interval",    TO_CHAR((a.VALUE - c.VALUE)) "Redo Size"  
FROM  dba_hist_sysstat  a , dba_hist_snapshot b, dba_hist_sysstat  c  
WHERE 
a.snap_id = b.snap_id 
AND   a.snap_id -1= c.snap_id
AND  c.stat_name IN ('redo size')
AND  a.stat_name IN ('redo size') 
AND  a.VALUE > c.VALUE
AND a.instance_number = 1 
AND c.instance_number = 1 
AND  a.instance_number = b.instance_number
ORDER BY a.snap_id DESC 
/

Note: Change the instance_number value defined to collect info for your environment. The result is cumulative.
*/



-- to show archived logs and SIZE, on a certain DATE, V$ARCHIVED_LOG shows the logswitch in ARCHIVE MODE
select to_char(first_time, 'DD-MON-YY HH24:MI:SS') FIRST_TIME,name,sequence#, blocks * block_size/1048576 arc_size 
from v$archived_log
where first_change# in (select first_change# from v$log_history where FIRST_TIME like '27-JUL-07')
order by FIRST_TIME desc;


-- -- to show percentage full of a certain logfile    
-- SELECT le.leseq                        CURRENT_LOG_SEQUENCE#,
--       100*cp.cpodr_bno/LE.lesiz       PERCENTAGE_FULL
-- from x$kcccp cp,x$kccle le
-- WHERE LE.leseq =CP.cpodr_seq;

-- select
--   le.leseq                        "Current log sequence No",
--   100*cp.cpodr_bno/le.lesiz       "Percent Full",
--   cp.cpodr_bno                    "Current Block No",
--   le.lesiz                        "Size of Log in Blocks"
-- from
--   x$kcccp cp,
--   x$kccle le
-- where
--   LE.leseq =CP.cpodr_seq
--   and bitand(le.leflg,24)=8;           



-- redo per hour
set pages 80
col mb format 999,990.0 heading 'Redo Generated MB'
col kbps format 999,990 heading 'Redo KB/s'
select to_char(completion_time, 'DD-MON-YYYY HH24')||':00' hour,
sum(blocks*block_size)/1048576 mb,
round(sum(blocks*block_size)/1024/1024/(60*60),2) MBs,
count(*) logs
from v$archived_log
group by to_char(completion_time, 'DD-MON-YYYY HH24')||':00'
order by min(completion_time);


-- redo log size

-- Query redo logs
set lines 300
col member format a60
select a.thread#, a.group#, b.member, a.bytes/1024/1024, a.status, b.type, a.sequence#
from v$log a, v$logfile b
where a.group# = b.group#
union all 
select b.thread#, b.group#, a.member, b.bytes/1024/1024, b.status, a.type, b.sequence#
from v$logfile a, v$standby_log b
where a.group# = b.group#
order by 1,2;

spool off
exit