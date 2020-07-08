set lines 300
set verify off
SELECT PARAMETER_NAME, PARAMETER_VALUE FROM DBA_SQL_MANAGEMENT_CONFIG;
BEGIN
  DBMS_SPM.configure('space_budget_percent', &space_budget_percent);
  DBMS_SPM.configure('plan_retention_weeks', &plan_retention_weeks);
END;
/
SELECT PARAMETER_NAME, PARAMETER_VALUE FROM DBA_SQL_MANAGEMENT_CONFIG;
