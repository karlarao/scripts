-- awr_iostat_filetype.sql
-- AWR IOSTAT FileType Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--

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

spool awr_iostat_filetype_wh.csv
select * from 
(
select
      target_name
      , dbid
      , id
      , TO_CHAR(begin_interval_time,'MM/DD/YY HH24:MI:SS') tm
      , inst
      , round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400)/60,2) dur
      , filetype_name
      , read_mbs/round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400),2) read_mbs
      , read_iops/round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400),2) read_iops
      , write_mbs/round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400),2) write_mbs
      , write_iops/round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400),2) write_iops
      , sread_mbs/round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400),2) sread_mbs
      , sread_iops/round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400),2) sread_iops
      , swrite_mbs/round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400),2) swrite_mbs
      , swrite_iops/round(((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 86400),2) swrite_iops
      , srst/decode(sread_iops,0,to_number(null),sread_iops) sr_lat  --small_read_servicetime/small_read_reqs
      , swst/decode(swrite_iops,0,to_number(null),swrite_iops) sw_lat
      , lrst/decode(read_iops-sread_iops,0,to_number(null),read_iops-sread_iops) lr_lat --large_read_servicetime/large_read_reqs
      , lwst/decode(write_iops-swrite_iops,0,to_number(null),write_iops-swrite_iops) lw_lat
from 
(
  select 
          wh.target_name target_name
          , wh.new_dbid dbid
          , s0.snap_id id
          , s1.begin_interval_time
          , s1.end_interval_time
          , s0.instance_number inst
          , e.filetype_name
          , sum(((e.small_read_megabytes - b.small_read_megabytes) + (e.large_read_megabytes  - b.large_read_megabytes)))   read_mbs          
          , sum(((e.small_read_reqs      - b.small_read_reqs) + (e.large_read_reqs       - b.large_read_reqs)))             read_iops 
          , sum(((e.small_write_megabytes - b.small_write_megabytes) + (e.large_write_megabytes  - b.large_write_megabytes)))  write_mbs 
          , sum(((e.small_write_reqs      - b.small_write_reqs) + (e.large_write_reqs       - b.large_write_reqs)))         write_iops            
          , sum(e.small_read_megabytes - b.small_read_megabytes)                   sread_mbs  
          , sum(e.small_read_reqs - b.small_read_reqs)                   sread_iops    
          , sum(e.small_write_megabytes - b.small_write_megabytes)                   swrite_mbs  
          , sum(e.small_write_reqs      - b.small_write_reqs)                   swrite_iops                                
          , sum((e.small_read_servicetime  - b.small_read_servicetime))  srst
          , sum((e.small_write_servicetime - b.small_write_servicetime)) swst
          , sum((e.large_read_servicetime - b.large_read_servicetime))   lrst
          , sum((e.large_write_servicetime - b.large_write_servicetime)) lwst
       from dba_hist_snapshot s0
            , dba_hist_snapshot s1
            , dba_hist_iostat_filetype b
            , dba_hist_iostat_filetype e
            , dbsnmp.caw_dbid_mapping wh
      where 
         wh.new_dbid              = s0.dbid 
         and s1.dbid              = s0.dbid
         and b.dbid               = s0.dbid
         and e.dbid               = s0.dbid
         and s1.instance_number   = s0.instance_number
         and b.instance_number    = s0.instance_number
         and e.instance_number    = s0.instance_number
         and s1.snap_id           = s0.snap_id + 1
         and b.snap_id            = s0.snap_id
         and e.snap_id            = s0.snap_id + 1
         and e.filetype_id     = b.filetype_id
         and e.filetype_name   = b.filetype_name
       group by wh.target_name, wh.new_dbid, s0.snap_id, s1.begin_interval_time, s1.end_interval_time, s0.instance_number, e.filetype_name 
)
where read_mbs + read_iops + write_mbs + write_iops > 0
)
/
spool off