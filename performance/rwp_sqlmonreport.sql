--Extract all types of SQL Monitor and DBMS_XPLAN reports of a SQL_ID
--by Karl Arao 
--
--HOWTO:
--
--Execute as user with DBA role 
-- 
--@rwp_sqlmonreport
--Enter SQL_ID (required)
--Enter value for 1: <sql_id>



PRO Enter SQL_ID (required)
DEF sqlmon_sqlid = '&&1';
DEF sqlmon_date_mask = 'YYYYMMDDHH24MISS';
DEF sqlmon_text = 'Y';
DEF sqlmon_active = 'Y';
DEF sqlmon_hist = 'Y';
DEF tuning_pack = 'Y';
-- number of SQL Monitoring reports to collect from memory and history
DEF rwp_conf_num_sqlmon_rep = '12';


SET LIN 32767 PAGES 0 LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SET TERM OFF;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') rwp_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET HEA OFF;
SET TERM ON; 

-- log
--SPO &&sqlmon_sqlid..txt APP;




VAR myreport CLOB

-- text
SET SERVEROUT ON SIZE 1000000;
SET TERM OFF
SPO rwp_sqlmon_&&sqlmon_sqlid._driver_txt.sql
DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line); 
  END put;
BEGIN
  FOR i IN (SELECT * FROM 
           (SELECT sid,
                   session_serial#,
                   sql_exec_start,
                   sql_exec_id,
                   inst_id
              FROM gv$sql_monitor 
             WHERE '&&tuning_pack.' = 'Y' 
               AND '&&sqlmon_text.' = 'Y'
               AND sql_id = '&&sqlmon_sqlid.' 
               AND sql_text IS NOT NULL
               AND process_name = 'ora'
             ORDER BY
                   sql_exec_start DESC)
             WHERE ROWNUM <= &&rwp_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_SQLTUNE.report_sql_monitor');
    put('( sql_id => ''&&sqlmon_sqlid.''');
    put(', session_id => '||i.sid);
    put(', session_serial => '||i.session_serial#);
    put(', sql_exec_start => TO_DATE('''||TO_CHAR(i.sql_exec_start, '&&sqlmon_date_mask.')||''', ''&&sqlmon_date_mask.'')');
    put(', sql_exec_id => '||i.sql_exec_id);
    put(', inst_id => '||i.inst_id);
    put(', report_level => ''ALL''');
    put(', type => ''TEXT'' );');
    put('END;');
    put('/');
    put('PRINT :myreport;');
    put('SPO rwp_sqlmon_&&sqlmon_sqlid._'||i.sql_exec_id||'_'||LPAD(TO_CHAR(i.sql_exec_start, 'HH24MISS'), 6, '0')||'.txt;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
SPO rwp_sqlmon_&&sqlmon_sqlid..txt;
SELECT DBMS_SQLTUNE.report_sql_monitor_list(sql_id => '&&sqlmon_sqlid.', type => 'TEXT') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_text.' = 'Y';
@rwp_sqlmon_&&sqlmon_sqlid._driver_txt.sql
SPO OFF;

-- active
SET SERVEROUT ON SIZE 1000000;
SPO rwp_sqlmon_&&sqlmon_sqlid._driver_active.sql
DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN
  FOR i IN (SELECT * FROM 
           (SELECT sid,
                   session_serial#,
                   sql_exec_start,
                   sql_exec_id,
                   inst_id
              FROM gv$sql_monitor 
             WHERE '&&tuning_pack.' = 'Y' 
               AND '&&sqlmon_active.' = 'Y'
               AND sql_id = '&&sqlmon_sqlid.' 
               AND sql_text IS NOT NULL
               AND process_name = 'ora'
             ORDER BY
                   sql_exec_start DESC)
             WHERE ROWNUM <= &&rwp_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_SQLTUNE.report_sql_monitor');
    put('( sql_id => ''&&sqlmon_sqlid.''');
    put(', session_id => '||i.sid);
    put(', session_serial => '||i.session_serial#);
    put(', sql_exec_start => TO_DATE('''||TO_CHAR(i.sql_exec_start, '&&sqlmon_date_mask.')||''', ''&&sqlmon_date_mask.'')');
    put(', sql_exec_id => '||i.sql_exec_id);
    put(', inst_id => '||i.inst_id);
    put(', report_level => ''ALL''');
    put(', type => ''ACTIVE'' );');
    put('END;');
    put('/');
    put('SPO rwp_sqlmon_&&sqlmon_sqlid._'||i.sql_exec_id||'_'||LPAD(TO_CHAR(i.sql_exec_start, 'HH24MISS'), 6, '0')||'.html;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
SPO rwp_sqlmon_&&sqlmon_sqlid._list.html;
SELECT DBMS_SQLTUNE.report_sql_monitor_list(sql_id => '&&sqlmon_sqlid.', type => 'HTML') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_active.' = 'Y';
SPO OFF;
@rwp_sqlmon_&&sqlmon_sqlid._driver_active.sql
SPO rwp_sqlmon_&&sqlmon_sqlid._detail.html;
SELECT DBMS_SQLTUNE.report_sql_detail(sql_id => '&&sqlmon_sqlid.', report_level => 'ALL', type => 'ACTIVE') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_active.' = 'Y';
SPO OFF;


-- historical, based on elapsed, worst &&rwp_conf_num_sqlmon_rep.
-- it errors out in < 12c but the error is not reported to screen/main files
SET SERVEROUT ON SIZE 1000000;
SPO rwp_sqlmon_&&sqlmon_sqlid._driver_hist.sql
DECLARE
  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;
BEGIN
  FOR i IN (SELECT * 
              FROM (SELECT report_id,
                           --TO_NUMBER(EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/stats/stat[@name="elapsed_time"]')) 
                           substr(key4,instr(key4,'#')+1, instr(key4,'#',1,2)-instr(key4,'#',1)-1) elapsed,  
                           --EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_exec_id') 
                           key2 sql_exec_id,
                           --EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_exec_start') 
                           key3 sql_exec_start
                      FROM dba_hist_reports
                     WHERE component_name = 'sqlmonitor'
                       --AND EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_id') = '&&sqlmon_sqlid.' 
                       AND key1 = '&&sqlmon_sqlid.'
                       AND '&&tuning_pack.' = 'Y' 
                       AND '&&sqlmon_hist.' = 'Y'
                     ORDER BY 2 DESC)
             WHERE ROWNUM <= &&rwp_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL');
    put('( rid => '||i.report_id);
    put(', type => ''ACTIVE'' );');
    put('END;');
    put('/');
    put('SPO rwp_sqlmon_&&sqlmon_sqlid._'||i.sql_exec_id||'_'||REPLACE(SUBSTR(i.sql_exec_start, 12, 8), ':','')||'_hist.html;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
@rwp_sqlmon_&&sqlmon_sqlid._driver_hist.sql


SPO rwp_sqlmon_&&sqlmon_sqlid._dplan.txt
select * from table( dbms_xplan.display_cursor('&&sqlmon_sqlid.', null, 'ADVANCED +ALLSTATS LAST +MEMSTATS LAST +PREDICATE +PEEKED_BINDS') );  
SPO OFF

SPO rwp_sqlmon_&&sqlmon_sqlid._dplan_awr.txt
select * from table(dbms_xplan.display_awr('&&sqlmon_sqlid.',null,null,'ADVANCED +ALLSTATS LAST +MEMSTATS LAST +PREDICATE +PEEKED_BINDS'));
SPO OFF 

SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF;
COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;
SPO rwp_sqlmon_&&sqlmon_sqlid._rac_xplan.txt;
PRO Current Execution Plans (last execution)
PRO
PRO Captured while still in memory. Metrics below are for the last execution of each child cursor.
PRO If STATISTICS_LEVEL was set to ALL at the time of the hard-parse then A-Rows column is populated.
PRO
SELECT RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, t.plan_table_output
 FROM gv$sql v,
 TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
 WHERE v.sql_id = '&&sqlmon_sqlid.'
 AND v.loaded_versions > 0;
SPO OFF;
SET ECHO OFF FEED 6 VER ON SHOW OFF HEA ON LIN 80 NEWP 1 PAGES 14 LONG 80 LONGC 80 SQLC MIX TAB ON TRIMS OFF TI OFF TIMI OFF ARRAY 15 NUMF "" SQLP SQL> SUF sql BLO . RECSEP WR APPI OFF AUTOT OFF;

alter session disable parallel query;

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_24hrs_db.html
select dbms_perf.report_perfhub(is_realtime=>0,type=>'active',outer_start_time=>sysdate-1,selected_start_time=>sysdate-1) from dual;
spool off

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_realtime_24hrs_db.html
select dbms_perf.report_perfhub(is_realtime=>1,type=>'active',outer_start_time=>sysdate-1,selected_start_time=>sysdate-1) from dual;
spool off

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_realtime_12hrs_db.html
select dbms_perf.report_perfhub(is_realtime=>1,type=>'active',outer_start_time=>sysdate-12/24,selected_start_time=>sysdate-12/24) from dual;
spool off

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_realtime_6hrs_db.html
select dbms_perf.report_perfhub(is_realtime=>1,type=>'active',outer_start_time=>sysdate-6/24,selected_start_time=>sysdate-6/24) from dual;
spool off

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_sqlid.html
select dbms_perf.report_sql(sql_id => '&&sqlmon_sqlid.', is_realtime=>0,type=>'active') from dual;
spool off



SET TERM ON

-- get current time
--SPO &&sqlmon_sqlid..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') current_time FROM DUAL;
SET TERM OFF


HOST zip -jmq rwp_&&sqlmon_sqlid._&&current_time. rwp_sqlmon_*

  
