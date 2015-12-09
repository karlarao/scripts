set head off pagesize 2 echo off timing off linesize 1000 long 2000000 longchunksize 2000000 feedback off verify off
spool sqlmon_&&sql_id..html
select dbms_sqltune.report_sql_monitor(sql_id=>'&&sql_id', type=>'ACTIVE', report_level=>'ALL') monitor_report from dual;
spool off