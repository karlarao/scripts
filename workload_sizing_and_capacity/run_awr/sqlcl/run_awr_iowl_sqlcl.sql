-- awr_iowl.sql
-- AWR IO Workload Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
-- NOTE:
--
-- Changes:
--		20140909: perf improvement on the script using WITH
--

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

COL name NEW_V _instname NOPRINT
select lower(instance_name) name from v$instance;
COL name NEW_V _hostname NOPRINT
select lower(host_name) name from v$instance;
COL ecr_dbid NEW_V ecr_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) ecr_dbid FROM v$database;
COL ecr_min_snap_id NEW_V ecr_min_snap_id;
SELECT 'get_min_snap_id', TO_CHAR(MIN(snap_id)) ecr_min_snap_id
FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid.
and to_date(to_char(END_INTERVAL_TIME,'MM/DD/YY HH24:MI:SS'),'MM/DD/YY HH24:MI:SS') > sysdate - 100;

spool awr_iowl-tableau_sqlcl-exa-&_instname-&_hostname..csv
WITH
sysstat_io AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = 'redo writes' THEN value ELSE 0 END) redo_writes,
       SUM(CASE WHEN stat_name = 'redo size' THEN value ELSE 0 END) redo_size,
       SUM(CASE WHEN stat_name = 'physical read total IO requests' THEN value ELSE 0 END) pread_io,
       SUM(CASE WHEN stat_name = 'physical read total multi block requests' THEN value ELSE 0 END) pread_multi_bytes,
       SUM(CASE WHEN stat_name = 'physical read total bytes' THEN value ELSE 0 END) pread_bytes,
       SUM(CASE WHEN stat_name = 'physical write total IO requests' THEN value ELSE 0 END) pwrite_io,
       SUM(CASE WHEN stat_name = 'physical write total multi block requests' THEN value ELSE 0 END) pwrite_multi_bytes,
       SUM(CASE WHEN stat_name = 'physical write total bytes' THEN value ELSE 0 END) pwrite_bytes,
       SUM(CASE WHEN stat_name = 'cell physical IO interconnect bytes' THEN value ELSE 0 END) cellpiob,
       SUM(CASE WHEN stat_name = 'cell physical IO bytes saved during optimized file creation' THEN value ELSE 0 END) cellpiobs,
       SUM(CASE WHEN stat_name = 'cell physical IO bytes saved during optimized RMAN file restore' THEN value ELSE 0 END) cellpiobsrman,
       SUM(CASE WHEN stat_name = 'cell physical IO bytes eligible for predicate offload' THEN value ELSE 0 END) cellpiobpreoff,
       SUM(CASE WHEN stat_name = 'cell physical IO bytes saved by storage index' THEN value ELSE 0 END) cellpiobsi,
       SUM(CASE WHEN stat_name = 'cell physical IO interconnect bytes returned by smart scan' THEN value ELSE 0 END) cellpiobss,
       SUM(CASE WHEN stat_name = 'cell IO uncompressed bytes' THEN value ELSE 0 END) celliouncomb,
       SUM(CASE WHEN stat_name = 'cell flash cache read hits' THEN value ELSE 0 END) flashcache
  FROM dba_hist_sysstat
 WHERE snap_id >= &&ecr_min_snap_id.
   AND dbid = &&ecr_dbid.
   AND stat_name IN
   ('redo writes','redo size','physical read total IO requests','physical read total multi block requests','physical read total bytes','physical write total IO requests','physical write total multi block requests','physical write total bytes','cell physical IO interconnect bytes','cell physical IO bytes saved during optimized file creation','cell physical IO bytes saved during optimized RMAN file restore','cell physical IO bytes eligible for predicate offload','cell physical IO bytes saved by storage index','cell physical IO interconnect bytes returned by smart scan','cell IO uncompressed bytes','cell flash cache read hits')
 GROUP BY
       instance_number,
       snap_id
)
SELECT /*+ MATERIALIZE NO_MERGE */
       trim('&_instname') instname,
       trim('&&ecr_dbid.') db_id,
       trim('&_hostname') hostname,
       s0.snap_id id,
       TO_CHAR(s0.END_INTERVAL_TIME,'MM/DD/YY HH24:MI:SS') tm,
       s0.instance_number inst,
       round(((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400)/60,2) dur,
       ((h1.pread_io - h0.pread_io) - (h1.pread_multi_bytes - h0.pread_multi_bytes)) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) SIORs,
       (h1.pread_multi_bytes - h0.pread_multi_bytes) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) MIORs,
       ((h1.pread_bytes - h0.pread_bytes)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) TIORmbs,
       ((h1.pwrite_io - h0.pwrite_io) - (h1.pwrite_multi_bytes - h0.pwrite_multi_bytes)) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) SIOWs,
       (h1.pwrite_multi_bytes - h0.pwrite_multi_bytes) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) MIOWs,
       ((h1.pwrite_bytes - h0.pwrite_bytes)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) TIOWmbs,
       (h1.redo_writes - h0.redo_writes) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) IORedo,
       ((h1.redo_size - h0.redo_size)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) redosizembs,
       ((h1.flashcache - h0.flashcache) / (h1.pread_io - h0.pread_io)) * 100 flashcache,
       ((h1.flashcache - h0.flashcache) / ((h1.pread_io - h0.pread_io)+(h1.pwrite_io - h0.pwrite_io))) * 100 flashcache2,
       ((h1.cellpiob - h0.cellpiob)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) cellpiob,
       ((h1.cellpiobss - h0.cellpiobss)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) cellpiobss,
       ((h1.cellpiobpreoff - h0.cellpiobpreoff)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) cellpiobpreoff,
       ((h1.cellpiobsi - h0.cellpiobsi)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) cellpiobsi,
       ((h1.celliouncomb - h0.celliouncomb)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) celliouncomb,
       ((h1.cellpiobs - h0.cellpiobs)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) cellpiobs,
       ((h1.cellpiobsrman - h0.cellpiobsrman)/1024/1024) / ((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400) cellpiobsrman
  FROM sysstat_io h0,
       dba_hist_snapshot s0,
       sysstat_io h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id >= &&ecr_min_snap_id.
   AND s0.dbid = &&ecr_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id >= &&ecr_min_snap_id.
   AND s1.dbid = &&ecr_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
/
spool off