SET SERVEROUTPUT ON
SET long 1000000
SET longchunksize 300
SET verify off
set lines 900
DECLARE
report clob;
BEGIN
report := DBMS_SPM.EVOLVE_SQL_PLAN_BASELINE(
sql_handle => '&sql_handle', 
verify => '&verify', 
commit => '&commit');
DBMS_OUTPUT.PUT_LINE(report);
END;
/
