
select TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') current_time from dual;

COL username FORMAT A20
COL wait_class FORMAT A20
COL program FORMAT A45

-- high level snapper
@@snapper ash 5 1 all@*

-- high level wait class and event
@@ashtop wait_class,event session_type='FOREGROUND' sysdate-5/24/60 sysdate

-- high level per node, wait class and event
@@ashtop inst_id,wait_class,event,username,sql_id session_type='FOREGROUND' sysdate-5/24/60 sysdate

-- session and sqls
@@ashtop inst_id,session_id,username,program,sql_id,sql_plan_hash_value,plsql_entry_object_id session_type='FOREGROUND' sysdate-5/24/60 sysdate

