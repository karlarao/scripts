----------------------------------------------------------------------------------------
--
-- File name:   planx.sql
--
-- Purpose:     Reports Execution Plans for one SQL_ID from RAC and AWR(opt)
--
-- Author:      Carlos Sierra
--
-- Version:     2018/01/29
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
--
--              For a more robust tool use SQLd360
--             
---------------------------------------------------------------------------------------
--
CL COL;
SET FEED OFF VER OFF HEA ON LIN 2200 PAGES 50 TIMI OFF LONG 80000 LONGC 2000 TRIMS ON AUTOT OFF;
SET SERVEROUT OFF;

PRO
PRO 1. Enter Oracle Diagnostics Pack License Flag [ Y | N ] (required)
DEF input_license = '&1.';
PRO
PRO 2. Enter SQL_ID (required)
DEF sql_id = '&2.';
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
-- display adaptive plan
COL format_adaptive NEW_V format_adaptive
SELECT '+ADAPTIVE' format_adaptive FROM v$instance WHERE version >= '12.';

-- is_10g
DEF is_10g = '';
COL is_10g NEW_V is_10g NOPRI;
SELECT '--' is_10g FROM v$instance WHERE version LIKE '10%';
-- is_11g
DEF is_11g = '';
COL is_11g NEW_V is_11g NOPRI;
SELECT '--' is_11 FROM v$instance WHERE version LIKE '11%';
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
SELECT TO_CHAR(MIN(begin_interval_time), 'YYYY-MM-DD"T"HH24:MI:SS') x_minimum_date FROM dba_hist_snapshot WHERE :license = 'Y' AND snap_id = &&x_minimum_snap_id.;
COL x_maximum_date NEW_V x_maximum_date NOPRI;
SELECT TO_CHAR(MAX(end_interval_time), 'YYYY-MM-DD"T"HH24:MI:SS') x_maximum_date FROM dba_hist_snapshot WHERE :license = 'Y' AND snap_id = &&x_maximum_snap_id.;
-- get sql_text
VAR sql_id VARCHAR2(13);
EXEC :sql_id := '&&sql_id.';
VAR sql_text CLOB;
EXEC :sql_text := NULL;
VAR signature NUMBER;
VAR signaturef NUMBER;
BEGIN
  SELECT exact_matching_signature, sql_text INTO :signature, :sql_text FROM gv$sql WHERE sql_id = '&&sql_id.' AND ROWNUM = 1;
END;
/
BEGIN
  IF :sql_text IS NULL OR NVL(DBMS_LOB.GETLENGTH(:sql_text), 0) = 0 THEN
    SELECT sql_fulltext 
      INTO :sql_text
      FROM gv$sqlstats 
     WHERE sql_id = :sql_id 
       AND ROWNUM = 1;
  END IF;
END;
/
BEGIN
  IF :license = 'Y' AND (:sql_text IS NULL OR NVL(DBMS_LOB.GETLENGTH(:sql_text), 0) = 0) THEN
    SELECT sql_text
      INTO :sql_text
      FROM dba_hist_sqltext
     WHERE sql_id = :sql_id
       AND ROWNUM = 1;
  END IF;
END;
/
BEGIN
  IF :signature IS NULL THEN
    :signature := NVL(DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(:sql_text), -1);
  END IF;
END;
/
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
COL x_host_name NEW_V x_host_name;
SELECT host_name x_host_name FROM v$instance;
COL x_db_name NEW_V x_db_name;
SELECT name x_db_name FROM v$database;
COL x_container NEW_V x_container;
SELECT 'NONE' x_container FROM DUAL;
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') x_container FROM DUAL;
DEF sql_handle = '';
COL sql_handle NEW_V sql_handle;
SELECT sql_handle FROM dba_sql_plan_baselines WHERE signature = &&signature. AND ROWNUM = 1;
COLUMN instname NEW_VALUE x_instname NOPRINT
select instance_name instname from v$instance;

-- spool and sql_text
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt;

PRO SQL_ID: &&sql_id.
PRO SIGNATURE: &&signature.
PRO SIGNATUREF: &&signaturef.
PRO SQL_HANDLE: &&sql_handle.
PRO HOST: &&x_host_name.
PRO DATABASE: &&x_db_name.
PRO INSTANCE NAME: &&x_instname.
PRO PDB NAME: &&x_container.
PRO
SET PAGES 0;
PRINT :sql_text;
SET PAGES 50;
-- columns funky format
COL action_ff                       FOR A30 HEA "Action";
COL appl_wait_secs_ff               FOR A18 HEA "Appl wait secs";
COL begin_interval_time_ff          FOR A20 HEA "Begin interval time";
COL buffer_gets_ff                  FOR A20 HEA "Buffer Gets";
COL cluster_wait_secs_ff            FOR A18 HEA "Cluster wait secs";
COL conc_wait_secs_ff               FOR A18 HEA "Conc wait secs";
COL cpu_secs_ff                     FOR A18 HEA "CPU secs";
COL current_object_ff               FOR A60 HEA "Current object";
COL direct_writes_ff                FOR A20 HEA "Direct Writes";
COL disk_reads_ff                   FOR A20 HEA "Disk Reads";
COL elsapsed_secs_ff                FOR A18 HEA "Elapsed secs";
COL end_interval_time_ff            FOR A20 HEA "End interval time";
COL executions_ff                   FOR A20 HEA "Executions";
COL fetches_ff                      FOR A20 HEA "Fetches";
COL first_load_time_ff              FOR A20 HEA "First load time";
COL inst_child_ff                   FOR A21 HEA "Inst child";
COL invalidations_ff                FOR A8  HEA "Invalidations";
COL io_cell_offload_eligible_b_ff   FOR A30 HEA "IO cell offload eligible bytes";
COL io_cell_offload_returned_b_ff   FOR A30 HEA "IO cell offload returned bytes";
COL io_cell_uncompressed_bytes_ff   FOR A30 HEA "IO cell uncompressed bytes";
COL io_interconnect_bytes_ff        FOR A30 HEA "IO interconnect bytes";
COL io_saved_ff                     FOR A10 HEA "IO saved";
COL java_exec_secs_ff               FOR A18 HEA "Java exec secs";
COL last_active_time_ff             FOR A20 HEA "Last active time";
COL last_load_time_ff               FOR A20 HEA "Last load time";
COL line_id_ff                      FOR 9999999 HEA "Line id";
COL loaded_ff                       FOR A6  HEA "Loaded";
COL loaded_versions_ff              FOR A15 HEA "Loaded versions";
COL loads_ff                        FOR A8  HEA "Loads";
COL module_ff                       FOR A30 HEA "Module";
COL open_versions_ff                FOR A15 HEA "Open versions";
COL operation_ff                    FOR A50 HEA "Operation";
COL parse_calls_ff                  FOR A20 HEA "Parse calls";
COL percent_ff                      FOR 9,990.0 HEA "Percent";
COL persistent_mem_ff               FOR A20 HEA "Persistent mem";
COL plan_timestamp_ff               FOR A19 HEA "Plan timestamp";
COL plsql_exec_secs_ff              FOR A18 HEA "PLSQL exec secs";
COL px_servers_executions_ff        FOR A20 HEA "PX servers executions";
COL rows_processed_ff               FOR A20 HEA "Rows processed";
COL runtime_mem_ff                  FOR A20 HEA "Runtime mem";
COL samples_ff                      FOR 999,999,999,999 HEA "Samples";
COL service_ff                      FOR A30 HEA "Service";
COL sharable_mem_ff                 FOR A20 HEA "Sharable mem";
COL sorts_ff                        FOR A20 HEA "Sorts";
COL sql_profile_ff                  FOR A30 HEA "SQL Profile";
COL timed_event_ff                  FOR A70 HEA "Timed event";
COL total_sharable_mem_ff           FOR A20 HEA "Total sharable mem";
COL user_io_wait_secs_ff            FOR A18 HEA "User IO wait secs";
COL users_executing_ff              FOR A15 HEA "Users executing";
COL users_opening_ff                FOR A15 HEA "Users opening";
COL version_count_ff                FOR A8  HEA "Version count";

COL obsl FOR A4;
COL sens FOR A4;
COL aware FOR A5;
COL shar FOR A4;
COL u_exec FOR 999999;
COL obj_sta FOR A7;

COL plan_name FOR A30;
COL created FOR A30;
COL last_executed FOR A30;

COL avg_et_ms_awr FOR A11 HEA 'ET Avg|AWR (ms)';
COL avg_et_ms_mem FOR A11 HEA 'ET Avg|MEM (ms)';
COL avg_cpu_ms_awr FOR A11 HEA 'CPU Avg|AWR (ms)';
COL avg_cpu_ms_mem FOR A11 HEA 'CPU Avg|MEM (ms)';
COL avg_bg_awr FOR 999,999,990 HEA 'BG Avg|AWR';
COL avg_bg_mem FOR 999,999,990 HEA 'BG Avg|MEM';
COL avg_row_awr FOR 999,999,990 HEA 'Rows Avg|AWR';
COL avg_row_mem FOR 999,999,990 HEA 'Rows Avg|MEM';
COL plan_hash_value FOR 9999999999 HEA 'Plan|Hash Value';
COL executions_awr FOR 999,999,999,999 HEA 'Executions|AWR';
COL executions_mem FOR 999,999,999,999 HEA 'Executions|MEM';
COL min_cost FOR 9,999,999 HEA 'MIN Cost';
COL max_cost FOR 9,999,999 HEA 'MAX Cost';
COL nl FOR 99;
COL hj FOR 99;
COL mj FOR 99;
COL p100_et_ms FOR A11 HEA 'ET 100th|Pctl (ms)';
COL p99_et_ms FOR A11 HEA 'ET 99th|Pctl (ms)';
COL p97_et_ms FOR A11 HEA 'ET 97th|Pctl (ms)';
COL p95_et_ms FOR A11 HEA 'ET 95th|Pctl (ms)';
COL p100_cpu_ms FOR A11 HEA 'CPU 100th|Pctl (ms)';
COL p99_cpu_ms FOR A11 HEA 'CPU 99th|Pctl (ms)';
COL p97_cpu_ms FOR A11 HEA 'CPU 97th|Pctl (ms)';
COL p95_cpu_ms FOR A11 HEA 'CPU 95th|Pctl (ms)';

PRO
PRO PLANS PERFORMANCE
PRO ~~~~~~~~~~~~~~~~~
WITH
pm AS (
SELECT plan_hash_value, operation,
       CASE operation WHEN 'NESTED LOOPS' THEN COUNT(DISTINCT id) ELSE 0 END nl,
       CASE operation WHEN 'HASH JOIN' THEN COUNT(DISTINCT id) ELSE 0 END hj,
       CASE operation WHEN 'MERGE JOIN' THEN COUNT(DISTINCT id) ELSE 0 END mj
  FROM gv$sql_plan
 WHERE sql_id = TRIM('&&sql_id.')
 GROUP BY
       plan_hash_value,
       operation ),
pa AS (
SELECT plan_hash_value, operation,
       CASE operation WHEN 'NESTED LOOPS' THEN COUNT(DISTINCT id) ELSE 0 END nl,
       CASE operation WHEN 'HASH JOIN' THEN COUNT(DISTINCT id) ELSE 0 END hj,
       CASE operation WHEN 'MERGE JOIN' THEN COUNT(DISTINCT id) ELSE 0 END mj
  FROM dba_hist_sql_plan
 WHERE sql_id = TRIM('&&sql_id.')
   AND :license = 'Y'
 GROUP BY
       plan_hash_value,
       operation ),
pm_pa AS (
SELECT plan_hash_value, MAX(nl) nl, MAX(hj) hj, MAX(mj) mj
  FROM pm
 GROUP BY
       plan_hash_value
 UNION
SELECT plan_hash_value, MAX(nl) nl, MAX(hj) hj, MAX(mj) mj
  FROM pa
 GROUP BY
       plan_hash_value ),
p AS (
SELECT plan_hash_value, MAX(nl) nl, MAX(hj) hj, MAX(mj) mj
  FROM pm_pa
 GROUP BY
       plan_hash_value ),
phv_perf AS (       
SELECT plan_hash_value,
       snap_id,
       SUM(elapsed_time_delta)/SUM(executions_delta) avg_et_us,
       SUM(cpu_time_delta)/SUM(executions_delta) avg_cpu_us
  FROM dba_hist_sqlstat
 WHERE sql_id = TRIM('&&sql_id.')
   AND executions_delta > 0
   AND optimizer_cost > 0
   AND :license = 'Y'
 GROUP BY
       plan_hash_value,
       snap_id ),
phv_stats AS (
SELECT plan_hash_value,
       MAX(avg_et_us) p100_et_us,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY avg_et_us) p99_et_us,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY avg_et_us) p97_et_us,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY avg_et_us) p95_et_us,
       MAX(avg_cpu_us) p100_cpu_us,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY avg_cpu_us) p99_cpu_us,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY avg_cpu_us) p97_cpu_us,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY avg_cpu_us) p95_cpu_us
  FROM phv_perf
 GROUP BY
       plan_hash_value ),
m AS (
SELECT plan_hash_value,
       SUM(elapsed_time)/SUM(executions) avg_et_us,
       SUM(cpu_time)/SUM(executions) avg_cpu_us,
       ROUND(SUM(buffer_gets)/SUM(executions)) avg_buffer_gets,
       ROUND(SUM(rows_processed)/SUM(executions)) avg_rows_processed,
       SUM(executions) executions,
       MIN(optimizer_cost) min_cost,
       MAX(optimizer_cost) max_cost
  FROM gv$sql
 WHERE sql_id = TRIM('&&sql_id.')
   AND executions > 0
   AND optimizer_cost > 0
 GROUP BY
       plan_hash_value ),
a AS (
SELECT plan_hash_value,
       SUM(elapsed_time_delta)/SUM(executions_delta) avg_et_us,
       SUM(cpu_time_delta)/SUM(executions_delta) avg_cpu_us,
       ROUND(SUM(buffer_gets_delta)/SUM(executions_delta)) avg_buffer_gets,
       ROUND(SUM(rows_processed_delta)/SUM(executions_delta)) avg_rows_processed,
       SUM(executions_delta) executions,
       MIN(optimizer_cost) min_cost,
       MAX(optimizer_cost) max_cost
  FROM dba_hist_sqlstat
 WHERE sql_id = TRIM('&&sql_id.')
   AND executions_delta > 0
   AND optimizer_cost > 0
   AND :license = 'Y'
 GROUP BY
       plan_hash_value )
SELECT 
       p.plan_hash_value,
       LPAD(TRIM(TO_CHAR(ROUND(a.avg_et_us/1e3, 6), '9999,990.000')), 11) avg_et_ms_awr,
       LPAD(TRIM(TO_CHAR(ROUND(m.avg_et_us/1e3, 6), '9999,990.000')), 11) avg_et_ms_mem,
       LPAD(TRIM(TO_CHAR(ROUND(a.avg_cpu_us/1e3, 6), '9999,990.000')), 11) avg_cpu_ms_awr,
       LPAD(TRIM(TO_CHAR(ROUND(m.avg_cpu_us/1e3, 6), '9999,990.000')), 11) avg_cpu_ms_mem,
       a.avg_buffer_gets avg_bg_awr,
       m.avg_buffer_gets avg_bg_mem,
       a.avg_rows_processed avg_row_awr,
       m.avg_rows_processed avg_row_mem,
       a.executions executions_awr,
       m.executions executions_mem,
       LEAST(NVL(m.min_cost, a.min_cost), NVL(a.min_cost, m.min_cost)) min_cost,
       GREATEST(NVL(m.max_cost, a.max_cost), NVL(a.max_cost, m.max_cost)) max_cost,
       p.nl,
       p.hj,
       p.mj,
       LPAD(TRIM(TO_CHAR(ROUND(s.p100_et_us/1e3, 6), '9999,990.000')), 11) p100_et_ms,
       LPAD(TRIM(TO_CHAR(ROUND(s.p99_et_us/1e3, 6), '9999,990.000')), 11) p99_et_ms,
       LPAD(TRIM(TO_CHAR(ROUND(s.p97_et_us/1e3, 6), '9999,990.000')), 11) p97_et_ms,
       LPAD(TRIM(TO_CHAR(ROUND(s.p95_et_us/1e3, 6), '9999,990.000')), 11) p95_et_ms,
       LPAD(TRIM(TO_CHAR(ROUND(s.p100_cpu_us/1e3, 6), '9999,990.000')), 11) p100_cpu_ms,
       LPAD(TRIM(TO_CHAR(ROUND(s.p99_cpu_us/1e3, 6), '9999,990.000')), 11) p99_cpu_ms,
       LPAD(TRIM(TO_CHAR(ROUND(s.p97_cpu_us/1e3, 6), '9999,990.000')), 11) p97_cpu_ms,
       LPAD(TRIM(TO_CHAR(ROUND(s.p95_cpu_us/1e3, 6), '9999,990.000')), 11) p95_cpu_ms
  FROM p, m, a, phv_stats s
 WHERE p.plan_hash_value = m.plan_hash_value(+)
   AND p.plan_hash_value = a.plan_hash_value(+)
   AND p.plan_hash_value = s.plan_hash_value(+)
 ORDER BY
       NVL(a.avg_et_us, m.avg_et_us), m.avg_et_us;

PRO
PRO GV$SQLSTATS (it shows only one row for SQL, with most recent info)
PRO ~~~~~~~~~~~
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT   inst_id
       , plan_hash_value
       , LPAD(TO_CHAR(parse_calls, '999,999,999,999,990'), 20) parse_calls_ff
       , LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions_ff
       , LPAD(TO_CHAR(px_servers_executions, '999,999,999,999,990'), 20) px_servers_executions_ff
       , LPAD(TO_CHAR(fetches, '999,999,999,999,990'), 20) fetches_ff
       , LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed_ff
       , LPAD(TO_CHAR(version_count, '999,990'), 8) version_count_ff
       , LPAD(TO_CHAR(loads, '999,990'), 8) loads_ff
       , LPAD(TO_CHAR(invalidations, '999,990'), 8) invalidations_ff
       , LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets_ff
       , LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads_ff
       , LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes_ff
       , LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elsapsed_secs_ff
       , LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs_ff
       , LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs_ff
       , LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs_ff
       , LPAD(TO_CHAR(sorts, '999,999,999,999,990'), 20) sorts_ff
       , LPAD(TO_CHAR(sharable_mem, '999,999,999,999,990'), 20) sharable_mem_ff
       , LPAD(TO_CHAR(total_sharable_mem, '999,999,999,999,990'), 20) total_sharable_mem_ff
       , LPAD(TO_CHAR(last_active_time, 'YYYY-MM-DD"T"HH24:MI:SS'), 20) last_active_time_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_b_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(io_cell_uncompressed_bytes, '999,999,999,999,999,999,990'), 30) io_cell_uncompressed_bytes_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(io_cell_offload_returned_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_returned_b_ff
       &&is_10g.&&is_11r1., LPAD(CASE WHEN io_cell_offload_eligible_bytes > io_cell_offload_returned_bytes AND io_cell_offload_eligible_bytes > 0 THEN LPAD(TO_CHAR(ROUND((io_cell_offload_eligible_bytes - io_cell_offload_returned_bytes) * 100 / io_cell_offload_eligible_bytes, 2), '990.00')||' %', 9) END, 10) io_saved_ff
  FROM gv$sqlstats
 WHERE sql_id = :sql_id
 ORDER BY inst_id
/

BREAK ON inst_id SKIP PAGE ON obj_sta SKIP PAGE ON obsl SKIP PAGE ON shar SKIP PAGE;
PRO
PRO GV$SQL (ordered by inst_id, object_status, is_obsolete, is_shareable, last_active_time and child_number)
PRO ~~~~~~
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT   inst_id
       , SUBSTR(object_status, 1, 7) obj_sta
       , is_obsolete obsl
       , is_shareable shar
       , LPAD(TO_CHAR(last_active_time, 'YYYY-MM-DD"T"HH24:MI:SS'), 20) last_active_time_ff
       , child_number
       , plan_hash_value
       , LPAD(TO_CHAR(parse_calls, '999,999,999,999,990'), 20) parse_calls_ff
       , LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions_ff
       , LPAD(TO_CHAR(px_servers_executions, '999,999,999,999,990'), 20) px_servers_executions_ff
       , LPAD(TO_CHAR(fetches, '999,999,999,999,990'), 20) fetches_ff
       , LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed_ff
       , LPAD(TO_CHAR(loaded_versions, '999,999,990'), 15) loaded_versions_ff
       , LPAD(TO_CHAR(open_versions, '999,999,990'), 15) open_versions_ff
       , LPAD(TO_CHAR(users_opening, '999,999,990'), 15) users_opening_ff
       , LPAD(TO_CHAR(users_executing, '999,999,990'), 15) users_executing_ff
       , LPAD(TO_CHAR(loads, '999,990'), 8) loads_ff
       , LPAD(TO_CHAR(invalidations, '999,990'), 8) invalidations_ff
       , LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets_ff
       , LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads_ff
       , LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes_ff
       , LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elsapsed_secs_ff
       , LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs_ff
       , LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs_ff
       , LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs_ff
       , LPAD(TO_CHAR(sorts, '999,999,999,999,990'), 20) sorts_ff
       , LPAD(TO_CHAR(sharable_mem, '999,999,999,999,990'), 20) sharable_mem_ff
       , LPAD(TO_CHAR(persistent_mem, '999,999,999,999,990'), 20) persistent_mem_ff
       , LPAD(TO_CHAR(runtime_mem, '999,999,999,999,990'), 20) runtime_mem_ff
       , LPAD(first_load_time, 20) first_load_time_ff
       , LPAD(last_load_time, 20) last_load_time_ff
       , optimizer_cost
       , optimizer_env_hash_value
       , parsing_schema_name
       , service service_ff
       , module module_ff
       , action action_ff
       , sql_profile sql_profile_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_b_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(io_cell_uncompressed_bytes, '999,999,999,999,999,999,990'), 30) io_cell_uncompressed_bytes_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(io_cell_offload_returned_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_returned_b_ff
       &&is_10g.&&is_11r1., LPAD(CASE WHEN io_cell_offload_eligible_bytes > io_cell_offload_returned_bytes AND io_cell_offload_eligible_bytes > 0 THEN LPAD(TO_CHAR(ROUND((io_cell_offload_eligible_bytes - io_cell_offload_returned_bytes) * 100 / io_cell_offload_eligible_bytes, 2), '990.00')||' %', 9) END, 10) io_saved_ff
  FROM gv$sql
 WHERE sql_id = :sql_id
 ORDER BY inst_id
       , SUBSTR(object_status, 1, 7) DESC
       , is_obsolete
       , is_shareable DESC
       , last_active_time DESC
       , child_number DESC
/
CLEAR BREAKS;

PRO
PRO GV$SQL (grouped by PHV and ordered by et_secs_per_exec)
PRO ~~~~~~
SELECT   plan_hash_value
       , TO_CHAR(ROUND(SUM(elapsed_time)/SUM(executions)/1e6,6), '999,990.000000') et_secs_per_exec
       , TO_CHAR(ROUND(SUM(cpu_time)/SUM(executions)/1e6,6), '999,990.000000') cpu_secs_per_exec
       , SUM(executions) executions
       --, TO_CHAR(ROUND(SUM(elapsed_time)/1e6,6), '999,999,999,990') et_secs_tot
       --, TO_CHAR(ROUND(SUM(cpu_time)/1e6,6), '999,999,999,990') cpu_secs_tot
       , COUNT(DISTINCT child_number) cursors
       , MAX(child_number) max_child
       , SUM(CASE is_bind_sensitive WHEN 'Y' THEN 1 ELSE 0 END) bind_send
       , SUM(CASE is_bind_aware WHEN 'Y' THEN 1 ELSE 0 END) bind_aware
       , SUM(CASE is_shareable WHEN 'Y' THEN 1 ELSE 0 END) shareable
       , SUM(CASE object_status WHEN 'VALID' THEN 1 ELSE 0 END) valid
       , SUM(CASE object_status WHEN 'INVALID_UNAUTH' THEN 1 ELSE 0 END) invalid     
       , TO_CHAR(MAX(last_active_time), 'YYYY-MM-DD"T"HH24:MI:SS') last_active_time
       , ROUND(SUM(buffer_gets)/SUM(executions)) buffers_per_exec
       , TO_CHAR(ROUND(SUM(rows_processed)/SUM(executions), 3), '999,999,999,990.000') rows_per_exec
  FROM gv$sql
 WHERE sql_id = :sql_id
   AND executions > 0
 GROUP BY
       plan_hash_value
 ORDER BY
       2
/

BREAK ON inst_id SKIP PAGE ON obj_sta SKIP PAGE ON obsl SKIP PAGE ON shar SKIP PAGE;
PRO
PRO GV$SQL (ordered by inst_id, object_status, is_obsolete, is_shareable, last_active_time and child_number)
PRO ~~~~~~
SELECT   inst_id
       , SUBSTR(object_status, 1, 7) obj_sta
       , is_obsolete obsl
       , is_shareable shar
       , LPAD(TO_CHAR(last_active_time, 'YYYY-MM-DD"T"HH24:MI:SS'), 20) last_active_time_ff
       , child_number
       , plan_hash_value
       , is_bind_sensitive sens
       , is_bind_aware aware
       , users_executing u_exec
       , TO_CHAR(ROUND(elapsed_time/executions/1e6,6), '999,990.000000') et_secs_per_exec
       , TO_CHAR(ROUND(cpu_time/executions/1e6,6), '999,990.000000') cpu_secs_per_exec
       , executions
       , TO_CHAR(ROUND(elapsed_time/1e6,6), '999,999,999,990') et_secs_tot
       , TO_CHAR(ROUND(cpu_time/1e6,6), '999,999,999,990') cpu_secs_tot
       , TO_CHAR(last_active_time, 'YYYY-MM-DD"T"HH24:MI:SS') last_active_time
       , ROUND(buffer_gets/executions) buffers_per_exec
       , TO_CHAR(ROUND(rows_processed/executions, 3), '999,999,999,990.000') rows_per_exec
  FROM gv$sql
 WHERE sql_id = :sql_id
   AND executions > 0
 ORDER BY inst_id
       , SUBSTR(object_status, 1, 7) DESC
       , is_obsolete
       , is_shareable DESC
       , last_active_time DESC
       , child_number DESC
/
CLEAR BREAKS;

BREAK ON inst_id SKIP PAGE ON obj_sta SKIP PAGE ON obsl SKIP PAGE ON shar SKIP PAGE;
PRO
PRO GV$SQL (ordered by inst_id, object_status, is_obsolete, is_shareable, last_active_time and child_number)
PRO ~~~~~~
SELECT   inst_id
       , SUBSTR(object_status, 1, 7) obj_sta
       , is_obsolete obsl
       , is_shareable shar
       , LPAD(TO_CHAR(last_active_time, 'YYYY-MM-DD"T"HH24:MI:SS'), 20) last_active_time_ff
       , child_number
       , plan_hash_value
       &&is_10g., sql_plan_baseline
       , sql_profile
       &&is_10g., sql_patch
  FROM gv$sql
 WHERE sql_id = :sql_id
   AND executions > 0
 ORDER BY inst_id
       , SUBSTR(object_status, 1, 7) DESC
       , is_obsolete
       , is_shareable DESC
       , last_active_time DESC
       , child_number DESC
/
CLEAR BREAKS;

PRO       
--PRO GV$SQL_PLAN_STATISTICS_ALL LAST (ordered by inst_id and child_number)
PRO GV$SQL_PLAN_STATISTICS_ALL LAST (ordered by child_number)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
--BREAK ON inst_child_ff SKIP 2;
SET PAGES 0;
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
/*
WITH v AS (
SELECT /*+ MATERIALIZE * /
       DISTINCT sql_id, inst_id, child_number
  FROM gv$sql
 WHERE sql_id = :sql_id
   AND loaded_versions > 0
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) * /
       RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child_ff, 
       t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 
       'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
/
*/
SELECT plan_table_output FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(:sql_id, NULL, 'ADVANCED ALLSTATS LAST &&format_adaptive'));

PRO
PRO DBA_HIST_SQLSTAT DELTA (ordered by snap_id DESC, instance_number and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SET PAGES 50;
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT   s.snap_id
       , TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD"T"HH24:MI:SS') begin_interval_time_ff
       , TO_CHAR(s.end_interval_time, 'YYYY-MM-DD"T"HH24:MI:SS') end_interval_time_ff
       , s.instance_number
       , h.plan_hash_value
       , DECODE(h.loaded_versions, 1, 'Y', 'N') loaded_ff
       , LPAD(TO_CHAR(h.version_count, '999,990'), 8) version_count_ff
       , LPAD(TO_CHAR(h.parse_calls_delta, '999,999,999,999,990'), 20) parse_calls_ff
       , LPAD(TO_CHAR(h.executions_delta, '999,999,999,999,990'), 20) executions_ff
       , LPAD(TO_CHAR(h.rows_processed_delta, '999,999,999,999,990'), 20) rows_processed_ff
       , LPAD(TO_CHAR(h.loads_delta, '999,990'), 8) loads_ff
       , LPAD(TO_CHAR(h.invalidations_delta, '999,990'), 8) invalidations_ff
       , LPAD(TO_CHAR(h.buffer_gets_delta, '999,999,999,999,990'), 20) buffer_gets_ff
       , LPAD(TO_CHAR(h.disk_reads_delta, '999,999,999,999,990'), 20) disk_reads_ff
       , LPAD(TO_CHAR(h.direct_writes_delta, '999,999,999,999,990'), 20) direct_writes_ff
       , LPAD(TO_CHAR(ROUND(h.elapsed_time_delta/1e6, 3), '999,999,990.000'), 18) elsapsed_secs_ff
       , LPAD(TO_CHAR(ROUND(h.cpu_time_delta/1e6, 3), '999,999,990.000'), 18) cpu_secs_ff
       , LPAD(TO_CHAR(ROUND(h.iowait_delta/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(h.clwait_delta/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(h.apwait_delta/1e6, 3), '999,999,990.000'), 18) appl_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(h.ccwait_delta/1e6, 3), '999,999,990.000'), 18) conc_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(h.plsexec_time_delta/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs_ff
       , LPAD(TO_CHAR(ROUND(h.javexec_time_delta/1e6, 3), '999,999,990.000'), 18) java_exec_secs_ff
       , LPAD(TO_CHAR(h.sorts_delta, '999,999,999,999,990'), 20) sorts_ff
       , LPAD(TO_CHAR(h.sharable_mem, '999,999,999,999,990'), 20) sharable_mem_ff
       , h.optimizer_cost
       , h.optimizer_env_hash_value
       , h.parsing_schema_name
       , h.module module_ff
       , h.action action_ff
       , h.sql_profile sql_profile_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(h.io_offload_elig_bytes_delta, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_b_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(h.io_interconnect_bytes_delta, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(h.cell_uncompressed_bytes_delta, '999,999,999,999,999,999,990'), 30) io_cell_uncompressed_bytes_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(h.io_offload_return_bytes_delta, '999,999,999,999,999,999,990'), 30) io_cell_offload_returned_b_ff
       &&is_10g.&&is_11r1., LPAD(CASE WHEN h.io_offload_elig_bytes_delta > h.io_offload_return_bytes_delta AND h.io_offload_elig_bytes_delta > 0 THEN LPAD(TO_CHAR(ROUND((h.io_offload_elig_bytes_delta - h.io_offload_return_bytes_delta) * 100 / h.io_offload_elig_bytes_delta, 2), '990.00')||' %', 9) END, 10) io_saved_ff
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license = 'Y'
   AND h.dbid = :dbid
   AND h.sql_id = :sql_id
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 ORDER BY 1 DESC, 4, 5
/

PRO
PRO DBA_HIST_SQLSTAT TOTAL (ordered by snap_id DESC, instance_number and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT   s.snap_id
       , TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD"T"HH24:MI:SS') begin_interval_time_ff
       , TO_CHAR(s.end_interval_time, 'YYYY-MM-DD"T"HH24:MI:SS') end_interval_time_ff
       , s.instance_number
       , h.plan_hash_value
       , DECODE(h.loaded_versions, 1, 'Y', 'N') loaded_ff
       , LPAD(TO_CHAR(h.version_count, '999,990'), 8) version_count_ff
       , LPAD(TO_CHAR(h.parse_calls_total, '999,999,999,999,990'), 20) parse_calls_ff
       , LPAD(TO_CHAR(h.executions_total, '999,999,999,999,990'), 20) executions_ff
       , LPAD(TO_CHAR(h.rows_processed_total, '999,999,999,999,990'), 20) rows_processed_ff
       , LPAD(TO_CHAR(h.loads_total, '999,990'), 8) loads_ff
       , LPAD(TO_CHAR(h.invalidations_total, '999,990'), 8) invalidations_ff
       , LPAD(TO_CHAR(h.buffer_gets_total, '999,999,999,999,990'), 20) buffer_gets_ff
       , LPAD(TO_CHAR(h.disk_reads_total, '999,999,999,999,990'), 20) disk_reads_ff
       , LPAD(TO_CHAR(h.direct_writes_total, '999,999,999,999,990'), 20) direct_writes_ff
       , LPAD(TO_CHAR(ROUND(h.elapsed_time_total/1e6, 3), '999,999,990.000'), 18) elsapsed_secs_ff
       , LPAD(TO_CHAR(ROUND(h.cpu_time_total/1e6, 3), '999,999,990.000'), 18) cpu_secs_ff
       , LPAD(TO_CHAR(ROUND(h.iowait_total/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(h.clwait_total/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(h.apwait_total/1e6, 3), '999,999,990.000'), 18) appl_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(h.ccwait_total/1e6, 3), '999,999,990.000'), 18) conc_wait_secs_ff
       , LPAD(TO_CHAR(ROUND(h.plsexec_time_total/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs_ff
       , LPAD(TO_CHAR(ROUND(h.javexec_time_total/1e6, 3), '999,999,990.000'), 18) java_exec_secs_ff
       , LPAD(TO_CHAR(h.sorts_total, '999,999,999,999,990'), 20) sorts_ff
       , LPAD(TO_CHAR(h.sharable_mem, '999,999,999,999,990'), 20) sharable_mem_ff
       , h.optimizer_cost
       , h.optimizer_env_hash_value
       , h.parsing_schema_name
       , h.module module_ff
       , h.action action_ff
       , h.sql_profile sql_profile_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(h.io_offload_elig_bytes_total, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_b_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(h.io_interconnect_bytes_total, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(h.cell_uncompressed_bytes_total, '999,999,999,999,999,999,990'), 30) io_cell_uncompressed_bytes_ff
       &&is_10g.&&is_11r1., LPAD(TO_CHAR(h.io_offload_return_bytes_total, '999,999,999,999,999,999,990'), 30) io_cell_offload_returned_b_ff
       &&is_10g.&&is_11r1., LPAD(CASE WHEN h.io_offload_elig_bytes_total > h.io_offload_return_bytes_total AND h.io_offload_elig_bytes_total > 0 THEN LPAD(TO_CHAR(ROUND((h.io_offload_elig_bytes_total - h.io_offload_return_bytes_total) * 100 / h.io_offload_elig_bytes_total, 2), '990.00')||' %', 9) END, 10) io_saved_ff
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license = 'Y'
   AND h.dbid = :dbid
   AND h.sql_id = :sql_id
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 ORDER BY 1 DESC, 4, 5
/

PRO
PRO DBA_HIST_SQLSTAT DELTA (ordered by et_secs_per_exec)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SELECT   plan_hash_value
       , TO_CHAR(ROUND(SUM(elapsed_time_delta)/SUM(executions_delta)/1e6,6), '999,990.000000') et_secs_per_exec
       , TO_CHAR(ROUND(SUM(cpu_time_delta)/SUM(executions_delta)/1e6,6), '999,990.000000') cpu_secs_per_exec
       , SUM(executions_delta) executions
       , TO_CHAR(ROUND(SUM(elapsed_time_delta)/1e6,6), '999,999,999,990') et_secs_tot
       , TO_CHAR(ROUND(SUM(cpu_time_delta)/1e6,6), '999,999,999,990') cpu_secs_tot
       , ROUND(SUM(buffer_gets_delta)/SUM(executions_delta)) buffers_per_exec
       , TO_CHAR(ROUND(SUM(rows_processed_delta)/SUM(executions_delta), 3), '999,999,999,990.000') rows_per_exec
  FROM dba_hist_sqlstat
 WHERE :license = 'Y'
   AND sql_id = :sql_id
   AND executions_delta > 0
 GROUP BY
       plan_hash_value
 ORDER BY
       2
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
BREAK ON plan_timestamp_ff SKIP 2;
SET PAGES 0;
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
WITH v AS (
SELECT /*+ MATERIALIZE */ 
       DISTINCT sql_id, plan_hash_value, dbid, timestamp
  FROM dba_hist_sql_plan 
 WHERE :license = 'Y'
   AND dbid = :dbid 
   AND sql_id = :sql_id
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */ 
       TO_CHAR(v.timestamp, 'YYYY-MM-DD"T"HH24:MI:SS') plan_timestamp_ff,
       t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED &&format_adaptive')) t
/  
CLEAR BREAK;

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
PRO GV$ACTIVE_SESSION_HISTORY 
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_slices = '10';
SET PAGES 50;
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
WITH
events AS (
SELECT /*+ MATERIALIZE */
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE :license = 'Y'
   AND sql_id = :sql_id
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
SELECT e.samples samples_ff,
       ROUND(100 * e.samples / t.samples, 1) percent_ff,
       e.timed_event timed_event_ff
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT others samples_ff,
       ROUND(100 * others / samples, 1) percent_ff,
       'Others' timed_event_ff
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
/

PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (past 7 days by timed event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_days = '7';
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
WITH
events AS (
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h
 WHERE :license = 'Y'
   AND h.dbid = :dbid 
   AND h.sql_id = :sql_id
   AND h.snap_id BETWEEN &&x_minimum_snap_id. AND &&x_maximum_snap_id.
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
SELECT e.samples samples_ff,
       ROUND(100 * e.samples / t.samples, 1) percent_ff,
       e.timed_event timed_event_ff
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT others samples_ff,
       ROUND(100 * others / samples, 1) percent_ff,
       'Others' timed_event_ff
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
/

PRO
PRO AWR History range considered: from &&x_minimum_date. to &&x_maximum_date.
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (past 31 days by timed event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_days = '31';
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
/

PRO
PRO GV$ACTIVE_SESSION_HISTORY 
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_slices = '15';
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
WITH
events AS (
SELECT /*+ MATERIALIZE */
       h.sql_plan_hash_value plan_hash_value,
       NVL(h.sql_plan_line_id, 0) line_id_ff,
       SUBSTR(h.sql_plan_operation||' '||h.sql_plan_options, 1, 50) operation_ff,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE :license = 'Y'
   AND sql_id = :sql_id
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
SELECT e.samples samples_ff,
       ROUND(100 * e.samples / t.samples, 1) percent_ff,
       e.plan_hash_value,
       e.line_id_ff,
       e.operation_ff,
       e.timed_event timed_event_ff
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT others samples_ff,
       ROUND(100 * others / samples, 1) percent_ff,
       TO_NUMBER(NULL) plan_hash_value, 
       TO_NUMBER(NULL) id, 
       NULL operation_ff, 
       'Others' timed_event_ff
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
/

PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (past 7 days by plan line and timed event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_days = '7';
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
WITH
events AS (
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       h.sql_plan_hash_value plan_hash_value,
       NVL(h.sql_plan_line_id, 0) line_id_ff,
       SUBSTR(h.sql_plan_operation||' '||h.sql_plan_options, 1, 50) operation_ff,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h
 WHERE :license = 'Y'
   AND h.dbid = :dbid 
   AND h.sql_id = :sql_id
   AND h.snap_id BETWEEN &&x_minimum_snap_id. AND &&x_maximum_snap_id.
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
SELECT e.samples samples_ff,
       ROUND(100 * e.samples / t.samples, 1) percent_ff,
       e.plan_hash_value,
       e.line_id_ff,
       e.operation_ff,
       e.timed_event timed_event_ff
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT others samples_ff,
       ROUND(100 * others / samples, 1) percent_ff,
       TO_NUMBER(NULL) plan_hash_value, 
       TO_NUMBER(NULL) id, 
       NULL operation_ff, 
       'Others' timed_event_ff
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
/

PRO
PRO AWR History range considered: from &&x_minimum_date. to &&x_maximum_date.
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (past 31 days by plan line and timed event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_days = '31';
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
/

PRO
PRO GV$ACTIVE_SESSION_HISTORY 
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_slices = '20';
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
WITH
events AS (
SELECT /*+ MATERIALIZE */
       h.sql_plan_hash_value plan_hash_value,
       NVL(h.sql_plan_line_id, 0) line_id_ff,
       SUBSTR(h.sql_plan_operation||' '||h.sql_plan_options, 1, 50) operation_ff,
       CASE h.session_state WHEN 'ON CPU' THEN -1 ELSE h.current_obj# END current_obj#,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE :license = 'Y'
   AND sql_id = :sql_id
 GROUP BY
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
SELECT e.samples samples_ff,
       ROUND(100 * e.samples / t.samples, 1) percent_ff,
       e.plan_hash_value,
       e.line_id_ff,
       e.operation_ff,
       SUBSTR(e.current_obj#||' '||TRIM(
       (SELECT CASE e.current_obj# WHEN 0 THEN ' UNDO' ELSE ' '||o.owner||'.'||o.object_name||' ('||o.object_type||')' END
          FROM dba_objects o WHERE o.object_id(+) = e.current_obj# AND ROWNUM = 1) 
       ), 1, 60) current_object_ff,
       e.timed_event timed_event_ff
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT others samples_ff,
       ROUND(100 * others / samples, 1) percent_ff,
       TO_NUMBER(NULL) plan_hash_value, 
       TO_NUMBER(NULL) id, 
       NULL operation_ff, 
       NULL current_object_ff,
       'Others' timed_event_ff
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
/

PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (past 7 days by plan line, obj and timed event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_days = '7';
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
WITH
events AS (
SELECT /*+ 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
       FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
       USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
       FULL(h.sn) 
       FULL(h.ash) 
       FULL(h.evt) 
       USE_HASH(h.sn h.ash h.evt)
       */
       h.sql_plan_hash_value plan_hash_value,
       NVL(h.sql_plan_line_id, 0) line_id_ff,
       SUBSTR(h.sql_plan_operation||' '||h.sql_plan_options, 1, 50) operation_ff,
       CASE h.session_state WHEN 'ON CPU' THEN -1 ELSE h.current_obj# END current_obj#,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' "'||h.event||'"' END timed_event,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h
 WHERE :license = 'Y'
   AND h.dbid = :dbid 
   AND h.sql_id = :sql_id
   AND h.snap_id BETWEEN &&x_minimum_snap_id. AND &&x_maximum_snap_id.
 GROUP BY
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
SELECT e.samples samples_ff,
       ROUND(100 * e.samples / t.samples, 1) percent_ff,
       e.plan_hash_value,
       e.line_id_ff,
       e.operation_ff,
       SUBSTR(e.current_obj#||' '||TRIM(
       (SELECT CASE e.current_obj# WHEN 0 THEN ' UNDO' ELSE ' '||o.owner||'.'||o.object_name||' ('||o.object_type||')' END
          FROM dba_objects o WHERE o.object_id(+) = e.current_obj# AND ROWNUM = 1) 
       ), 1, 60) current_object_ff,
       e.timed_event timed_event_ff
  FROM events e,
       total t
 WHERE ROWNUM <= &&x_slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT others samples_ff,
       ROUND(100 * others / samples, 1) percent_ff,
       TO_NUMBER(NULL) plan_hash_value, 
       TO_NUMBER(NULL) id, 
       NULL operation_ff, 
       NULL current_object_ff,
       'Others' timed_event_ff
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
/

PRO
PRO AWR History range considered: from &&x_minimum_date. to &&x_maximum_date.
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (past 31 days by plan line, obj and timed event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DEF x_days = '31';
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
/

PRO
PRO SQL Plan Baselines
PRO ~~~~~~~~~~~~~~~~~~
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT created, plan_name, origin, enabled, accepted, fixed, reproduced, &&is_10g.&&is_11g.adaptive,
       last_executed, last_modified, description
FROM dba_sql_plan_baselines WHERE signature = :signature
ORDER BY created, plan_name
/
SET HEA OFF PAGES 0;
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE('&&sql_handle.'))
/
SET HEA ON PAGES 50;

SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
PRO get list of tables from execution plan
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
  	       AND sql_id = :sql_id
  	       AND object_owner IS NOT NULL
  	       AND object_name IS NOT NULL
  	     UNION
  	    SELECT object_owner owner, object_name name
  	      FROM dba_hist_sql_plan
  	     WHERE :license = 'Y'
  	       AND dbid = :dbid
  	       AND sql_id = :sql_id
  	       AND object_owner IS NOT NULL
  	       AND object_name IS NOT NULL
  	     UNION
  	    SELECT CASE h.current_obj# WHEN 0 THEN 'SYS' ELSE o.owner END owner, 
  	           CASE h.current_obj# WHEN 0 THEN 'UNDO' ELSE o.object_name END name
  	      FROM gv$active_session_history h,
  	           dba_objects o
  	     WHERE :license = 'Y'
  	       AND h.sql_id = :sql_id
  	       AND h.current_obj# >= 0
  	       AND o.object_id(+) = h.current_obj#
           AND h.wait_class in ('Application', 'Cluster', 'Concurrency', 'User I/O')
  	     UNION
  	    SELECT /*+ 
               FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) 
               FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) 
               FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) 
               USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt)
               FULL(h.sn) 
               FULL(h.ash) 
               FULL(h.evt) 
               USE_HASH(h.sn h.ash h.evt)
               */
               CASE h.current_obj# WHEN 0 THEN 'SYS' ELSE o.owner END owner, 
  	           CASE h.current_obj# WHEN 0 THEN 'UNDO' ELSE o.object_name END name
  	      FROM dba_hist_active_sess_history h,
  	           dba_objects o
  	     WHERE :license = 'Y'
  	       AND h.dbid = :dbid
  	       AND h.sql_id = :sql_id
  	       AND h.current_obj# >= 0
  	       AND o.object_id(+) = h.current_obj#
           AND h.wait_class in ('Application', 'Cluster', 'Concurrency', 'User I/O')
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
      IF DBMS_LOB.GETLENGTH(:tables_list) < 2799 THEN
        DBMS_LOB.WRITEAPPEND(:tables_list, 1, ',');
      END IF;
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
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT :tables_list tables_list FROM DUAL
/
SET HEAD ON;

PRO
PRO Tables Accessed 
PRO ~~~~~~~~~~~~~~~
COL table_name FOR A50;
COL degree FOR A10;
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT owner||'.'||table_name table_name,
       partitioned,
       degree,
       temporary,
       blocks,
       num_rows,
       avg_row_len,
       sample_size,
       TO_CHAR(last_analyzed, 'YYYY-MM-DD"T"HH24:MI:SS') last_analyzed,
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
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
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
       TO_CHAR(i.last_analyzed, 'YYYY-MM-DD"T"HH24:MI:SS') last_analyzed,
       i.global_stats
  FROM dba_indexes i
 WHERE (i.table_owner, i.table_name) IN &&tables_list.
 ORDER BY
       i.table_owner,
       i.table_name,
       i.owner,
       i.index_name
/

SET LONG 200 LONGC 20;
COL index_and_column_name FOR A70;
COL table_and_column_name FOR A70;
COL data_type FOR A20;
COL data_default FOR A20;
COL low_value FOR A32;
COL high_value FOR A32;
COL low_value_translated FOR A32;
COL high_value_translated FOR A32;
PRO
PRO Table Columns 
PRO ~~~~~~~~~~~~~
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT c.owner||'.'||c.table_name||' '||c.column_name table_and_column_name,
       c.data_type,
       c.nullable,
       c.data_default,
       c.num_distinct,
       CASE WHEN c.data_type = 'NUMBER' THEN to_char(utl_raw.cast_to_number(c.low_value))
        WHEN c.data_type IN ('VARCHAR2', 'CHAR') THEN SUBSTR(to_char(utl_raw.cast_to_varchar2(c.low_value)),1,32)
        WHEN c.data_type IN ('NVARCHAR2','NCHAR') THEN SUBSTR(to_char(utl_raw.cast_to_nvarchar2(c.low_value)),1,32)
        WHEN c.data_type = 'BINARY_DOUBLE' THEN to_char(utl_raw.cast_to_binary_double(c.low_value))
        WHEN c.data_type = 'BINARY_FLOAT' THEN to_char(utl_raw.cast_to_binary_float(c.low_value))
        WHEN c.data_type = 'DATE' THEN rtrim(
                    ltrim(to_char(100*(to_number(substr(c.low_value,1,2) ,'XX')-100) + (to_number(substr(c.low_value,3,2) ,'XX')-100),'0000'))||'-'||
                    ltrim(to_char(     to_number(substr(c.low_value,5,2) ,'XX')  ,'00'))||'-'||
                    ltrim(to_char(     to_number(substr(c.low_value,7,2) ,'XX')  ,'00'))||'/'||
                    ltrim(to_char(     to_number(substr(c.low_value,9,2) ,'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.low_value,11,2),'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.low_value,13,2),'XX')-1,'00')))
        WHEN c.data_type LIKE 'TIMESTAMP%' THEN rtrim(
                    ltrim(to_char(100*(to_number(substr(c.low_value,1,2) ,'XX')-100) + (to_number(substr(c.low_value,3,2) ,'XX')-100),'0000'))||'-'||
                    ltrim(to_char(     to_number(substr(c.low_value,5,2) ,'XX')  ,'00'))||'-'||
                    ltrim(to_char(     to_number(substr(c.low_value,7,2) ,'XX')  ,'00'))||'/'||
                    ltrim(to_char(     to_number(substr(c.low_value,9,2) ,'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.low_value,11,2),'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.low_value,13,2),'XX')-1,'00'))||'.'||
                    to_number(substr(c.low_value,15,8),'XXXXXXXX'))
       END low_value_translated,
       CASE WHEN c.data_type = 'NUMBER' THEN to_char(utl_raw.cast_to_number(c.high_value))
        WHEN c.data_type IN ('VARCHAR2', 'CHAR') THEN SUBSTR(to_char(utl_raw.cast_to_varchar2(c.high_value)),1,32)
        WHEN c.data_type IN ('NVARCHAR2','NCHAR') THEN SUBSTR(to_char(utl_raw.cast_to_nvarchar2(c.high_value)),1,32)
        WHEN c.data_type = 'BINARY_DOUBLE' THEN to_char(utl_raw.cast_to_binary_double(c.high_value))
        WHEN c.data_type = 'BINARY_FLOAT' THEN to_char(utl_raw.cast_to_binary_float(c.high_value))
        WHEN c.data_type = 'DATE' THEN rtrim(
                    ltrim(to_char(100*(to_number(substr(c.high_value,1,2) ,'XX')-100) + (to_number(substr(c.high_value,3,2) ,'XX')-100),'0000'))||'-'||
                    ltrim(to_char(     to_number(substr(c.high_value,5,2) ,'XX')  ,'00'))||'-'||
                    ltrim(to_char(     to_number(substr(c.high_value,7,2) ,'XX')  ,'00'))||'/'||
                    ltrim(to_char(     to_number(substr(c.high_value,9,2) ,'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.high_value,11,2),'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.high_value,13,2),'XX')-1,'00')))
        WHEN c.data_type LIKE 'TIMESTAMP%' THEN rtrim(
                    ltrim(to_char(100*(to_number(substr(c.high_value,1,2) ,'XX')-100) + (to_number(substr(c.high_value,3,2) ,'XX')-100),'0000'))||'-'||
                    ltrim(to_char(     to_number(substr(c.high_value,5,2) ,'XX')  ,'00'))||'-'||
                    ltrim(to_char(     to_number(substr(c.high_value,7,2) ,'XX')  ,'00'))||'/'||
                    ltrim(to_char(     to_number(substr(c.high_value,9,2) ,'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.high_value,11,2),'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.high_value,13,2),'XX')-1,'00'))||'.'||
                    to_number(substr(c.high_value,15,8),'XXXXXXXX'))
        END high_value_translated,
       c.density,
       c.num_nulls,
       c.num_buckets,
       c.histogram,
       c.sample_size,
       TO_CHAR(c.last_analyzed, 'YYYY-MM-DD"T"HH24:MI:SS') last_analyzed,
       c.global_stats,
       c.avg_col_len
  FROM dba_tab_cols c
 WHERE (c.owner, c.table_name) IN &&tables_list.
 ORDER BY
       c.owner,
       c.table_name,
       c.column_name
/

PRO
PRO Index Columns 
PRO ~~~~~~~~~~~~~
SPO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt APP;
SELECT i.index_owner||'.'||i.index_name||' '||c.column_name index_and_column_name,
       c.data_type,
       c.nullable,
       c.data_default,
       c.num_distinct,
       CASE WHEN c.data_type = 'NUMBER' THEN to_char(utl_raw.cast_to_number(c.low_value))
        WHEN c.data_type IN ('VARCHAR2', 'CHAR') THEN SUBSTR(to_char(utl_raw.cast_to_varchar2(c.low_value)),1,32)
        WHEN c.data_type IN ('NVARCHAR2','NCHAR') THEN SUBSTR(to_char(utl_raw.cast_to_nvarchar2(c.low_value)),1,32)
        WHEN c.data_type = 'BINARY_DOUBLE' THEN to_char(utl_raw.cast_to_binary_double(c.low_value))
        WHEN c.data_type = 'BINARY_FLOAT' THEN to_char(utl_raw.cast_to_binary_float(c.low_value))
        WHEN c.data_type = 'DATE' THEN rtrim(
                    ltrim(to_char(100*(to_number(substr(c.low_value,1,2) ,'XX')-100) + (to_number(substr(c.low_value,3,2) ,'XX')-100),'0000'))||'-'||
                    ltrim(to_char(     to_number(substr(c.low_value,5,2) ,'XX')  ,'00'))||'-'||
                    ltrim(to_char(     to_number(substr(c.low_value,7,2) ,'XX')  ,'00'))||'/'||
                    ltrim(to_char(     to_number(substr(c.low_value,9,2) ,'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.low_value,11,2),'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.low_value,13,2),'XX')-1,'00')))
        WHEN c.data_type LIKE 'TIMESTAMP%' THEN rtrim(
                    ltrim(to_char(100*(to_number(substr(c.low_value,1,2) ,'XX')-100) + (to_number(substr(c.low_value,3,2) ,'XX')-100),'0000'))||'-'||
                    ltrim(to_char(     to_number(substr(c.low_value,5,2) ,'XX')  ,'00'))||'-'||
                    ltrim(to_char(     to_number(substr(c.low_value,7,2) ,'XX')  ,'00'))||'/'||
                    ltrim(to_char(     to_number(substr(c.low_value,9,2) ,'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.low_value,11,2),'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.low_value,13,2),'XX')-1,'00'))||'.'||
                    to_number(substr(c.low_value,15,8),'XXXXXXXX'))
       END low_value_translated,
       CASE WHEN c.data_type = 'NUMBER' THEN to_char(utl_raw.cast_to_number(c.high_value))
        WHEN c.data_type IN ('VARCHAR2', 'CHAR') THEN SUBSTR(to_char(utl_raw.cast_to_varchar2(c.high_value)),1,32)
        WHEN c.data_type IN ('NVARCHAR2','NCHAR') THEN SUBSTR(to_char(utl_raw.cast_to_nvarchar2(c.high_value)),1,32)
        WHEN c.data_type = 'BINARY_DOUBLE' THEN to_char(utl_raw.cast_to_binary_double(c.high_value))
        WHEN c.data_type = 'BINARY_FLOAT' THEN to_char(utl_raw.cast_to_binary_float(c.high_value))
        WHEN c.data_type = 'DATE' THEN rtrim(
                    ltrim(to_char(100*(to_number(substr(c.high_value,1,2) ,'XX')-100) + (to_number(substr(c.high_value,3,2) ,'XX')-100),'0000'))||'-'||
                    ltrim(to_char(     to_number(substr(c.high_value,5,2) ,'XX')  ,'00'))||'-'||
                    ltrim(to_char(     to_number(substr(c.high_value,7,2) ,'XX')  ,'00'))||'/'||
                    ltrim(to_char(     to_number(substr(c.high_value,9,2) ,'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.high_value,11,2),'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.high_value,13,2),'XX')-1,'00')))
        WHEN c.data_type LIKE 'TIMESTAMP%' THEN rtrim(
                    ltrim(to_char(100*(to_number(substr(c.high_value,1,2) ,'XX')-100) + (to_number(substr(c.high_value,3,2) ,'XX')-100),'0000'))||'-'||
                    ltrim(to_char(     to_number(substr(c.high_value,5,2) ,'XX')  ,'00'))||'-'||
                    ltrim(to_char(     to_number(substr(c.high_value,7,2) ,'XX')  ,'00'))||'/'||
                    ltrim(to_char(     to_number(substr(c.high_value,9,2) ,'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.high_value,11,2),'XX')-1,'00'))||':'||
                    ltrim(to_char(     to_number(substr(c.high_value,13,2),'XX')-1,'00'))||'.'||
                    to_number(substr(c.high_value,15,8),'XXXXXXXX'))
        END high_value_translated,
       c.density,
       c.num_nulls,
       c.num_buckets,
       c.histogram,
       c.sample_size,
       TO_CHAR(c.last_analyzed, 'YYYY-MM-DD"T"HH24:MI:SS') last_analyzed,
       c.global_stats,
       c.avg_col_len
  FROM dba_ind_columns i,
       dba_tab_cols c
 WHERE (i.table_owner, i.table_name) IN &&tables_list.
   AND c.owner = i.table_owner
   AND c.table_name = i.table_name
   AND c.column_name = i.column_name
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
PRO planx_&&x_db_name.-&&x_instname.-&&x_container-&&sql_id._&&current_time..txt has been generated
SPO OFF;

