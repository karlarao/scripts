-- awr_sysstat.sql
-- AWR CPU Workload Report
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

-- ttitle center 'AWR SYSSTAT Report' skip 2
set pagesize 50000
set linesize 550

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

spool awr_sgapga-tableau-sgapga-&_instname-&_hostname..csv
SELECT , TO_CHAR(start_time,'MM/DD/YY HH24:MI:SS') start_time, TO_CHAR(end_time,'MM/DD/YY HH24:MI:SS') end_time, component, oper_type, oper_mode, initial_size, target_size, final_size, status
    FROM dba_hist_memory_resize_ops
    ORDER BY 1, 2;
spool off
host sed -n -i '2,$ p' awr_sgapga-tableau-sgapga-&_instname-&_hostname..csv
-- host gzip -v awr_sgapga-tableau-sgapga-&_instname-&_hostname..csv
-- host tar -cvf awr_sgapga-tableau-sgapga-&_instname-&_hostname..tar awr_sgapga-tableau-sgapga-&_instname-&_hostname..csv.gz
-- host rm awr_sgapga-tableau-sgapga-&_instname-&_hostname..csv.gz
