-- awr_sysstat.sql
-- AWR CPU Workload Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
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

spool awr_sgapga_wh.csv
WITH sga_mem AS (
  select snap_id, dbid, instance_number, sum(value) value from dba_hist_sga group by snap_id, dbid, instance_number
)
  SELECT 
         wh.target_name target_name, 
         wh.new_dbid dbid,  
         s0.snap_id id,
         TO_CHAR(s0.END_INTERVAL_TIME,'MM/DD/YY HH24:MI:SS') tm,
         s0.instance_number inst,
  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
  round(s4t1.value/1024/1024/1024,2) AS memgb,
  round(s37t1.value/1024/1024/1024,2) AS sgagb,
  round(s36t1.value/1024/1024/1024,2) AS pgagb
FROM dba_hist_snapshot s0,
  dba_hist_snapshot s1,
  dba_hist_osstat s4t1,         -- osstat just get the end value
  sga_mem s37t1, -- total SGA allocated, just get the end value
  dba_hist_pgastat s36t1,   -- total PGA allocated, just get the end value
  dbsnmp.caw_dbid_mapping wh
WHERE 
wh.new_dbid              = s0.dbid               
AND s1.dbid              = s0.dbid
AND s4t1.dbid            = s0.dbid
AND s36t1.dbid           = s0.dbid
AND s37t1.dbid           = s0.dbid
AND s1.instance_number   = s0.instance_number
AND s4t1.instance_number = s0.instance_number
AND s36t1.instance_number = s0.instance_number
AND s37t1.instance_number = s0.instance_number
AND s1.snap_id           = s0.snap_id + 1
AND s4t1.snap_id         = s0.snap_id + 1
AND s36t1.snap_id        = s0.snap_id + 1
AND s37t1.snap_id        = s0.snap_id + 1
AND s4t1.stat_name       = 'PHYSICAL_MEMORY_BYTES'
AND s36t1.name           = 'total PGA allocated'
/
spool off