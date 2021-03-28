-- awr_storagesize.sql
-- AWR Storage Forecast Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--

set feedback off pages 0 term off head on und off trimspool on echo off lines 4000 colsep ','

set arraysize 5000
set termout off
set echo off verify off

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
select distinct block_size blocksize from v$datafile;

COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;

COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;

COLUMN name NEW_VALUE _hostname NOPRINT
select lower(host_name) name from v$instance;

COLUMN instancenumber NEW_VALUE _instancenumber NOPRINT
select instance_number instancenumber from v$instance;

COL ecr_dbid NEW_V ecr_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) ecr_dbid FROM v$database;
COL ecr_instance_number NEW_V ecr_instance_number;
SELECT 'get_instance_number', TO_CHAR(instance_number) ecr_instance_number FROM v$instance;
COL ecr_min_snap_id NEW_V ecr_min_snap_id;
SELECT 'get_min_snap_id', TO_CHAR(MIN(snap_id)) ecr_min_snap_id
FROM dba_hist_snapshot WHERE dbid = &&ecr_dbid.
and to_date(to_char(END_INTERVAL_TIME,'MM/DD/YY HH24:MI:SS'),'MM/DD/YY HH24:MI:SS') > sysdate - 300;

-- ttitle center 'AWR Storage Forecast Report' skip 2
set pagesize 50000
set linesize 550

-- storage size
spool awr_storagesize_summary-tableau-&_instname-&_hostname..csv
WITH
ts_per_snap_id AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       us.snap_id,
       TRUNC(CAST(sn.end_interval_time AS DATE), 'HH') + (1/24) end_time,
       SUM(us.tablespace_size * ts.block_size) all_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'PERMANENT' THEN us.tablespace_size * ts.block_size ELSE 0 END) perm_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'UNDO'      THEN us.tablespace_size * ts.block_size ELSE 0 END) undo_tablespaces_bytes,
       SUM(CASE ts.contents WHEN 'TEMPORARY' THEN us.tablespace_size * ts.block_size ELSE 0 END) temp_tablespaces_bytes
  FROM dba_hist_tbspc_space_usage us,
       dba_hist_snapshot sn,
       v$tablespace vt,
       dba_tablespaces ts
 WHERE us.snap_id >= TO_NUMBER(NVL('&&ecr_min_snap_id.','0'))
   AND us.dbid = &&ecr_dbid.
   AND sn.snap_id = us.snap_id
   AND sn.dbid = us.dbid
   AND sn.instance_number = &&ecr_instance_number.
   AND vt.ts# = us.tablespace_id
   AND ts.tablespace_name = vt.name
 GROUP BY
       us.snap_id,
       sn.end_interval_time
)
SELECT
  trim('&_instname') instname,
  trim('&_dbid') db_id,
  trim('&_hostname') hostname,
TO_CHAR(end_time, 'MM/DD/YY HH24:MI:SS') MONTH,
ROUND((MAX(perm_tablespaces_bytes)+MAX(undo_tablespaces_bytes)+MAX(temp_tablespaces_bytes)))/1024/1024 USED_SIZE_MB,
ROUND((MAX(perm_tablespaces_bytes)+MAX(undo_tablespaces_bytes)+MAX(temp_tablespaces_bytes)))/1024/1024 INC_USED_SIZE_MB
  FROM ts_per_snap_id
 GROUP BY
       end_time
 ORDER BY
       1 asc
/
spool off
host sed -n -i '2,$ p' awr_storagesize_summary-tableau-&_instname-&_hostname..csv
-- host gzip -v awr_storagesize_summary-tableau-&_instname-&_hostname..csv
-- host tar -cvf awr_storagesize_summary-tableau-&_instname-&_hostname..tar awr_storagesize_summary-tableau-&_instname-&_hostname..csv.gz
-- host rm awr_storagesize_summary-tableau-&_instname-&_hostname..csv.gz

-- backup size
spool awr_storagesize_rman-tableau-&_instname-&_hostname..csv
select
trim('&_instname') instname,
trim('&_dbid') db_id,
trim('&_hostname') hostname,
status,
input_type,
TO_CHAR(start_time, 'MM/DD/YY HH24:MI:SS') as "start",
round(elapsed_seconds)/60/60 etimehours,
round(input_bytes/1024/1024/1024,2) inGB,
round(output_bytes/1024/1024/1024,2) outGB,
output_device_type device,
autobackup_done,
optimized
from V$RMAN_BACKUP_JOB_DETAILS
order by start_time asc;
spool off
host sed -n -i '2,$ p' awr_storagesize_rman-tableau-&_instname-&_hostname..csv
-- host gzip -v awr_storagesize_rman-tableau-&_instname-&_hostname..csv
-- host tar -cvf awr_storagesize_rman-tableau-&_instname-&_hostname..tar awr_storagesize_rman-tableau-&_instname-&_hostname..csv.gz
-- host rm awr_storagesize_rman-tableau-&_instname-&_hostname..csv.gz
