set lines 200
set verify off
select * from table(dbms_xplan.display_cursor('&sql_id','&child_no','advanced +peeked_binds'))
/
