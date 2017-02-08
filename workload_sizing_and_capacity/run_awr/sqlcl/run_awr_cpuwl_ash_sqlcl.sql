
-- this section is from https://github.com/carlos-sierra/esp_collect

set feedback off 
set pages 50000 
set term off 
set head on 
set trimspool on 
set echo off 
set lines 4000 
set colsep ',' 
set arraysize 5000 
set verify off
set sqlformat csv

DEF MAX_DAYS = '365';
--SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;

-- get host name (up to 30, stop before first '.', no special characters)
DEF esp_host_name_short = '';
COL esp_host_name_short NEW_V esp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) esp_host_name_short FROM DUAL;
SELECT SUBSTR('&&esp_host_name_short.', 1, INSTR('&&esp_host_name_short..', '.') - 1) esp_host_name_short FROM DUAL;
SELECT TRANSLATE('&&esp_host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') esp_host_name_short FROM DUAL;

-- get collection date
DEF esp_collection_yyyymmdd = '';
COL esp_collection_yyyymmdd NEW_V esp_collection_yyyymmdd FOR A8;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') esp_collection_yyyymmdd FROM DUAL;

-- get collection days
DEF collection_days = '&&MAX_DAYS.';
COL collection_days NEW_V collection_days;
SELECT NVL(TO_CHAR(LEAST(EXTRACT(DAY FROM retention), TO_NUMBER('&&MAX_DAYS.'))), '&&MAX_DAYS.') collection_days FROM dba_hist_wr_control;

DEF skip_on_10g = '';
COL skip_on_10g NEW_V skip_on_10g;
SELECT '--' skip_on_10g FROM v$instance WHERE version LIKE '10%';

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';

DEF ecr_sq_fact_hints = 'MATERIALIZE NO_MERGE';
DEF ecr_date_format = 'YYYY-MM-DD/HH24:MI:SS';

CL COL;
COL ecr_collection_key NEW_V ecr_collection_key;
SELECT 'get_collection_key', SUBSTR(name||ora_hash(dbid||name||instance_name||host_name||systimestamp), 1, 13) ecr_collection_key FROM v$instance, v$database
/
COL ecr_dbid NEW_V ecr_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) ecr_dbid FROM v$database
/
COL ecr_instance_number NEW_V ecr_instance_number;
SELECT 'get_instance_number', TO_CHAR(instance_number) ecr_instance_number FROM v$instance
/
COL ecr_min_snap_id NEW_V ecr_min_snap_id;
SELECT 'get_min_snap_id', TO_CHAR(MIN(snap_id)) ecr_min_snap_id FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid. AND CAST(begin_interval_time AS DATE) > SYSDATE - &&collection_days.
/
COL ecr_collection_host NEW_V ecr_collection_host;
SELECT 'get_collection_host', LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', 1, INSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', '.') - 1)) ecr_collection_host FROM DUAL
/

DEF;
SELECT 'get_current_time', TO_CHAR(SYSDATE, '&&ecr_date_format.') current_time FROM DUAL
/

SPO esp_requirements_awr_sqlcl_&&esp_host_name_short._&&esp_collection_yyyymmdd..csv APP;

-- header
SELECT 'collection_host,collection_key,category,data_element,source,instance_number,inst_id,value' FROM DUAL
/

-- id
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'collector_version', 'v1601', 0, 0, '2016-01-05' FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'collection_date', 'sysdate', 0, 0, TO_CHAR(SYSDATE, '&&ecr_date_format.') FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'awr_retention_days', 'dba_hist_snapshot', 0, 0,  ROUND(CAST(MAX(end_interval_time) AS DATE) - CAST(MIN(begin_interval_time) AS DATE), 1) FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid. AND CAST(begin_interval_time AS DATE) > SYSDATE - &&collection_days.
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'awr_retention_days', 'dba_hist_snapshot', instance_number, 0, ROUND(CAST(MAX(end_interval_time) AS DATE) - CAST(MIN(begin_interval_time) AS DATE), 1) FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid. AND CAST(begin_interval_time AS DATE) > SYSDATE - &&collection_days. GROUP BY instance_number ORDER BY instance_number
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'collection_days', 'dba_hist_wr_control', 0, 0, '&&collection_days.' FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'user', 'user', 0, 0, USER FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'host', 'sys_context', 0, 0, LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'HOST')||'.', 1, INSTR(SYS_CONTEXT('USERENV', 'HOST')||'.', '.') - 1)) FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'server_host', 'sys_context', 0, 0, LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', 1, INSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST')||'.', '.') - 1)) FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'dbid', 'v$database', 0, 0, '&&ecr_dbid.' FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'db_name', 'sys_context', 0, 0, SYS_CONTEXT('USERENV', 'DB_NAME') FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'db_unique_name', 'sys_context', 0, 0, SYS_CONTEXT('USERENV', 'DB_UNIQUE_NAME') FROM DUAL
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'platform_name', 'v$database', 0, 0, platform_name FROM v$database
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'host_name', 'gv$instance', instance_number, inst_id, LOWER(SUBSTR(host_name||'.', 1, INSTR(host_name||'.', '.') - 1)) FROM gv$instance ORDER BY inst_id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'version', 'gv$instance', instance_number, inst_id, version FROM gv$instance ORDER BY inst_id
/
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'instance_name', 'gv$instance', instance_number, inst_id, instance_name FROM gv$instance ORDER BY inst_id
/
SELECT DISTINCT '&&ecr_collection_host.', '&&ecr_collection_key', 'id', 'instance_name', 'dba_hist_database_instance', instance_number, 0, instance_name FROM dba_hist_database_instance WHERE dbid = &&ecr_dbid. AND CAST(startup_time AS DATE) > SYSDATE - &&collection_days. ORDER BY instance_number
/

-- cpu time series
WITH
cpu_per_inst_and_sample AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       h.instance_number,
       h.snap_id,
       h.sample_id,
       MIN(h.sample_time) sample_time,
       CASE h.session_state WHEN 'ON CPU' THEN 'ON CPU' ELSE 'resmgr:cpu quantum' END session_state,
       COUNT(*) active_sessions
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE h.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND h.dbid = &&ecr_dbid.
   AND (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   --AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
   AND s.begin_interval_time between SYSDATE-100 and SYSDATE 
 GROUP BY
       h.instance_number,
       h.snap_id,
       h.sample_id,
       h.session_state,
       h.event
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&ecr_sq_fact_hints. */
       session_state,
       instance_number,
       TO_CHAR(TRUNC(CAST(sample_time AS DATE), 'HH') + (1/24), '&&ecr_date_format.') end_time,
       MAX(active_sessions) active_sessions_max, -- 100% percentile or max or peak
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY active_sessions) active_sessions_99p, -- 99% percentile
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY active_sessions) active_sessions_97p, -- 97% percentile
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY active_sessions) active_sessions_95p, -- 95% percentile
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY active_sessions) active_sessions_90p, -- 90% percentile
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY active_sessions) active_sessions_75p, -- 75% percentile
       ROUND(MEDIAN(active_sessions), 1) active_sessions_med, -- 50% percentile or median
       ROUND(AVG(active_sessions), 1) active_sessions_avg -- average
  FROM cpu_per_inst_and_sample
 GROUP BY
       session_state,
       instance_number,
       TRUNC(CAST(sample_time AS DATE), 'HH')
)
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts', session_state, end_time, instance_number, 0 inst_id, active_sessions_max value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_99p', session_state, end_time, instance_number, 0 inst_id, active_sessions_99p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_97p', session_state, end_time, instance_number, 0 inst_id, active_sessions_97p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_95p', session_state, end_time, instance_number, 0 inst_id, active_sessions_95p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_90p', session_state, end_time, instance_number, 0 inst_id, active_sessions_90p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_75p', session_state, end_time, instance_number, 0 inst_id, active_sessions_75p value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_med', session_state, end_time, instance_number, 0 inst_id, active_sessions_med value FROM cpu_per_inst_and_hour
 UNION ALL
SELECT '&&ecr_collection_host.', '&&ecr_collection_key', 'cpu_ts_avg', session_state, end_time, instance_number, 0 inst_id, active_sessions_avg value FROM cpu_per_inst_and_hour
 ORDER BY
       3, 4, 6, 5
/
spool off
