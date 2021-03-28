for INST in $(ps axo cmd | grep ora_pmo[n] | sed 's/^ora_pmon_//' | grep -v 'sed '); do
        if [ "$( cat /etc/oratab | grep -v ^# | grep -v ^$ | awk -F: '{ print $1 }' | grep $INST | head -n1 | wc -l)" -ne 0 ]; then
                echo "$INST: instance name = db_unique_name (single instance database)"
                export ORACLE_SID=$INST; export ORAENV_ASK=NO; . oraenv
        else
                # remove last char (instance nr) and look for name again
                LAST_REMOVED=$(echo "${INST:0:$(echo ${#INST}-1 | bc)}")
                if [ $LAST_REMOVED = "$( cat /etc/oratab | grep -v ^# | grep -v ^$ | awk -F: '{ print $1 }' | grep $LAST_REMOVED )" ]; then
                        echo "$INST: instance name with last char removed = db_unique_name (RAC: instance number added)"
                        export ORACLE_SID=$LAST_REMOVED; export ORAENV_ASK=NO; . oraenv; export ORACLE_SID=$INST
                elif [[ "$(echo $INST | sed 's/.*\(_[12]\)/\1/')" =~ "_[12]" ]]; then
                        # remove last two chars (rac one node addition) and look for name again
                        LAST_TWO_REMOVED=$(echo "${INST:0:$(echo ${#INST}-2 | bc)}")
                        if [ $LAST_TWO_REMOVED = "$( cat /etc/oratab | grep -v ^# | grep -v ^$ | awk -F: '{ print $1 }' | grep $LAST_TWO_REMOVED )" ]; then
                                echo "$INST: instance name with either _1 or _2 removed = db_unique_name (RAC one node)"
                                export ORACLE_SID=$LAST_TWO_REMOVED; export ORAENV_ASK=NO; . oraenv; export ORACLE_SID=$INST
                        fi
                else
                        echo "couldn't find instance $INST in oratab"
                        continue
                fi
        fi

sqlplus -s /nolog <<EOF
connect / as sysdba

select '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~' from dual;



set lines 3000
set verify off
set head on

COLUMN instance_name NEW_VALUE _xinstance_name NOPRINT
select value instance_name from v\$parameter where name in ('instance_name');

COLUMN instance_number NEW_VALUE _xinstance_number NOPRINT
select value instance_number from v\$parameter where name in ('instance_number');

COLUMN hostname NEW_VALUE _xhostname NOPRINT
select host_name hostname from v\$instance;

COLUMN sga_target NEW_VALUE _xsga_target NOPRINT
select round(value/1024/1024/1024,2) sga_target from v\$parameter where name in ('sga_target');

COLUMN sga_max_size NEW_VALUE _xsga_max_size NOPRINT
select round(value/1024/1024/1024,2) sga_max_size from v\$parameter where name in ('sga_max_size');

COLUMN memory_target NEW_VALUE _xmemory_target NOPRINT
select round(value/1024/1024/1024,2) memory_target from v\$parameter where name in ('memory_target');

COLUMN memory_max_target NEW_VALUE _xmemory_max_target NOPRINT
select round(value/1024/1024/1024,2) memory_max_target from v\$parameter where name in ('memory_max_target');

COLUMN pga_target NEW_VALUE _xpga_target NOPRINT
select round(value/1024/1024/1024,2) pga_target from v\$parameter where name in ('pga_aggregate_target');

COLUMN cpu_count NEW_VALUE _xcpu_count NOPRINT
select value cpu_count from v\$parameter where name in ('cpu_count');

COLUMN resource_manager_plan NEW_VALUE _xresource_manager_plan NOPRINT
select value resource_manager_plan from v\$parameter where name in ('resource_manager_plan');


COLUMN gb NEW_VALUE _xgb NOPRINT
WITH
sizes AS (
SELECT
       'Data' file_type,
       SUM(bytes) bytes
  FROM v\$datafile
 UNION ALL
SELECT 'Temp' file_type,
       SUM(bytes) bytes
  FROM v\$tempfile
 UNION ALL
SELECT 'Log' file_type,
       SUM(bytes) * MAX(members) bytes
  FROM v\$log
 UNION ALL
SELECT 'Control' file_type,
       SUM(block_size * file_size_blks) bytes
  FROM v\$controlfile
),
dbsize AS (
SELECT /*+  MATERIALIZE NO_MERGE  */ /* 1e.77 */
       'Total' file_type,
       SUM(bytes) bytes
  FROM sizes
)
SELECT
       ROUND(s.bytes/POWER(10,9),2) gb
  FROM v\$database d,
       dbsize s;

COLUMN segsgb NEW_VALUE _xsegsgb NOPRINT
select round(sum(bytes)/1024/1024/1024,2) segsgb
from dba_segments;

COLUMN retention_days NEW_VALUE _retention_days
select
   ((TRUNC(SYSDATE) + a.RETENTION - TRUNC(SYSDATE)) * 86400)/60/60/24 AS retention_days
from dba_hist_wr_control a, v\$database b
where a.dbid = b.dbid;

COLUMN dgon NEW_VALUE _xdgon NOPRINT
select count(*) dgon from v\$archive_dest where status = 'VALID' and target = 'STANDBY';

COLUMN dgfeat NEW_VALUE _xdgfeat NOPRINT
 select CURRENTLY_USED dgfeat from 
  (select *
  FROM DBA_FEATURE_USAGE_STATISTICS
  WHERE NAME = 'Data Guard'
  order by LAST_SAMPLE_DATE desc)
  where rownum < 2;



set colsep ',' underline off newpage none feedback off term off
col instance_name_ format a20
col sga_target_gb format a10
col sga_max_size_gb format a10
col memory_target_gb format a10
col memory_max_target_gb format a10
col pga_target_gb format a10
col cpucount format a10
col rmplan format a50
col db_gb_ format a15
col seg_gb format a15
col awrdays format a10
col dg_on format a10
col dg_feat format a5
select
'SIZING_INFO' sizing_info,
trim('&_xhostname') hstname,
'&_xinstance_name-&_xinstance_number' instname,
trim('&_xpga_target') pga_target_gb,
trim('&_xsga_target') sga_target_gb,
trim('&_xsga_max_size') sga_max_size_gb,
trim('&_xmemory_target') memory_target_gb,
trim('&_xmemory_max_target') memory_max_target_gb,
trim('&_xcpu_count') cpucount,
trim('&_xresource_manager_plan') rmplan,
trim('&_xgb') db_gb_,
trim('&_xsegsgb') seg_gb,
trim('&_retention_days') awrdays,
trim('&_xdgon') dg_on,
trim('&_xdgfeat') dg_feat
from dual;

EOF
done



