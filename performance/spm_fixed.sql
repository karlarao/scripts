set verify off
declare
myplan pls_integer;
begin
myplan:=DBMS_SPM.ALTER_SQL_PLAN_BASELINE (sql_handle => '&sql_handle',plan_name  => '&plan_name',attribute_name => 'FIXED',   attribute_value => '&YES_OR_NO');
end;
/
