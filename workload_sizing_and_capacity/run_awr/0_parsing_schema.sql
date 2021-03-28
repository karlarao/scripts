set feedback off pages 0 term off head on und off trimspool on
set arraysize 5000
set termout off
set echo off verify off

COLUMN name NEW_VALUE _instname NOPRINT
select lower(SUBSTR(b.instance_name, 0, LENGTH(b.instance_name) - 1)) name from v$instance b;

set lines 150
col username format a60
col user_id format 99999999999999999

spool parsing_schema-calcfield-&_instname..calc
select username, user_id from dba_users order by 1;
spool off





