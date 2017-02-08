-- awr_iostat_filetype.sql
-- AWR IOSTAT FileType Report
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
--
-- Changes:

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

COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;

COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;

COLUMN name NEW_VALUE _hostname NOPRINT
select lower(host_name) name from v$instance;

COLUMN instancenumber NEW_VALUE _instancenumber NOPRINT
select instance_number instancenumber from v$instance;

-- ttitle center 'AWR IOSTAT FileType Report' skip 2

col instname    format a15
col hostname    format a30
col tm          format a15              heading tm           --"Snap|Start|Time"
col id          format 99999            heading id           --"Snap|ID"
col inst        format 90               heading inst         --"i|n|s|t|#"
col dur         format 999990.00        heading dur          --"Snap|Dur|(m)"

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

spool awr_iostat_filetype-tableau_sqlcl-&_instname-&_hostname..csv
select * from 
(
select
  trim('&_instname') instname
  , trim('&_dbid') db_id
  , trim('&_hostname') hostname
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
          s0.snap_id id
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
      where 
         s0.dbid                  = &_dbid            
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
       group by s0.snap_id, s1.begin_interval_time, s1.end_interval_time, s0.instance_number, e.filetype_name
       order by s0.snap_id asc 
)
where read_mbs + read_iops + write_mbs + write_iops > 0
);
spool off