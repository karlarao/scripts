-- awr_topsqlx-exa.sql
-- AWR Top SQL Report, a version of "Top SQL" but across SNAP_IDs with AAS metric and more details
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
-- NOTES: SEE COMMENTS ON THE SCRIPT..ESPECIALLY ON SQL_TEXT, TIME_RANK, AND ORDER BY SECTIONS
--
-- Changes:
-- 20100512     added timestamp to filter specific workload periods, must uncomment to use
-- 20120825     added the join of dba_hist_sqltext to audit_actions to show the short name of command_type

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

-- ttitle center 'AWR Top SQL Report' skip 2

col snap_id             format 99999            heading -- "Snap|ID"
col tm                  format a15              heading -- "Snap|Start|Time"
col inst                format 90               heading -- "i|n|s|t|#"
col dur                 format 990.00           heading -- "Snap|Dur|(m)"
col sql_id              format a15              heading -- "SQL|ID"
col phv                 format 99999999999      heading -- "Plan|Hash|Value"
col module              format a50
col elap                format 999990.00        heading -- "Ela|Time|(s)"
col elapexec            format 999990.00        heading -- "Ela|Time|per|exec|(s)"
col cput                format 999990.00        heading -- "CPU|Time|(s)"
col iowait              format 999990.00        heading -- "IO|Wait|(s)"
col appwait             format 999990.00        heading -- "App|Wait|(s)"
col concurwait          format 999990.00        heading -- "Ccr|Wait|(s)"
col clwait              format 999990.00        heading -- "Cluster|Wait|(s)"
col bget                format 99999999990      heading -- "LIO"
col dskr                format 99999999990      heading -- "PIO"
col dpath               format 99999999990      heading -- "Direct|Writes"
col rowp                format 99999999990      heading -- "Rows"
col exec                format 9999990          heading -- "Exec"
col prsc                format 999999990        heading -- "Parse|Count"
col pxexec              format 9999990          heading -- "PX|Server|Exec"
col icbytes             format 99999990         heading -- "IC|MB"
col offloadbytes        format 99999990         heading -- "Offload|MB"
col offloadreturnbytes  format 99999990         heading -- "Offload|return|MB"
col flashcachereads     format 99999990         heading -- "Flash|Cache|MB"
col uncompbytes         format 99999990         heading -- "Uncomp|MB"
col pctdbt              format 990              heading -- "DB Time|%"
col aas                 format 990.00           heading -- "A|A|S"
col time_rank           format 90               heading -- "Time|Rank"
col sql_text            format a6               heading -- "SQL|Text"

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

spool awr_topsqlx-tableau-exa_sqlcl-&_instname-&_hostname..csv
     select *
       from (
             select
                  trim('&_instname') instname,
                  trim('&_dbid') db_id,
                  trim('&_hostname') hostname,
                  sqt.snap_id snap_id,
                  TO_CHAR(sqt.tm,'MM/DD/YY HH24:MI:SS') tm,
                  sqt.inst inst,
                  sqt.dur dur,
                  sqt.aas aas,
                  nvl((sqt.elap), to_number(null)) elap,
                  nvl((sqt.elapexec), 0) elapexec,
                  nvl((sqt.cput), to_number(null)) cput,
                  sqt.iowait iowait,
                  sqt.appwait appwait,
                  sqt.concurwait concurwait,
                  sqt.clwait clwait,
                  sqt.bget bget,
                  sqt.dskr dskr,
                  sqt.dpath dpath,
                  sqt.rowp rowp,
                  sqt.exec exec,
                  sqt.prsc prsc,
                  sqt.pxexec pxexec,
                  sqt.icbytes,
                  sqt.offloadbytes,
                  sqt.offloadreturnbytes,
                  sqt.flashcachereads,
                  sqt.uncompbytes,
                  sqt.time_rank time_rank,
                  sqt.sql_id sql_id,
                  sqt.phv phv,
                  sqt.parse_schema parse_schema,
                  substr(to_clob(decode(sqt.module, null, null, sqt.module)),1,50) module,
                  st.sql_text sql_text     -- PUT/REMOVE COMMENT TO HIDE/SHOW THE SQL_TEXT
             from        (
                          select snap_id, tm, inst, dur, sql_id, phv, parse_schema, module, elap, elapexec, cput, iowait, appwait, concurwait, clwait, bget, dskr, dpath, rowp, exec, prsc, pxexec, icbytes, offloadbytes, offloadreturnbytes, flashcachereads, uncompbytes, aas, time_rank
                          from
                                             (
                                               select
                                                      s0.snap_id snap_id,
                                                      s0.END_INTERVAL_TIME tm,
                                                      s0.instance_number inst,
                                                      round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                              + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                              + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                              + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
                                                      e.sql_id sql_id,
                                                      e.plan_hash_value phv,
                                                      e.parsing_schema_name parse_schema,
                                                      max(e.module) module,
                                                      sum(e.elapsed_time_delta)/1000000 elap,
                                                      decode((sum(e.executions_delta)), 0, to_number(null), ((sum(e.elapsed_time_delta)) / (sum(e.executions_delta)) / 1000000)) elapexec,
                                                      sum(e.cpu_time_delta)/1000000     cput,
                                                      sum(e.iowait_delta)/1000000 iowait,
                                                      sum(e.apwait_delta)/1000000 appwait,
                                                      sum(e.ccwait_delta)/1000000 concurwait,
                                                      sum(e.clwait_delta)/1000000 clwait,
                                                      sum(e.buffer_gets_delta) bget,
                                                      sum(e.disk_reads_delta) dskr,
                                                      sum(e.direct_writes_delta) dpath,
                                                      sum(e.rows_processed_delta) rowp,
                                                      sum(e.executions_delta)   exec,
                                                      sum(e.parse_calls_delta) prsc,
                                                      sum(e.px_servers_execs_delta) pxexec,
                                                      sum(e.io_interconnect_bytes_delta)/1024/1024 icbytes,
                                                      sum(e.io_offload_elig_bytes_delta)/1024/1024 offloadbytes,
                                                      sum(e.io_offload_return_bytes_delta)/1024/1024 offloadreturnbytes,
                                                      (sum(e.optimized_physical_reads_delta)* &_blocksize)/1024/1024 flashcachereads,
                                                      sum(e.cell_uncompressed_bytes_delta)/1024/1024 uncompbytes,
                                                      (sum(e.elapsed_time_delta)/1000000) / ((round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                                                            + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                                                            + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                                                            + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2))*60) aas,
                                                      DENSE_RANK() OVER (
                                                      PARTITION BY s0.snap_id ORDER BY e.elapsed_time_delta DESC) time_rank
                                               from
                                                   dba_hist_snapshot s0,
                                                   dba_hist_snapshot s1,
                                                   dba_hist_sqlstat e
                                                   where
                                                    s0.dbid                   = &_dbid                -- CHANGE THE DBID HERE!
                                                    AND s1.dbid               = s0.dbid
                                                    and e.dbid                = s0.dbid
                                                    --AND s0.instance_number    = &_instancenumber      -- CHANGE THE INSTANCE_NUMBER HERE!
                                                    AND s1.instance_number    = s0.instance_number
                                                    and e.instance_number     = s0.instance_number
                                                    AND s1.snap_id            = s0.snap_id + 1
                                                    and e.snap_id             = s0.snap_id + 1
                                               group by
                                                    s0.snap_id, s0.END_INTERVAL_TIME, s0.instance_number, e.sql_id, e.plan_hash_value, e.parsing_schema_name, e.elapsed_time_delta, s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME
                                             )
                          where
                          time_rank <= 5                                     -- GET TOP 5 SQL ACROSS SNAP_IDs... YOU CAN ALTER THIS TO HAVE MORE DATA POINTS
                         )
                        sqt,
                        (select sql_id, dbid, nvl(b.name, a.command_type) sql_text from dba_hist_sqltext a, audit_actions b where a.command_type =  b.action(+)) st
             where st.sql_id(+)             = sqt.sql_id
             and st.dbid(+)                 = &_dbid
-- AND TO_CHAR(tm,'D') >= 1                                                  -- Day of week: 1=Sunday 7=Saturday
-- AND TO_CHAR(tm,'D') <= 7
-- AND TO_CHAR(tm,'HH24MI') >= 0900                                          -- Hour
-- AND TO_CHAR(tm,'HH24MI') <= 1800
-- AND tm >= TO_DATE('2010-jan-17 00:00:00','yyyy-mon-dd hh24:mi:ss')     -- Data range
-- AND tm <= TO_DATE('2010-aug-22 23:59:59','yyyy-mon-dd hh24:mi:ss')
-- AND snap_id in (338,339)
-- AND snap_id = 338
-- AND snap_id >= 335 and snap_id <= 339
-- AND lower(st.sql_text) like 'select%'
-- AND lower(st.sql_text) like 'insert%'
-- AND lower(st.sql_text) like 'update%'
-- AND lower(st.sql_text) like 'merge%'
-- AND pxexec > 0
-- AND aas > .5
             order by
             snap_id                             -- TO GET SQL OUTPUT ACROSS SNAP_IDs SEQUENTIALLY AND ASC
             -- nvl(sqt.elap, -1) desc, sqt.sql_id     -- TO GET SQL OUTPUT BY ELAPSED TIME
             )
-- where rownum <= 20
WHERE
to_date(tm,'MM/DD/YY HH24:MI:SS') > sysdate - :g_retention
;
spool off