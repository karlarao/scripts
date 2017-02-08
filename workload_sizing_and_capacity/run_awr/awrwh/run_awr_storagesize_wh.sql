-- awr_storagesize.sql
-- AWR Storage Forecast Report
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

spool awr_storagesize_wh.csv
WITH tbs_size AS (
      SELECT 
             s0.dbid dbid,
             s0.snap_id id,
             TO_CHAR(TO_DATE(s0.rtime,'MM/DD/YY HH24:MI:SS'),'MM/DD/YY HH24:MI:SS') tm,
            (sum(s0.tablespace_size))/1024/1024/1024 as ts_size_gb, 
            (sum(s0.tablespace_usedsize))/1024/1024/1024 as ts_used_gb
      FROM 
            dba_hist_tbspc_space_usage s0
      GROUP BY s0.dbid, s0.snap_id, s0.rtime
  ),
  bsize as (
      select dbid, max(value) value from dba_hist_parameter where parameter_name like '%db_block_size%' and (dbid, snap_id) in ( SELECT dbid, MAX(snap_id) FROM dba_hist_parameter group by dbid ) group by dbid
  )
SELECT 
       wh.target_name target_name, 
       wh.new_dbid dbid,
       s0.id id,
       s0.tm,
       s0.ts_size_gb * s1.value ts_size_gb, 
       s0.ts_used_gb * s1.value ts_used_gb  
FROM
  tbs_size s0,
  bsize s1, 
  dbsnmp.caw_dbid_mapping wh
WHERE 
  s0.dbid = wh.new_dbid 
  AND s0.dbid = s1.dbid  
/
spool off  