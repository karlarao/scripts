SET SERVEROUT ON;
DECLARE
  x NUMBER;
  y NUMBER := 0;
BEGIN
  FOR i IN (SELECT DISTINCT sql_handle, plan_name FROM dba_sql_plan_baselines)
  LOOP
    x := DBMS_SPM.DROP_SQL_PLAN_BASELINE(i.sql_handle, i.plan_name);
    y := y + x;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('plans deleted: '||y);
END;
/
SET SERVEROUT OFF;
