-- View the exectution plan stored in baselines (format options - basic, typical, all)
set lines 200
set verify off
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(sql_handle=>'&sql_handle', format=>'basic'));
