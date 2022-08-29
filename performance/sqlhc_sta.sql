SET DEF ^ 
set TERM On
set ECHO ON 
set AUTOP OFF 
set VER OFF 
set SERVEROUT ON SIZE 1000000;
REM
REM $Header: 1366133.1 sqlhc.sql 19th Aug 2020 stelios.charalambides $
REM
REM Copyright (c) 2020, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   Stelios.charalambides@oracle.com
REM
REM SCRIPT
REM   sqlhc_sta.sql: SQL Health-Check SQL Tuning Advisor script.
REM
REM DESCRIPTION
REM   Produces an SQL Tuning Advisor text report. 
REM
REM   Inputs a memory-resident SQL_ID.
REM
REM   This script does not install any objects in the database.
REM   It does not perform any DDL commands.
REM   It can be used in Dataguard or any read-only database.
REM
REM PRE-REQUISITES
REM   1. Execute as SYS or user with DBA role or user with access
REM      to data dictionary views.
REM   2. The SQL for which this script is executed must be
REM      memory-resident.
REM   3. Can be run standalone or from SQLHC.sql as part of that script. 
REM
REM PARAMETERS
REM   1. Oracle Pack license (Tuning or Diagnostics or None) T|D|N
REM   2. SQL_ID of interest.
REM
REM EXECUTION
REM   1. Start SQL*Plus connecting as SYS or user with DBA role or
REM      user with access to data dictionary views.
REM   2. Execute script sqlhc.sql passing values for parameters.
REM
REM EXAMPLE
REM   # sqlplus / as sysdba
REM   SQL> START [path]sqlhc_sta.sql [T|D|N] [SQL_ID]
REM   SQL> START sqlhc_sta.sql T 51x6yr9ym5hdc
REM
REM   or
REM   
REM   SQL> START sqlhc_sta.sql T 51x6yr9ym5hdc
REM
REM NOTES
REM   1. For possible errors see sqlhc_sta.log.
REM   2. If site has both Tuning and Diagnostics licenses then
REM      specified T (Oracle Tuning pack includes Oracle Diagnostics)
REM
DEF script = 'sqlhc_sta';
DEF method = 'SQLHC_STA';
DEF mos_doc = '1366133.1';
DEF doc_ver = '19.1.200819';
DEF doc_date = '2020/08/19';

execute dbms_workload_repository.create_snapshot(flush_level=>'ALL');

col sta_min_snap_id new_v sta_min_snap_id;
select min(snap_id) sta_min_snap_id from dba_hist_snapshot;
var sta_min_snap_id number;
exec :sta_min_snap_id := ^^sta_min_snap_id;

col sta_max_snap_id new_v sta_max_snap_id;
select max(snap_id) sta_max_snap_id from dba_hist_snapshot;
var sta_max_snap_id number;
exec :sta_max_snap_id := ^^sta_max_snap_id;

--DBMS_SQLTUNE.drop_TUNING_TASK(task_name=>'^^2._tuning_task');
--select count(task_name) from dba_advisor_tasks where task_name='^^2._tuning_task';

DECLARE
  l_sql_tune_task_id VARCHAR2(100);
  sta_task_count number;
BEGIN
  select count(task_name) into sta_task_count from dba_advisor_tasks where task_name='^^2._tuning_task';
  if sta_task_count > 0 then DBMS_SQLTUNE.drop_TUNING_TASK(task_name=>'^^2._tuning_task');
  end if;
  l_sql_tune_task_id := DBMS_SQLTUNE.CREATE_TUNING_TASK(
    begin_snap=>^sta_min_snap_id,
	end_snap=>^sta_max_snap_id,
	sql_id=>'^^2',
	scope=>'COMPREHENSIVE',
--	time_limit=>14400,
    time_limit=>1200, 
    task_name=>'^^2._tuning_task',
	description=>'Tuning task for statement ' || '^^2');
  DBMS_OUTPUT.put_line('Tuning Task ' || l_sql_tune_task_id||' created.');
  
  EXCEPTION
    WHEN OTHERS THEN 
	  if sqlcode <> 0 then dbms_output.put_line(SQLERRM);
	  raise;
	  end if;
END;
/

Declare	
  sta_task_count number;													  
BEGIN
  select count(task_name) into sta_task_count from dba_advisor_tasks where task_name='^^2._tuning_task';
  if sta_task_count > 0 
  then DBMS_SQLTUNE.EXECUTE_TUNING_TASK( task_name => '^^2._tuning_task');
  end if;
END;
/

SET LONG 90000
SET LONGCHUNKSIZE 90000
SET LINESIZE 125
SET PAGESIZE 500
spool sqlhc_sta_^^2..out
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK( '^^2._tuning_task') from DUAL;
spool off
