
--### SECTION 1: BEGIN CLOCK TIME
select to_char(sysdate, 'YY/MM/DD HH24:MI:SS') AS "START" from dual;
col time1 new_value time1
col time2 new_value time2
select to_char(sysdate, 'SSSSS') time1 from dual;


--### SECTION 2 (OPTIONAL): INCREASE SESSION ARRAYSIZE, TERM OUTPUT OFF 
-- set arraysize 5000
-- set termout off
-- set echo off verify off


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
alter session set current_schema=infoload_prod;
set serveroutput off



--### SECTION 5: THE SQL STATEMENT
-- select /*+ MONITOR */ /* baseline 1 */ WRK_ITM_ASSGN_HI01.IDENTIFIER ,WRK_ITM_ASSGN_HI01.TYPE_CODE ,WRK_ITM_ASSGN_HI01.SEQUENCE_NUMBER ,WRK_ITM_ASSGN_HI01.USER_ID ,WRK_ITM_ASSGN_HI01.DEPARTMENT_ID ,WRK_ITM_ASSGN_HI01.LOCATION_ID ,
-- WRK_ITM_ASSGN_HI01.SVC_UNIT_ID ,WRK_ITM_ASSGN_HI01.TRANSFER_REASON_CD ,WRK_ITM_ASSGN_HI01.TRANS_FROM_USER_ID ,WRK_ITM_ASSGN_HI01.ADJUDICATION_NBR ,TO_CHAR(WRK_ITM_ASSGN_HI01.CREATION_TIMESTAMP,
-- 'YYYY-MM-DD.HH24.MI.SS.FF6') ,WRK_ITM_ASSGN_HI01.CREATION_TIMESTAMP  from WRK_ITM_ASSGN_HIST WRK_ITM_ASSGN_HI01 where (WRK_ITM_ASSGN_HI01.TYPE_CODE=:b0 and WRK_ITM_ASSGN_HI01.IDENTIFIER=:b1)
--  order by WRK_ITM_ASSGN_HI01.ADJUDICATION_NBR desc ,WRK_ITM_ASSGN_HI01.SEQUENCE_NUMBER desc ,WRK_ITM_ASSGN_HI01.CREATION_TIMESTAMP desc
--  /
-- select /*+ MONITOR */ /* baseline 32 */ max(object_id), min(object_id), sum(object_id) from all_objects;


VAR SYS_B_0 VARCHAR2(32)
VAR SYS_B_1 NUMBER
VAR SYS_B_2 NUMBER
VAR SYS_B_3 NUMBER
VAR SYS_B_4 NUMBER
VAR SYS_B_5 VARCHAR2(32)
VAR SYS_B_6 VARCHAR2(32)
VAR SYS_B_7 VARCHAR2(32)

EXEC :SYS_B_0 := '';
EXEC :SYS_B_1 := ;
EXEC :SYS_B_2 := ;
EXEC :SYS_B_3 := ;
EXEC :SYS_B_4 := ;
EXEC :SYS_B_5 := 'G';
EXEC :SYS_B_6 := 'B';
EXEC :SYS_B_7 := 'D';

SELECT  distinct  TRIM(INVOICE_RECIPIENT_ID)||:"SYS_B_0"||SUBSTR(INVOICE_RECIPIENT_NAME_UC,:"SYS_B_1",:"SYS_B_2") AS RSLT,  TRIM(INVOICE_RECIPIENT_ID) AS INVOICE_RECIPIENT_ID,  SUBSTR(INVOICE_RECIPIENT_NAME_UC,:"SYS_B_3",:"SYS_B_4") AS INVOICE_RECIPIENT_NAME FROM INVOICE_RECIPIENT_VW WHERE TRIM(INVOICE_RECIPIENT_TYPE_CD) IN(:"SYS_B_5",:"SYS_B_6",:"SYS_B_7") ORDER BY INVOICE_RECIPIENT_ID,INVOICE_RECIPIENT_NAME,RSLT

/



--### SECTION 6: END CLOCK TIME AND CAPTURE SQL_ID
set termout on
COL p_sqlid NEW_V p_sqlid;
select prev_sql_id p_sqlid from v$session where sid=sys_context('userenv','sid');
@mystat.sql

select to_char(sysdate, 'YY/MM/DD HH24:MI:SS') AS "END" from dual;
select to_char(sysdate, 'SSSSS') time2 from dual;
select &&time2 - &&time1 total_time from dual;
select '''END''' END from dual;


--### SECTION 7 (OPTIONAL): GET EXECUTION PLAN INFO AND PERFORMANCE 
-- @planx Y &p_sqlid
-- @rwp_sqlmonreport.sql &p_sqlid
-- @sqlhc T &p_sqlid

--### for ADW use the following 
@planxash Y &p_sqlid
@rwp_sqlmonreport.sql &p_sqlid
@sqlhcash T &p_sqlid



