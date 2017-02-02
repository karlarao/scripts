set head off pagesize 2 echo off timing off linesize 1000 long 2000000 longchunksize 2000000 feedback off verify off
SPOOL sqlmon_detail_&&sql_id..html
SELECT DBMS_SQLTUNE.report_sql_detail(
  sql_id       => '&&sql_id',
  type         => 'ACTIVE',
  report_level => 'ALL') AS report
FROM dual;
SPOOL OFF