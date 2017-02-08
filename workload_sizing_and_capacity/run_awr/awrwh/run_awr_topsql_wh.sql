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

spool awr_topsqlx_wh.csv
     select *
       from (
             select
                  sqt.target_name, 
                  sqt.dbid,
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
                          select target_name, dbid, snap_id, tm, inst, dur, sql_id, phv, parse_schema, module, elap, elapexec, cput, iowait, appwait, concurwait, clwait, bget, dskr, dpath, rowp, exec, prsc, pxexec, icbytes, offloadbytes, offloadreturnbytes, flashcachereads, uncompbytes, aas, time_rank
                          from
                                             (
                                               select
                                                      wh.target_name target_name, 
                                                      wh.new_dbid dbid,
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
                                                      (sum(e.optimized_physical_reads_delta)* 8192)/1024/1024 flashcachereads,
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
                                                   dba_hist_sqlstat e, 
                                                   dbsnmp.caw_dbid_mapping wh
                                                   where
                                                    s0.dbid                   = e.dbid
                                                    AND s0.dbid               = wh.new_dbid                
                                                    AND s1.dbid               = s0.dbid
                                                    and e.dbid                = s0.dbid
                                                    AND s1.instance_number    = s0.instance_number
                                                    and e.instance_number     = s0.instance_number
                                                    AND s1.snap_id            = s0.snap_id + 1
                                                    and e.snap_id             = s0.snap_id + 1
                                               group by
                                                    wh.target_name, wh.new_dbid, s0.snap_id, s0.END_INTERVAL_TIME, s0.instance_number, e.sql_id, e.plan_hash_value, e.parsing_schema_name, e.elapsed_time_delta, s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME
                                             )
                          where
                          time_rank <= 5                                     -- GET TOP 5 SQL ACROSS SNAP_IDs... YOU CAN ALTER THIS TO HAVE MORE DATA POINTS
                         )
                        sqt,
                        (select sql_id, dbid, nvl(b.name, a.command_type) sql_text from dba_hist_sqltext a, audit_actions b where a.command_type =  b.action(+)) st
             where st.sql_id(+)             = sqt.sql_id
             and st.dbid(+)                 = sqt.dbid
             )
/
spool off