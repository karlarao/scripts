-- This script is to be run on the Standby of a Data Guard Physical Standby Site

set echo off 
set feedback off 
column timecol new_value tstamp 
column spool_extension new_value suffix 
select to_char(sysdate,'Mondd_hhmi') timecol from sys.dual; 
column output new_value dbname 
select value || '_' output from v$parameter where name = 'db_name'; 

-- Output the results to this file

spool dg_Standby_diag_&&dbname&&tstamp
set lines 132
set pagesize 500
set numformat 999999999999999
set trim on 
set trims on 

-- Get the current Date

set feedback on 
select systimestamp from dual;

-- Standby Site Details
set heading off
set feedback off
select 'Standby Site Details' from dual;
select '********************' from dual;
set heading on
set feedback on

col db_unique_name format a15
col flashb_on format a10

select DB_UNIQUE_NAME,DATABASE_ROLE DB_ROLE,FORCE_LOGGING F_LOG,FLASHBACK_ON FLASHB_ON,LOG_MODE,OPEN_MODE,
       GUARD_STATUS GUARD,PROTECTION_MODE PROT_MODE
from v$database;

-- Current SCN - this value on the primary and standby sites where real time apply is in place should be nearly the same

select DB_UNIQUE_NAME,SWITCHOVER_STATUS,CURRENT_SCN from v$database;

-- Incarnation Information
--

set heading off
set feedback off
select 'Incarnation Destination Configuration' from dual;
select '*************************************' from dual;
set heading on
set feedback on

select INCARNATION# INC#, RESETLOGS_CHANGE# RS_CHANGE#, RESETLOGS_TIME, PRIOR_RESETLOGS_CHANGE# PRIOR_RS_CHANGE#, STATUS,FLASHBACK_DATABASE_ALLOWED FB_OK from v$database_incarnation;


set heading off
set feedback off
select 'Archive Destination Configuration' from dual;
select '*********************************' from dual;
set heading on
set feedback on
-- Current Archive Locations
-- 
 
column host_name format a30 tru 
column version format a10 tru 
select INSTANCE_NAME,HOST_NAME,VERSION,ARCHIVER from v$instance; 

column destination format a35 wrap 
column process format a7 
column archiver format a8 
column dest_id format 99999999 
 
select DEST_ID,DESTINATION,STATUS,TARGET,ARCHIVER,PROCESS,REGISTER,TRANSMIT_MODE  
from v$archive_dest
where DESTINATION IS NOT NULL;

column name format a22
column value format a100
select NAME,VALUE from v$parameter where NAME like 'log_archive_dest%' and upper(VALUE) like 'SERVICE%';

set heading off
set feedback off
select 'Archive Destination Errors' from dual;
select '**************************' from dual;
set heading on
set feedback on

column error format a55 tru 
select DEST_ID,STATUS,ERROR from v$archive_dest
where DESTINATION IS NOT NULL;

column message format a80 
select MESSAGE, TIMESTAMP 
from v$dataguard_status 
where SEVERITY in ('Error','Fatal') 
order by TIMESTAMP;

-- Redo Log configuration
-- The size of the standby redo logs must match exactly the size on the online redo logs

set heading off
set feedback off
select 'Data Guard Redo Log Configuration' from dual;
select '*********************************' from dual;
set heading on
set feedback on

select GROUP# STANDBY_GROUP#,THREAD#,SEQUENCE#,BYTES,USED,ARCHIVED,STATUS from v$standby_log order by GROUP#,THREAD#;

select GROUP# ONLINE_GROUP#,THREAD#,SEQUENCE#,BYTES,ARCHIVED,STATUS from v$log order by GROUP#,THREAD#;

-- Data Guard Parameters
--
set heading off
set feedback off
select 'Data Guard Related Parameters' from dual;
select '*****************************' from dual;
set heading on
set feedback on

column name format a30
column value format a100
select NAME,VALUE from v$parameter where NAME IN ('db_unique_name','cluster_database','dg_broker_start','dg_broker_config_file1','dg_broker_config_file2','fal_client','fal_server','log_archive_config','log_archive_trace','log_archive_max_processes','archive_lag_target','remote_login_password_file','redo_transport_user') order by name;

-- Managed Recovery State

set heading off
set feedback off
select 'Data Guard Apply Status' from dual;
select '***********************' from dual;
set heading on
set feedback on

select systimestamp from dual;

column client_pid format a10
select PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS
from v$managed_standby  order by CLIENT_PROCESS,THREAD#,SEQUENCE#;

host sleep 10

select systimestamp from dual;

select PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS
from v$managed_standby  order by CLIENT_PROCESS,THREAD#,SEQUENCE#;

host sleep 10

select systimestamp from dual;

select PROCESS,STATUS,CLIENT_PROCESS,CLIENT_PID,THREAD#,SEQUENCE#,BLOCK#,ACTIVE_AGENTS,KNOWN_AGENTS
from v$managed_standby  order by CLIENT_PROCESS,THREAD#,SEQUENCE#;


set heading off
set feedback off
select 'Data Guard Apply Lag' from dual;
select '********************' from dual;
set heading on
set feedback on

column name format a12
column lag_time format a20
column datum_time format a20
column time_computed format a20
SELECT NAME, VALUE LAG_TIME, DATUM_TIME, TIME_COMPUTED 
from V$DATAGUARD_STATS where name like 'apply lag';

-- If there is a lag remove the comment for the select below
--SELECT * FROM V$STANDBY_EVENT_HISTOGRAM WHERE NAME = 'apply lag'  AND COUNT > 0;

set heading off
set feedback off
select 'Data Guard Gap Problems' from dual;
select '***********************' from dual;
set heading on
set feedback on

select * from v$archive_gap; 

set heading off
set feedback off
select 'Data Guard Errors in the Last Hour' from dual;
select '**********************************' from dual;
set heading on
set feedback on

select TIMESTAMP,SEVERITY,ERROR_CODE,MESSAGE from v$dataguard_status where timestamp > systimestamp-1/24;
spool off

exit

