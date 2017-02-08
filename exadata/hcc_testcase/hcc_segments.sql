select sum(bytes)/1024/1024, segment_name from dba_segments where owner = 'HCCUSER' group by segment_name;
