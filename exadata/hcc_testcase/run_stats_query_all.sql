
    col test_name format a15
    col name format a70
    select test_name, begin_snap, end_snap, snap_type, stat_class, name, delta from 
    (
    select 
            test_name, 
            snap_type, 
            stat_class,
            'secs - ' || name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (snap_time - (lag(snap_time) over (order by snap_time)))*86400 delta
        from get_run_stats
        where name = 'elapsed time'
    union all   
    select 
            test_name, 
            snap_type, 
            stat_class,
            name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            value-lag(value) over (order by snap_time) delta
        from get_run_stats
    )
    where snap_type = 'END'
    and delta > 0
    /

