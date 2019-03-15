set pagesize 0 echo off timing off linesize 1000 trimspool on trim on long 2000000 longchunksize 2000000 feedback off verify off
spool sqlmon_&&sql_id..html
select dbms_sqltune.report_sql_monitor(report_level=>'+histogram', type=>'EM', sql_id=>'&&sql_id') monitor_report from dual;
spool off

SPOOL sqlmon_detail_&&sql_id..html
SELECT DBMS_SQLTUNE.report_sql_detail(
  sql_id       => '&&sql_id',
  type         => 'ACTIVE',
  report_level => 'ALL') AS report
FROM dual;
SPOOL OFF

SPOOL sqlmon_&&sql_id..txt
SELECT DBMS_SQLTUNE.report_sql_detail(
  sql_id       => '&&sql_id',
  type         => 'TEXT',
  report_level => 'ALL') AS report
FROM dual;
SPOOL OFF

