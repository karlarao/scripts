-- awr_cpuwl.sql
-- AWR CPU Workload Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
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

spool awr_cpuwl_wh.csv

WITH
cpuwl AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       instance_number,
       snap_id,
       dbid,
       SUM(CASE WHEN stat_name = 'BUSY_TIME' THEN value ELSE 0 END) busy_time,
       SUM(CASE WHEN stat_name = 'SYS_TIME' THEN value ELSE 0 END) sys_time,
       SUM(CASE WHEN stat_name = 'IOWAIT_TIME' THEN value ELSE 0 END) io_wait,
       SUM(CASE WHEN stat_name = 'RSRC_MGR_CPU_WAIT_TIME' THEN value ELSE 0 END) rsrcmgr,
       SUM(CASE WHEN stat_name = 'LOAD' THEN value ELSE 0 END) loadavg,
       SUM(CASE WHEN stat_name = 'NUM_CPUS' THEN value ELSE 0 END) cpu
  FROM dba_hist_osstat
   where stat_name IN
   ('BUSY_TIME','SYS_TIME','IOWAIT_TIME','RSRC_MGR_CPU_WAIT_TIME','LOAD','NUM_CPUS')
 GROUP BY
       instance_number,
       snap_id,
       dbid
)
SELECT /*+ MATERIALIZE NO_MERGE */
       wh.target_name target_name, 
       wh.new_dbid dbid,
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
       dba_hist_snapshot s1,
       dbsnmp.caw_dbid_mapping wh 
 WHERE 
    s0.dbid = h0.dbid 
   AND s0.dbid = wh.new_dbid 
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   /
spool off 