
--### SECTION 1: BEGIN CLOCK TIME
select to_char(sysdate, 'YY/MM/DD HH24:MI:SS') AS "START" from dual;
col time1 new_value time1
col time2 new_value time2
select to_char(sysdate, 'SSSSS') time1 from dual;


--### SECTION 2 (OPTIONAL): INCREASE SESSION ARRAYSIZE, TERM OUTPUT OFF 
-- set arraysize 5000
 set termout off
 set echo off verify off

 --for ADW to use hints
 alter session set optimizer_ignore_hints=false;
 --/*+ no_result_cache */  for individual SQLs


--### SECTION 3: DEFINE THE BIND VARIABLES 
-- var b0 varchar2(32)
-- var b1 varchar2(32)
-- var b3 varchar2(50)

-- Set the bind values
-- exec :b0 := '3'; 
-- exec :b1 := '3';
-- exec :b3 := '05/31/2018 00:00:00';


@mystat.sql
--### SECTION 4: DEFINE THE APPLICATION PARSING SCHEMA 
--alter session set current_schema=infoload_prod;
set serveroutput off


--### SECTION 5: THE SQL STATEMENT

select /*+ monitor */ 
..
from 
table_name
;




--### SECTION 6: END CLOCK TIME AND CAPTURE SQL_ID
set termout on
COL p_sqlid NEW_V p_sqlid;
select prev_sql_id p_sqlid from v$session where sid=sys_context('userenv','sid');

spool mystat-&p_sqlid..txt
@mystat.sql
spool off

select to_char(sysdate, 'YY/MM/DD HH24:MI:SS') AS "END" from dual;
select to_char(sysdate, 'SSSSS') time2 from dual;
select &&time2 - &&time1 total_time from dual;
select '''END''' END from dual;


--### SECTION 7 (OPTIONAL): GET EXECUTION PLAN INFO AND PERFORMANCE 
-- @planx Y &p_sqlid
-- @rwp_sqlmonreport.sql &p_sqlid
-- @sqlhc T &p_sqlid

--### for ADW use the following to avoid hitting dba_hist_active_sess_history
@planxash.sql Y &p_sqlid
@rwp_sqlmonreport.sql &p_sqlid
@sqlhc_adb.sql T &p_sqlid



