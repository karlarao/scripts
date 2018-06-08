
-- sqld360 configuration file. for those cases where you must change sqld360 functionality

/*************************** ok to modify (if really needed) ****************************/


DEF sqld360_sqlid = '&&sqld360_sqlid';

-- history days (default 31)
DEF sqld360_conf_days = '31';

-- range of dates below superceed history days when values are other than YYYY-MM-DD
DEF sqld360_conf_date_from = 'YYYY-MM-DD';
DEF sqld360_conf_date_to = 'YYYY-MM-DD';

/**************************** not recommended to modify *********************************/

-- excluding report types reduce usability while providing marginal performance gain
DEF sqld360_conf_incl_html   = 'Y';
DEF sqld360_conf_incl_text   = 'N';
DEF sqld360_conf_incl_csv    = 'N';
DEF sqld360_conf_incl_xml    = 'N';
DEF sqld360_conf_incl_line   = 'Y';
DEF sqld360_conf_incl_pie    = 'Y';
DEF sqld360_conf_incl_bar    = 'Y';
DEF sqld360_conf_incl_tree   = 'Y';
DEF sqld360_conf_incl_bubble = 'Y';

-- include/exclude SQL Monitor reports
DEF sqld360_conf_incl_sqlmon = 'Y';

-- include/exclude DBA_HIST_ASH (always on by default, turned off only by eDB180) 
DEF sqld360_conf_incl_ash_hist = 'Y';

-- include/exclude AWR Reports (always off by default) 
DEF sqld360_conf_incl_awrrpt = 'N';

-- include/exclude ASH SQL Reports (always off by default, very expensive and little benefit) 
DEF sqld360_conf_incl_ashrpt = 'N';

-- include/exclude eAdam (only for standalone execs, always skipped for eDB360 execs) 
DEF sqld360_conf_incl_eadam = 'Y';

-- include/exclude raw ASH data sample (only for standalone execs, always skipped for eDB360 execs) 
DEF sqld360_conf_incl_rawash = 'Y';

-- include/exclude stats history (always on by default, turned off only by eDB180) 
DEF sqld360_conf_incl_stats_h = 'Y';

-- include/exclude search for FORCE MATCHING SQLs (only for standalone execs, always skipped for eDB360 execs) 
DEF sqld360_conf_incl_fmatch = 'Y';

-- include/exclude Metadata section (useful to work around DBMS_METADATA bugs) 
DEF sqld360_conf_incl_metadata = 'Y';

-- include/exclude basic stats commands 
DEF sqld360_conf_incl_stats = 'Y';

-- include/exclude Testcase Builder (only for standalone execs, always skipped for eDB360 execs) 
DEF sqld360_conf_incl_tcb = 'N';

-- include/exclude SQL Tuning Advisor reports (not calling the API, just reporting on already executed tasks)
DEF sqld360_conf_incl_sta = 'Y';

-- TCB data, sampling percentage, 0 means no data, any other value between 1 and 100 is ok (only for standalone execs, always skipped for eDB360 execs) 
-- THIS OPTION IS INTENTIONALLY INGORED, email me if you'd like to have TCB with data
DEF sqld360_conf_tcb_sample = '0';

-- include/exclude translate min/max/histograms endpoint values
DEF sqld360_conf_translate_lowhigh = 'Y';

-- number of partitions to consider for column stats gathering (first 100, last 100)
DEF sqld360_conf_first_part = '10';
DEF sqld360_conf_last_part = '10';

-- number of PHV to include in Plan Details
DEF sqld360_num_plan_details = '20';

-- number of top executions to individually analyze, from memory and history
DEF sqld360_conf_num_top_execs = '3';

-- number of AWR reports to collect, total and NOT per instance
DEF sqld360_conf_num_awrrpt = '3';

-- number of SQL Monitoring reports to collect, from memory and history
DEF sqld360_conf_num_sqlmon_rep = '12';

-- percentile to use in Avg ET based on ASH
DEF sqld360_conf_avg_et_percth = '90';

-- include/exclude v$object_dependency (tends to pollute the report, but brings more views)
DEF sqld360_conf_incl_obj_dept = 'N';

-- enable / disable SQLd360 tracing itself (0 => OFF, everything else is ON)
DEF sqld360_sqltrace_level = '0';

-- specify a different DBID than default
DEF sqld360_conf_dbid = '';

/**************************** not recommended to modify *********************************/

DEF sqld360_conf_tool_page = '<a href="http://www.enkitec.com/products/sqld360" target="_blank">';
DEF sqld360_conf_tool_page = '<a href="http://mauro-pagano.com/2015/02/16/sqld360-sql-diagnostics-collection-made-faster/" target="_blank">';
DEF sqld360_conf_all_pages_icon = '<a href="http://www.enkitec.com/products/sqld360" target="_blank"><img src="SQLd360_img.jpg" alt="SQLd360" height="49" width="58"></a>';
DEF sqld360_conf_all_pages_icon = '<a href="http://mauro-pagano.com/2015/02/16/sqld360-sql-diagnostics-collection-made-faster/" target="_blank"><img src="SQLd360_img.jpg" alt="SQLd360" height="49" width="58"></a>';
DEF sqld360_conf_all_pages_logo = '<img src="SQLd360_all_pages_logo.jpg" alt="Enkitec now part of Accenture" width="117" height="29">';
DEF sqld360_conf_all_pages_logo = '';
DEF sqld360_conf_google_charts = '<script type="text/javascript" src="https://www.google.com/jsapi"></script>';


/**************************** enter your modifications here *****************************/

--DEF sqld360_conf_incl_text = 'N';
--DEF sqld360_conf_incl_csv = 'N';
--DEF sqld360_conf_date_from = '2016-04-15';
--DEF sqld360_conf_date_to = '2016-04-18';




DEF sqld360_prefix = 'sqlmon';
DEF sqld360_main_report = 'sqlmon';
DEF section_id = '5b';
DEF section_name = 'SQL Monitor Reports';
DEF report_sequence = '5b';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');
SPO &&sqld360_main_report..html APP;
-- PRO <h2>&&section_id.. &&section_name.</h2>
-- PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'SQL Monitor Reports';
DEF main_table = 'GV$SQL_MONITOR';

-- @@sqld360_0s_pre_nondef


SET LIN 32767 PAGES 0 LONG 32767000 LONGC 32767 TRIMS ON AUTOT OFF;
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SET TERM OFF;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') sqld360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SELECT REPLACE(TRANSLATE('&&title.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789_'), '__', '_') title_no_spaces FROM DUAL;
SELECT '&&common_sqld360_prefix._&&section_id._&&report_sequence._&&title_no_spaces.' spool_filename FROM DUAL;
SET HEA OFF;

-- add seq to spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

SET TERM ON; 

-- log
SPO &&sqld360_log..txt APP;
-- PRO
-- PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- PRO
-- PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number. "&&section_name."
-- PRO &&hh_mm_ss. &&title.&&title_suffix.




VAR myreport CLOB

-- text
SET SERVEROUT ON SIZE 1000000;
SET TERM OFF
SPO sqld360_sqlmon_&&sqld360_sqlid._driver_txt.sql
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
               AND sql_id = '&&sqld360_sqlid.' 
               AND sql_text IS NOT NULL
               AND process_name = 'ora'
             ORDER BY
                   sql_exec_start DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_SQLTUNE.report_sql_monitor');
    put('( sql_id => ''&&sqld360_sqlid.''');
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
    put('SPO sqld360_sqlmon_&&sqld360_sqlid._'||i.sql_exec_id||'_'||LPAD(TO_CHAR(i.sql_exec_start, 'HH24MISS'), 6, '0')||'.txt;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
SPO sqld360_sqlmon_&&sqld360_sqlid..txt;
SELECT DBMS_SQLTUNE.report_sql_monitor_list(sql_id => '&&sqld360_sqlid.', type => 'TEXT') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_text.' = 'Y';
@sqld360_sqlmon_&&sqld360_sqlid._driver_txt.sql
SPO OFF;

-- active
SET SERVEROUT ON SIZE 1000000;
SPO sqld360_sqlmon_&&sqld360_sqlid._driver_active.sql
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
               AND sql_id = '&&sqld360_sqlid.' 
               AND sql_text IS NOT NULL
               AND process_name = 'ora'
             ORDER BY
                   sql_exec_start DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_SQLTUNE.report_sql_monitor');
    put('( sql_id => ''&&sqld360_sqlid.''');
    put(', session_id => '||i.sid);
    put(', session_serial => '||i.session_serial#);
    put(', sql_exec_start => TO_DATE('''||TO_CHAR(i.sql_exec_start, '&&sqlmon_date_mask.')||''', ''&&sqlmon_date_mask.'')');
    put(', sql_exec_id => '||i.sql_exec_id);
    put(', inst_id => '||i.inst_id);
    put(', report_level => ''ALL''');
    put(', type => ''ACTIVE'' );');
    put('END;');
    put('/');
    put('SPO sqld360_sqlmon_&&sqld360_sqlid._'||i.sql_exec_id||'_'||LPAD(TO_CHAR(i.sql_exec_start, 'HH24MISS'), 6, '0')||'.html;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
SPO sqld360_sqlmon_&&sqld360_sqlid._list.html;
SELECT DBMS_SQLTUNE.report_sql_monitor_list(sql_id => '&&sqld360_sqlid.', type => 'HTML') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_active.' = 'Y';
SPO OFF;
@sqld360_sqlmon_&&sqld360_sqlid._driver_active.sql
SPO sqld360_sqlmon_&&sqld360_sqlid._detail.html;
SELECT DBMS_SQLTUNE.report_sql_detail(sql_id => '&&sqld360_sqlid.', report_level => 'ALL', type => 'ACTIVE') 
  FROM DUAL 
 WHERE '&&tuning_pack.' = 'Y' 
   AND '&&sqlmon_active.' = 'Y';
SPO OFF;


-- historical, based on elapsed, worst &&sqld360_conf_num_sqlmon_rep.
-- it errors out in < 12c but the error is not reported to screen/main files
SET SERVEROUT ON SIZE 1000000;
SPO sqld360_sqlmon_&&sqld360_sqlid._driver_hist.sql
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
                       --AND EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_id') = '&&sqld360_sqlid.' 
                       AND key1 = '&&sqld360_sqlid.'
                       AND '&&tuning_pack.' = 'Y' 
                       AND '&&sqlmon_hist.' = 'Y'
                     ORDER BY 2 DESC)
             WHERE ROWNUM <= &&sqld360_conf_num_sqlmon_rep.)
  LOOP
    put('BEGIN');
    put(':myreport :=');
    put('DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL');
    put('( rid => '||i.report_id);
    put(', type => ''ACTIVE'' );');
    put('END;');
    put('/');
    put('SPO sqld360_sqlmon_&&sqld360_sqlid._'||i.sql_exec_id||'_'||REPLACE(SUBSTR(i.sql_exec_start, 12, 8), ':','')||'_hist.html;');
    put('PRINT :myreport;');
    put('SPO OFF;');
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
@sqld360_sqlmon_&&sqld360_sqlid._driver_hist.sql

-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SET TERM ON
-- get current time
SPO &&sqld360_log..txt APP;
COL current_time NEW_V current_time FOR A15;
SELECT 'Completed: ' x, TO_CHAR(SYSDATE, 'HH24:MI:SS') current_time FROM DUAL;
SET TERM OFF

HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log..txt

-- update main report
SPO &&sqld360_main_report..html APP;
-- PRO <li title="&&main_table.">&&title.
-- PRO <a href="&&one_spool_filename._sqlmon.zip">zip</a>
-- PRO </li>
-- PRO </ol>
SPO OFF;
HOS zip -jmq 99999_sqld360_&&sqld360_sqlid._drivers sqld360_sqlmon_&&sqld360_sqlid._driver*
HOS zip -jmq &&one_spool_filename._sqlmon sqld360_sqlmon_&&sqld360_sqlid.*
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename._sqlmon.zip
HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_main_report..html

--HOS zip -q &&sqld360_main_filename._&&sqld360_file_time. &&sqld360_log2..txt


  