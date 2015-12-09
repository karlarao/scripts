
select TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') current_time from dual;

accept _start_time prompt 'Enter start YYYY-MM-DD HH24:MI:SS -> '
accept _end_time prompt 'Enter end YYYY-MM-DD HH24:MI:SS -> '

define _start_time='&_start_time'
define _end_time='&_end_time'

COL username FORMAT A20
COL wait_class FORMAT A20
COL program FORMAT A45

--@snapper ash 5 1 all@*

-- time series events of current instance
@@ash_aveactn_dba_hist.sql

-- high level wait class and event
@@dashtop wait_class,event session_type='FOREGROUND' "TIMESTAMP'&_start_time'" "TIMESTAMP'&_end_time'"

-- high level per node, wait class and event
@@dashtop instance_number,wait_class,event,username,sql_id session_type='FOREGROUND' "TIMESTAMP'&_start_time'" "TIMESTAMP'&_end_time'"

-- session and sqls
@@dashtop instance_number,session_id,username,program,sql_id,sql_plan_hash_value,plsql_entry_object_id session_type='FOREGROUND' "TIMESTAMP'&_start_time'" "TIMESTAMP'&_end_time'"


