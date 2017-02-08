-- first, gather stats on tables 
--exec dbms_stats.gather_schema_stats('HCCUSER');

-- compare the compressed tables vs the base uncompressed table 
select segment_name, 0 ratio, round(sum(bytes)/1024/1024,2) size_mb from user_segments 
where segment_type = 'TABLE' 
and segment_name = 'HCCTABLE'
group by segment_name
union all
SELECT comp.table_name, round(uncomp.blocks/comp.blocks,3) AS ratio, seg.size_mb
FROM 
  user_tables comp, 
  (select * from user_tables where table_name = 'HCCTABLE') uncomp, 
  (select segment_name, round(sum(bytes)/1024/1024,2) size_mb from user_segments where segment_type = 'TABLE' group by segment_name) seg
WHERE comp.compression = 'ENABLED'
AND uncomp.compression = 'DISABLED'
AND seg.segment_name = comp.table_name
ORDER BY 2 ASC;

