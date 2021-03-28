-- awr_topsegments
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

-- ttitle center 'AWR Top Segments' skip 2

spool awr_topsegments-tableau_sqlcl-&_instname-&_hostname..csv
SELECT
  trim('&_instname') instname,
  trim('&_dbid') db_id,
  trim('&_hostname') hostname,
  snap_id, tm, inst,
  owner,
  tablespace_name,
  dataobj#,
  object_name,
  subobject_name,
  object_type,
  physical_rw,
  LOGICAL_READS_DELTA,
  BUFFER_BUSY_WAITS_DELTA,
  DB_BLOCK_CHANGES_DELTA,
  PHYSICAL_READS_DELTA,
  PHYSICAL_WRITES_DELTA,
  PHYSICAL_READS_DIRECT_DELTA,
  PHYSICAL_WRITES_DIRECT_DELTA,
  ITL_WAITS_DELTA,
  ROW_LOCK_WAITS_DELTA,
  GC_CR_BLOCKS_SERVED_DELTA,
  GC_CU_BLOCKS_SERVED_DELTA,
  GC_BUFFER_BUSY_DELTA,
  GC_CR_BLOCKS_RECEIVED_DELTA,
  GC_CU_BLOCKS_RECEIVED_DELTA,
  SPACE_USED_DELTA,
  SPACE_ALLOCATED_DELTA,
  TABLE_SCANS_DELTA,
  CHAIN_ROW_EXCESS_DELTA,
  PHYSICAL_READ_REQUESTS_DELTA,
  PHYSICAL_WRITE_REQUESTS_DELTA,
  OPTIMIZED_PHYSICAL_READS_DELTA,
  seg_rank
FROM
    (
        SELECT
          r.snap_id,
          TO_CHAR(r.tm,'MM/DD/YY HH24:MI:SS') tm,
          r.inst,
          n.owner,
          n.tablespace_name,
          n.dataobj#,
          n.object_name,
          CASE
            WHEN LENGTH(n.subobject_name) < 11
            THEN n.subobject_name
            ELSE SUBSTR(n.subobject_name,LENGTH(n.subobject_name)-9)
          END subobject_name,
          n.object_type,
          (r.PHYSICAL_READS_DELTA + r.PHYSICAL_WRITES_DELTA) as physical_rw,
          r.LOGICAL_READS_DELTA,
          r.BUFFER_BUSY_WAITS_DELTA,
          r.DB_BLOCK_CHANGES_DELTA,
          r.PHYSICAL_READS_DELTA,
          r.PHYSICAL_WRITES_DELTA,
          r.PHYSICAL_READS_DIRECT_DELTA,
          r.PHYSICAL_WRITES_DIRECT_DELTA,
          r.ITL_WAITS_DELTA,
          r.ROW_LOCK_WAITS_DELTA,
          r.GC_CR_BLOCKS_SERVED_DELTA,
          r.GC_CU_BLOCKS_SERVED_DELTA,
          r.GC_BUFFER_BUSY_DELTA,
          r.GC_CR_BLOCKS_RECEIVED_DELTA,
          r.GC_CU_BLOCKS_RECEIVED_DELTA,
          r.SPACE_USED_DELTA,
          r.SPACE_ALLOCATED_DELTA,
          r.TABLE_SCANS_DELTA,
          r.CHAIN_ROW_EXCESS_DELTA,
          r.PHYSICAL_READ_REQUESTS_DELTA,
          r.PHYSICAL_WRITE_REQUESTS_DELTA,
          r.OPTIMIZED_PHYSICAL_READS_DELTA,
          DENSE_RANK() OVER (PARTITION BY r.snap_id ORDER BY r.PHYSICAL_READS_DELTA + r.PHYSICAL_WRITES_DELTA DESC) seg_rank
        FROM
              dba_hist_seg_stat_obj n,
              (
                SELECT
                  s0.snap_id snap_id,
                  s0.END_INTERVAL_TIME tm,
                  s0.instance_number inst,
                  b.dataobj#,
                  b.obj#,
                  b.dbid,
                  sum(b.LOGICAL_READS_DELTA) LOGICAL_READS_DELTA,
                  sum(b.BUFFER_BUSY_WAITS_DELTA) BUFFER_BUSY_WAITS_DELTA,
                  sum(b.DB_BLOCK_CHANGES_DELTA) DB_BLOCK_CHANGES_DELTA,
                  sum(b.PHYSICAL_READS_DELTA) PHYSICAL_READS_DELTA,
                  sum(b.PHYSICAL_WRITES_DELTA) PHYSICAL_WRITES_DELTA,
                  sum(b.PHYSICAL_READS_DIRECT_DELTA) PHYSICAL_READS_DIRECT_DELTA,
                  sum(b.PHYSICAL_WRITES_DIRECT_DELTA) PHYSICAL_WRITES_DIRECT_DELTA,
                  sum(b.ITL_WAITS_DELTA) ITL_WAITS_DELTA,
                  sum(b.ROW_LOCK_WAITS_DELTA) ROW_LOCK_WAITS_DELTA,
                  sum(b.GC_CR_BLOCKS_SERVED_DELTA) GC_CR_BLOCKS_SERVED_DELTA,
                  sum(b.GC_CU_BLOCKS_SERVED_DELTA) GC_CU_BLOCKS_SERVED_DELTA,
                  sum(b.GC_BUFFER_BUSY_DELTA) GC_BUFFER_BUSY_DELTA,
                  sum(b.GC_CR_BLOCKS_RECEIVED_DELTA) GC_CR_BLOCKS_RECEIVED_DELTA,
                  sum(b.GC_CU_BLOCKS_RECEIVED_DELTA) GC_CU_BLOCKS_RECEIVED_DELTA,
                  sum(b.SPACE_USED_DELTA) SPACE_USED_DELTA,
                  sum(b.SPACE_ALLOCATED_DELTA) SPACE_ALLOCATED_DELTA,
                  sum(b.TABLE_SCANS_DELTA) TABLE_SCANS_DELTA,
                  sum(b.CHAIN_ROW_EXCESS_DELTA) CHAIN_ROW_EXCESS_DELTA,
                  sum(b.PHYSICAL_READ_REQUESTS_DELTA) PHYSICAL_READ_REQUESTS_DELTA,
                  sum(b.PHYSICAL_WRITE_REQUESTS_DELTA) PHYSICAL_WRITE_REQUESTS_DELTA,
                  sum(b.OPTIMIZED_PHYSICAL_READS_DELTA) OPTIMIZED_PHYSICAL_READS_DELTA
                FROM
                    dba_hist_snapshot s0,
                    dba_hist_snapshot s1,
                    dba_hist_seg_stat b
                WHERE
                    s0.dbid                  = &_dbid
                    AND s1.dbid              = s0.dbid
                    AND b.dbid               = s0.dbid
                    --AND s0.instance_number   = &_instancenumber
                    AND s1.instance_number   = s0.instance_number
                    AND b.instance_number    = s0.instance_number
                    AND s1.snap_id           = s0.snap_id + 1
                    AND b.snap_id            = s0.snap_id + 1
                    --AND s0.snap_id = 35547
                GROUP BY
                  s0.snap_id, s0.END_INTERVAL_TIME, s0.instance_number, b.dataobj#, b.obj#, b.dbid
              ) r
        WHERE n.dataobj#     = r.dataobj#
        AND n.obj#           = r.obj#
        AND n.dbid           = r.dbid
        AND r.PHYSICAL_READS_DELTA + r.PHYSICAL_WRITES_DELTA > 0
        ORDER BY physical_rw DESC,
          object_name,
          owner,
          subobject_name
    )
WHERE
seg_rank <=5
order by inst, snap_id, seg_rank asc;
spool off