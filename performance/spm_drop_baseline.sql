set verify off
DECLARE
  plans_dropped    PLS_INTEGER;
BEGIN
  plans_dropped := DBMS_SPM.drop_sql_plan_baseline (
sql_handle => '&sql_handle',
plan_name  => '&plan_name');
DBMS_OUTPUT.put_line(plans_dropped);
END;
 /
