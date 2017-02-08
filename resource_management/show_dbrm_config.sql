-- Check Resource Manager configuration
#############################################

set wrap off
set head on
set linesize 300
set pagesize 132
col comments format a64

-- show current resource plan
select * from  V$RSRC_PLAN;

-- show all resource plans
select PLAN,NUM_PLAN_DIRECTIVES,CPU_METHOD,substr(COMMENTS,1,64) "COMMENTS",STATUS,MANDATORY 
from dba_rsrc_plans 
order by plan;

-- show consumer groups
select CONSUMER_GROUP,CPU_METHOD,STATUS,MANDATORY,substr(COMMENTS,1,64) "COMMENTS" 
from DBA_RSRC_CONSUMER_GROUPS 
order by consumer_group;

-- show  category
SELECT consumer_group, category
FROM DBA_RSRC_CONSUMER_GROUPS
ORDER BY category;

-- show mappings
col value format a30
select ATTRIBUTE, VALUE, CONSUMER_GROUP, STATUS 
from DBA_RSRC_GROUP_MAPPINGS
order by 3;

-- show mapping priority 
select * from DBA_RSRC_MAPPING_PRIORITY;

-- show directives 
SELECT plan,group_or_subplan,cpu_p1,cpu_p2,cpu_p3, PARALLEL_DEGREE_LIMIT_P1, status 
FROM dba_rsrc_plan_directives 
order by 1,3 desc,4 desc,5 desc;

-- show grants
select * from DBA_RSRC_CONSUMER_GROUP_PRIVS order by grantee;
select * from DBA_RSRC_MANAGER_SYSTEM_PRIVS order by grantee;

-- show scheduler windows
select window_name, resource_plan, START_DATE, DURATION, WINDOW_PRIORITY, enabled, active from dba_scheduler_windows;


