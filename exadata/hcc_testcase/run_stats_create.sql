-- added the wait events, the initial versions are from carlos sierra and andy klock
-- usage: 
--  exec get_snap_time.begin_snap('Test 1')
--  run SQL code
--  exec get_snap_time.end_snap('Test 1')


create table get_run_stats 
   (    test_name varchar2(100), 
    snap_type varchar2(5), 
    snap_time date, 
    stat_class varchar2(100), 
    name varchar2(100), 
    value number)
/

create or replace package get_snap_time is
  procedure begin_snap (p_run_name varchar2);
  procedure end_snap (p_run_name varchar2);
end get_snap_time;
/

create or replace package body get_snap_time is
  procedure begin_snap (p_run_name varchar2) is
    l_sysdate date:=sysdate; 
   
    begin
        -- snap begin elapsed time
        insert into get_run_stats values (p_run_name,'BEGIN',l_sysdate,'ELAPSED','elapsed time',null);

        -- snap begin mystat
        insert into get_run_stats
        SELECT p_run_name record_type,
               'BEGIN',
               l_sysdate,
               TRIM (',' FROM
               TRIM (' ' FROM
               DECODE(BITAND(n.class,   1),   1, 'User, ')||
               DECODE(BITAND(n.class,   2),   2, 'Redo, ')||
               DECODE(BITAND(n.class,   4),   4, 'Enqueue, ')||
               DECODE(BITAND(n.class,   8),   8, 'Cache, ')||
               DECODE(BITAND(n.class,  16),  16, 'OS, ')||
               DECODE(BITAND(n.class,  32),  32, 'RAC, ')||
               DECODE(BITAND(n.class,  64),  64, 'SQL, ')||
               DECODE(BITAND(n.class, 128), 128, 'Debug, ')
               )) class,
               n.name,
               s.value
          FROM v$mystat s,
               v$statname n
        WHERE s.statistic# = n.statistic#;

        -- snap begin wait event
        insert into get_run_stats
        select 
            p_run_name record_type,
            'BEGIN',
            l_sysdate,
            wait_class || ' - ' || event as class, 
            measure, 
            value
        from 
        (
        select * from v$session_event 
        unpivot (value for measure in (TOTAL_WAITS as 'TOTAL_WAITS', 
                                        TOTAL_TIMEOUTS as 'TOTAL_TIMEOUTS',
                                        TIME_WAITED as 'TIME_WAITED',
                                        AVERAGE_WAIT as 'AVERAGE_WAIT',
                                        MAX_WAIT as 'MAX_WAIT',
                                        TIME_WAITED_MICRO as 'TIME_WAITED_MICRO', 
                                        EVENT_ID as 'EVENT_ID',
                                        WAIT_CLASS_ID as 'WAIT_CLASS_ID',
                                        WAIT_CLASS# as 'WAIT_CLASS#'
                                        ))
        where sid in (select /*+ no_merge */ sid from v$mystat where rownum = 1)
        );

        commit;
  end begin_snap;

  procedure end_snap (p_run_name varchar2) is
    l_sysdate date:=sysdate;
    begin
        -- snap end elapsed time
        insert into get_run_stats values (p_run_name,'END',l_sysdate,'ELAPSED','elapsed time',null);

        -- snap end mystat
        insert into get_run_stats
        SELECT p_run_name record_type,
               'END',
               l_sysdate,
               TRIM (',' FROM
               TRIM (' ' FROM
               DECODE(BITAND(n.class,   1),   1, 'User, ')||
               DECODE(BITAND(n.class,   2),   2, 'Redo, ')||
               DECODE(BITAND(n.class,   4),   4, 'Enqueue, ')||
               DECODE(BITAND(n.class,   8),   8, 'Cache, ')||
               DECODE(BITAND(n.class,  16),  16, 'OS, ')||
               DECODE(BITAND(n.class,  32),  32, 'RAC, ')||
               DECODE(BITAND(n.class,  64),  64, 'SQL, ')||
               DECODE(BITAND(n.class, 128), 128, 'Debug, ')
               )) class,
               n.name,
               s.value
          FROM v$mystat s,
               v$statname n
        WHERE s.statistic# = n.statistic#;

        -- snap end wait event
        insert into get_run_stats
        select 
            p_run_name record_type,
            'END',
            l_sysdate,
            wait_class || ' - ' || event as class, 
            measure, 
            value
        from 
        (
        select * from v$session_event 
        unpivot (value for measure in (TOTAL_WAITS as 'TOTAL_WAITS', 
                                        TOTAL_TIMEOUTS as 'TOTAL_TIMEOUTS',
                                        TIME_WAITED as 'TIME_WAITED',
                                        AVERAGE_WAIT as 'AVERAGE_WAIT',
                                        MAX_WAIT as 'MAX_WAIT',
                                        TIME_WAITED_MICRO as 'TIME_WAITED_MICRO', 
                                        EVENT_ID as 'EVENT_ID',
                                        WAIT_CLASS_ID as 'WAIT_CLASS_ID',
                                        WAIT_CLASS# as 'WAIT_CLASS#'
                                        ))
        where sid in (select /*+ no_merge */ sid from v$mystat where rownum = 1)
        );

        commit;
  end end_snap;

end get_snap_time;
/


