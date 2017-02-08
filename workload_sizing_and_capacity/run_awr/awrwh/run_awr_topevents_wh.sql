-- awr_topevents.sql
-- AWR Top Events Report, a version of "Top 5 Timed Events" but across SNAP_IDs with AAS metric
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
-- Changes:
-- 20100427     included the columns "tm, inst, dur" and "event_rank"
-- 20100511     added timestamp to filter specific workload periods, must uncomment to use
-- 20120120     added a section to compute for "CPU wait" (new metric in 11g) to include the
--               "unaccounted for DB Time" on high run queue or CPU intensive workloads
-- 20120420     added NULLIF on pctdbt for very idle databases

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

spool awr_topevents_wh.csv
select 
  target_name,
  dbid,
  snap_id, 
  tm, inst, 
  dur, 
  event, 
  event_rank, 
  waits, 
  time, 
  avgwt, 
  pctdbt, 
  aas, 
  wait_class
from
      (select target_name, dbid, snap_id, TO_CHAR(tm,'MM/DD/YY HH24:MI:SS') tm, inst, dur, event, waits, time, avgwt, pctdbt, aas, wait_class,
            DENSE_RANK() OVER (
          PARTITION BY snap_id ORDER BY time DESC) event_rank
      from
              (
              select * from
                    (select * from
                          (select
                            wh.target_name target_name, 
                            wh.new_dbid dbid,
                            s0.snap_id snap_id,
                            s0.END_INTERVAL_TIME tm,
                            s0.instance_number inst,
                            round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                    + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                    + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                    + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
                            e.event_name event,
                            e.total_waits - nvl(b.total_waits,0)       waits,
                            round ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000, 2)  time,     -- THIS IS EVENT (sec)
                            round (decode ((e.total_waits - nvl(b.total_waits, 0)), 0, to_number(NULL), ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000) / (e.total_waits - nvl(b.total_waits,0))), 2) avgwt,
                            ((round ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000, 2)) / NULLIF(((s5t1.value - nvl(s5t0.value,0)) / 1000000),0))*100 as pctdbt,     -- THIS IS EVENT (sec) / DB TIME (sec)
                            (round ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000, 2))/60 /  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                            + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                            + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                            + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) aas,     -- THIS IS EVENT (min) / SnapDur (min) TO GET THE % DB CPU ON AAS
                            e.wait_class wait_class
                            from
                                 dba_hist_snapshot s0,
                                 dba_hist_snapshot s1,
                                 dba_hist_system_event b,
                                 dba_hist_system_event e,
                                 dba_hist_sys_time_model s5t0,
                                 dba_hist_sys_time_model s5t1,
                                 dbsnmp.caw_dbid_mapping wh
                            where wh.new_dbid           = s0.dbid
                              AND s1.dbid               = s0.dbid
                              and b.dbid(+)             = s0.dbid
                              and e.dbid                = s0.dbid
                              AND s5t0.dbid             = s0.dbid
                              AND s5t1.dbid             = s0.dbid
                              AND s1.instance_number    = s0.instance_number
                              and b.instance_number(+)  = s0.instance_number
                              and e.instance_number     = s0.instance_number
                              AND s5t0.instance_number = s0.instance_number
                              AND s5t1.instance_number = s0.instance_number
                              AND s1.snap_id            = s0.snap_id + 1
                              AND b.snap_id(+)          = s0.snap_id
                              and e.snap_id             = s0.snap_id + 1
                              AND s5t0.snap_id         = s0.snap_id
                              AND s5t1.snap_id         = s0.snap_id + 1
                              AND s5t0.stat_name       = 'DB time'
                              AND s5t1.stat_name       = s5t0.stat_name
                                    and b.event_id            = e.event_id
                                    and e.wait_class          != 'Idle'
                                    and e.total_waits         > nvl(b.total_waits,0)
                                    and e.event_name not in ('smon timer',
                                                             'pmon timer',
                                                             'dispatcher timer',
                                                             'dispatcher listen timer',
                                                             'rdbms ipc message')
                              )
                    union all
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
                                        'CPU time',
                                        0,
                                        round ((s6t1.value - s6t0.value) / 1000000, 2) as time,     -- THIS IS DB CPU (sec)
                                        0,
                                        ((round ((s6t1.value - s6t0.value) / 1000000, 2)) / NULLIF(((s5t1.value - nvl(s5t0.value,0)) / 1000000),0))*100 as pctdbt,     -- THIS IS DB CPU (sec) / DB TIME (sec)..TO GET % OF DB CPU ON DB TIME FOR TOP 5 TIMED EVENTS SECTION
                                        (round ((s6t1.value - s6t0.value) / 1000000, 2))/60 /  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                                    + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                                    + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                                    + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) aas,  -- THIS IS DB CPU (min) / SnapDur (min) TO GET THE % DB CPU ON AAS
                                        'CPU'
                                      from
                                        dba_hist_snapshot s0,
                                        dba_hist_snapshot s1,
                                        dba_hist_sys_time_model s6t0,
                                        dba_hist_sys_time_model s6t1,
                                        dba_hist_sys_time_model s5t0,
                                        dba_hist_sys_time_model s5t1,
                                        dbsnmp.caw_dbid_mapping wh
                                      where wh.new_dbid           = s0.dbid
                                      AND s1.dbid               = s0.dbid
                                      AND s6t0.dbid            = s0.dbid
                                      AND s6t1.dbid            = s0.dbid
                                      AND s5t0.dbid            = s0.dbid
                                      AND s5t1.dbid            = s0.dbid
                                      AND s1.instance_number    = s0.instance_number
                                      AND s6t0.instance_number = s0.instance_number
                                      AND s6t1.instance_number = s0.instance_number
                                      AND s5t0.instance_number = s0.instance_number
                                      AND s5t1.instance_number = s0.instance_number
                                      AND s1.snap_id            = s0.snap_id + 1
                                      AND s6t0.snap_id         = s0.snap_id
                                      AND s6t1.snap_id         = s0.snap_id + 1
                                      AND s5t0.snap_id         = s0.snap_id
                                      AND s5t1.snap_id         = s0.snap_id + 1
                                      AND s6t0.stat_name       = 'DB CPU'
                                      AND s6t1.stat_name       = s6t0.stat_name
                                      AND s5t0.stat_name       = 'DB time'
                                      AND s5t1.stat_name       = s5t0.stat_name
                    union all
                                      (select
                                               dbtime.target_name, 
                                               dbtime.dbid,
                                               dbtime.snap_id,
                                               dbtime.tm,
                                               dbtime.inst,
                                               dbtime.dur,
                                               'CPU wait',
                                                0,
                                                round(dbtime.time - accounted_dbtime.time, 2) time,     -- THIS IS UNACCOUNTED FOR DB TIME (sec)
                                                0,
                                                ((dbtime.aas - accounted_dbtime.aas)/ NULLIF(nvl(dbtime.aas,0),0))*100 as pctdbt,     -- THIS IS UNACCOUNTED FOR DB TIME (sec) / DB TIME (sec)
                                                round(dbtime.aas - accounted_dbtime.aas, 2) aas,     -- AAS OF UNACCOUNTED FOR DB TIME
                                                'CPU wait'
                                      from
                                                  (select
                                                     wh.target_name target_name, 
                                                     wh.new_dbid dbid,
                                                     s0.snap_id,
                                                     s0.END_INTERVAL_TIME tm,
                                                     s0.instance_number inst,
                                                    round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                    + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                    + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                    + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
                                                    'DB time',
                                                    0,
                                                    round ((s5t1.value - s5t0.value) / 1000000, 2) as time,     -- THIS IS DB time (sec)
                                                    0,
                                                    0,
                                                     (round ((s5t1.value - s5t0.value) / 1000000, 2))/60 /  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                                                    + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                                                    + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                                                    + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) aas,
                                                    'DB time'
                                                  from
                                                                    dba_hist_snapshot s0,
                                                                    dba_hist_snapshot s1,
                                                                    dba_hist_sys_time_model s5t0,
                                                                    dba_hist_sys_time_model s5t1,
                                                                    dbsnmp.caw_dbid_mapping wh
                                                                  where wh.new_dbid           = s0.dbid
                                                                  AND s1.dbid               = s0.dbid
                                                                  AND s5t0.dbid            = s0.dbid
                                                                  AND s5t1.dbid            = s0.dbid
                                                                  AND s1.instance_number    = s0.instance_number
                                                                  AND s5t0.instance_number = s0.instance_number
                                                                  AND s5t1.instance_number = s0.instance_number
                                                                  AND s1.snap_id            = s0.snap_id + 1
                                                                  AND s5t0.snap_id         = s0.snap_id
                                                                  AND s5t1.snap_id         = s0.snap_id + 1
                                                                  AND s5t0.stat_name       = 'DB time'
                                                                  AND s5t1.stat_name       = s5t0.stat_name) dbtime,
                                                  (select target_name, dbid, snap_id, inst, sum(time) time, sum(AAS) aas from
                                                          (select * from (select
                                                                wh.target_name target_name, 
                                                                wh.new_dbid dbid,
                                                                s0.snap_id snap_id,
                                                                s0.END_INTERVAL_TIME tm,
                                                                s0.instance_number inst,
                                                                round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                                        + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                                        + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                                        + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) dur,
                                                                e.event_name event,
                                                                e.total_waits - nvl(b.total_waits,0)       waits,
                                                                round ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000, 2)  time,     -- THIS IS EVENT (sec)
                                                                round (decode ((e.total_waits - nvl(b.total_waits, 0)), 0, to_number(NULL), ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000) / (e.total_waits - nvl(b.total_waits,0))), 2) avgwt,
                                                                ((round ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000, 2)) / NULLIF(((s5t1.value - nvl(s5t0.value,0)) / 1000000),0))*100 as pctdbt,     -- THIS IS EVENT (sec) / DB TIME (sec)
                                                                (round ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000, 2))/60 /  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                                                                + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                                                                + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                                                                + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) aas,     -- THIS IS EVENT (min) / SnapDur (min) TO GET THE % DB CPU ON AAS
                                                                e.wait_class wait_class
                                                          from
                                                               dba_hist_snapshot s0,
                                                               dba_hist_snapshot s1,
                                                               dba_hist_system_event b,
                                                               dba_hist_system_event e,
                                                               dba_hist_sys_time_model s5t0,
                                                               dba_hist_sys_time_model s5t1,
                                                               dbsnmp.caw_dbid_mapping wh
                                                            where wh.new_dbid           = s0.dbid
                                                            AND s1.dbid               = s0.dbid
                                                            and b.dbid(+)             = s0.dbid
                                                            and e.dbid                = s0.dbid
                                                            AND s5t0.dbid             = s0.dbid
                                                            AND s5t1.dbid             = s0.dbid
                                                            AND s1.instance_number    = s0.instance_number
                                                            and b.instance_number(+)  = s0.instance_number
                                                            and e.instance_number     = s0.instance_number
                                                            AND s5t0.instance_number = s0.instance_number
                                                            AND s5t1.instance_number = s0.instance_number
                                                            AND s1.snap_id            = s0.snap_id + 1
                                                            AND b.snap_id(+)          = s0.snap_id
                                                            and e.snap_id             = s0.snap_id + 1
                                                            AND s5t0.snap_id         = s0.snap_id
                                                            AND s5t1.snap_id         = s0.snap_id + 1
                                                      AND s5t0.stat_name       = 'DB time'
                                                      AND s5t1.stat_name       = s5t0.stat_name
                                                            and b.event_id            = e.event_id
                                                            and e.wait_class          != 'Idle'
                                                            and e.total_waits         > nvl(b.total_waits,0)
                                                            and e.event_name not in ('smon timer',
                                                                                     'pmon timer',
                                                                                     'dispatcher timer',
                                                                                     'dispatcher listen timer',
                                                                                     'rdbms ipc message')
                                                                  )
                                                    union all
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
                                                                    'CPU time',
                                                                    0,
                                                                    round ((s6t1.value - s6t0.value) / 1000000, 2) as time,     -- THIS IS DB CPU (sec)
                                                                    0,
                                                                    ((round ((s6t1.value - s6t0.value) / 1000000, 2)) / NULLIF(((s5t1.value - nvl(s5t0.value,0)) / 1000000),0))*100 as pctdbt,     -- THIS IS DB CPU (sec) / DB TIME (sec)..TO GET % OF DB CPU ON DB TIME FOR TOP 5 TIMED EVENTS SECTION
                                                                    (round ((s6t1.value - s6t0.value) / 1000000, 2))/60 /  round(EXTRACT(DAY FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 1440
                                                                                                + EXTRACT(HOUR FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) * 60
                                                                                                + EXTRACT(MINUTE FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME)
                                                                                                + EXTRACT(SECOND FROM s1.END_INTERVAL_TIME - s0.END_INTERVAL_TIME) / 60, 2) aas,  -- THIS IS DB CPU (min) / SnapDur (min) TO GET THE % DB CPU ON AAS
                                                                    'CPU'
                                                                  from
                                                                    dba_hist_snapshot s0,
                                                                    dba_hist_snapshot s1,
                                                                    dba_hist_sys_time_model s6t0,
                                                                    dba_hist_sys_time_model s6t1,
                                                                    dba_hist_sys_time_model s5t0,
                                                                    dba_hist_sys_time_model s5t1,
                                                                    dbsnmp.caw_dbid_mapping wh
                                                                  where wh.new_dbid           = s0.dbid
                                                                  AND s1.dbid               = s0.dbid
                                                                  AND s6t0.dbid            = s0.dbid
                                                                  AND s6t1.dbid            = s0.dbid
                                                                  AND s5t0.dbid            = s0.dbid
                                                                  AND s5t1.dbid            = s0.dbid
                                                                  AND s1.instance_number    = s0.instance_number
                                                                  AND s6t0.instance_number = s0.instance_number
                                                                  AND s6t1.instance_number = s0.instance_number
                                                                  AND s5t0.instance_number = s0.instance_number
                                                                  AND s5t1.instance_number = s0.instance_number
                                                                  AND s1.snap_id            = s0.snap_id + 1
                                                                  AND s6t0.snap_id         = s0.snap_id
                                                                  AND s6t1.snap_id         = s0.snap_id + 1
                                                                  AND s5t0.snap_id         = s0.snap_id
                                                                  AND s5t1.snap_id         = s0.snap_id + 1
                                                                  AND s6t0.stat_name       = 'DB CPU'
                                                                  AND s6t1.stat_name       = s6t0.stat_name
                                                                  AND s5t0.stat_name       = 'DB time'
                                                                  AND s5t1.stat_name       = s5t0.stat_name
                                                          ) group by target_name, dbid, snap_id, inst) accounted_dbtime
                                                            where dbtime.snap_id = accounted_dbtime.snap_id
                                                            and dbtime.inst = accounted_dbtime.inst
                                                            and dbtime.dbid = accounted_dbtime.dbid
                                        )
                    )
              )
      )
WHERE event_rank <= 5
/
spool off