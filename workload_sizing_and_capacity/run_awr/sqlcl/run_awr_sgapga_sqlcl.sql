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

-- ttitle center 'AWR SYSSTAT Report' skip 2

col instname    format a15              heading instname        -- instname
col hostname    format a30              heading hostname        -- hostname
col tm          format a17              heading tm              -- "tm"
col id          format 99999            heading id              -- "snapid"
col inst        format 90               heading inst            -- "inst"
col dur         format 999990.00        heading dur             -- "dur"
col cpu         format 90               heading cpu             -- "cpu"
col cap         format 9999990.00       heading cap             -- "capacity"
col dbt         format 999990.00        heading dbt             -- "DBTime"
col dbc         format 99990.00         heading dbc             -- "DBcpu"
col bgc         format 99990.00         heading bgc             -- "BGcpu"
col rman        format 9990.00          heading rman            -- "RMANcpu"
col aas         format 990.0            heading aas             -- "AAS"
col totora      format 9999990.00       heading totora          -- "TotalOracleCPU"
col busy        format 9999990.00       heading busy            -- "BusyTime"
col load        format 990.00           heading load            -- "OSLoad"
col totos       format 9999990.00       heading totos           -- "TotalOSCPU"
col mem         format 999990.00        heading mem             -- "PhysicalMemorymb"
col IORs        format 9990.000         heading IORs            -- "IOPsr"
col IOWs        format 9990.000         heading IOWs            -- "IOPsw"
col IORedo      format 9990.000         heading IORedo          -- "IOPsredo"
col IORmbs      format 9990.000         heading IORmbs          -- "IOrmbs"
col IOWmbs      format 9990.000         heading IOWmbs          -- "IOwmbs"
col redosizesec format 9990.000         heading redosizesec     -- "Redombs"
col logons      format 990              heading logons          -- "Sess"
col logone      format 990              heading logone          -- "SessEnd"
col logonscum   format 990              heading logons          -- "SessCum"
col exsraw      format 99990.000        heading exsraw          -- "Execrawdelta"
col exs         format 9990.000         heading exs             -- "Execs"
col ucs         format 9990.000         heading ucs             -- "UserCalls"
col ucoms       format 9990.000         heading ucoms           -- "Commit"
col urs         format 9990.000         heading urs             -- "Rollback"
col lios        format 9999990.00       heading lios            -- "LIOs"
col oracpupct   format 990              heading oracpupct       -- "OracleCPUPct"
col rmancpupct  format 990              heading rmancpupct      -- "RMANCPUPct"
col oscpupct    format 990              heading oscpupct        -- "OSCPUPct"
col oscpuusr    format 990              heading oscpuusr        -- "USRPct"
col oscpusys    format 990              heading oscpusys        -- "SYSPct"
col oscpuio     format 990              heading oscpuio         -- "IOPct"

VARIABLE  g_retention  NUMBER
DEFINE    p_default = 8
DEFINE    p_max = 100
SET VERIFY OFF
DECLARE
  v_default  NUMBER(3) := &p_default;
  v_max      NUMBER(3) := &p_max;
BEGIN
  select
    ((TRUNC(SYSDATE) + RETENTION - TRUNC(SYSDATE)) * 86400)/60/60/24 AS RETENTION_DAYS
    into :g_retention
  from dba_hist_wr_control
  where dbid in (select dbid from v$database);

  if :g_retention > v_default then
    :g_retention := v_max;
  else
    :g_retention := v_default;
  end if;
END;
/

spool awr_sgapga-tableau_sqlcl-sgapga-&_instname-&_hostname..csv
SELECT * FROM
(
  SELECT trim('&_instname') instname,
         trim('&_dbid') db_id,
         trim('&_hostname') hostname,
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
  (select snap_id, dbid, instance_number, sum(value) value from dba_hist_sga group by snap_id, dbid, instance_number) s37t1, -- total SGA allocated, just get the end value
  dba_hist_pgastat s36t1   -- total PGA allocated, just get the end value
WHERE s0.dbid            = &_dbid    -- CHANGE THE DBID HERE!
AND s1.dbid              = s0.dbid
AND s4t1.dbid            = s0.dbid
AND s36t1.dbid            = s0.dbid
AND s37t1.dbid            = s0.dbid
--AND s0.instance_number   = &_instancenumber   -- CHANGE THE INSTANCE_NUMBER HERE!
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
)
WHERE
to_date(tm,'MM/DD/YY HH24:MI:SS') > sysdate - :g_retention
-- id  in (select snap_id from (select * from r2toolkit.r2_regression_data union all select * from r2toolkit.r2_outlier_data))
-- id in (336)
-- aas > 1
-- oracpupct > 50
-- oscpupct > 50
-- AND TO_CHAR(s0.END_INTERVAL_TIME,'D') >= 1     -- Day of week: 1=Sunday 7=Saturday
-- AND TO_CHAR(s0.END_INTERVAL_TIME,'D') <= 7
-- AND TO_CHAR(s0.END_INTERVAL_TIME,'HH24MI') >= 0900     -- Hour
-- AND TO_CHAR(s0.END_INTERVAL_TIME,'HH24MI') <= 1800
-- AND s0.END_INTERVAL_TIME >= TO_DATE('2010-jan-17 00:00:00','yyyy-mon-dd hh24:mi:ss')     -- Data range
-- AND s0.END_INTERVAL_TIME <= TO_DATE('2010-aug-22 23:59:59','yyyy-mon-dd hh24:mi:ss')
ORDER BY id ASC;
spool off