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
REM   sachin.sp.pawar@oracle.com
REM
REM SCRIPT
REM   sqlhc_tcb.sql: SQL Health-Check SQL Tuning Advisor script.
REM
REM DESCRIPTION
REM   Produces an Test Case zip file
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
REM   3. DIRECTORY to write the testcase
REM
REM EXECUTION
REM   1. Start SQL*Plus connecting as SYS or user with DBA role or
REM      user with access to data dictionary views.
REM   2. Execute script sqlhc.sql passing values for parameters.
REM
REM EXAMPLE
REM   # sqlplus / as sysdba
REM   SQL> START [path]sqlhc_tcb.sql [T|D|N] [SQL_ID] [DIRECTORY]
REM   SQL> START sqlhc_tcb.sql T 51x6yr9ym5hdc DATA_PUMP_DIR
REM
REM   or
REM
REM   SQL> START sqlhc_tcb.sql T 51x6yr9ym5hdc DATA_PUMP_DIR
REM
REM NOTES
REM   1. For possible errors see sqlhc_tcb.log.
REM   2. If site has both Tuning and Diagnostics licenses then
REM      specified T (Oracle Tuning pack includes Oracle Diagnostics)
REM
DEF script = 'sqlhc_tcb';
DEF method = 'SQLHC_TCB';
DEF mos_doc = '1366133.1';
DEF doc_ver = '19.1.200819';
DEF doc_date = '2020/08/19';

spool sqlhc_tcb_^^2..out

set serveroutput on 
declare
  tc_out clob;
begin
dbms_sqldiag.export_sql_testcase(directory=>'^^3', sql_id=>'^^2', exportMetadata=>TRUE, exportData=>FALSE, testcase=>tc_out);
end;
/

spool off
