
set lines 300
col name format a50

select
        inst_id, first_load_time, child_number, last_load_time,
        plan_hash_value, loads, executions
from
        gv$sql
where
    sql_id = '&&sql_id'
;    


break on child_number skip 1    
 
select
        inst_id, child_number, name, value
from    gv$sql_optimizer_env
where
    sql_id = '&&sql_id'
order by
        child_number,
        name
;    
