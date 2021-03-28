-- awr_cpuwl.sql
-- AWR CPU Workload Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
--

set feedback off pages 50000 term off head on und off trimspool on echo off lines 4000 colsep ',' arraysize 5000 verify off

COL name NEW_V _instname NOPRINT
select lower(instance_name) name from v$instance;
COL name NEW_V _hostname NOPRINT
select lower(host_name) name from v$instance;
COL ecr_dbid NEW_V ecr_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) ecr_dbid FROM v$database;
COL ecr_min_snap_id NEW_V ecr_min_snap_id;
SELECT 'get_min_snap_id', TO_CHAR(MIN(snap_id)) ecr_min_snap_id
FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid.
and to_date(to_char(END_INTERVAL_TIME,'MM/DD/YY HH24:MI:SS'),'MM/DD/YY HH24:MI:SS') > sysdate - 300;

spool awr_cpuwl-tableau-&_instname-&_hostname..csv
WITH
cpuwl AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = 'BUSY_TIME' THEN value ELSE 0 END) busy_time,
       SUM(CASE WHEN stat_name = 'SYS_TIME' THEN value ELSE 0 END) sys_time,
       SUM(CASE WHEN stat_name = 'IOWAIT_TIME' THEN value ELSE 0 END) io_wait,
       SUM(CASE WHEN stat_name = 'RSRC_MGR_CPU_WAIT_TIME' THEN value ELSE 0 END) rsrcmgr,
       SUM(CASE WHEN stat_name = 'LOAD' THEN value ELSE 0 END) loadavg,
       SUM(CASE WHEN stat_name = 'NUM_CPUS' THEN value ELSE 0 END) cpu
  FROM dba_hist_osstat
 WHERE snap_id >= &&ecr_min_snap_id.
   AND dbid = &&ecr_dbid.
   AND stat_name IN
   ('BUSY_TIME','SYS_TIME','IOWAIT_TIME','RSRC_MGR_CPU_WAIT_TIME','LOAD','NUM_CPUS')
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
       h1.cpu AS cpu,
       round(h1.loadavg,2) AS loadavg,
       ((((h1.busy_time - h0.busy_time)+(h1.rsrcmgr - h0.rsrcmgr))/100) / (((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400)*h1.cpu) )*h1.cpu as aas_cpu,
       (((h1.rsrcmgr - h0.rsrcmgr)/100) / (((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400)*h1.cpu) )*100 as rsrcmgrpct,
       (((h1.busy_time - h0.busy_time)/100) / (((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400)*h1.cpu) )*100 as oscpupct,
       (((h1.sys_time - h0.sys_time)/100) / (((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400)*h1.cpu) )*100 as oscpusys,
       (((h1.io_wait - h0.io_wait)/100) / (((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400)*h1.cpu) )*100 as oscpuio
  FROM cpuwl h0,
       dba_hist_snapshot s0,
       cpuwl h1,
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
host sed -n -i '2,$ p' awr_cpuwl-tableau-&_instname-&_hostname..csv
-- host gzip -v awr_cpuwl-tableau-&_instname-&_hostname..csv
-- host tar -cvf awr_cpuwl-tableau-&_instname-&_hostname..tar awr_cpuwl-tableau-&_instname-&_hostname..csv.gz
-- host rm awr_cpuwl-tableau-&_instname-&_hostname..csv.gz
