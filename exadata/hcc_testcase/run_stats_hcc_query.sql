
    col test_name format a20
    col name format a60
    col stat_class format a45
    select substr(test_name,1,20) test_name, begin_snap, end_snap, stat_class, name, delta from 
    (
    select 
            test_name, snap_type, stat_class,
            'secs - ' || name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (snap_time - (lag(snap_time) over (order by snap_time)))*86400 delta,
            1 stat_order
    	from get_run_stats
    	where name = 'elapsed time'
    union all	
    select 
            test_name, snap_type, stat_class,
            'secs - ' || name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time))/100 delta,
            2 stat_order
    	from get_run_stats
        where name = 'CPU used by this session'
    union all   
    select 
            test_name, snap_type, stat_class,
            'MB/s - ' || name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time))/1024/1024 delta,
            3 stat_order
        from get_run_stats
        where name = 'cell physical IO bytes eligible for predicate offload'
    union all   
    select 
            test_name, snap_type, stat_class,
            'MB/s - ' || name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time))/1024/1024 delta,
            4 stat_order
        from get_run_stats
        where name = 'physical read total bytes'
    union all   
    select 
            test_name, snap_type, stat_class,
            'MB/s - ' || name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time))/1024/1024 delta,
            5 stat_order
        from get_run_stats
        where name = 'cell physical IO interconnect bytes'
    union all   
    select 
            test_name, snap_type, stat_class,
            'MB/s - ' || name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time))/1024/1024 delta,
            6 stat_order
        from get_run_stats
        where name = 'cell IO uncompressed bytes'
    union all   
    select 
            test_name, snap_type, stat_class,
            name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time)) delta,
            7 stat_order
        from get_run_stats
        where name = 'cell CUs processed for uncompressed'                                
    union all   
    select 
            test_name, snap_type, stat_class,
            name as name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time)) delta,
            8 stat_order
        from get_run_stats
        where name = 'cell CUs sent uncompressed'       
    union all   
    select 
            test_name, snap_type, stat_class,
            name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time)) delta,
            9 stat_order
        from get_run_stats
        where name in ('EHCC CUs Decompressed',
                    'EHCC Query High CUs Decompressed',
                    'EHCC Query Low CUs Decompressed',
                    'EHCC Archive CUs Decompressed')
    union all   
    select * from (
    select 
            test_name, snap_type, stat_class,
            name, 
            lag(snap_time) over (order by snap_time) begin_snap,
            snap_time end_snap,
            (value-lag(value) over (order by snap_time)) delta,
            10 stat_order
        from get_run_stats
        where name in ('TIME_WAITED_MICRO')
                    )
    where delta > 0 
    )
    where snap_type = 'END'
    order by end_snap asc, stat_order asc, delta desc
    /


