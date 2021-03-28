-- awr_services.sql
-- AWR Services Statistics Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
--
-- Changes:

set echo off verify off

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
select distinct block_size blocksize from v$datafile;

set feedback off pages 0 term off head on und off trimspool on echo off lines 4000 colsep ','

set arraysize 5000
set termout off
set echo off verify off


COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;

COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;

COLUMN name NEW_VALUE _hostname NOPRINT
select lower(host_name) name from v$instance;

COLUMN instancenumber NEW_VALUE _instancenumber NOPRINT
select instance_number instancenumber from v$instance;

-- ttitle center 'AWR Services Statistics Report' skip 2
set pagesize 50000
set linesize 550

col instname    format a15
col hostname    format a30
col tm          format a15              heading tm           --"Snap|Start|Time"
col id          format 99999            heading id           --"Snap|ID"
col inst        format 90               heading inst         --"i|n|s|t|#"
col dur         format 999990.00        heading dur          --"Snap|Dur|(m)"
col cpu         format 90               heading cpu          --"C|P|U"
col cap         format 9999990.00       heading cap          --"***|Total|CPU|Time|(s)"
col dbt         format 999990.00        heading dbt          --"DB|Time"
col dbc         format 99990.00         heading dbc          --"DB|CPU"
col bgc         format 99990.00         heading bgc          --"Bg|CPU"
col rman        format 9990.00          heading rman         --"RMAN|CPU"
col aas         format 990.0            heading aas          --"A|A|S"
col totora      format 9999990.00       heading totora       --"***|Total|Oracle|CPU|(s)"
col busy        format 9999990.00       heading busy         --"Busy|Time"
col load        format 990.00           heading load         --"OS|Load"
col totos       format 9999990.00       heading totos        --"***|Total|OS|CPU|(s)"
col mem         format 999990.00        heading mem          --"Physical|Memory|(mb)"
col IORs        format 9990.000         heading IORs         --"IOPs|r"
col IOWs        format 9990.000         heading IOWs         --"IOPs|w"
col IORedo      format 9990.000         heading IORedo       --"IOPs|redo"
col IORmbs      format 9990.000         heading IORmbs       --"IO r|(mb)/s"
col IOWmbs      format 9990.000         heading IOWmbs       --"IO w|(mb)/s"
col redosizesec format 9990.000         heading redosizesec  --"Redo|(mb)/s"
col logons      format 990              heading logons       --"Sess"
col logone      format 990              heading logone       --"Sess|End"
col exsraw      format 99990.000        heading exsraw       --"Exec|raw|delta"
col exs         format 9990.000         heading exs          --"Exec|/s"
col oracpupct   format 990              heading oracpupct    --"Oracle|CPU|%"
col rmancpupct  format 990              heading rmancpupct   --"RMAN|CPU|%"
col oscpupct    format 990              heading oscpupct     --"OS|CPU|%"
col oscpuusr    format 990              heading oscpuusr     --"U|S|R|%"
col oscpusys    format 990              heading oscpusys     --"S|Y|S|%"
col oscpuio     format 990              heading oscpuio      --"I|O|%"
col phy_reads   format 99999990.00      heading phy_reads    --"physical|reads"
col log_reads   format 99999990.00      heading log_reads    --"logical|reads"

VARIABLE  g_retention  NUMBER
DEFINE    p_default = 8
DEFINE    p_max = 300
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

spool awr_services-tableau-&_instname-&_hostname..csv
select * from
(
select  trim('&_instname') instname, trim('&_dbid') db_id, trim('&_hostname') hostname, snap_id,
        TO_CHAR(tm,'MM/DD/YY HH24:MI:SS') tm,
        inst,
        dur,
        service_name,
        round(db_time / 1000000, 1) as dbt,
        round(db_cpu  / 1000000, 1) as dbc,
        phy_reads,
        log_reads,
        aas
 from (select
          s1.snap_id,
          s1.tm,
          s1.inst,
          s1.dur,
          s1.service_name,
          sum(decode(s1.stat_name, 'DB time', s1.diff, 0)) db_time,
          sum(decode(s1.stat_name, 'DB CPU',  s1.diff, 0)) db_cpu,
          sum(decode(s1.stat_name, 'physical reads', s1.diff, 0)) phy_reads,
          sum(decode(s1.stat_name, 'session logical reads', s1.diff, 0)) log_reads,
          round(sum(decode(s1.stat_name, 'DB time', s1.diff, 0))/1000000,1)/60 / s1.dur as aas
   from
     (select s0.snap_id snap_id,
             s0.END_INTERVAL_TIME tm,
             s0.instance_number inst,
            round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                  + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                  + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                  + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
             e.service_name     service_name,
             e.stat_name        stat_name,
             e.value - b.value  diff
       from dba_hist_snapshot s0,
            dba_hist_snapshot s1,
            dba_hist_service_stat b,
            dba_hist_service_stat e
       where
         s0.dbid                  = &_dbid            -- CHANGE THE DBID HERE!
         and s1.dbid              = s0.dbid
         and b.dbid               = s0.dbid
         and e.dbid               = s0.dbid
         --and s0.instance_number   = &_instancenumber  -- CHANGE THE INSTANCE_NUMBER HERE!
         and s1.instance_number   = s0.instance_number
         and b.instance_number    = s0.instance_number
         and e.instance_number    = s0.instance_number
         and s1.snap_id           = s0.snap_id + 1
         and b.snap_id            = s0.snap_id
         and e.snap_id            = s0.snap_id + 1
         and b.stat_id            = e.stat_id
         and b.service_name_hash  = e.service_name_hash) s1
   group by
     s1.snap_id, s1.tm, s1.inst, s1.dur, s1.service_name
   order by
     snap_id asc, aas desc, service_name)
)
WHERE
to_date(tm,'MM/DD/YY HH24:MI:SS') > sysdate - :g_retention
-- where
-- AND TO_CHAR(tm,'D') >= 1     -- Day of week: 1=Sunday 7=Saturday
-- AND TO_CHAR(tm,'D') <= 7
-- AND TO_CHAR(tm,'HH24MI') >= 0900     -- Hour
-- AND TO_CHAR(tm,'HH24MI') <= 1800
-- AND tm >= TO_DATE('2010-jan-17 00:00:00','yyyy-mon-dd hh24:mi:ss')     -- Data range
-- AND tm <= TO_DATE('2010-aug-22 23:59:59','yyyy-mon-dd hh24:mi:ss')
-- snap_id = 338
-- and snap_id >= 335 and snap_id <= 339
-- aas > .5
;
spool off
host sed -n -i '2,$ p' awr_services-tableau-&_instname-&_hostname..csv
-- host gzip -v awr_services-tableau-&_instname-&_hostname..csv
-- host tar -cvf awr_services-tableau-&_instname-&_hostname..tar awr_services-tableau-&_instname-&_hostname..csv.gz
-- host rm awr_services-tableau-&_instname-&_hostname..csv.gz
