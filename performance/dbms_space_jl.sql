rem
rem Script:     dbms_space_use_sf.sql
rem Author:     Jonathan Lewis
rem Dated:      Dec 2013
rem Purpose:    
rem
rem Last tested 
rem     12.1.0.2
rem     11.2.0.4
rem Not tested
rem     11.1.0.7
rem Not relevant
rem     10.2.0.5
rem      9.2.0.8
rem      8.1.7.4
rem
rem Notes:
rem See also dbms_space_use.sql
rem
rem 11g introduced securefiles lobs and two overloads of 
rem dbms_space_usage to report space used by their segments
rem
rem Valid values for suoption are:
rem     SPACEUSAGE_EXACT (16): Computes space usage exhaustively
rem     SPACEUSAGE_FAST  (17): Retrieves values from in-memory statistics
rem
rem This version allows for partitioned objects, could delete
rem lines to parameter 4 and partition names to eliminate
rem the complaints about substitution variables.
rem
 
 
define m_seg_owner  = &1
define m_seg_name   = &2
define m_seg_type   = '&3'
define m_part_name  = &4
 
define m_segment_owner  = &m_seg_owner
define m_segment_name   = &m_seg_name
define m_segment_type   = '&m_seg_type'
define m_partition_name = &m_part_name
 
@@setenv
 
execute snap_enqueues.start_snap
execute snap_events.start_snap
execute snap_my_stats.start_snap
 
spool dbms_space_use_sf
 
prompt  ============
prompt  Secure files
prompt  ============
 
declare
    wrong_ssm   exception;
    pragma exception_init(wrong_ssm, -10614);
 
    m_segment_size_blocks   number(12,0);
    m_segment_size_bytes    number(12,0);
    m_used_blocks       number(12,0);
    m_used_bytes        number(12,0);
    m_expired_blocks    number(12,0);
    m_expired_bytes     number(12,0);
    m_unexpired_blocks  number(12,0);
    m_unexpired_bytes   number(12,0);
 
begin
    dbms_space.space_usage(
        upper('&m_segment_owner'),
        upper('&m_segment_name'),
        upper('&m_segment_type'),
        suoption        => dbms_space.spaceusage_exact,  
--      suoption        => dbms_space.spaceusage_fast,
        segment_size_blocks => m_segment_size_blocks,
        segment_size_bytes  => m_segment_size_bytes,
        used_blocks     => m_used_blocks,
        used_bytes      => m_used_bytes,
        expired_blocks      => m_expired_blocks,
        expired_bytes       => m_expired_bytes,
        unexpired_blocks    => m_unexpired_blocks,
        unexpired_bytes     => m_unexpired_bytes,
        partition_name      => upper('&m_partition_name')
    );
 
    dbms_output.new_line;
    dbms_output.put_line(' Segment Blocks:   ' || to_char(m_segment_size_blocks,'999,999,990') || ' Bytes: ' || to_char(m_segment_size_bytes,'999,999,999,990')); 
    dbms_output.put_line(' Used Blocks:      ' || to_char(m_used_blocks,'999,999,990')         || ' Bytes: ' || to_char(m_used_bytes,'999,999,999,990')); 
    dbms_output.put_line(' Expired Blocks:   ' || to_char(m_expired_blocks,'999,999,990')      || ' Bytes: ' || to_char(m_expired_bytes,'999,999,999,990')); 
    dbms_output.put_line(' Unexpired Blocks: ' || to_char(m_unexpired_blocks,'999,999,990')    || ' Bytes: ' || to_char(m_unexpired_bytes,'999,999,999,990')); 
 
exception
    when wrong_ssm then
        dbms_output.put_line('Segment not ASSM');
end;
/
 
prompt  ===============
prompt  Generic details
prompt  ===============
 
declare
    m_total_blocks          number;
    m_total_bytes           number;
    m_unused_blocks         number;
    m_unused_bytes          number;
    m_last_used_extent_file_id  number;
    m_last_used_extent_block_id number;
    m_last_used_block       number;
begin
    dbms_space.unused_space(
        segment_owner       => upper('&m_segment_owner'),
        segment_name        => upper('&m_segment_name'),
        segment_type        => upper('&m_segment_type'),
        total_blocks        => m_total_blocks,
        total_bytes         => m_total_bytes, 
        unused_blocks       => m_unused_blocks,  
        unused_bytes        => m_unused_bytes,
        last_used_extent_file_id    => m_last_used_extent_file_id, 
        last_used_extent_block_id   => m_last_used_extent_block_id,
        last_used_block     => m_last_used_block,
        partition_name      => upper('&m_partition_name')
    );
 
    dbms_output.put_line('Segment Total blocks: ' || to_char(m_total_blocks,'999,999,990'));
    dbms_output.put_line('Object Unused blocks: ' || to_char(m_unused_blocks,'999,999,990'));
 
end;
/
 
-- execute snap_my_stats.end_snap
-- execute snap_events.end_snap
-- execute snap_enqueues.end_snap
 
spool off