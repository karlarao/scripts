COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;

set termout off verify off 
set heading on
set markup html on
spool storage_02_asmfree-&_instname..html


-- WITH REDUNDANCY
set colsep ','
set lines 600
col state format a9
col dgname format a15
col sector format 999990
col block format 999990
col label format a25
col path format a40
col redundancy format a25
col pct_used format 990
col pct_free format 990
col voting format a6   
BREAK ON REPORT
COMPUTE SUM OF raw_gb ON REPORT 
COMPUTE SUM OF usable_total_gb ON REPORT 
COMPUTE SUM OF usable_used_gb ON REPORT 
COMPUTE SUM OF usable_free_gb ON REPORT 
COMPUTE SUM OF required_mirror_free_gb ON REPORT 
COMPUTE SUM OF usable_file_gb ON REPORT 
COL name NEW_V _hostname NOPRINT
select lower(host_name) name from v$instance;
select 
        trim('&_hostname') hostname,
        name as dgname,
        state,
        type,
        sector_size sector,
        block_size block,
        allocation_unit_size au,
        round(total_mb/1024,2) raw_gb,
        round((DECODE(TYPE, 'HIGH', 0.3333 * total_mb, 'NORMAL', .5 * total_mb, total_mb))/1024,2) usable_total_gb,
        round((DECODE(TYPE, 'HIGH', 0.3333 * (total_mb - free_mb), 'NORMAL', .5 * (total_mb - free_mb), (total_mb - free_mb)))/1024,2) usable_used_gb,
        round((DECODE(TYPE, 'HIGH', 0.3333 * free_mb, 'NORMAL', .5 * free_mb, free_mb))/1024,2) usable_free_gb,
        round((DECODE(TYPE, 'HIGH', 0.3333 * required_mirror_free_mb, 'NORMAL', .5 * required_mirror_free_mb, required_mirror_free_mb))/1024,2) required_mirror_free_gb,
        round(usable_file_mb/1024,2) usable_file_gb,
        round((total_mb - free_mb)/total_mb,2)*100 as "PCT_USED", 
        round(free_mb/total_mb,2)*100 as "PCT_FREE",
        offline_disks,
        voting_files voting
from v$asm_diskgroup
where total_mb != 0
order by 1;

spool off
set markup html off