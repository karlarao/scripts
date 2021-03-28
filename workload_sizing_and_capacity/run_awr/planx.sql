----------------------------------------------------------------------------------------
--
-- File name:   planx.sql
--
-- Purpose:     Reports Execution Plans for one SQL_ID from RAC and AWR(opt)
--
-- Author:      Carlos Sierra
--
-- Version:     2015/04/27
--
-- Usage:       This script inputs two parameters. Parameter 1 is a flag to specify if
--              your database is licensed to use the Oracle Diagnostics Pack or not.
--              Parameter 2 specifies the SQL_ID for which you want to report all
--              execution plans from all nodes, plus all plans from AWR.
--              If you don't have the Oracle Diagnostics Pack license, or if you want
--              to omit the AWR portion then specify "N" on Parameter 1.
--
-- Example:     @planx.sql Y f995z9antmhxn
--
-- Notes:       Developed and tested on 11.2.0.3 and 12.0.1.0
--              For a more robust tool use SQLHC or SQLTXPLAIN(SQLT) from MOS
--             
---------------------------------------------------------------------------------------
--
CL COL;
SET FEED OFF VER OFF HEA ON LIN 2000 PAGES 50 TIMI OFF LONG 80000 LONGC 2000 TRIMS ON AUTOT OFF TERM OFF;
PRO
PRO 1. Enter Oracle Diagnostics Pack License Flag [ Y | N ] (required)
DEF input_license = '&1';
PRO
PRO 2. Enter SQL_ID (required)
DEF sql_id = '&2';
-- set license
VAR license CHAR(1);
BEGIN
  SELECT UPPER(SUBSTR(TRIM('&input_license.'), 1, 1)) INTO :license FROM DUAL;
END;
/
-- get dbid
VAR dbid NUMBER;
BEGIN
  SELECT dbid INTO :dbid FROM v$database;
END;
/
-- is_10g
DEF is_10g = '';
COL is_10g NEW_V is_10g NOPRI;
SELECT '--' is_10g FROM v$instance WHERE version LIKE '10%';
-- is_11r1
DEF is_11r1 = '';
COL is_11r1 NEW_V is_11r1 NOPRI;
SELECT '--' is_11r1 FROM v$instance WHERE version LIKE '11.1%';
-- get current time
COL current_time NEW_V current_time FOR A15;
SELECT 'current_time: ' x, TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') current_time FROM DUAL;
-- set min and max snap id
COL x_minimum_snap_id NEW_V x_minimum_snap_id NOPRI;
SELECT NVL(TO_CHAR(MAX(snap_id)), '0') x_minimum_snap_id FROM dba_hist_snapshot WHERE :license = 'Y' AND begin_interval_time < SYSDATE - 31;
SELECT '-1' x_minimum_snap_id FROM DUAL WHERE TRIM('&&x_minimum_snap_id.') IS NULL;
COL x_maximum_snap_id NEW_V x_maximum_snap_id NOPRI;
SELECT NVL(TO_CHAR(MAX(snap_id)), '&&x_minimum_snap_id.') x_maximum_snap_id FROM dba_hist_snapshot WHERE :license = 'Y';
SELECT '-1' x_maximum_snap_id FROM DUAL WHERE TRIM('&&x_maximum_snap_id.') IS NULL;
COL x_minimum_date NEW_V x_minimum_date NOPRI;
SELECT TO_CHAR(MIN(begin_interval_time), 'DD-MON-YYYY HH24:MI:SS') x_minimum_date FROM dba_hist_snapshot WHERE :license = 'Y' AND snap_id = &&x_minimum_snap_id.;
COL x_maximum_date NEW_V x_maximum_date NOPRI;
SELECT TO_CHAR(MAX(end_interval_time), 'DD-MON-YYYY HH24:MI:SS') x_maximum_date FROM dba_hist_snapshot WHERE :license = 'Y' AND snap_id = &&x_maximum_snap_id.;
-- get sql_text
VAR sql_text CLOB;
EXEC :sql_text := NULL;
BEGIN
  SELECT sql_fulltext 
    INTO :sql_text
    FROM gv$sqlstats 
   WHERE sql_id = '&&sql_id.' 
     AND ROWNUM = 1;
END;
/
BEGIN
  IF :sql_text IS NULL OR NVL(DBMS_LOB.GETLENGTH(:sql_text), 0) = 0 THEN
    SELECT sql_text
      INTO :sql_text
      FROM dba_hist_sqltext
     WHERE sql_id = '&&sql_id.'
       AND ROWNUM = 1;
  END IF;
END;
/
VAR signature NUMBER;
VAR signaturef NUMBER;
EXEC :signature := NVL(DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(:sql_text), -1);
EXEC :signaturef := NVL(DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(:sql_text, TRUE), -1);
COL signature NEW_V signature FOR A20;
COL signaturef NEW_V signaturef FOR A20;
SELECT TO_CHAR(:signature) signature, TO_CHAR(:signaturef) signaturef FROM DUAL;
BEGIN
  IF :sql_text IS NULL THEN
    :sql_text := 'Unknown SQL Text';
  END IF;
END;
/
-- spool and sql_text

COLUMN xconname NEW_VALUE _xconname NOPRINT
select sys_context('userenv', 'con_name') xconname from dual;

COLUMN name NEW_VALUE _xdbname NOPRINT
select name from v$database;

COLUMN name NEW_VALUE _instname NOPRINT
select instance_name name from v$instance;

SPO planx_&&_xdbname-&&_instname-&&_xconname-&&sql_id._&&current_time..txt;
PRO SQL_ID: &&sql_id.
PRO SIGNATURE: &&signature.
PRO SIGNATUREF: &&signaturef.
PRO DB NAME: &&_xdbname
PRO INSTANCE NAME: &&_instname
PRO PDB NAME: &&_xconname
PRO
SET PAGES 0;
PRINT :sql_text;
SET PAGES 50000;
-- columns format
COL is_shareable FOR A12;
COL loaded FOR A6;
COL executions FOR A20;
COL rows_processed FOR A20;
COL buffer_gets FOR A20;
COL disk_reads FOR A20;
COL direct_writes FOR A20;
COL elapsed_secs FOR A18;
COL cpu_secs FOR A18;
COL user_io_wait_secs FOR A18;
COL cluster_wait_secs FOR A18;
COL appl_wait_secs FOR A18;
COL conc_wait_secs FOR A18;
COL plsql_exec_secs FOR A18;
COL java_exec_secs FOR A18;
COL io_cell_offload_eligible_bytes FOR A30;
COL io_interconnect_bytes FOR A30;
COL io_saved FOR A8;
PRO
PRO GV$SQLSTATS (ordered by inst_id)
PRO ~~~~~~~~~~~
SELECT inst_id, 
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs&&is_10g.&&is_11r1.,
       &&is_10g.&&is_11r1.LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       &&is_10g.&&is_11r1.LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       &&is_10g.&&is_11r1.CASE 
         &&is_10g.&&is_11r1.WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           &&is_10g.&&is_11r1.LPAD(TO_CHAR(ROUND(
           &&is_10g.&&is_11r1.(io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           &&is_10g.&&is_11r1., 2), '990.00')||' %', 8) END io_saved
  FROM gv$sqlstats
 WHERE sql_id = '&&sql_id.'
 ORDER BY 1
/
PRO
PRO GV$SQLSTATS_PLAN_HASH (ordered by inst_id and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~
SELECT inst_id, plan_hash_value,
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs&&is_11r1.,
       &&is_11r1.LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       &&is_11r1.LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       &&is_11r1.CASE 
         &&is_11r1.WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           &&is_11r1.LPAD(TO_CHAR(ROUND(
           &&is_11r1.(io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           &&is_11r1., 2), '990.00')||' %', 8) END io_saved
  FROM gv$sqlstats_plan_hash
 WHERE sql_id = '&&sql_id.'
 ORDER BY 1, 2
/
PRO
PRO GV$SQL (ordered by inst_id and child_number)
PRO ~~~~~~
SELECT inst_id, child_number, plan_hash_value, &&is_10g.is_shareable, 
       DECODE(loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs&&is_10g.&&is_11r1.,
       &&is_11r1.&&is_10g.LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       &&is_11r1.&&is_10g.LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       &&is_11r1.&&is_10g.CASE 
         &&is_11r1.&&is_10g.WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           &&is_11r1.&&is_10g.LPAD(TO_CHAR(ROUND(
           &&is_11r1.&&is_10g.(io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           &&is_11r1.&&is_10g., 2), '990.00')||' %', 8) END io_saved
  FROM gv$sql
 WHERE sql_id = '&&sql_id.'
 ORDER BY 1, 2
/
PRO       
PRO GV$SQL_PLAN_STATISTICS_ALL LAST (ordered by inst_id and child_number)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;
SET PAGES 0;
WITH v AS (
SELECT /*+ MATERIALIZE */
       DISTINCT sql_id, inst_id, child_number
  FROM gv$sql
 WHERE sql_id = '&&sql_id.'
   AND loaded_versions > 0
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */
       RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, 
       t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 
       'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
/
CLEAR BREAKS
PRO
PRO DBA_HIST_SQLSTAT DELTA (ordered by snap_id DESC, instance_number and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SET PAGES 50000
SELECT s.snap_id, 
       TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       s.instance_number, h.plan_hash_value,
       DECODE(h.loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(h.executions_delta, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(h.rows_processed_delta, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(h.buffer_gets_delta, '999,999,999,999,990'), 20) buffer_gets, 
       LPAD(TO_CHAR(h.disk_reads_delta, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(h.direct_writes_delta, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(h.elapsed_time_delta/1e6, 3), '999,999,990.000'), 18) elapsed_secs,
       LPAD(TO_CHAR(ROUND(h.cpu_time_delta/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(h.iowait_delta/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(h.clwait_delta/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(h.apwait_delta/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(h.ccwait_delta/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(h.plsexec_time_delta/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(h.javexec_time_delta/1e6, 3), '999,999,990.000'), 18) java_exec_secs&&is_10g.&&is_11r1.,
       &&is_11r1.&&is_10g.LPAD(TO_CHAR(h.io_offload_elig_bytes_delta, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       &&is_11r1.&&is_10g.LPAD(TO_CHAR(h.io_interconnect_bytes_delta, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       &&is_11r1.&&is_10g.CASE 
         &&is_11r1.&&is_10g.WHEN h.io_offload_elig_bytes_delta > h.io_interconnect_bytes_delta THEN
           &&is_11r1.&&is_10g.LPAD(TO_CHAR(ROUND(
           &&is_11r1.&&is_10g.(h.io_offload_elig_bytes_delta - h.io_interconnect_bytes_delta) * 100 / h.io_offload_elig_bytes_delta
           &&is_11r1.&&is_10g., 2), '990.00')||' %', 8) END io_saved
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license = 'Y'
   AND h.dbid = :dbid
   AND h.sql_id = '&&sql_id.'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 ORDER BY 1 DESC, 4, 5
/
PRO
PRO DBA_HIST_SQLSTAT TOTAL (ordered by snap_id DESC, instance_number and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SELECT s.snap_id, 
       TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       s.instance_number, h.plan_hash_value,
       DECODE(h.loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(h.executions_total, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(h.rows_processed_total, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(h.buffer_gets_total, '999,999,999,999,990'), 20) buffer_gets, 
       LPAD(TO_CHAR(h.disk_reads_total, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(h.direct_writes_total, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(h.elapsed_time_total/1e6, 3), '999,999,990.000'), 18) elapsed_secs,
       LPAD(TO_CHAR(ROUND(h.cpu_time_total/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(h.iowait_total/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(h.clwait_total/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(h.apwait_total/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(h.ccwait_total/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(h.plsexec_time_total/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(h.javexec_time_total/1e6, 3), '999,999,990.000'), 18) java_exec_secs &&is_10g.&&is_11r1.,
       &&is_11r1.&&is_10g.LPAD(TO_CHAR(h.io_offload_elig_bytes_total, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       &&is_11r1.&&is_10g.LPAD(TO_CHAR(h.io_interconnect_bytes_total, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       &&is_11r1.&&is_10g.CASE 
         &&is_11r1.&&is_10g.WHEN h.io_offload_elig_bytes_total > h.io_interconnect_bytes_total THEN
           &&is_11r1.&&is_10g.LPAD(TO_CHAR(ROUND(
           &&is_11r1.&&is_10g.(h.io_offload_elig_bytes_total - h.io_interconnect_bytes_total) * 100 / h.io_offload_elig_bytes_total
           &&is_11r1.&&is_10g., 2), '990.00')||' %', 8) END io_saved
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license = 'Y'
   AND h.dbid = :dbid
   AND h.sql_id = '&&sql_id.'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 ORDER BY 1 DESC, 4, 5
/
PRO
PRO AWR_PLAN_CHANGE
PRO ~~~~~~~~~~~~~~~~~~~~~~
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio,
(io_offload_elig_bytes_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_offload,
s.parsing_schema_name
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where S.sql_id = '&&sql_id.'
and ss.dbid = :dbid
and ss.dbid = S.dbid
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1, 2, 3
/
PRO
PRO DBA_HIST_SQL_PLAN (ordered by plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~
COL plan_timestamp FOR A19;
BREAK ON plan_timestamp SKIP 2;
SET PAGES 0;
WITH v AS (
SELECT /*+ MATERIALIZE */ 
       DISTINCT sql_id, plan_hash_value, dbid, timestamp
  FROM dba_hist_sql_plan 
 WHERE :license = 'Y'
   AND dbid = :dbid 
   AND sql_id = '&&sql_id.'
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */ 
       TO_CHAR(v.timestamp, 'YYYY-MM-DD HH24:MI:SS') plan_timestamp,
       t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED')) t
/  
CLEAR BREAKS
PRO
PRO GV$ACTIVE_SESSION_HISTORY - ash_elap by exec (recent)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
set lines 300
SET PAGES 50000
col sql_exec_start format a30
col run_time_timestamp format a30
select 'realtime' source, sql_id, 
       sql_exec_id,
       sql_plan_hash_value,
       CAST(sql_exec_start AS TIMESTAMP) sql_exec_start,
       run_time run_time_timestamp, 
 (EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60 
                    + EXTRACT(SECOND FROM run_time)) run_time_sec,
       round(temp/1024/1024,2) temp_mb,
       round(pga/1024/1024,2) pga_mb,
       round(rbytes/1024/1024,2) read_mb,
       round(wbytes/1024/1024,2) write_mb,
       riops,
       wiops
from  (
select 
       sql_id,
       sql_exec_id,
       sql_plan_hash_value,
       max(sql_exec_start) sql_exec_start,
       max(sample_time - sql_exec_start) run_time,
       max(TEMP_SPACE_ALLOCATED) temp,
       max(PGA_ALLOCATED) pga,
       max(DELTA_READ_IO_BYTES) rbytes,
       max(DELTA_READ_IO_REQUESTS) riops,
       max(DELTA_WRITE_IO_BYTES) wbytes,
       max(DELTA_WRITE_IO_REQUESTS) wiops
from 
       v$active_session_history
where sql_id = '&&sql_id.'
and sql_exec_start is not null 
group by sql_id,sql_exec_id,sql_plan_hash_value
order by sql_exec_start desc 
)
where rownum < 21
order by 1, sql_exec_start asc
/ 

select 'historical' source, sql_id, 
       sql_exec_id,
       sql_plan_hash_value,
       CAST(sql_exec_start AS TIMESTAMP) sql_exec_start,
       run_time run_time_timestamp, 
 (EXTRACT(HOUR FROM run_time) * 3600
                    + EXTRACT(MINUTE FROM run_time) * 60 
                    + EXTRACT(SECOND FROM run_time)) run_time_sec,
       round(temp/1024/1024,2) temp_mb,
       round(pga/1024/1024,2) pga_mb,
       round(rbytes/1024/1024,2) read_mb,
       round(wbytes/1024/1024,2) write_mb,
       riops,
       wiops
from  (
select 
       sql_id,
       sql_exec_id,
       sql_plan_hash_value,
       max(sql_exec_start) sql_exec_start,
       max(sample_time - sql_exec_start) run_time,
       max(TEMP_SPACE_ALLOCATED) temp,
       max(PGA_ALLOCATED) pga,
       max(DELTA_READ_IO_BYTES) rbytes,
       max(DELTA_READ_IO_REQUESTS) riops,
       max(DELTA_WRITE_IO_BYTES) wbytes,
       max(DELTA_WRITE_IO_REQUESTS) wiops
from 
       dba_hist_active_sess_history
where sql_id = '&&sql_id.'
and sql_exec_start is not null 
group by sql_id,sql_exec_id,sql_plan_hash_value
order by sql_exec_start desc 
)
where rownum < 21
order by 1, sql_exec_start asc
/ 
PRO
PRO GV$ACTIVE_SESSION_HISTORY - ash_elap exec avg min max 
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
select 'realtime' source, sql_plan_hash_value,  
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
               gv$active_session_history 
        where
               sql_exec_start is not null 
               and sql_id = '&&sql_id.'
        group by sql_id,sql_exec_id,sql_plan_hash_value
       )
group by sql_plan_hash_value
union all
select  null, null,
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
               gv$active_session_history 
        where
               sql_exec_start is not null 
               and sql_id = '&&sql_id.'
        group by sql_id,sql_exec_id,sql_plan_hash_value
       )
/

select 'historical' source, sql_plan_hash_value,  
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
select  null, null,
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
PRO
PRO GV$ACTIVE_SESSION_HISTORY 
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_slices = '10';
SET PAGES 50000;
COL samples FOR 999,999,999,999
COL percent FOR 9,990.0;
COL timed_event FOR A70;
WITH
events AS (
SELECT /*+ MATERIALIZE */
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE :license = 'Y'
   AND sql_id = '&&sql_id.'
 GROUP BY
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END
 ORDER BY
       2 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&x_slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT 'realtime' source, e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       e.timed_event
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT null, others samples,
       ROUND(100 * others / samples, 1) percent,
       'Others' timed_event
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
   order by 2 desc
/

WITH
events AS (
SELECT /*+ MATERIALIZE */
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h
 WHERE :license = 'Y'
   AND sql_id = '1g10r6kwgmv30'
 GROUP BY
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END
 ORDER BY
       2 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&x_slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT 'historical' source, e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       e.timed_event
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT null, others samples,
       ROUND(100 * others / samples, 1) percent,
       'Others' timed_event
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
   order by 2 desc
/
PRO
PRO GV$ACTIVE_SESSION_HISTORY - by inst_id
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_slices = '10';
SET PAGES 50000;
COL samples FOR 999,999,999,999
COL percent FOR 9,990.0;
COL timed_event FOR A70;
WITH
events AS (
SELECT /*+ MATERIALIZE */
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       inst_id,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE :license = 'Y'
   AND sql_id = '&&sql_id.'
 GROUP BY
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END,
       inst_id
 ORDER BY
       3 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&x_slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT 'realtime' source, e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       e.inst_id,
       e.timed_event
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT null, others samples,
       ROUND(100 * others / samples, 1) percent,
       null inst_id,
       'Others' timed_event
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
   order by 2 desc
/

WITH
events AS (
SELECT /*+ MATERIALIZE */
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       instance_number,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h
 WHERE :license = 'Y'
   AND sql_id = '&&sql_id.'
 GROUP BY
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END,
       instance_number
 ORDER BY
       3 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&x_slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT 'historical' source, e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       e.instance_number,
       e.timed_event
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT null, others samples,
       ROUND(100 * others / samples, 1) percent,
       null instance_number,
       'Others' timed_event
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
   order by 2 desc
/
PRO
PRO GV$ACTIVE_SESSION_HISTORY 
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_slices = '15';
COL operation FOR A50;
COL line_id FOR 9999999;
WITH
events AS (
SELECT /*+ MATERIALIZE */
       h.sql_plan_hash_value plan_hash_value,
       NVL(h.sql_plan_line_id, 0) line_id,
       SUBSTR(h.sql_plan_operation||' '||h.sql_plan_options, 1, 50) operation,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE :license = 'Y'
   AND sql_id = '&&sql_id.'
 GROUP BY
       h.sql_plan_hash_value,
       h.sql_plan_line_id,
       h.sql_plan_operation,
       h.sql_plan_options,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END
 ORDER BY
       5 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&x_slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       e.plan_hash_value,
       e.line_id,
       e.operation,
       e.timed_event
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT others samples,
       ROUND(100 * others / samples, 1) percent,
       TO_NUMBER(NULL) plan_hash_value, 
       TO_NUMBER(NULL) id, 
       NULL operation, 
       'Others' timed_event
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
/
PRO
PRO
PRO GV$ACTIVE_SESSION_HISTORY
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_slices = '20';
COL current_object FOR A60;
COL line_id FOR 9999999;
WITH
events AS (
SELECT /*+ MATERIALIZE */
       h.sql_plan_hash_value plan_hash_value,
       NVL(h.sql_plan_line_id, 0) line_id,
       SUBSTR(h.sql_plan_operation||' '||h.sql_plan_options, 1, 50) operation,
       CASE h.session_state WHEN 'ON CPU' THEN -1 ELSE h.current_obj# END current_obj#,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       case when px_flags is null then 'SERIAL' else 'px'||trunc(px_flags/2097152) end dop,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE :license = 'Y'
   AND sql_id = '&&sql_id.'
 GROUP BY
       h.sql_plan_hash_value,
       h.sql_plan_line_id,
       h.sql_plan_operation,
       h.sql_plan_options,
       CASE h.session_state WHEN 'ON CPU' THEN -1 ELSE h.current_obj# END,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END,
       case when px_flags is null then 'SERIAL' else 'px'||trunc(px_flags/2097152) end
 ORDER BY
       7 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&x_slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       e.plan_hash_value,
       e.line_id,
       e.operation,
       SUBSTR(e.dop||' '||e.current_obj#||TRIM(NVL(
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
       TO_NUMBER(NULL) plan_hash_value,
       TO_NUMBER(NULL) id,
       NULL operation,
       NULL current_object,
       'Others' timed_event
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
/
PRO
PRO
PRO GV$ACTIVE_SESSION_HISTORY - px distribution
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
break on sql_exec_start on SQL_EXEC_ID on sql_plan_hash_value on dop
col dop format a10
col program format a60
with sql_exec_id_data as (select sql_exec_id,sql_exec_start from
        (
        select 
		       sql_exec_id,
		       max(sql_exec_start) sql_exec_start
		from 
		       gv$active_session_history  
		where sql_id = '&&sql_id.'
		and sql_exec_start is not null 
		group by SQL_EXEC_ID
		order by sql_exec_start desc 
        )
        where rownum < 4)
select 
	CAST(max(sql_exec_start) AS TIMESTAMP) sql_exec_start, 
	sql_exec_id, 
	sql_plan_hash_value, 
	sql_plan_line_id,
	case when px_flags is null then 'SERIAL' else 'px'||trunc(px_flags/2097152) end dop, 
	program, 
	count(*)
from gv$active_session_history
where sql_id = '&&sql_id.'
and (sql_exec_id,sql_exec_start) in (select sql_exec_id,sql_exec_start from sql_exec_id_data)
group by sql_exec_id, sql_plan_hash_value, sql_plan_line_id, case when px_flags is null then 'SERIAL' else 'px'||trunc(px_flags/2097152) end, program
order by 1 asc, 4 asc, 6 asc
/
CLEAR BREAKS

PRO
PRO
VAR tables_list CLOB;
EXEC :tables_list := NULL;
-- get list of tables from execution plan
-- format (('owner', 'table_name'), (), ()...)
DECLARE
  l_pair VARCHAR2(32767);
BEGIN
  DBMS_LOB.CREATETEMPORARY(:tables_list, TRUE, DBMS_LOB.SESSION);
  FOR i IN (WITH object AS (
  	    SELECT /*+ MATERIALIZE */
  	           object_owner owner, object_name name
  	      FROM gv$sql_plan
  	     WHERE inst_id IN (SELECT inst_id FROM gv$instance)
  	       AND sql_id = '&&sql_id.'
  	       AND object_owner IS NOT NULL
  	       AND object_name IS NOT NULL
  	     UNION
  	    SELECT object_owner owner, object_name name
  	      FROM dba_hist_sql_plan
  	     WHERE :license = 'Y'
  	       AND dbid = :dbid
  	       AND sql_id = '&&sql_id.'
  	       AND object_owner IS NOT NULL
  	       AND object_name IS NOT NULL
  	     UNION
  	    SELECT o.owner, o.object_name name
  	      FROM gv$active_session_history h,
  	           dba_objects o
  	     WHERE :license = 'Y'
  	       AND h.sql_id = '&&sql_id.'
  	       AND h.current_obj# > 0
  	       AND o.object_id = h.current_obj#
  	     /*UNION
  	    SELECT o.owner, o.object_name name
  	      FROM gv$active_session_history h,
  	           dba_objects o
  	     WHERE :license = 'Y'
  	       AND h.sql_id = '&&sql_id.'
  	       AND h.current_obj# > 0
  	       AND o.data_object_id = h.current_obj#*/
  	     UNION
  	    SELECT o.owner, o.object_name name
  	      FROM dba_hist_active_sess_history h,
  	           dba_objects o
  	     WHERE :license = 'Y'
  	       AND h.dbid = :dbid
  	       AND h.sql_id = '&&sql_id.'
  	       AND h.current_obj# > 0
  	       AND o.object_id = h.current_obj#
  	     /*UNION
  	    SELECT o.owner, o.object_name name
  	      FROM dba_hist_active_sess_history h,
  	           dba_objects o
  	     WHERE :license = 'Y'
  	       AND h.dbid = :dbid
  	       AND h.sql_id = '&&sql_id.'
  	       AND h.current_obj# > 0
  	       AND o.data_object_id = h.current_obj#*/
  	    )
  	    SELECT 'TABLE', t.owner, t.table_name
  	      FROM dba_tab_statistics t, -- include fixed objects
  	           object o
  	     WHERE t.owner = o.owner
  	       AND t.table_name = o.name
  	     UNION
  	    SELECT 'TABLE', i.table_owner, i.table_name
  	      FROM dba_indexes i,
  	           object o
  	     WHERE i.owner = o.owner
  	       AND i.index_name = o.name)
  LOOP
    IF l_pair IS NULL THEN
      DBMS_LOB.WRITEAPPEND(:tables_list, 1, '(');
    ELSE
      DBMS_LOB.WRITEAPPEND(:tables_list, 1, ',');
    END IF;
    l_pair := '('''||i.owner||''','''||i.table_name||''')';
    -- SP2-0341: line overflow during variable substitution (>3000 characters at line 12)
    IF DBMS_LOB.GETLENGTH(:tables_list) < 2800 THEN 
      DBMS_LOB.WRITEAPPEND(:tables_list, LENGTH(l_pair), l_pair);
    ELSE
      EXIT;
    END IF; 
  END LOOP;
  IF l_pair IS NULL THEN
    l_pair := '((''DUMMY'',''DUMMY''))';
    DBMS_LOB.WRITEAPPEND(:tables_list, LENGTH(l_pair), l_pair);
  ELSE
    DBMS_LOB.WRITEAPPEND(:tables_list, 1, ')');
  END IF;
END;
/
SET LONG 2000000 LONGC 2000 LIN 32767;
COL tables_list NEW_V tables_list FOR A32767;
SET HEAD OFF;
PRO 
PRO (owner, table) list
PRO ~~~~~~~~~~~~~~~~~~~
SELECT :tables_list tables_list FROM DUAL;
SET HEAD ON;
PRO
PRO Tables Accessed 
PRO ~~~~~~~~~~~~~~~
COL table_name FOR A50;
SELECT owner||'.'||table_name table_name,
       partitioned,
       degree,
       temporary,
       blocks,
       num_rows,
       sample_size,
       TO_CHAR(last_analyzed, 'YYYY-MM-DD HH24:MI:SS') last_analyzed,
       global_stats,
       compression
  FROM dba_tables
 WHERE (owner, table_name) IN &&tables_list.
 ORDER BY
       owner,
       table_name
/
PRO
PRO Indexes 
PRO ~~~~~~~
COL table_and_index_name FOR A70;
COL degree FOR A6;
SELECT i.table_owner||'.'||i.table_name||' '||i.owner||'.'||i.index_name table_and_index_name,
       i.partitioned,
       i.degree,
       i.index_type,
       i.uniqueness,
       (SELECT COUNT(*) FROM dba_ind_columns ic WHERE ic.index_owner = i.owner AND ic.index_name = i.index_name) columns,
       i.status,
       &&is_10g.i.visibility,
       i.blevel,
       i.leaf_blocks,
       i.distinct_keys,
       i.clustering_factor,
       i.num_rows,
       i.sample_size,
       TO_CHAR(i.last_analyzed, 'YYYY-MM-DD HH24:MI:SS') last_analyzed,
       i.global_stats
  FROM dba_indexes i
 WHERE (i.table_owner, i.table_name) IN &&tables_list.
 ORDER BY
       i.table_owner,
       i.table_name,
       i.owner,
       i.index_name
/
-- compute low and high values for each table column
DELETE plan_table WHERE statement_id = 'low_high';
DECLARE
  l_low VARCHAR2(256);
  l_high VARCHAR2(256);
  FUNCTION compute_low_high (p_data_type IN VARCHAR2, p_raw_value IN RAW)
  RETURN VARCHAR2 AS
    l_number NUMBER;
    l_varchar2 VARCHAR2(256);
    l_date DATE;
  BEGIN
    IF p_data_type = 'NUMBER' THEN
      DBMS_STATS.convert_raw_value(p_raw_value, l_number);
      RETURN TO_CHAR(l_number);
    ELSIF p_data_type IN ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'CHAR2') THEN
      DBMS_STATS.convert_raw_value(p_raw_value, l_varchar2);
      RETURN l_varchar2;
    ELSIF SUBSTR(p_data_type, 1, 4) IN ('DATE', 'TIME') THEN
      DBMS_STATS.convert_raw_value(p_raw_value, l_date);
      RETURN TO_CHAR(l_date, 'YYYY-MM-DD HH24:MI:SS');
    ELSE
      RETURN RAWTOHEX(p_raw_value);
    END IF;
  END compute_low_high;
BEGIN
  FOR i IN (SELECT owner, table_name, column_name, data_type, low_value, high_value
              FROM dba_tab_cols
             WHERE (owner, table_name) IN &&tables_list.)
  LOOP
    l_low := compute_low_high(i.data_type, i.low_value);
    l_high := compute_low_high(i.data_type, i.high_value);
    INSERT INTO plan_table (statement_id, object_owner, object_name, other_tag, partition_start, partition_stop)
    VALUES ('low_high', i.owner, i.table_name, i.column_name, l_low, l_high);
  END LOOP;
END;
/
PRO
PRO Table Columns 
PRO ~~~~~~~~~~~~~
SET LONG 200 LONGC 20;
COL table_and_column_name FOR A70;
COL data_type FOR A20;
COL data_default FOR A20;
COL low_value FOR A32;
COL high_value FOR A32;
SELECT c.owner||'.'||c.table_name||' '||c.column_name table_and_column_name,
       c.data_type,
       c.nullable,
       c.data_default,
       c.num_distinct,
       NVL(p.partition_start, c.low_value) low_value,
       NVL(p.partition_stop, c.high_value) high_value,
       c.density,
       c.num_nulls,
       c.num_buckets,
       c.histogram,
       c.sample_size,
       TO_CHAR(c.last_analyzed, 'YYYY-MM-DD HH24:MI:SS') last_analyzed,
       c.global_stats,
       c.avg_col_len
  FROM dba_tab_cols c,
       plan_table p
 WHERE (c.owner, c.table_name) IN &&tables_list.
   AND p.statement_id(+) = 'low_high'
   AND p.object_owner(+) = c.owner
   AND p.object_name(+) = c.table_name
   AND p.other_tag(+) = c.column_name
 ORDER BY
       c.owner,
       c.table_name,
       c.column_name
/
PRO
PRO Index Columns 
PRO ~~~~~~~~~~~~~
COL index_and_column_name FOR A70;
SELECT i.index_owner||'.'||i.index_name||' '||c.column_name index_and_column_name,
       c.data_type,
       c.nullable,
       c.data_default,
       c.num_distinct,
       NVL(p.partition_start, c.low_value) low_value,
       NVL(p.partition_stop, c.high_value) high_value,
       c.density,
       c.num_nulls,
       c.num_buckets,
       c.histogram,
       c.sample_size,
       TO_CHAR(c.last_analyzed, 'YYYY-MM-DD HH24:MI:SS') last_analyzed,
       c.global_stats,
       c.avg_col_len
  FROM dba_ind_columns i,
       dba_tab_cols c,
       plan_table p
 WHERE (i.table_owner, i.table_name) IN &&tables_list.
   AND c.owner = i.table_owner
   AND c.table_name = i.table_name
   AND c.column_name = i.column_name
   AND p.statement_id(+) = 'low_high'
   AND p.object_owner(+) = c.owner
   AND p.object_name(+) = c.table_name
   AND p.other_tag(+) = c.column_name
 ORDER BY
       i.index_owner,
       i.index_name,
       i.column_position
/

-- PRO
-- PRO SNAPPER
-- PRO ~~~~~~~~~~~~~~~~~~~~~~
-- @snapper all 2 1 "select inst_id, sid from gv$session a where a.sql_id = '&&sql_id.'"

PRO 
PRO GV_SQL_MONITOR 
PRO ~~~~~~~~~~~~~~~~~~~~~~

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
col RGB format 9999999999
col sql_exec_id format 9999999999
col username format a15
col sql_text format a70
col sid format 9999
col rm_group format a10
select
        a.status,
        decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'N','Y') Offload,
        decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'Y','N') InMemPX,
        a.INST_ID inst,
        a.SID,
        b.EXECUTIONS exec,
        round(a.ELAPSED_TIME/1000000,2) ela_tm,
        round(a.CPU_TIME/1000000,2) cpu_tm,
        round(a.USER_IO_WAIT_TIME/1000000,2) io_tm,
        round((a.PHYSICAL_READ_BYTES/1024/1024)/NULLIF(nvl((a.ELAPSED_TIME/1000000),0),0),2) RMBs,
        round((a.PHYSICAL_WRITE_BYTES/1024/1024)/NULLIF(nvl((a.ELAPSED_TIME/1000000),0),0),2) WMBs,
        round((a.PHYSICAL_READ_BYTES/1024/1024/1024),2) RGB,
        substr (a.MODULE, 1,16) module,
 a.RM_CONSUMER_GROUP rm_group,  -- new in 11204
        a.SQL_ID,
        a.SQL_PLAN_HASH_VALUE PHV,
        a.sql_exec_id,
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
and a.SQL_ID = '&&sql_id.'
order by a.status, a.SQL_EXEC_START, a.SQL_EXEC_ID, a.PX_SERVERS_ALLOCATED, a.PX_SERVER_SET, a.PX_SERVER# asc
/

select
        a.status,
        decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'N','Y') Offload,
        decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'Y','N') InMemPX,
        a.INST_ID inst,
        a.SID,
        b.EXECUTIONS exec,
        round(a.ELAPSED_TIME/1000000,2) ela_tm,
        round(a.CPU_TIME/1000000,2) cpu_tm,
        round(a.USER_IO_WAIT_TIME/1000000,2) io_tm,
        round((a.PHYSICAL_READ_BYTES/1024/1024)/NULLIF(nvl((a.ELAPSED_TIME/1000000),0),0),2) RMBs,
        round((a.PHYSICAL_WRITE_BYTES/1024/1024)/NULLIF(nvl((a.ELAPSED_TIME/1000000),0),0),2) WMBs,
        round((a.PHYSICAL_READ_BYTES/1024/1024/1024),2) RGB,
        substr (a.MODULE, 1,16) module,
 a.RM_CONSUMER_GROUP rm_group,  -- new in 11204
        a.SQL_ID,
        a.SQL_PLAN_HASH_VALUE PHV,
        a.sql_exec_id,
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
and a.status in ('DONE','DONE (ALL ROWS)')
and a.SQL_ID = '&&sql_id.'
order by a.status, a.SQL_EXEC_START, a.SQL_EXEC_ID, a.PX_SERVERS_ALLOCATED, a.PX_SERVER_SET, a.PX_SERVER# asc
/

PRO 
PRO GV_SESSION
PRO ~~~~~~~~~~~~~~~~~~~~~~
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
col hours format 99999
col machine format a30
col osuser format a10
select a.inst_id inst, sid, username, substr(program,1,19) prog, b.sql_id, child_number child, plan_hash_value, executions execs,
(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
substr(event,1,20) event,
p1text,p1,p2text,p2,p3text,p3 ,
substr(sql_text,1,30) sql_text,
LAST_CALL_ET/60/60 hours,
decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,'No','Yes') Offload,
decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,0,100*(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES-b.IO_INTERCONNECT_BYTES)
/decode(b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES,0,1,b.IO_CELL_OFFLOAD_ELIGIBLE_BYTES)) "IO_SAVED_%", a.machine "machine", a.osuser osuser
from gv$session a, gv$sql b
where status = 'ACTIVE'
and username is not null
and a.sql_id = b.sql_id
and a.inst_id = b.inst_id
and a.sql_child_number = b.child_number
--and sql_text not like 'select a.inst_id inst, sid, substr(program,1,19) prog, b.sql_id, child_number child,%' -- don't show this query
--and sql_text not like 'declare%' -- skip PL/SQL blocks
and a.sql_id = '&&sql_id.'
order by hours desc, sql_id, child
..

-- spool off and cleanup
PRO
PRO planx_&&_xdbname-&&_instname-&&_xconname-&&sql_id._&&current_time..txt has been generated
SET FEED ON VER ON LIN 80 PAGES 14 LONG 80 LONGC 80 TRIMS OFF TERM ON;
SPO OFF;
UNDEF 1 2
-- end

