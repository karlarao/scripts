set lines 300
PRO ##############################
PRO high level wait class and event
PRO ##############################
@@ashtop wait_class,event 1=1 sysdate-.1/24/60 sysdate

PRO ##############################
PRO high level per node, wait class and event
PRO ##############################
@@ashtop inst_id,wait_class,event,username,sql_id 1=1 sysdate-.1/24/60 sysdate


PRO ##############################
PRO high level wait class and event
PRO ##############################
@@ashtop wait_class,event username='GLUENT_APP' sysdate-.1/24/60 sysdate


PRO ##############################
PRO high level per node, wait class and event
PRO ##############################
@@ashtop inst_id,wait_class,event,username,sql_id username='GLUENT_APP' sysdate-.1/24/60 sysdate



