

set feedback off pages 0 term off head on und off trimspool on 
set arraysize 5000
set termout off
set echo off verify off

COLUMN name NEW_VALUE _instname NOPRINT
select lower(SUBSTR(b.instance_name, 0, LENGTH(b.instance_name) - 1)) name from v$instance b;

spool service_names-calcfield-&_instname..calc
set lines 150
select inst_id, name svc_name, name_hash from gv$services order by 1;
spool off





