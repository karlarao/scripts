
PRO ##############################
PRO high level wait class and event
PRO ##############################
@@ashtop wait_class,event username='GLUENT_APP' sysdate-.1/24/60 sysdate


PRO ##############################
PRO high level per node, wait class and event
PRO ##############################
@@ashtop inst_id,wait_class,event,username,sql_id username='GLUENT_APP' sysdate-.1/24/60 sysdate


PRO ##############################
PRO session and sqls
PRO ##############################
@@ashtop inst_id,session_id,username,program,sql_id,sql_plan_hash_value,plsql_entry_object_id,blocking_session,event username='GLUENT_APP' sysdate-.1/24/60 sysdate


PRO ##############################
PRO ash get what part of the execution plan the SQL is spending most of its time
PRO ##############################
col object_name format a20
@@ashtop inst_id,session_id,username,program,sql_id,sql_plan_hash_value,plsql_entry_object_id,sql_plan_operation,sql_plan_options,sql_plan_line_id,o.object_name username='GLUENT_APP' sysdate-.1/24/60 sysdate


PRO ##############################
PRO ash by plan hash value and current_obj
PRO ##############################
@@ashtop inst_id,session_id,sql_plan_hash_value,plsql_entry_object_id,sql_plan_operation,sql_plan_options,sql_plan_line_id,o.object_name username='GLUENT_APP' sysdate-.1/24/60 sysdate

