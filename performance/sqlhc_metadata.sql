SPO sqlhc.log
SET DEF ^ TERM OFF ECHO ON AUTOP OFF VER OFF SERVEROUT ON SIZE 1000000;
REM
REM $Header: 1366133.1 sqlhc.sql 12.1.08 2014/04/18 carlos.sierra mauro.pagano $
REM
REM Copyright (c) 2000-2013, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM   mauro.pagano@oracle.com
REM
REM SCRIPT
REM   sqlhc.sql SQL Health-Check (extract mode)
REM
REM DESCRIPTION
REM   Produces an HTML report with a list of observations based on
REM   health-checks performed in and around a SQL statement that
REM   may be performing poorly.
REM
REM   Inputs a memory-resident SQL_ID.
REM
REM   In addition to the health_check report, it generates some
REM   additional diagnostics files regarding SQL performance.
REM
REM   This script does not install any objects in the database.
REM   It does not perform any DDL commands.
REM   It only performs DML commands against the PLAN_TABLE then it
REM   rolls back those temporary inserts.
REM   It can be used in Dataguard or any read-only database.
REM
REM PRE-REQUISITES
REM   1. Execute as SYS or user with DBA role or user with access
REM      to data dictionary views.
REM   2. The SQL for which this script is executed must be
REM      memory-resident.
REM
REM PARAMETERS
REM   1. Oracle Pack license (Tuning or Diagnostics or None) T|D|N
REM   2. SQL_ID of interest.
REM
REM EXECUTION
REM   1. Start SQL*Plus connecting as SYS or user with DBA role or
REM      user with access to data dictionary views.
REM   2. Execute script sqlhc.sql passing values for parameters.
REM
REM EXAMPLE
REM   # sqlplus / as sysdba
REM   SQL> START [path]sqlhc.sql [T|D|N] [SQL_ID]
REM   SQL> START sqlhc.sql T 51x6yr9ym5hdc
REM
REM NOTES
REM   1. For possible errors see sqlhc.log.
REM   2. If site has both Tuning and Diagnostics licenses then
REM      specified T (Oracle Tuning pack includes Oracle Diagnostics)
REM   3. On a read-only instance, the "Observations" section with the
REM      results of the health-checks will be missing.
REM
DEF health_checks = 'Y';
DEF shared_cursor = 'N';
DEF sql_monitor_reports = '12';
REM
DEF script = 'sqlhc';
DEF method = 'SQLHC';
DEF mos_doc = '1366133.1';
DEF doc_ver = '12.1.06';
DEF doc_date = '2014/01/30';
-- sqldx_output: HTML/CSV/BOTH/NONE
DEF sqldx_output = 'CSV';

/**************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_MODULE(module_name => '^^method. ^^doc_ver.', action_name => '^^script..sql');
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => '^^method.');
VAR health_checks CHAR(1);
EXEC :health_checks := '^^health_checks.';
VAR shared_cursor CHAR(1);
EXEC :shared_cursor := '^^shared_cursor.';
SET TERM ON ECHO OFF;
PRO
PRO Parameter 1:
PRO Oracle Pack License (Tuning, Diagnostics or None) [T|D|N] (required)
PRO
DEF input_license = '^1';
PRO
SET TERM OFF;
COL license NEW_V license FOR A1;

SELECT UPPER(SUBSTR(TRIM('^^input_license.'), 1, 1)) license FROM DUAL;

VAR license CHAR(1);
EXEC :license := '^^license.';

COL unique_id NEW_V unique_id FOR A15;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') unique_id FROM DUAL;

SET TERM ON;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

BEGIN
  IF '^^license.' IS NULL OR '^^license.' NOT IN ('T', 'D', 'N') THEN
    RAISE_APPLICATION_ERROR(-20100, 'Oracle Pack License (Tuning, Diagnostics or None) must be specified as "T" or "D" or "N".');
  END IF;
END;
/

WHENEVER SQLERROR CONTINUE;

PRO
PRO Parameter 2:
PRO SQL_ID of the SQL to be analyzed (required)
PRO
DEF input_sql_id = '^2';
DEF input_parameter = '^^input_sql_id.';
PRO

PRO Values passed:
PRO License: "^^input_license."
PRO SQL_ID : "^^input_sql_id."
PRO
--SET TERM OFF;

-- get dbid
COL dbid NEW_V dbid;
SELECT dbid FROM v$database;

COL sql_id NEW_V sql_id FOR A13;

SELECT sql_id
  FROM gv$sqlarea
 WHERE sql_id = TRIM('^^input_sql_id.')
 UNION
SELECT sql_id
  FROM dba_hist_sqltext
 WHERE :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = TRIM('^^input_sql_id.');

VAR sql_id VARCHAR2(13);
EXEC :sql_id := '^^sql_id.';

SET TERM ON;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

BEGIN
  IF '^^sql_id.' IS NULL THEN
    IF :license IN ('T', 'D') THEN
      RAISE_APPLICATION_ERROR(-20200, 'SQL_ID "^^input_sql_id." not found in memory nor in AWR.');
    ELSE
      RAISE_APPLICATION_ERROR(-20200, 'SQL_ID "^^input_sql_id." not found in memory.');
    END IF;
  END IF;
END;
/

WHENEVER SQLERROR CONTINUE;
SET ECHO ON TIMI ON;

/**************************************************************************************************
 *
 * begin_common: from begin_common to end_common sqlhc.sql and sqlhcxec.sql are identical
 *
 **************************************************************************************************/
SELECT 'BEGIN: '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;

DEF doc_link = 'https://support.oracle.com/CSP/main/article?cmd=show&type=NOT&id=';
DEF bug_link = 'https://support.oracle.com/CSP/main/article?cmd=show&type=BUG&id=';

-- tracing script in case it takes long to execute so we can diagnose it
-- ALTER SESSION SET MAX_DUMP_FILE_SIZE = '1G';
-- ALTER SESSION SET TRACEFILE_IDENTIFIER = "^^script._^^unique_id.";
-- --ALTER SESSION SET STATISTICS_LEVEL = 'ALL';
-- ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT FOREVER, LEVEL 12';

-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';

/**************************************************************************************************/

/* -------------------------
 *
 * get sql_text
 *
 * ------------------------- */

VAR sql_text CLOB;
EXEC :sql_text := NULL;

-- get sql_text from memory
DECLARE
  l_sql_text VARCHAR2(32767);
BEGIN -- 10g see bug 5017909
  DBMS_OUTPUT.PUT_LINE('getting sql_text from memory');
  FOR i IN (SELECT DISTINCT piece, sql_text
              FROM gv$sqltext_with_newlines
             WHERE sql_id = '^^sql_id.'
             ORDER BY 1, 2)
  LOOP
    IF :sql_text IS NULL THEN
      DBMS_LOB.CREATETEMPORARY(:sql_text, TRUE);
      DBMS_LOB.OPEN(:sql_text, DBMS_LOB.LOB_READWRITE);
    END IF;
    l_sql_text := REPLACE(i.sql_text, CHR(00), ' ');
    DBMS_LOB.WRITEAPPEND(:sql_text, LENGTH(l_sql_text), l_sql_text);
  END LOOP;
  IF :sql_text IS NOT NULL THEN
    DBMS_LOB.CLOSE(:sql_text);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('getting sql_text from memory: '||SQLERRM);
    :sql_text := NULL;
END;
/

-- get sql_text from awr
BEGIN
  IF :license IN ('T', 'D') AND (:sql_text IS NULL OR NVL(DBMS_LOB.GETLENGTH(:sql_text), 0) = 0) THEN
    DBMS_OUTPUT.PUT_LINE('getting sql_text from awr');
    SELECT REPLACE(sql_text, CHR(00), ' ')
      INTO :sql_text
      FROM dba_hist_sqltext
     WHERE :license IN ('T', 'D')
       AND dbid = ^^dbid.
       AND sql_id = '^^sql_id.'
       AND sql_text IS NOT NULL
       AND ROWNUM = 1;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('getting sql_text from awr: '||SQLERRM);
    :sql_text := NULL;
END;
/

SELECT :sql_text FROM DUAL;

/* -------------------------
 *
 * get several values
 *
 * ------------------------- */

-- signature (force=false)
VAR signature NUMBER;
BEGIN
  IF :license = 'T' THEN
    :signature := DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(:sql_text, FALSE);
  ELSE
    :signature := -1;
  END IF;
END;
/
COL signature NEW_V signature FOR A20;
SELECT TO_CHAR(:signature) signature FROM DUAL;

-- signature (force=true)
VAR signaturef NUMBER;
BEGIN
  IF :license = 'T' THEN
    :signaturef := DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(:sql_text, TRUE);
  ELSE
    :signaturef := -1;
  END IF;
END;
/
COL signaturef NEW_V signaturef FOR A20;
SELECT TO_CHAR(:signaturef) signaturef FROM DUAL;

-- get database name (up to 10, stop before first '.', no special characters)
COL database_name_short NEW_V database_name_short FOR A10;
SELECT SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10) database_name_short FROM DUAL;
SELECT SUBSTR('^^database_name_short.', 1, INSTR('^^database_name_short..', '.') - 1) database_name_short FROM DUAL;
SELECT TRANSLATE('^^database_name_short.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789') database_name_short FROM DUAL;

-- get host name (up to 30, stop before first '.', no special characters)
COL host_name_short NEW_V host_name_short FOR A30;
SELECT SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30) host_name_short FROM DUAL;
SELECT SUBSTR('^^host_name_short.', 1, INSTR('^^host_name_short..', '.') - 1) host_name_short FROM DUAL;
SELECT TRANSLATE('^^host_name_short.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789') host_name_short FROM DUAL;

-- get rdbms version
COL rdbms_version NEW_V rdbms_version FOR A17;
SELECT version rdbms_version FROM v$instance;

-- get platform
COL platform NEW_V platform FOR A80;
SELECT UPPER(TRIM(REPLACE(REPLACE(product, 'TNS for '), ':' ))) platform FROM product_component_version WHERE product LIKE 'TNS for%' AND ROWNUM = 1;

-- get instance
COL instance_number NEW_V instance_number FOR A10;
SELECT TO_CHAR(instance_number) instance_number FROM v$instance;

-- YYYYMMDD_HH24MISS
COL time_stamp NEW_V time_stamp FOR A15;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') time_stamp FROM DUAL;

-- YYYY-MM-DD/HH24:MI:SS
COL time_stamp2 NEW_V time_stamp2 FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') time_stamp2 FROM DUAL;

-- get db_block_size
COL sys_db_block_size NEW_V sys_db_block_size FOR A17;
SELECT value sys_db_block_size FROM v$system_parameter2 WHERE LOWER(name) = 'db_block_size';

-- get cpu_count
COL sys_cpu NEW_V sys_cpu FOR A17;
SELECT value sys_cpu FROM v$system_parameter2 WHERE LOWER(name) = 'cpu_count';

-- get ofe
COL sys_ofe NEW_V sys_ofe FOR A17;
SELECT value sys_ofe FROM v$system_parameter2 WHERE LOWER(name) = 'optimizer_features_enable';

-- get ds
COL sys_ds NEW_V sys_ds FOR A10;
SELECT value sys_ds FROM v$system_parameter2 WHERE LOWER(name) = 'optimizer_dynamic_sampling';

-- Exadata?
COL exadata NEW_V exadata FOR A1;
SELECT 'Y' exadata FROM v$cell_state WHERE ROWNUM = 1;

-- get user
COL sessionuser NEW_V sessionuser FOR A50;
SELECT TO_CHAR(SYS_CONTEXT('USERENV','SESSION_USER')) sessionuser FROM dual;

-- get num_cpu
COL num_cpus NEW_V num_cpus FOR A10
SELECT TO_CHAR(value) num_cpus FROM v$osstat WHERE stat_name = 'NUM_CPUS';

-- get num_cores
COL num_cores NEW_V num_cores FOR A10
SELECT TO_CHAR(value) num_cores FROM v$osstat WHERE stat_name = 'NUM_CPU_CORES';

-- get num_cpu
COL num_sockets NEW_V num_sockets FOR A10
SELECT TO_CHAR(value) num_sockets FROM v$osstat WHERE stat_name = 'NUM_CPU_SOCKETS';

/* -------------------------
 *
 * application vendor
 *
 * ------------------------- */

-- ebs
COL is_ebs NEW_V is_ebs FOR A1;
COL ebs_owner NEW_V ebs_owner FOR A30;
SELECT 'Y' is_ebs, owner ebs_owner
  FROM dba_tab_columns
 WHERE table_name = 'FND_PRODUCT_GROUPS'
   AND column_name = 'RELEASE_NAME'
   AND data_type = 'VARCHAR2'
   AND ROWNUM = 1;

-- siebel
COL is_siebel NEW_V is_siebel FOR A1;
COL siebel_owner NEW_V siebel_owner FOR A30;
SELECT 'Y' is_siebel, owner siebel_owner
  FROM dba_tab_columns
 WHERE '^^is_ebs.' IS NULL
   AND table_name = 'S_REPOSITORY'
   AND column_name = 'ROW_ID'
   AND data_type = 'VARCHAR2'
   AND ROWNUM = 1;

-- psft
COL is_psft NEW_V is_psft FOR A1;
COL psft_owner NEW_V psft_owner FOR A30;
SELECT 'Y' is_psft, owner psft_owner
  FROM dba_tab_columns
 WHERE '^^is_ebs.' IS NULL
   AND '^^is_siebel.' IS NULL
   AND table_name = 'PSSTATUS'
   AND column_name = 'TOOLSREL'
   AND data_type = 'VARCHAR2'
   AND ROWNUM = 1;

/* -------------------------
 *
 * find tables and indexes
 *
 * ------------------------- */

-- transaction begins here. it will be rolled back after generating spool file
SAVEPOINT save_point_1;

-- this script uses the gtt plan_table as a temporary staging place to store results of health-checks
DELETE plan_table;

-- record tables
INSERT INTO plan_table (object_type, object_owner, object_name)
WITH object AS (
SELECT /*+ MATERIALIZE */
       object_owner owner, object_name name
  FROM gv$sql_plan
 WHERE :health_checks = 'Y'
   AND inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
 UNION
SELECT object_owner owner, object_name name
  FROM dba_hist_sql_plan
 WHERE :health_checks = 'Y'
   AND :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
)
SELECT 'TABLE', t.owner, t.table_name
  FROM dba_tab_statistics t, -- include fixed objects
       object o
 WHERE :health_checks = 'Y'
   AND t.owner = o.owner
   AND t.table_name = o.name
 UNION
SELECT 'TABLE', i.table_owner, i.table_name
  FROM dba_indexes i,
       object o
 WHERE :health_checks = 'Y'
   AND i.owner = o.owner
   AND i.index_name = o.name;

-- list tables
SELECT object_owner owner, object_name table_name
  FROM plan_table
 WHERE :health_checks = 'Y'
   AND object_type = 'TABLE'
 ORDER BY 1, 2;

-- record indexes from known plans
INSERT INTO plan_table (object_type, object_owner, object_name, other_tag)
SELECT 'INDEX', object_owner owner, object_name index_name, 'YES'
  FROM gv$sql_plan
 WHERE :health_checks = 'Y'
   AND inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND (object_type LIKE '%INDEX%' OR operation LIKE '%INDEX%')
 UNION
SELECT 'INDEX', object_owner owner, object_name index_name, 'YES'
  FROM dba_hist_sql_plan
 WHERE :health_checks = 'Y'
   AND :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND (object_type LIKE '%INDEX%' OR operation LIKE '%INDEX%');

-- record indexes from tables in plan
INSERT INTO plan_table (object_type, object_owner, object_name, other_tag)
SELECT 'INDEX', owner, index_name, 'NO'
  FROM plan_table t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND t.object_type = 'TABLE'
   AND t.object_owner = i.table_owner
   AND t.object_name = i.table_name
 MINUS
SELECT 'INDEX', object_owner, object_name, 'NO'
  FROM plan_table t
 WHERE :health_checks = 'Y'
   AND object_type = 'INDEX';

COL in_plan FOR A7;
-- list indexes
SELECT object_owner owner, object_name index_name, other_tag in_plan
  FROM plan_table
 WHERE :health_checks = 'Y'
   AND object_type = 'INDEX'
 ORDER BY 1, 2;

/* -------------------------
 *
 * record type enumerator
 *
 * ------------------------- */

-- constants
VAR E_GLOBAL     NUMBER;
VAR E_EBS        NUMBER;
VAR E_SIEBEL     NUMBER;
VAR E_PSFT       NUMBER;
VAR E_TABLE      NUMBER;
VAR E_INDEX      NUMBER;
VAR E_1COL_INDEX NUMBER;
VAR E_TABLE_PART NUMBER;
VAR E_INDEX_PART NUMBER;
VAR E_TABLE_COL  NUMBER;

EXEC :E_GLOBAL     := 01;
EXEC :E_EBS        := 02;
EXEC :E_SIEBEL     := 03;
EXEC :E_PSFT       := 04;
EXEC :E_TABLE      := 05;
EXEC :E_INDEX      := 06;
EXEC :E_1COL_INDEX := 07;
EXEC :E_TABLE_PART := 08;
EXEC :E_INDEX_PART := 09;
EXEC :E_TABLE_COL  := 10;

/**************************************************************************************************/

/* -------------------------
 *
 * Metadata
 *
 * ------------------------- */
PRO <a name="metadata"></a><h2>Metadata</h2>
PRO
PRO Table and Index Metadata of the objects involved in the plan and their dependent objects
PRO
SET LONG 1000000 LONGCHUNKSIZE 1000000
WITH object AS (
SELECT /*+ MATERIALIZE */
       object_owner owner, object_name name
  FROM gv$sql_plan
 WHERE inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
 UNION
SELECT object_owner owner, object_name name
  FROM dba_hist_sql_plan
 WHERE :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
 )
 SELECT '<h3>Table: '||t.object_owner||'.'||t.object_name||'</h3>'||REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DBMS_METADATA.GET_DDL('TABLE',t.object_name,t.object_owner), '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;'), '''', CHR(38)||'#39;'), '"', CHR(38)||'quot;'), CHR(10), '<br>'||CHR(10))
   FROM (SELECT t.owner object_owner, t.table_name object_name
           FROM dba_tables t, -- include fixed objects
                object o
          WHERE t.owner = o.owner
            AND t.table_name = o.name
          UNION
         SELECT i.table_owner object_owner, i.table_name object_name
           FROM dba_indexes i,
                object o
          WHERE i.owner = o.owner
            AND i.index_name = o.name) t;
			
WITH object AS (
SELECT /*+ MATERIALIZE */
       object_owner owner, object_name name
  FROM gv$sql_plan
 WHERE inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
 UNION
SELECT object_owner owner, object_name name
  FROM dba_hist_sql_plan
 WHERE :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
 ), plan_tables AS (
 SELECT /*+ MATERIALIZE */
        'TABLE' object_type, t.owner object_owner, t.table_name object_name
   FROM dba_tables t, -- include fixed objects
        object o
  WHERE t.owner = o.owner
    AND t.table_name = o.name
  UNION
 SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
   FROM dba_indexes i,
        object o
  WHERE i.owner = o.owner
    AND i.index_name = o.name
)
SELECT '<h3>Index: '||s.owner||'.'||s.index_name||'</h3>'||REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DBMS_METADATA.GET_DDL('INDEX',s.index_name,s.owner), '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;'), '''', CHR(38)||'#39;'), '"', CHR(38)||'quot;'), CHR(10), '<br>'||CHR(10))
  FROM plan_tables pt,
       dba_indexes s
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
 ORDER BY
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner;
			


/**************************************************************************************************/

/* -------------------------
 *
 * wrap up
 *
 * ------------------------- */

-- -- turing trace off
-- ALTER SESSION SET SQL_TRACE = FALSE;
-- --ALTER SESSION SET STATISTICS_LEVEL = 'TYPICAL';

-- -- get udump directory path
-- COL udump_path NEW_V udump_path FOR A500;
-- SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') udump_path FROM v$parameter2 WHERE name = 'user_dump_dest';

-- -- tkprof for trace from execution of tool in case someone reports slow performance in tool
-- HOS tkprof ^^udump_path.*^^script._^^unique_id.*.trc ^^files_prefix._tkprof_nosort.txt
-- HOS tkprof ^^udump_path.*^^script._^^unique_id.*.trc ^^files_prefix._tkprof_sort.txt sort=prsela exeela fchela

-- -- windows workaround (copy below will error out on linux and unix)
-- HOS copy ^^udump_path.*^^script._^^unique_id.*.trc ^^udump_path.^^script._^^unique_id..trc
-- HOS tkprof ^^udump_path.^^script._^^unique_id..trc ^^files_prefix._tkprof_nosort.txt
-- HOS tkprof ^^udump_path.^^script._^^unique_id..trc ^^files_prefix._tkprof_sort.txt sort=prsela exeela fchela

SPO ^^script..log APP
SELECT 'END: '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
SPO OFF;

/**************************************************************************************************
 *
 * end_common: from begin_common to end_common sqlhc.sql and sqlhcxec.sql are identical
 *
 **************************************************************************************************/

-- zip now in case DBMS_SQLDIAG.DUMP_TRACE disconnects
HOS zip -m ^^files_prefix..zip ^^files_prefix._1_health_check.html
HOS zip -m ^^files_prefix..zip ^^files_prefix._2_diagnostics.html
HOS zip -m ^^files_prefix..zip ^^files_prefix._3_execution_plans.html
HOS zip -m ^^files_prefix..zip ^^files_prefix._4_sql_detail.html
HOS zip -m ^^files_prefix._9_log.zip ^^script..log
HOS zip -m ^^files_prefix._9_log.zip sql_shared_cursor_sum_^^sql_id..sql
HOS zip -m ^^files_prefix._9_log.zip sql_shared_cursor_col_^^sql_id..sql
HOS zip -m ^^files_prefix._9_log.zip sql_shared_cursor_cur_^^sql_id..sql
HOS zip -m ^^files_prefix._9_log.zip ^^files_prefix._tkprof_*.txt
HOS zip -m ^^files_prefix._9_log.zip ^^files_prefix._5_sql_monitor.sql
HOS zip -m ^^files_prefix..zip ^^files_prefix._9_log.zip
HOS zip -m ^^files_prefix._5_sql_monitor.zip ^^files_prefix._*_5_sql_monitor.html
HOS zip -m ^^files_prefix..zip ^^files_prefix._5_sql_monitor.zip

-- end
EXEC DBMS_APPLICATION_INFO.SET_MODULE(module_name => NULL, action_name => NULL);
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO(client_info => '^^sqldx_prefix.');
@@sqldx.sql ^^license. ^^sqldx_output. ^^sql_id.
SET TERM ON ECHO OFF FEED 6 VER ON SHOW OFF HEA ON LIN 80 NEWP 1 PAGES 14 LONG 80 LONGC 80 SQLC MIX TAB ON TRIMS OFF TI OFF TIMI OFF ARRAY 15 NUMF "" SQLP SQL> SUF sql BLO . RECSEP WR APPI OFF SERVEROUT OFF AUTOT OFF;
PRO
SET DEF ON;
HOS zip -m &&files_prefix..zip &&sqldx_prefix.*
PRO
PRO SQLDX files have been added to &&files_prefix..zip
PRO
HOS unzip -l &&files_prefix..zip
CL COL;
UNDEF 1 2 method script mos_doc doc_ver doc_date doc_link bug_link input_parameter input_sql_id input_license unique_id sql_id signature signaturef license udump_path sqldx_prefix sqldx_output;
