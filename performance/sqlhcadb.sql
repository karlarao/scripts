SPO sqlhc.log
SET DEF ^
SET TERM OFF ECHO ON AUTOP OFF VER OFF SERVEROUT ON SIZE 1000000;
REM
Rem $Header: pdbcs/no_ship_src/service/scripts/ops/adb_sql/diagsql/sqlhc.sql /main/3 2022/03/07 01:33:04 scharala Exp $
REM
REM Copyright (c) 2000, 2022, Oracle and/or its affiliates. 
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
REM uday enabled shared cursors
REM
Rem    MODIFIED   (MM/DD/YY)
Rem    kdrupare    02/24/22 - Bug 33709268: Collect more historical sql_monitor
Rem                           reports
Rem    scharala    01/21/22 - Bug 33779031; Added new TCB functionality
Rem    kruparel    09/24/21 - Created
Rem    kdrupare    09/24/21 - Created
Rem
DEF health_checks = 'Y';
DEF shared_cursor = 'Y';
DEF sql_monitor_reports = '12';
REM
DEF script = 'sqlhc';
DEF method = 'SQLHC';
DEF mos_doc = '1366133.1';
DEF doc_ver = '12.1.08.PSRv10.15';
DEF doc_date = '2020/10/22';
-- sqldx_output: HTML/CSV/BOTH/NONE
-- uday disabled sqldx
DEF sqldx_output = 'NONE';

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

VAR L_SQLHC_MIN NUMBER;
COL unique_id NEW_V unique_id FOR A15;
col sqlhcstart NEW_V sqlhcstart
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') unique_id, to_char(systimestamp, 'DD-Mon-RR HH24:MI:SS.FF') sqlhcstart FROM DUAL;
-- SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') unique_id FROM DUAL;

SET TERM ON LIN 100 TRIMS ON FEED OFF;
var Fusion_PDB     varchar2(128);
var is_multitenant varchar2(4);
var con_id         number;
var con_name       varchar2(128);
var pdb_name       varchar2(128);

declare
  dbname       varchar(25);
  inst_number  number;
  inst_name    varchar(25);
  cdbid        number;
begin
  -- get the current db/instance information
  select d.con_dbid, d.name, sys_context('USERENV', 'CON_ID'), sys_context('USERENV', 'CON_NAME'), upper(d.CDB)
        ,i.instance_number, i.instance_name
  into   cdbid, dbname, :con_id, :con_name, :is_multitenant, inst_number, inst_name
  from   v$database d,
         v$instance i;
    -- display the info
    dbms_output.put_line('~~~~~~~~~~~~~~~~');
    dbms_output.put_line('Current Instance');
    dbms_output.put_line('~~~~~~~~~~~~~~~~');
    dbms_output.put_line(rpad('DB Id', 15) ||' '||rpad('DB Name', 15) ||' '||
                         rpad('Inst Num', 15) ||' '|| rpad('Instance', 15) ||' '||
                         --rpad('MultiTenant',11)||' '|| 
                         rpad('Container Id', 15) ||' '||
                         rpad('Container Name', 15));
    dbms_output.put_line(rpad('-',15,'-') ||' '|| rpad('-',15,'-') ||' '|| 
                         rpad('-',15,'-') ||' '|| rpad('-',15,'-') ||' '||
                         --rpad('-',11,'-') ||' '||
                         rpad('-',15,'-') ||' '|| rpad('-',15,'-'));
    dbms_output.put_line(rpad(cdbid, 15) ||' '|| 
                         rpad(dbname, 15) || ' ' || 
                         rpad(inst_number,15) ||' '||
                         rpad(inst_name, 15) ||' '|| 
                         --rpad(:is_multitenant, 11) ||' '||
                         rpad(:con_id,15) ||' '|| rpad(:con_name,15));
    dbms_output.put_line(chr(10));
    if :is_multitenant <> 'YES' then
      :Fusion_PDB := :con_name;
    end if;
end;
/

begin   
  -- show PDB info (highlight supposedly FUSION FA PDB)
  --if :is_multitenant = 'YES' and :con_id <> 0 then
  if :is_multitenant = 'YES' then
    -- you are in CDB
    dbms_output.put_line('~~~~~~~~~~~~~~~~');    
    dbms_output.put_line('*Available PDBs*');
    dbms_output.put_line('~~~~~~~~~~~~~~~~');        
    dbms_output.put_line(rpad('PDB NAME', 15)||' '||rpad('FA PDB?', 35));
    dbms_output.put_line(rpad('-',15,'-')||' '||rpad('-',35,'-'));
    -- get the PDBs
    for pdb_rec in (select PDB_NAME from dba_pdbs order by 1)
    loop
      if regexp_count(pdb_rec.PDB_NAME,'_F$',1,'i') > 0 then
      --if regexp_count(pdb_rec.PDB_NAME,'1$',1,'i') > 0 then
        dbms_output.put_line(rpad(pdb_rec.PDB_NAME, 15)||' ' ||rpad('YES [** per the naming convention]', 35));
        :Fusion_PDB := pdb_rec.PDB_NAME;    
        exit;    
      else
        dbms_output.put_line(rpad(pdb_rec.PDB_NAME, 15)||' ' ||rpad('NO', 35));
        :Fusion_PDB := pdb_rec.PDB_NAME;    
      end if;           
    end loop;
    dbms_output.put_line(rpad('-',15,'-')||' '||rpad('-',35,'-'));    
  else
    :Fusion_PDB := :con_name;
  end if;
end;
/
 
pro
set term off
column Fusion_PDB new_value Fusion_PDB noprint;
select :Fusion_PDB Fusion_PDB from dual;

spool ask_container.sql
begin
  if :is_multitenant = 'YES' and :con_id = 1 then
    dbms_output.put_line('pro Please input the container in which you wish to run SQLHC');
    dbms_output.put_line('pro Press enter if you want container to be "^^Fusion_PDB."');
    dbms_output.put_line('Accept pdb_name char default ''^^Fusion_PDB.'' prompt ''Enter Container Name: ''');
    dbms_output.put_line('pro');
  else
    dbms_output.put_line('def pdb_name=''^^Fusion_PDB.''');
  end if;
end;
/
SPO sqlhc.log APP;
set term on
@ask_container.sql

set term off  
spool ask_container1.sql
begin
  if :is_multitenant = 'YES' and :con_id = 1 then
    dbms_output.put_line('exec :pdb_name:=''^^pdb_name.''');
  end if;
end;
/
SPO sqlhc.log APP;
@ask_container1.sql

set term on
begin
  if upper(:pdb_name)='CDB$ROOT' then
    dbms_output.put_line('>>>>>>>>>>>>>> IMPORTANT <<<<<<<<<<<<<<<');
    dbms_output.put_line('YOU ARE CREATING SQL PATCH IN A CDB$ROOT');
    dbms_output.put_line('>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<');
    --RAISE PROGRAM_ERROR;
  end if;
  
  if :is_multitenant = 'YES' and :con_id = 1 then
    execute immediate 'alter session set container='||:pdb_name;
    dbms_output.put_line('>>>>>>>>>> YOU ARE CONNECTED TO A CDB: Setting container to an entered value => '||:pdb_name||' <<<<<<<<<<');
    -- this dbms output will NOT be shown if the switching to PDB (bug 30484412 logged against RDBMS)
  else
    --dbms_output.put_line('>>>>>>>>>> Setting container to an entered value => '||:Fusion_PDB.||' <<<<<<<<<<');
    NULL;
  end if;
exception
  when program_error then
    --dbms_output.put_line('You can''t run SQLHC in '||:pdb_name);
    RAISE_APPLICATION_ERROR(-20100, 'You can''t create SQLHC from '||:pdb_name);
  when others then
    --dbms_output.put_line(SQLERRM||chr(10)||'>>>>>>>>>> Can''t continue with the container=>'||:pdb_name||' <<<<<<<<<<');
    RAISE_APPLICATION_ERROR(-20101, SQLERRM||chr(10)||'>>>>>>>>>> Can''t continue with the container=>'||:pdb_name||' <<<<<<<<<<');
end;
/

select sys_context('USERENV', 'CON_NAME') Fusion_PDB from dual;
pro Proceeding with "^^Fusion_PDB."

SET SERVEROUT ON SIZE 1000000
WHENEVER SQLERROR EXIT SQL.SQLCODE;

BEGIN
  IF '^^license.' IS NULL OR '^^license.' NOT IN ('T', 'D', 'N') THEN
    RAISE_APPLICATION_ERROR(-20100, 'Oracle Pack License (Tuning, Diagnostics or None) must be specified as "T" or "D" or "N".');
  END IF;

  --IF regexp_count(USER,'FUSION_READ_ONLY',1,'i')>0 then
  --  return;
  --END IF;
  
  IF regexp_count(USER,'SYS',1,'i')=0 AND regexp_count(USER,'ADMIN',1,'i')=0 then 
    RAISE_APPLICATION_ERROR(-20100, 'Connected as '||USER||CHR(10)||'********** Connect as SYS or ADMIN to retry, preferrably from a DB host, as recommended!');
  END IF;
END;
/

/* Disable parallel query for ADBS */

ALTER SESSION DISABLE PARALLEL QUERY;

set term off FEED on;
VAR request_retval NUMBER;
VAR lockhandle     VARCHAR2(128)
DECLARE 
  l_str varchar2(200);
BEGIN
  begin
    /* Pushkar - Request a lock so that other SQLHCs cannot run */  
    l_str := q'[begin dbms_lock.allocate_unique(lockname => 'IS_SQLHC_RUNNING', lockhandle => :1, expiration_secs => 100); end;]';
    execute immediate l_str using OUT :lockhandle;
    
    l_str := q'[begin :1 := dbms_lock.request (lockhandle => :2, timeout => 0); end;]';
    execute immediate l_str using OUT :request_retval, IN :lockhandle;
  exception 
    when others then dbms_output.put_line(SQLERRM); 
     -- dbms lock privs?    
    :request_retval := -9;
  end;
END;
/

set term on
BEGIN
  IF :request_retval in (0,4,-9) THEN
     -- got lock. Move forward.
     NULL;
  ELSE
     --NULL;
     RAISE_APPLICATION_ERROR(-20100, 'Another SQLHC is being run!'||CHR(10)|| '********** Try running after some time [lockhandle=>'||:lockhandle||')]!!');
  END IF;	 
END;
/

set term off
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

var diff varchar2(10);
col diff new_value diff for A5 noprint
var start_time varchar2(50);

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

prompt Press ENTER for no Test Case or "TCB" or "tcb" to collect one
define sqlhc_tcb = '^^3';
column sqlhc_tcb new_value sqlhc_tcb format a1;
variable sqlhc_tcb char(3);
exec :sqlhc_tcb := '^sqlhc_tcb.';

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
ALTER SESSION SET MAX_DUMP_FILE_SIZE = '1G';
ALTER SESSION SET TRACEFILE_IDENTIFIER = "^^script._^^unique_id.";
--ALTER SESSION SET STATISTICS_LEVEL = 'ALL';
-- ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT FOREVER, LEVEL 12';

-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';

Prompt ---;
Prompt ignore below error if DB version is 11g
Prompt ---;
alter session set "_optimizer_adaptive_plans"=false;

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
--PSRv10 start

COL release_name NEW_V fa_release FOR A20;
var fa_release varchar2(50)
exec :fa_release := 'n/a';
declare
 l_fa varchar2(1);
begin
  SELECT 'Y' 
    INTO l_fa
    FROM dba_tab_columns
   WHERE table_name = 'AD_PRODUCT_GROUPS'
     AND column_name = 'RELEASE_NAME'
     AND data_type = 'VARCHAR2'
     AND owner = 'FUSION'
  ;

  IF l_fa = 'Y' THEN
    execute immediate 'select release_name from fusion.AD_PRODUCT_GROUPS' into :fa_release;
  END IF;
exception when others then
  :fa_release := 'n/a';
end;
/
select :fa_release fa_release from dual;

col service new_value service_name
col source new_value sql_source

  select service, 
         case when program_id <> 0 then 
                 (select owner||'.'||object_name||'  Line#: '|| program_line# from dba_objects o where o.object_id = s.program_id)
              else ''
         end source
    from gv$sql s
   where sql_id = :sql_id
     and rownum = 1
;

col service new_value service_name
col ash_plsql_entry new_value ash_plsql_entry
col ash_plsql_object new_value ash_plsql_object
col source_batch_ui new_value source_batch_ui

select case when '^^service_name' is null then 
                (select name from v$services s where s.name_hash = ash.service_hash) 
            else '^^service_name'
       end service,
       case when plsql_entry_object_id is not null then
           (select object_name||'.'||procedure_name from dba_procedures where object_id = plsql_entry_object_id 
               and SUBPROGRAM_ID = plsql_entry_subprogram_id and rownum=1) 
            else ''
       end ash_plsql_entry,
       case when plsql_entry_object_id is not null then 
             (select object_name||'.'||procedure_name from dba_procedures where object_id = plsql_object_id 
                 and SUBPROGRAM_ID = plsql_subprogram_id and rownum=1) 
            else ''
       end ash_plsql_object,
       (select distinct case when consumer_group = 'FUSIONAPPS_ONLINE_GROUP' then 'UI'
                    when consumer_group = 'FUSIONAPPS_BATCH_GROUP'  then 'Batch'
                    when consumer_group = 'FUSIONAPPS_DIAG_GROUP'   then 'Diag (RO/ERO)'
                    else consumer_group 
               end
          from DBA_RSRC_CONSUMER_GROUPS cg
         where cg.consumer_group_id = ash.consumer_group_id) source_batch_ui
  from gv$ACTIVE_SESSION_HISTORY ash
 where sql_id = :sql_id
   and rownum = 1
;

col service new_value service_name
col ash_plsql_entry new_value ash_plsql_entry
col ash_plsql_object new_value ash_plsql_object
col source_batch_ui new_value source_batch_ui

select case when '^^service_name' is null then 
                (select name from v$services s where s.name_hash = ash.service_hash) 
            else '^^service_name'
       end service,
       case when '^^ash_plsql_entry' is not null then
               '^^ash_plsql_entry'
            when '^^ash_plsql_entry' is null and plsql_entry_object_id is not null then 
               (select owner||'.'||object_name||'.'||procedure_name from dba_procedures where object_id = plsql_entry_object_id 
                   and SUBPROGRAM_ID = plsql_entry_subprogram_id and rownum=1) 
            else ''
       end ash_plsql_entry,
       case when '^^ash_plsql_object' is not null then
               '^^ash_plsql_object'
            when '^^ash_plsql_object' is null and plsql_entry_object_id is not null then 
               (select owner||'.'||object_name||'.'||procedure_name from dba_procedures where object_id = plsql_object_id 
                   and SUBPROGRAM_ID = plsql_subprogram_id and rownum=1) 
            else ''
       end ash_plsql_object,
       (select distinct case when consumer_group = 'FUSIONAPPS_ONLINE_GROUP' then 'UI'
                    when consumer_group = 'FUSIONAPPS_BATCH_GROUP'  then 'Batch'
                    when consumer_group = 'FUSIONAPPS_DIAG_GROUP'   then 'Diag (RO/ERO)'
                    else consumer_group 
               end
          from DBA_RSRC_CONSUMER_GROUPS cg
         where cg.consumer_group_id = ash.consumer_group_id) source_batch_ui
from dba_hist_active_sess_history ash, dba_hist_snapshot ss
 where 1 = 1
   and ss.dbid = (select dbid from v$database)
   and ss.BEGIN_INTERVAL_TIME > systimestamp - interval '15' day
   and ash.dbid = ss.dbid
   and ash.snap_id = ss.snap_id
   and ash.instance_number = ss.instance_number
   and sql_id = :sql_id
   and '^^service_name' is null
   and rownum = 1
;

--col pod_size new_value pod_size

--select regexp_substr(l.dimension_parameter, '[^:]+', 1, 3) pod_size
--  from sys.v$lcm_audit l
-- where action in ('AUDIT', 'UPDATE') 
--   and status not like '%ERRORS%' 
-- order by audit_date desc fetch first 1 row only
--;

col pod_size  NEW_V pod_size  FOR A32;
var pod_size varchar2(32)
exec :pod_size := 'n/a';
begin
    execute immediate 'select regexp_substr(l.dimension_parameter, ''[^:]+'', 1, 3) pod_size
                       from sys.v$lcm_audit l
                       where action in (''AUDIT'', ''UPDATE'')
                       and status not like ''%ERRORS%''
                       order by audit_date desc fetch first 1 row only' into :pod_size;
exception when others then
  :pod_size := 'n/a';
end;
/
select :pod_size pod_size from dual;

exec dbms_output.put_line('POD size : ' || :pod_size)

col instances new_value instances
select count(*) instances from gv$instance;

-- get job_queue_processes
COL jobqp NEW_V jobqp FOR A17;
SELECT value jobqp FROM v$system_parameter2 WHERE LOWER(name) = 'job_queue_processes';


--PSRv10 Stop

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

-- Pushkar when did the EBR upgrade happen
COL ebr_date      NEW_V ebr_date             ;
SELECT TO_CHAR(created,'YYYY-MM-DD/HH24:MI:SS') ebr_date 
FROM dba_objects 
WHERE object_name='fre_ebr_programs' and object_type='TABLE';

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

-- this script uses the gtt plan_table as a temporary staging place to store results of health-checks
/* Pushkar */
DELETE plan_table where STATEMENT_ID = :sql_id;
commit;

-- transaction begins here. it will be rolled back after generating spool file
SAVEPOINT save_point_1;

-- record tables
INSERT INTO plan_table (STATEMENT_ID, object_type, object_owner, object_name)
WITH object AS (
SELECT /*+ MATERIALIZE */
       object_owner owner, object_name name
  FROM gv$sql_plan
 WHERE :health_checks = 'Y'
   AND inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
 UNION
SELECT object_owner owner, object_name name
  FROM dba_hist_sql_plan
 WHERE :health_checks = 'Y'
   AND :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
)
SELECT :sql_id, 'TABLE', t.owner, t.table_name
  FROM dba_tab_statistics t, -- include fixed objects
       object o
 WHERE :health_checks = 'Y'
   AND t.owner = o.owner
   AND t.table_name = o.name
 UNION
SELECT :sql_id, 'TABLE', i.table_owner, i.table_name
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
   AND STATEMENT_ID = :sql_id
 ORDER BY 1, 2;

-- record indexes from known plans
INSERT INTO plan_table (STATEMENT_ID, object_type, object_owner, object_name, other_tag)
SELECT :sql_id, 'INDEX', object_owner owner, object_name index_name, 'YES'
  FROM gv$sql_plan
 WHERE :health_checks = 'Y'
   AND inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND (object_type LIKE '%INDEX%' OR operation LIKE '%INDEX%')
 UNION
SELECT :sql_id, 'INDEX', object_owner owner, object_name index_name, 'YES'
  FROM dba_hist_sql_plan
 WHERE :health_checks = 'Y'
   AND :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND (object_type LIKE '%INDEX%' OR operation LIKE '%INDEX%');

-- record indexes from tables in plan
INSERT INTO plan_table (STATEMENT_ID, object_type, object_owner, object_name, other_tag)
SELECT :sql_id, 'INDEX', owner, index_name, 'NO'
  FROM plan_table t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND t.object_type = 'TABLE'
   AND t.object_owner = i.table_owner
   AND t.object_name = i.table_name
 MINUS
SELECT :sql_id, 'INDEX', object_owner, object_name, 'NO'
  FROM plan_table t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND object_type = 'INDEX';

COL in_plan FOR A7;
-- list indexes
SELECT object_owner owner, object_name index_name, other_tag in_plan
  FROM plan_table
 WHERE :health_checks = 'Y'
   AND object_type = 'INDEX'
   AND STATEMENT_ID = :sql_id
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
 * global hc
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Global Health Check - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));

-- 5969780 STATISTICS_LEVEL = ALL on LINUX
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'STATISTICS_LEVEL',
       'Parameter STATISTICS_LEVEL is set to ALL on ^^platform. platform.',
       'STATISTICS_LEVEL = ALL provides valuable metrics like A-Rows. Be aware of Bug <a target="MOS" href="^^bug_link.5969780">5969780</a> CPU overhead.<br>'||CHR(10)||
       'Use a value of ALL only at the session level. You could use CBO hint /*+ gather_plan_statistics */ to accomplish the same.'
  FROM v$system_parameter2
 WHERE :health_checks = 'Y'
   AND UPPER(name) = 'STATISTICS_LEVEL'
   AND UPPER(value) = 'ALL'
   AND '^^rdbms_version.' LIKE '10%'
   AND '^^platform.' LIKE '%LINUX%';

-- cbo parameters with non-default values at sql level
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, UPPER(name),
       'CBO initialization parameter "'||name||'" with a non-default value of "'||value||'" as per V$SQL_OPTIMIZER_ENV.',
       'Review the correctness of this non-default value "'||value||'" for SQL_ID '||:sql_id||'.'
  FROM (
SELECT DISTINCT name, value
  FROM v$sql_optimizer_env
 WHERE :health_checks = 'Y'
   AND sql_id = :sql_id
   AND isdefault = 'NO' );

-- cbo parameters with non-default values at system level
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
-- 
-- in 12c, performance issue in CRMAP when accessing v$sql_optimizer_env
--
-- UdayRemoved.v6 SELECT :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, UPPER(g.name),
-- UdayRemoved.v6        'CBO initialization parameter "'||g.name||'" with a non-default value of "'||g.value||'" as per V$SYS_OPTIMIZER_ENV.',
-- UdayRemoved.v6        'Review the correctness of this non-default value "'||g.value||'".<br>'||CHR(10)||
-- UdayRemoved.v6        'Unset this parameter unless there is a strong reason for keeping its current value.<br>'||CHR(10)||
-- UdayRemoved.v6        'Default value is "'||g.default_value||'" as per V$SYS_OPTIMIZER_ENV.'
-- UdayRemoved.v6  FROM v$sys_optimizer_env g
-- UdayRemoved.v6 WHERE :health_checks = 'Y'
-- UdayRemoved.v6   AND g.isdefault = 'NO'
-- UdayRemoved.v6   AND NOT EXISTS (
-- UdayRemoved.v6SELECT NULL
-- UdayRemoved.v6  FROM v$sql_optimizer_env s
-- UdayRemoved.v6 WHERE :health_checks = 'Y'
-- UdayRemoved.v6   AND s.sql_id = :sql_id
-- UdayRemoved.v6   AND s.isdefault = 'NO'
-- UdayRemoved.v6   AND s.name = g.name
-- UdayRemoved.v6   AND s.value = g.value )
with sysp as
(
SELECT /*+ MATERIALIZE */ name, value, default_value
  FROM v$sys_optimizer_env g
 WHERE :health_checks = 'Y'
   AND g.isdefault = 'NO'
)
,
sqlp as
(
SELECT /*+ MATERIALIZE */ distinct name, value
  FROM v$sql_optimizer_env s
 WHERE :health_checks = 'Y'
   AND s.sql_id = :sql_id
   AND s.isdefault = 'NO'
)
SELECT :sql_id, :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, UPPER(g.name),
       'CBO initialization parameter "'||g.name||'" with a non-default value of "'||g.value||'" as per V$SYS_OPTIMIZER_ENV.',
       'Review the correctness of this non-default value "'||g.value||'".<br>'||CHR(10)||
       'Unset this parameter unless there is a strong reason for keeping its current value.<br>'||CHR(10)||
       'Default value is "'||g.default_value||'" as per V$SYS_OPTIMIZER_ENV.'
  from sysp g
 where not exists (select null from sqlp s where s.name = g.name and s.value = g.value)
;


-- optimizer_features_enable <> rdbms_version at system level
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'OPTIMIZER_FEATURES_ENABLE',
       'DB version ^^rdbms_version. and OPTIMIZER_FEATURES_ENABLE ^^sys_ofe. do not match as per V$SYSTEM_PARAMETER2.',
       'Be aware that you are using a prior version of the optimizer. New CBO features in your DB version may not be used.'
  FROM DUAL
 WHERE :health_checks = 'Y'
   AND SUBSTR('^^rdbms_version.', 1, LEAST(LENGTH('^^rdbms_version.'), LENGTH('^^sys_ofe.'))) <> SUBSTR('^^sys_ofe.', 1, LEAST(LENGTH('^^rdbms_version.'), LENGTH('^^sys_ofe.')));

-- optimizer_features_enable <> rdbms_version at sql level
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'OPTIMIZER_FEATURES_ENABLE',
       'DB version ^^rdbms_version. and OPTIMIZER_FEATURES_ENABLE '||v.value||' do not match for SQL_ID '||:sql_id||' as per V$SQL_OPTIMIZER_ENV.',
       'Be aware that you are using a prior version of the optimizer. New CBO features in your DB version may not be used.'
  FROM (
SELECT DISTINCT value
  FROM v$sql_optimizer_env
 WHERE :health_checks = 'Y'
   AND sql_id = :sql_id
   AND LOWER(name) = 'optimizer_features_enable'
   AND SUBSTR('^^rdbms_version.', 1, LEAST(LENGTH('^^rdbms_version.'), LENGTH(value))) <> SUBSTR(value, 1, LEAST(LENGTH('^^rdbms_version.'), LENGTH(value))) ) v;

-- optimizer_dynamic_sampling between 1 and 3 at system level
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'OPTIMIZER_DYNAMIC_SAMPLING',
       'Dynamic Sampling is set to small value of ^^sys_ds. as per V$SYSTEM_PARAMETER2.',
       'Be aware that using such a small value may produce statistics of poor quality.<br>'||CHR(10)||
       'If you rely on this functionality consider using a value no smaller than 4.'
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND TO_NUMBER('^^sys_ds.') BETWEEN 1 AND 3
   AND pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.temporary = 'N'
   AND (t.last_analyzed IS NULL OR t.num_rows IS NULL)
   AND ROWNUM = 1;

-- db_file_multiblock_read_count should not be set
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'CBO PARAMETER', SYSTIMESTAMP, 'DB_FILE_MULTIBLOCK_READ_COUNT',
       'MBRC Parameter is set to "'||value||'" overriding its default value.',
       'The default value of this parameter is a value that corresponds to the maximum I/O size that can be performed efficiently.<br>'||CHR(10)||
       'This value is platform-dependent and is 1MB for most platforms.<br>'||CHR(10)||
       'Because the parameter is expressed in blocks, it will be set to a value that is equal to the maximum I/O size that can be performed efficiently divided by the standard block size.'
  FROM v$system_parameter2
 WHERE :health_checks = 'Y'
   AND UPPER(name) = 'DB_FILE_MULTIBLOCK_READ_COUNT'
   AND (isdefault = 'FALSE' OR ismodified <> 'FALSE');

-- nls_sort is not binary (session)
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'NLS PARAMETER', SYSTIMESTAMP, 'NLS_SORT',
       'NLS_SORT Session Parameter is set to "'||value||'" in V$NLS_PARAMETERS.',
       'Setting NLS_SORT to anything other than BINARY causes a sort to use a full table scan, regardless of the path chosen by the optimizer.'
  FROM v$nls_parameters
 WHERE :health_checks = 'Y'
   AND UPPER(parameter) = 'NLS_SORT'
   AND UPPER(value) <> 'BINARY';

-- nls_sort is not binary (instance)
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'NLS PARAMETER', SYSTIMESTAMP, 'NLS_SORT',
       'NLS_SORT Instance Parameter is set to "'||value||'" in V$SYSTEM_PARAMETER.',
       'Setting NLS_SORT to anything other than BINARY causes a sort to use a full table scan, regardless of the path chosen by the optimizer.'
  FROM v$system_parameter
 WHERE :health_checks = 'Y'
   AND UPPER(name) = 'NLS_SORT'
   AND UPPER(value) <> 'BINARY';

-- nls_sort is not binary (global)
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'NLS PARAMETER', SYSTIMESTAMP, 'NLS_SORT',
       'NLS_SORT Global Parameter is set to "'||value||'" in NLS_DATABASE_PARAMETERS.',
       'Setting NLS_SORT to anything other than BINARY causes a sort to use a full table scan, regardless of the path chosen by the optimizer.'
  FROM nls_database_parameters
 WHERE :health_checks = 'Y'
   AND UPPER(parameter) = 'NLS_SORT'
   AND UPPER(value) <> 'BINARY';

-- DBMS_STATS automatic gathering on 10g
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'DBA_SCHEDULER_JOBS',
       'Automatic gathering of CBO statistics is enabled.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using FND_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Disable this job immediately and re-gather statistics for all affected schemas using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Be aware that small sample sizes could produce poor quality histograms,<br>'||CHR(10)||
           'which combined with bind sensitive predicates could render suboptimal plans.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM dba_scheduler_jobs
 WHERE :health_checks = 'Y'
   AND job_name = 'GATHER_STATS_JOB'
   AND enabled = 'TRUE';

--PSRv10 getting hung or taking long -- DBMS_STATS automatic gathering on 11g
--PSRv10 getting hung or taking long INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
--PSRv10 getting hung or taking long SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'DBA_AUTOTASK_CLIENT',
--PSRv10 getting hung or taking long        'Automatic gathering of CBO statistics is enabled.',
--PSRv10 getting hung or taking long        CASE
--PSRv10 getting hung or taking long          WHEN '^^is_ebs.' = 'Y' THEN
--PSRv10 getting hung or taking long            'Disable this job immediately and re-gather statistics for all affected schemas using FND_STATS or coe_stats.sql.<br>'||CHR(10)||
--PSRv10 getting hung or taking long            'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
--PSRv10 getting hung or taking long          WHEN '^^is_siebel.' = 'Y' THEN
--PSRv10 getting hung or taking long            'Disable this job immediately and re-gather statistics for all affected schemas using coe_siebel_stats.sql.<br>'||CHR(10)||
--PSRv10 getting hung or taking long            'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
--PSRv10 getting hung or taking long          WHEN '^^is_psft.' = 'Y' THEN
--PSRv10 getting hung or taking long            'Disable this job immediately and re-gather statistics for all affected schemas using pscbo_stats.sql.<br>'||CHR(10)||
--PSRv10 getting hung or taking long            'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
--PSRv10 getting hung or taking long          ELSE
--PSRv10 getting hung or taking long            'Be aware that small sample sizes could produce poor quality histograms,<br>'||CHR(10)||
--PSRv10 getting hung or taking long            'which combined with bind sensitive predicates could render suboptimal plans.<br>'||CHR(10)||
--PSRv10 getting hung or taking long            'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
--PSRv10 getting hung or taking long          END
--PSRv10 getting hung or taking long   FROM dba_autotask_client
--PSRv10 getting hung or taking long  WHERE :health_checks = 'Y'
--PSRv10 getting hung or taking long    AND client_name = 'auto optimizer stats collection'
--PSRv10 getting hung or taking long    AND status = 'ENABLED';
--PSRv10 getting hung or taking long    
--PSRv10 getting hung or taking long -- DBMS_STATS automatic gathering on 11g but not running for a week   
--PSRv10 getting hung or taking long INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
--PSRv10 getting hung or taking long SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'DBA_AUTOTASK_CLIENT',
--PSRv10 getting hung or taking long        'Automatic gathering of CBO statistics is enabled but no job was<br>executed in the last 8 days',
--PSRv10 getting hung or taking long        'The job is enabled in the system but there is no evidence it was ever<br>executed in the last 8 days.'
--PSRv10 getting hung or taking long   FROM dba_autotask_client
--PSRv10 getting hung or taking long  WHERE :health_checks = 'Y'
--PSRv10 getting hung or taking long    AND client_name = 'auto optimizer stats collection'
--PSRv10 getting hung or taking long    AND status = 'ENABLED'
--PSRv10 getting hung or taking long    AND 0 = (SELECT count(*)
--PSRv10 getting hung or taking long 		     FROM dba_autotask_client_history
--PSRv10 getting hung or taking long             WHERE client_name = 'auto optimizer stats collection'
--PSRv10 getting hung or taking long               AND window_start_time > (SYSDATE-8)); 
--PSRv10 getting hung or taking long 
--PSRv10 getting hung or taking long -- DBMS_STATS automatic gathering on 11g but some jobs not running for a week   
--PSRv10 getting hung or taking long INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
--PSRv10 getting hung or taking long SELECT :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'DBA_AUTOTASK_CLIENT',
--PSRv10 getting hung or taking long        'Automatic gathering of CBO statistics is enabled but some job did<br>not complete in the last 8 days.',
--PSRv10 getting hung or taking long        'The job is enabled in the system but there are some jobs in the<br>last 8 days that did not complete.'
--PSRv10 getting hung or taking long   FROM dba_autotask_client
--PSRv10 getting hung or taking long  WHERE :health_checks = 'Y'
--PSRv10 getting hung or taking long    AND client_name = 'auto optimizer stats collection'
--PSRv10 getting hung or taking long    AND status = 'ENABLED'
--PSRv10 getting hung or taking long    AND 0 <> (SELECT count(*)
--PSRv10 getting hung or taking long 		       FROM dba_autotask_client_history
--PSRv10 getting hung or taking long               WHERE client_name = 'auto optimizer stats collection'
--PSRv10 getting hung or taking long                 AND window_start_time > (SYSDATE-8)
--PSRv10 getting hung or taking long 			    AND (jobs_created-jobs_started > 0 OR jobs_started-jobs_completed > 0));		  
--PSRv10 getting hung or taking long 
-- multiple CBO environments in SQL Area
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'PLAN', SYSTIMESTAMP, 'OPTIMIZER_ENV',
       'SQL Area references '||COUNT(DISTINCT optimizer_env_hash_value)||' distinct CBO Environments for this one SQL.',
       'Distinct CBO Environments may produce different Plans.'
  FROM gv$sqlarea_plan_hash
 WHERE :health_checks = 'Y'
   AND sql_id = :sql_id
HAVING COUNT(*) > 1;

-- multiple CBO environments in GV$SQL
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'PLAN', SYSTIMESTAMP, 'OPTIMIZER_ENV',
       'GV$SQL references '||COUNT(DISTINCT optimizer_env_hash_value)||' distinct CBO Environments for this one SQL.',
       'Distinct CBO Environments may produce different Plans.'
  FROM gv$sql
 WHERE :health_checks = 'Y'
   AND sql_id = :sql_id
HAVING COUNT(*) > 1;

-- multiple CBO environments in AWR
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'PLAN', SYSTIMESTAMP, 'OPTIMIZER_ENV',
       'AWR references '||COUNT(DISTINCT optimizer_env_hash_value)||' distinct CBO Enviornments for this one SQL.',
       'Distinct CBO Environments may produce different Plans.'
  FROM dba_hist_sqlstat
 WHERE :health_checks = 'Y'
   AND :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
HAVING COUNT(*) > 1;

-- multiple plans with same PHV but different predicate ordering
-- Uday.PSR.v6: not displaying predicates now
--
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'PLAN', SYSTIMESTAMP, 'PREDICATES ORDERING',
       'There are plans with same PHV '||v.plan_hash_value||' but different predicate ordering.',
       'Different ordering in the predicates for '||v.plan_hash_value||' can affect the performance of this SQL,<br>'||CHR(10)||
       'focus on ' || v.type || ' predicates of Step ID '||v.id||'.'
       -- 'focus on Step ID '||v.id||' predicates '||v.predicates||' .'
  FROM ( 
WITH d AS (
SELECT sql_id,
       plan_hash_value,
       id,
       COUNT(DISTINCT access_predicates) distinct_access_predicates,
       COUNT(DISTINCT filter_predicates) distinct_filter_predicates
  FROM gv$sql_plan_statistics_all
 WHERE sql_id = :sql_id
 GROUP BY
       sql_id,
       plan_hash_value,
       id
HAVING MIN(NVL(access_predicates, 'X')) != MAX(NVL(access_predicates, 'X'))
    OR MIN(NVL(filter_predicates, 'X')) != MAX(NVL(filter_predicates, 'X'))
)
SELECT d.plan_hash_value,
       d.id,
       'Access' type
  FROM d
 WHERE d.distinct_access_predicates > 1
 UNION ALL
SELECT d.plan_hash_value,
       d.id,
       'Filter' type
  FROM d
 WHERE d.distinct_filter_predicates > 1
 ORDER BY
       1, 2, 3) v
  WHERE :health_checks = 'Y' ;

--
-- below joins causing performance issue so replaced with above
-- NOW, we are not printing the predicates instead telling 'which' predicates differ
--
--UdayRemoved.v6 SELECT v.plan_hash_value,
--UdayRemoved.v6        v.id,
--UdayRemoved.v6        'access' type,
--UdayRemoved.v6        v.inst_id,
--UdayRemoved.v6        v.child_number,
--UdayRemoved.v6        v.access_predicates predicates
--UdayRemoved.v6   FROM d,
--UdayRemoved.v6        gv$sql_plan_statistics_all v
--UdayRemoved.v6  WHERE v.sql_id = d.sql_id
--UdayRemoved.v6    AND v.plan_hash_value = d.plan_hash_value
--UdayRemoved.v6    AND v.id = d.id
--UdayRemoved.v6    AND d.distinct_access_predicates > 1
--UdayRemoved.v6  UNION ALL
--UdayRemoved.v6 SELECT v.plan_hash_value,
--UdayRemoved.v6        v.id,
--UdayRemoved.v6        'filter' type,
--UdayRemoved.v6        v.inst_id,
--UdayRemoved.v6        v.child_number,
--UdayRemoved.v6        v.filter_predicates predicates
--UdayRemoved.v6   FROM d,
--UdayRemoved.v6        gv$sql_plan_statistics_all v
--UdayRemoved.v6  WHERE v.sql_id = d.sql_id
--UdayRemoved.v6    AND v.plan_hash_value = d.plan_hash_value
--UdayRemoved.v6    AND v.id = d.id
--UdayRemoved.v6    AND d.distinct_filter_predicates > 1
--UdayRemoved.v6  ORDER BY
--UdayRemoved.v6        1, 2, 3, 6, 4, 5) v
--UdayRemoved.v6   WHERE :health_checks = 'Y' 

-- plans with implicit data_type conversion
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'PLAN', SYSTIMESTAMP, 'PLAN_HASH_VALUE',
       'Plan '||v.plan_hash_value||' may have implicit data_type conversion functions in Filter Predicates.',
       'Review Execution Plans.<br>'||CHR(10)||
       'If Filter Predicates for '||v.plan_hash_value||' include unexpected INTERNAL_FUNCTION to perform an implicit data_type conversion,<br>'||CHR(10)||
       'be sure it is not preventing a column from being used as an Access Predicate.'
  FROM (
SELECT DISTINCT plan_hash_value
  FROM gv$sql_plan
 WHERE :health_checks = 'Y'
   AND inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND filter_predicates LIKE '%INTERNAL_FUNCTION%'
 ORDER BY 1) v;

-- plan operations with cost 0 and card 1
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'PLAN', SYSTIMESTAMP, 'PLAN_HASH_VALUE',
       'Plan '||v.plan_hash_value||' has operations with Cost 0 and Card 1. Possible incorrect Selectivity.',
       'Review Execution Plans.<br>'||CHR(10)||
       'Look for Plan operations in '||v.plan_hash_value||' where Cost is 0 and Estimated Cardinality is 1.<br>'||CHR(10)||
       'Suspect predicates out of range or incorrect statistics.'
  FROM (
SELECT plan_hash_value
  FROM gv$sql_plan
 WHERE :health_checks = 'Y'
   AND inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND cost = 0
   AND cardinality = 1
 UNION
SELECT plan_hash_value
  FROM dba_hist_sql_plan
 WHERE :health_checks = 'Y'
   AND :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND cost = 0
   AND cardinality = 1) v;

-- high version count
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'VERSION COUNT', SYSTIMESTAMP, 'VERSION COUNT',
       'This SQL shows evidence of high version count of '||MAX(v.version_count)||'.',
       'Review Execution Plans for details.'
  FROM (
SELECT MAX(version_count) version_count
  FROM gv$sqlarea_plan_hash
 WHERE :health_checks = 'Y'
   AND sql_id = :sql_id
 UNION
SELECT MAX(version_count) version_count
  FROM dba_hist_sqlstat
 WHERE :health_checks = 'Y'
   AND :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id ) v
HAVING MAX(v.version_count) > 20;

-- first rows
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'OPTIMZER MODE', SYSTIMESTAMP, 'FIRST_ROWS',
       'OPTIMIZER_MODE was set to FIRST_ROWS in '||v.pln_count||' Plan(s).',
       'The optimizer uses a mix of cost and heuristics to find a best plan for fast delivery of the first few rows.<br>'||CHR(10)||
       'Using heuristics sometimes leads the query optimizer to generate a plan with a cost that is significantly larger than the cost of a plan without applying the heuristic.<br>'||CHR(10)||
       'FIRST_ROWS is available for backward compatibility and plan stability; use FIRST_ROWS_n instead.'
FROM (
SELECT COUNT(*) pln_count
  FROM (
SELECT plan_hash_value
  FROM gv$sql
 WHERE :health_checks = 'Y'
   AND sql_id = :sql_id
   AND optimizer_mode = 'FIRST_ROWS'
 UNION
SELECT plan_hash_value
  FROM dba_hist_sqlstat
 WHERE :health_checks = 'Y'
   AND :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND optimizer_mode = 'FIRST_ROWS') v) v
 WHERE :health_checks = 'Y'
   AND v.pln_count > 0;

-- fixed objects missing stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'FIXED OBJECTS', SYSTIMESTAMP, 'DBA_TAB_COL_STATISTICS',
       'There exist(s) '||v.tbl_count||' Fixed Object(s) accessed by this SQL without CBO statistics.',
       'Consider gathering statistics for fixed objects using DBMS_STATS.GATHER_FIXED_OBJECTS_STATS.<br>'||CHR(10)||
       'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
FROM (
SELECT COUNT(*) tbl_count
  FROM plan_table pt,
       dba_tab_statistics t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.object_type = 'FIXED TABLE'
   AND NOT EXISTS (
SELECT NULL
  FROM dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND t.owner = c.owner
   AND t.table_name = c.table_name )) v
 WHERE :health_checks = 'Y'
   AND v.tbl_count > 0;

-- system statistics not gathered
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Workload CBO System Statistics are not gathered. CBO is using default values.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$
 WHERE :health_checks = 'Y'
   AND sname = 'SYSSTATS_MAIN'
   AND pname = 'CPUSPEED'
   AND pval1 IS NULL;

-- mreadtim < sreadtim
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Multi-block read time of '||a1.pval1||'ms seems too small compared to single-block read time of '||a2.pval1||'ms.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting SREADTIM and MREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$ a1, sys.aux_stats$ a2
 WHERE :health_checks = 'Y'
   AND a1.sname = 'SYSSTATS_MAIN'
   AND a1.pname = 'MREADTIM'
   AND a2.sname = 'SYSSTATS_MAIN'
   AND a2.pname = 'SREADTIM'
   AND a1.pval1 < a2.pval1;

-- (1.2 * sreadtim) > mreadtim > sreadtim
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Multi-block read time of '||a1.pval1||'ms seems too small compared to single-block read time of '||a2.pval1||'ms.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting SREADTIM and MREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$ a1, sys.aux_stats$ a2
 WHERE :health_checks = 'Y'
   AND a1.sname = 'SYSSTATS_MAIN'
   AND a1.pname = 'MREADTIM'
   AND a2.sname = 'SYSSTATS_MAIN'
   AND a2.pname = 'SREADTIM'
   AND (1.2 * a2.pval1) > a1.pval1
   AND a1.pval1 > a2.pval1;

-- sreadtim < 2
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Single-block read time of '||pval1||' milliseconds seems too small.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting SREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$
 WHERE :health_checks = 'Y'
   AND sname = 'SYSSTATS_MAIN'
   AND pname = 'SREADTIM'
   AND pval1 < 2
   AND NVL('^^exadata.','N') = 'N'; 

-- mreadtim < 3
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Multi-block read time of '||pval1||' milliseconds seems too small.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting MREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
  FROM sys.aux_stats$
 WHERE :health_checks = 'Y'
   AND sname = 'SYSSTATS_MAIN'
   AND pname = 'MREADTIM'
   AND pval1 < 3
   AND NVL('^^exadata.','N') = 'N'; 

-- sreadtim > 18
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Single-block read time of '||pval1||' milliseconds seems too large.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting SREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a> and Bug <a target="MOS" href="^^bug_link.9842771">9842771</a>.'
  FROM sys.aux_stats$
 WHERE :health_checks = 'Y'
   AND sname = 'SYSSTATS_MAIN'
   AND pname = 'SREADTIM'
   AND pval1 > 18
   AND NVL('^^exadata.','N') = 'N'; 

-- mreadtim > 522
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Multi-block read time of '||pval1||' milliseconds seems too large.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting MREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a> and Bug <a target="MOS" href="^^bug_link.9842771">9842771</a>.'
  FROM sys.aux_stats$
 WHERE :health_checks = 'Y'
   AND sname = 'SYSSTATS_MAIN'
   AND pname = 'MREADTIM'
   AND pval1 > 522
   AND NVL('^^exadata.','N') = 'N'; 
   
-- sreadtim not between 0.5 and 10 in Exadata
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Single-block read time of '||pval1||' milliseconds seems unlikely for an Exadata system.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting SREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a> and Bug <a target="MOS" href="^^bug_link.9842771">9842771</a>.'
  FROM sys.aux_stats$
 WHERE :health_checks = 'Y'
   AND sname = 'SYSSTATS_MAIN'
   AND pname = 'SREADTIM'
   AND pval1 NOT BETWEEN 0.5 AND 10
   AND '^^exadata.' = 'Y';   
   
-- mreadtim not between 0.5 and 10 in Exadata
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'DBMS_STATS', SYSTIMESTAMP, 'SYSTEM STATISTICS',
       'Multi-block read time of '||pval1||' milliseconds seems unlikely for  an Exadata system.',
       'Consider gathering workload system statistics using DBMS_STATS.GATHER_SYSTEM_STATS or adjusting MREADTIM using DBMS_STATS.SET_SYSTEM_STATS.<br>'||CHR(10)||
       'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a> and Bug <a target="MOS" href="^^bug_link.9842771">9842771</a>.'
  FROM sys.aux_stats$
 WHERE :health_checks = 'Y'
   AND sname = 'SYSSTATS_MAIN'
   AND pname = 'MREADTIM'
   AND pval1 NOT BETWEEN 0.5 AND 10
   AND '^^exadata.' = 'Y';    
   
-- exadata specific check, offload disabled because of bad timezone file to cells (bug 11836425)   
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'OFFLOAD', SYSTIMESTAMP, 'OFFLOAD OFF',
       'Due to a timezone upgrade pending the offload might be disabled.',
       'Offload might get rejected if the cells don''t have the propert timezone file.'
  FROM database_properties
 WHERE :health_checks = 'Y'
   AND property_name = 'DST_UPGRADE_STATE' 
   AND property_value<>'NONE'
   AND ROWNUM = 1
   AND '^^exadata.' = 'Y'; 
   
-- Exadata specific check, offload disabled because tables with CACHE = YES
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'OFFLOAD', SYSTIMESTAMP, 'OFFLOAD OFF',
       'There is/are tables(s) with property CACHE = ''Y'', this causes offload to be disabled on it/them.',
       'Offload is not used for tables that have property CACHE = ''Y''.'
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   -- AND t.object_type = 'TABLE'    -- uday bug fix
   AND ROWNUM = 1
   AND t.cache = 'Y'
   AND '^^exadata.' = 'Y';    
   
-- Exadata specific check, offload disabled for SQL executed by shared servers
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'OFFLOAD', SYSTIMESTAMP, 'OFFLOAD OFF',
       'Offload is not used for SQLs executed from Shared Server.',
       'SQLs executed by Shared Server cannot be offloaded since they don''t use direct path reads.'
  FROM v$system_parameter2 
 WHERE :health_checks = 'Y'
   AND UPPER(name) = 'SHARED_SERVERS'
   -- AND UPPER(value) > 0
   AND value != '0'  -- uday
   AND '^^exadata.' = 'Y';   

-- Exadata specific check, offload disabled for serial DML 
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'OFFLOAD', SYSTIMESTAMP, 'OFFLOAD OFF',
       'Offload is not used for SQLs that don''t use direct path reads.',
       'Serial DMLs cannot be offloaded by default since they don''t use direct path reads<br>'||CHR(10)||
	   'If this execution is serial then make sure to use direct path reads or offload won'' be possible.'
  FROM v$sql 
 WHERE :health_checks = 'Y'
   AND TRIM(UPPER(SUBSTR(LTRIM(sql_text),1,6))) IN ('INSERT','UPDATE','DELETE','MERGE')
   AND sql_id = '^^sql_id.'
   AND ROWNUM = 1
   AND '^^exadata.' = 'Y';  

-- AutoDOP and no IO Calibration   
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'PX', SYSTIMESTAMP, 'AUTODOP OFF',
       'AutoDOP is enable but there are no IO Calibration stats.',
       'AutoDOP requires IO Calibration stats, consider collecting them using DBMS_RESOURCE_MANAGER.CALIBRATE_IO.'
  FROM v$system_parameter2 
 WHERE :health_checks = 'Y'
   AND UPPER(name) = 'PARALLEL_DEGREE_POLICY'
   AND UPPER(value) IN ('AUTO','LIMITED')
   AND NOT EXISTS (SELECT 1 
                     FROM dba_rsrc_io_calibrate); 

-- Manuaul DOP and Tables with DEFAULT degree
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'PX', SYSTIMESTAMP, 'MANUAL DOP WITH DEFAULT',
       'The DEGREE on some tables in set to DEFAULT and PARALLEL_DEGREE_POLICY is MANUAL',
       'DEFAULT degree combined with PARALLEL_DEGREE_POLICY = MANUAL might translate in a high degree of parallelism.'
  FROM v$system_parameter2 
 WHERE :health_checks = 'Y'
   AND UPPER(name) = 'PARALLEL_DEGREE_POLICY'
   AND UPPER(value) = 'MANUAL'
   AND EXISTS (SELECT 1 
                 FROM plan_table pt,
                      dba_tables t
                WHERE pt.object_type = 'TABLE'
                  AND STATEMENT_ID = :sql_id
                  AND pt.object_owner = t.owner
                  AND pt.object_name = t.table_name
                  -- AND t.object_type = 'TABLE'    -- uday bug fix
                  AND t.degree = 'DEFAULT'); 					 
   
-- sql with policies as per v$vpd_policy
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection, cost)
SELECT :sql_id, :E_GLOBAL, 'VPD', SYSTIMESTAMP, 'V$VPD_POLICY',
       'Virtual Private Database. There is one or more policies affecting this SQL.',
       'Review Execution Plans and look for their injected predicates.',
       COUNT(distinct policy) -- PSRv10
  FROM gv$vpd_policy
 WHERE :health_checks = 'Y'
   AND sql_id = :sql_id
HAVING COUNT(*) > 0;

-- materialized views with rewrite enabled
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'MAT_VIEW', SYSTIMESTAMP, 'REWRITE_ENABLED',
       'There are '||COUNT(*)||' materialized views with rewrite enabled.',
       'A large number of materialized views could affect parsing time since CBO would have to evaluate each during a hard-parse.'
  FROM v$system_parameter2 p,
       dba_mviews m
 WHERE :health_checks = 'Y'
   AND UPPER(p.name) = 'QUERY_REWRITE_ENABLED'
   AND UPPER(p.value) = 'TRUE'
   AND m.rewrite_enabled = 'Y'
HAVING COUNT(*) > 1;

-- rewrite equivalences from DBMS_ADVANCED_REWRITE
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'REWRITE_EQUIVALENCE', SYSTIMESTAMP, 'REWRITE_EQUIVALENCE',
       'There is/are '||COUNT(*)||' rewrite equivalence(s) defined by the owner(s) of the involved objects.',
       'A rewrite equivalence makes the CBO rewrite the original SQL to a different one so that needs to be considered when analyzing the case.'
  FROM dba_rewrite_equivalences m,
       (SELECT DISTINCT object_owner owner FROM plan_table where STATEMENT_ID = :sql_id) o
 WHERE :health_checks = 'Y'
   AND m.owner = o.owner
HAVING COUNT(*) > 0;

-- table with bitmap index(es)
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'INDEX', SYSTIMESTAMP, 'BITMAP',
       'Your DML statement references '||COUNT(DISTINCT pt.object_name||pt.object_owner)||' Table(s) with at least one Bitmap index.',
       'Be aware that frequent DML operations operations in a Table with Bitmap indexes may produce contention where concurrent DML operations are common. If your SQL suffers of "TX-enqueue row lock contention" suspect this situation.'
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type = 'BITMAP'
   AND EXISTS (
SELECT NULL
  FROM gv$sqlarea s
 WHERE :health_checks = 'Y'
   AND s.sql_id = :sql_id
   AND s.command_type IN (2, 6, 7)) -- INSERT, UPDATE, DELETE
HAVING COUNT(*) > 0;

-- index in plan no longer exists
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT DISTINCT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Index referenced by an Execution Plan no longer exists.',
       'If a Plan references a missing index then this Plan can no longer be generated by the CBO.'
  FROM plan_table pt
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.other_tag = 'YES'
   AND NOT EXISTS (
SELECT NULL
  FROM dba_indexes i
 WHERE :health_checks = 'Y'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name );

-- index in plan is now unusable
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT DISTINCT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Index referenced by an Execution Plan is now unusable.',
       'If a Plan references an unusable index then this Plan cannot be generated by the CBO.<br>'||CHR(10)||
       'If you need to enable tha Plan that references this index you need to rebuild it first.'
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.other_tag = 'YES'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'NO'
   AND i.status = 'UNUSABLE';

-- index in plan has now unusable partitions
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT DISTINCT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Index referenced by an Execution Plan has now unusable partitions.',
       'If a Plan references an index with unusable partitions then this Plan cannot be generated by the CBO.<br>'||CHR(10)||
       'If you need to enable tha Plan that references this index you need to rebuild the unusable partitions first.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.other_tag = 'YES'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
   AND p.status = 'UNUSABLE';

-- index in plan has now unusable subpartitions
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT DISTINCT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Index referenced by an Execution Plan has now unusable subpartitions.',
       'If a Plan references an index with unusable subpartitions then this Plan cannot be generated by the CBO.<br>'||CHR(10)||
       'If you need to enable tha Plan that references this index you need to rebuild the unusable subpartitions first.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_subpartitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.other_tag = 'YES'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
   AND p.status = 'UNUSABLE';

-- index in plan is now invisible
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT DISTINCT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Index referenced by an Execution Plan is now invisible.',
       'If a Plan references an invisible index then this Plan cannot be generated by the CBO.<br>'||CHR(10)||
       'If you need to enable tha Plan that references this index you need to make this index visible.'
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.other_tag = 'YES'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'NO'
   AND i.visibility = 'INVISIBLE';

-- unusable indexes
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'INDEX', SYSTIMESTAMP, 'UNUSABLE',
       'There are '||COUNT(*)||' unusable index(es) in tables being accessed by your SQL.',
       'Unusable indexes cannot be used by the CBO. This may cause Execution Plans to change.'
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'NO'
   AND i.status = 'UNUSABLE'
HAVING COUNT(*) > 0;

-- unusable index partitions
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'INDEX PARTITION', SYSTIMESTAMP, 'UNUSABLE',
       'There are '||COUNT(*)||' unusable index partition(s) in tables being accessed by your SQL.',
       'Unusable index partitions cannot be used by the CBO. This may cause Execution Plans to change.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
   AND p.status = 'UNUSABLE'
HAVING COUNT(*) > 0;

-- unusable index subpartitions
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'INDEX SUBPARTITION', SYSTIMESTAMP, 'UNUSABLE',
       'There are '||COUNT(*)||' unusable index subpartition(s) in tables being accessed by your SQL.',
       'Unusable index subpartitions cannot be used by the CBO. This may cause Execution Plans to change.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_subpartitions sp
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND pt.object_owner = sp.index_owner
   AND pt.object_name = sp.index_name
   AND sp.status = 'UNUSABLE'
HAVING COUNT(*) > 0;

-- invisible indexes
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_GLOBAL, 'INDEX', SYSTIMESTAMP, 'INVISIBLE',
       'There are '||COUNT(*)||' invisible index(es) in tables being accessed by your SQL.',
       'Invisible indexes cannot be used by the CBO. This may cause Execution Plans to change.'
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.visibility = 'INVISIBLE'
HAVING COUNT(*) > 0;

/* -------------------------
 *
 * table hc
 *
 * ------------------------- */

-- empty_blocks > blocks
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has more empty blocks ('||t.empty_blocks||') than actual blocks ('||t.blocks||') according to CBO statistics.',
       'Review Table statistics and consider re-organizing this Table.'
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.empty_blocks > t.blocks;

-- table dop is set
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table''s DOP is "'||TRIM(t.degree)||'".',
       'Degree of parallelism greater than 1 may cause parallel-execution PX plans.<br>'||CHR(10)||
       'Review table properties and execute "ALTER TABLE '||pt.object_owner||'.'||pt.object_name||' NOPARALLEL" to reset degree of parallelism to 1 if PX plans are not desired.'
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND TRIM(t.degree) NOT IN ('0', '1', 'DEFAULT');

-- table has indexes with dop set
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has '||COUNT(*)||' index(es) with DOP greater than 1.',
       'Degree of parallelism greater than 1 may cause parallel-execution PX plans.<br>'||CHR(10)||
       'Review index properties and execute "ALTER INDEX index_name NOPARALLEL" to reset degree of parallelism to 1 if PX plans are not desired.'
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND TRIM(i.degree) NOT IN ('0', '1', 'DEFAULT')
 GROUP BY
       pt.object_owner,
       pt.object_name;

-- index degree <> table degree
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has '||COUNT(*)||' index(es) with DOP different than its table.',
       'Table has a degree of parallelism of "'||TRIM(t.degree)||'".<br>'||CHR(10)||
       'Review index properties and fix degree of parallelism of table and/or its index(es).'
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND TRIM(t.degree) <> TRIM(i.degree)
 GROUP BY
       pt.object_owner,
       pt.object_name,
       TRIM(t.degree);

-- no stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table lacks CBO Statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.temporary = 'N'
   AND (t.last_analyzed IS NULL OR t.num_rows IS NULL);

-- no rows
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Number of rows equal to zero according to table''s CBO statistics.',
       CASE
         WHEN t.temporary = 'Y' THEN
           'Consider deleting table statistics on this GTT using DBMS_STATS.DELETE_TABLE_STATS.'
         WHEN '^^is_ebs.' = 'Y' THEN
           'If this table has rows consider gathering table statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has less than 15 rows consider deleting table statistics using DBMS_STATS.DELETE_TABLE_STATS,<br>'||CHR(10)||
           'else gathering table statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'If this table has rows consider gathering table statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows = 0;

-- siebel small tables with CBO statistics
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Small table with CBO statistics.',
       'Consider deleting table statistics on this small table using DBMS_STATS.DELETE_TABLE_STATS.<br>'||CHR(10)||
       'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND '^^is_siebel.' = 'Y'
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows < 15;

-- small sample size
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Sample size of '||v.sample_size||' rows may be too small for table with '||v.num_rows||' rows.',
       'Sample percent used was:'||TRIM(TO_CHAR(ROUND(v.ratio * 100, 2), '99999990D00'))||'%.<br>'||CHR(10)||
       'Consider gathering better quality table statistics with DBMS_STATS.AUTO_SAMPLE_SIZE on 11g or with a sample size of '||ROUND(v.factor * 100)||'% on 10g.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.num_rows,
       t.sample_size,
       (t.sample_size / t.num_rows) ratio,
       CASE
         WHEN t.num_rows < 1e6 THEN -- up to 1M then 100%
           1
         WHEN t.num_rows < 1e7 THEN -- up to 10M then 30%
           3/10
         WHEN t.num_rows < 1e8 THEN -- up to 100M then 10%
           1/10
         WHEN t.num_rows < 1e9 THEN -- up to 1B then 3%
           3/100
         ELSE -- more than 1B then 1%
           1/100
         END factor
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.sample_size > 0
   AND t.last_analyzed IS NOT NULL ) v
 WHERE :health_checks = 'Y'
   AND v.ratio < (9/10) * v.factor;

-- old stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table CBO statistics are '||ROUND(SYSDATE - v.last_analyzed)||' days old: '||TO_CHAR(v.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS')||'.',
       'Consider gathering better quality table statistics with DBMS_STATS.AUTO_SAMPLE_SIZE on 11g or with a sample size of '||ROUND(v.factor * 100)||'% on 10g.<br>'||CHR(10)||
       'Old statistics could contain low/high values for which a predicate may be out of range, producing then a poor plan.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.last_analyzed,
       t.num_rows,
       t.sample_size,
       (t.sample_size / t.num_rows) ratio,
       CASE
         WHEN t.num_rows < 1e6 THEN -- up to 1M then 100%
           1
         WHEN t.num_rows < 1e7 THEN -- up to 10M then 30%
           3/10
         WHEN t.num_rows < 1e8 THEN -- up to 100M then 10%
           1/10
         WHEN t.num_rows < 1e9 THEN -- up to 1B then 3%
           3/100
         ELSE -- more than 1B then 1%
           1/100
         END factor
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.sample_size > 0
   AND t.last_analyzed IS NOT NULL ) v
 WHERE :health_checks = 'Y'
   AND (v.last_analyzed < SYSDATE - 49
    OR (v.num_rows BETWEEN 0 AND 1e6 AND v.last_analyzed < SYSDATE - 21)
    OR (v.num_rows BETWEEN 1e6 AND 1e7 AND v.last_analyzed < SYSDATE - 28)
    OR (v.num_rows BETWEEN 1e7 AND 1e8 AND v.last_analyzed < SYSDATE - 35)
    OR (v.num_rows BETWEEN 1e8 AND 1e9 AND v.last_analyzed < SYSDATE - 42));


-- extended statistics
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has '||COUNT(*)||' CBO statistics extension(s).',
       'Review table statistics extensions. Extensions can be used for expressions or column groups.<br>'||CHR(10)||
       'If your SQL contain matching predicates these extensions can influence the CBO.'
  FROM plan_table pt,
       dba_stat_extensions e
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = e.owner
   AND pt.object_name = e.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name;

-- columns with no stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Contains '||COUNT(*)||' column(s) with missing CBO statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.last_analyzed IS NULL
 GROUP BY
       pt.object_owner,
       pt.object_name;

-- columns missing low/high values
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Contains '||COUNT(*)||' column(s) with null low/high values.',
       'CBO cannot compute correct selectivity with these column statistics missing.<br>'||CHR(10)||
       'You may possibly have Bug <a target="MOS" href="^^bug_link.10248781">10248781</a><br>'||CHR(10)||
       'Consider gathering statistics for this table.'
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.last_analyzed IS NOT NULL
   AND c.num_distinct > 0
   AND (c.low_value IS NULL OR c.high_value IS NULL)
 GROUP BY
       pt.object_owner,
       pt.object_name;

-- columns with old stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains column(s) with outdated CBO statistics for up to '||TRUNC(ABS(v.tbl_last_analyzed - v.col_last_analyzed))||' day(s).',
       'CBO table and column statistics are inconsistent. Consider gathering statistics for this table.<br>'||CHR(10)||
       'Old statistics could contain low/high values for which a predicate may be out of range, producing then a poor plan.'
  FROM (
-- 
-- Perf issue...more than minute on crmap
--
-- UdayRemoved.v6: SELECT pt.object_owner,
-- UdayRemoved.v6:        pt.object_name,
-- UdayRemoved.v6:        t.last_analyzed tbl_last_analyzed,
-- UdayRemoved.v6:        MIN(c.last_analyzed) col_last_analyzed
-- UdayRemoved.v6:   FROM plan_table pt,
-- UdayRemoved.v6:        dba_tables t,
-- UdayRemoved.v6:        dba_tab_cols c
-- UdayRemoved.v6:  WHERE :health_checks = 'Y'
-- UdayRemoved.v6:    AND pt.object_type = 'TABLE'
-- UdayRemoved.v6:    AND pt.object_owner = t.owner
-- UdayRemoved.v6:    AND pt.object_name = t.table_name
-- UdayRemoved.v6:    AND t.num_rows > 0
-- UdayRemoved.v6:    AND t.last_analyzed IS NOT NULL
-- UdayRemoved.v6:    AND pt.object_owner = c.owner
-- UdayRemoved.v6:    AND pt.object_name = c.table_name
-- UdayRemoved.v6:    AND c.last_analyzed IS NOT NULL
-- UdayRemoved.v6:  GROUP BY
-- UdayRemoved.v6:        pt.object_owner,
-- UdayRemoved.v6:        pt.object_name,
-- UdayRemoved.v6:        t.last_analyzed 
with t as (
SELECT /*+ MATERIALIZE */ pt.object_owner,
       pt.object_name,
       t.last_analyzed tbl_last_analyzed
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
)
, c as (
select /*+ MATERIALIZE */ c.owner, c.table_name, min(c.last_analyzed) col_last_analyzed
  from dba_tab_cols c
 where (c.owner, c.table_name) in (select  pt.object_owner, pt.object_name FROM plan_table pt where pt.STATEMENT_ID = :sql_id and pt.object_type = 'TABLE')
   AND c.last_analyzed IS NOT NULL
 group by c.owner, c.table_name
)
select t.object_owner, t.object_name, t.tbl_last_analyzed, c.col_last_analyzed
  from t, c
 where t.object_owner = c.owner
   AND t.object_name = c.table_name
) v
 WHERE :health_checks = 'Y'
   AND ABS(v.tbl_last_analyzed - v.col_last_analyzed) > 1;

-- more nulls than rows
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Number of nulls greater than number of rows by more than 10% in '||v.col_count||' column(s).',
       'There cannot be more rows with null value in a column than actual rows in the table.<br>'||CHR(10)||
       'Worst column shows '||v.num_nulls||' nulls while table has '||v.tbl_num_rows||' rows.<br>'||CHR(10)||
       'CBO table and column statistics are inconsistent. Consider gathering statistics for this table using a large sample size.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.num_rows tbl_num_rows,
       COUNT(*) col_count,
       MAX(c.num_nulls) num_nulls
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.num_nulls > t.num_rows
   AND (c.num_nulls - t.num_rows) > t.num_rows * 0.1
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.num_rows ) v
 WHERE :health_checks = 'Y'
   AND v.col_count > 0;

-- more distinct values than rows
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Number of distinct values greater than number of rows by more than 10% in '||v.col_count||' column(s).',
       'There cannot be a larger number of distinct values in a column than actual rows in the table.<br>'||CHR(10)||
       'Worst column shows '||v.num_distinct||' distinct values while table has '||v.tbl_num_rows||' rows.<br>'||CHR(10)||
       'CBO table and column statistics are inconsistent. Consider gathering statistics for this table using a large sample size.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.num_rows tbl_num_rows,
       COUNT(*) col_count,
       MAX(c.num_distinct) num_distinct
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.num_distinct > t.num_rows
   AND (c.num_distinct - t.num_rows) > t.num_rows * 0.1
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.num_rows ) v
 WHERE :health_checks = 'Y'
   AND v.col_count > 0;

-- zero distinct values on columns with value
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Number of distinct values is zero in at least '||v.col_count||' column(s) with value.',
       'There should not be columns with value ((num_rows - num_nulls) greater than 0) where the number of distinct values for the same column is zero.<br>'||CHR(10)||
       'Worst column shows '||(v.tbl_num_rows - v.num_nulls)||' rows with value while the number of distinct values for it is zero.<br>'||CHR(10)||
       'CBO table and column statistics are inconsistent. Consider gathering statistics for this table using a large sample size.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.num_rows tbl_num_rows,
       COUNT(*) col_count,
       MIN(c.num_nulls) num_nulls
  FROM plan_table pt,
       dba_tables t,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND t.num_rows > c.num_nulls
   AND c.num_distinct = 0
   AND (t.num_rows - c.num_nulls) > t.num_rows * 0.1
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.num_rows ) v
 WHERE :health_checks = 'Y'
   AND v.col_count > 0;

-- 9885553 incorrect NDV in long char column with histogram
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains '||v.col_count||' long CHAR column(s) with Histogram. Number of distinct values (NDV) could be incorrect.',
       'Possible Bug <a target="MOS" href="^^bug_link.9885553">9885553</a>.<br>'||CHR(10)||
       'When building histogram for a varchar column that is long, we only use its first 32 characters.<br>'||CHR(10)||
       'Two distinct values that share the same first 32 characters are deemed the same in the histogram.<br>'||CHR(10)||
       'Therefore the NDV derived from the histogram is inaccurate.'||CHR(10)||
       'If NDV is wrong then drop the Histogram.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) col_count
  FROM plan_table pt,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.num_distinct > 0
   AND c.data_type LIKE '%CHAR%'
   AND c.avg_col_len > 32
   AND c.histogram IN ('FREQUENCY', 'HEIGHT BALANCED')
   AND '^^rdbms_version.' < '11.2.0.3'
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.col_count > 0;

-- 10174050 frequency histograms with less buckets than NDV
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains '||v.col_count||' column(s) where the number of distinct values does not match the number of buckets.',
       'Review column statistics for this table and look for "Num Distinct" and "Num Buckets". If there are values missing from the frequency histogram you may have Bug <a target="MOS" href="^^bug_link.10174050">10174050</a>.<br>'||CHR(10)||
       'If you are referencing in your predicates one of the missing values the CBO can over estimate table cardinality, and this may produce a sub-optimal plan.<br>'||CHR(10)||
       'You can either gather statistics with 100% or as a workaround: ALTER system/session "_fix_control"=''5483301:OFF'';'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) col_count
  FROM plan_table pt,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.histogram = 'FREQUENCY'
   AND c.num_distinct <> c.num_buckets
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.col_count > 0;

-- frequency histogram with 1 bucket
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains '||v.col_count||' column(s) where the number of buckets is 1 for a "FREQUENCY" histogram.',
       'Review column statistics for this table and look for "Num Buckets" and "Histogram". Possible Bugs '||
       '<a target="MOS" href="^^bug_link.1386119">1386119</a>, '||
       '<a target="MOS" href="^^bug_link.4406309">4406309</a>, '||
       '<a target="MOS" href="^^bug_link.4495422">4495422</a>, '||
       '<a target="MOS" href="^^bug_link.4567767">4567767</a>, '||
       '<a target="MOS" href="^^bug_link.5483301">5483301</a> or '||
       '<a target="MOS" href="^^bug_link.6082745">6082745</a>.<br>'||CHR(10)||
       'If you are referencing in your predicates one of the missing values the CBO can over estimate table cardinality, and this may produce a sub-optimal plan.<br>'||CHR(10)||
       'You can either gather statistics with 100% or as a workaround: ALTER system/session "_fix_control"=''5483301:OFF'';'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) col_count
  FROM plan_table pt,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.histogram = 'FREQUENCY'
   AND c.num_buckets = 1
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.col_count > 0;

-- height balanced histogram with no popular values
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains '||v.col_count||' column(s) with no popular values on a "HEIGHT BALANCED" histogram.',
       'A Height-balanced histogram with no popular values is not helpful nor desired. Consider dropping this histogram by collecting new CBO statistics while using METHOD_OPT with SIZE 1.'
  FROM (
with t as (
SELECT /*+ MATERIALIZE */ pt.object_owner,
       pt.object_name,
       c.column_name
  FROM plan_table pt,
       dba_tab_cols c
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND c.histogram = 'HEIGHT BALANCED'
   AND c.num_buckets > 253
 GROUP BY
       pt.object_owner,
       pt.object_name,
       c.column_name
),
c as (
select /*+ MATERIALIZE */ t.object_owner, t.object_name, h.column_name
  FROM dba_tab_histograms h, t
 WHERE :health_checks = 'Y'
   AND h.owner = t.object_owner
   AND h.table_name = t.object_name
   AND h.column_name = t.column_name
 group by t.object_owner, t.object_name, h.column_name
 having count(*) > 253
)
select object_owner, object_name, count(*) col_count
  from c
 group by object_owner, object_name
 ) v
;

--udayRemoved:v6 Perf Issue SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
--udayRemoved:v6 Perf Issue        'Table contains '||v.col_count||' column(s) with no popular values on a "HEIGHT BALANCED" histogram.',
--udayRemoved:v6 Perf Issue        'A Height-balanced histogram with no popular values is not helpful nor desired. Consider dropping this histogram by collecting new CBO statistics while using METHOD_OPT with SIZE 1.'
--udayRemoved:v6 Perf Issue   FROM (
--udayRemoved:v6 Perf Issue SELECT pt.object_owner,
--udayRemoved:v6 Perf Issue        pt.object_name,
--udayRemoved:v6 Perf Issue        COUNT(*) col_count
--udayRemoved:v6 Perf Issue   FROM plan_table pt,
--udayRemoved:v6 Perf Issue        dba_tab_cols c
--udayRemoved:v6 Perf Issue  WHERE :health_checks = 'Y'
--udayRemoved:v6 Perf Issue    AND pt.object_type = 'TABLE'
--udayRemoved:v6 Perf Issue    AND pt.object_owner = c.owner
--udayRemoved:v6 Perf Issue    AND pt.object_name = c.table_name
--udayRemoved:v6 Perf Issue    AND c.histogram = 'HEIGHT BALANCED'
--udayRemoved:v6 Perf Issue    AND c.num_buckets > 253
--udayRemoved:v6 Perf Issue    AND (SELECT COUNT(*)
--udayRemoved:v6 Perf Issue           FROM dba_tab_histograms h
--udayRemoved:v6 Perf Issue          WHERE :health_checks = 'Y'
--udayRemoved:v6 Perf Issue            AND h.owner = c.owner
--udayRemoved:v6 Perf Issue            AND h.table_name = c.table_name
--udayRemoved:v6 Perf Issue            AND h.column_name = c.column_name) > 253
--udayRemoved:v6 Perf Issue  GROUP BY
--udayRemoved:v6 Perf Issue        pt.object_owner,
--udayRemoved:v6 Perf Issue        pt.object_name ) v
--udayRemoved:v6 Perf Issue  WHERE :health_checks = 'Y'
--udayRemoved:v6 Perf Issue    AND v.col_count > 0

-- UdayRemoved.v6 SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
-- UdayRemoved.v6        'Table contains '||v.col_count||' column(s) with corrupted histogram.',
-- UdayRemoved.v6        'These columns have buckets with values out of order. Consider dropping those histogram by collecting new CBO statistics while using METHOD_OPT with SIZE 1. Possible Bugs '||
-- UdayRemoved.v6        '<a target="MOS" href="^^bug_link.8543770">8543770</a>, '||
-- UdayRemoved.v6        '<a target="MOS" href="^^bug_link.10267075">10267075</a>, '||
-- UdayRemoved.v6        '<a target="MOS" href="^^bug_link.12819221">12819221</a> or '||
-- UdayRemoved.v6        '<a target="MOS" href="^^bug_link.12876988">12876988</a>.'
-- UdayRemoved.v6   FROM (
-- UdayRemoved.v6 SELECT pt.object_owner,
-- UdayRemoved.v6        pt.object_name,
-- UdayRemoved.v6        COUNT(*) col_count
-- UdayRemoved.v6   FROM plan_table pt,
-- UdayRemoved.v6        dba_tab_cols c
-- UdayRemoved.v6  WHERE :health_checks = 'Y'
-- UdayRemoved.v6    AND pt.object_type = 'TABLE'
-- UdayRemoved.v6    AND pt.object_owner = c.owner
-- UdayRemoved.v6    AND pt.object_name = c.table_name
-- UdayRemoved.v6    AND c.num_distinct > 0
-- UdayRemoved.v6    AND c.num_buckets > 1
-- UdayRemoved.v6    AND (SELECT COUNT(*) 
-- UdayRemoved.v6           FROM (SELECT CASE WHEN LAG(endpoint_value) OVER (ORDER BY endpoint_number) > c1.endpoint_value THEN 1 else 0 END mycol
-- UdayRemoved.v6                   FROM dba_tab_histograms c1
-- UdayRemoved.v6                  WHERE :health_checks = 'Y'
-- UdayRemoved.v6                    AND c1.owner = c.owner
-- UdayRemoved.v6                    AND c1.table_name = c.table_name
-- UdayRemoved.v6                    AND c1.column_name = c.column_name)
-- UdayRemoved.v6          WHERE mycol = 1) > 0
-- UdayRemoved.v6  GROUP BY
-- UdayRemoved.v6        pt.object_owner,
-- UdayRemoved.v6        pt.object_name ) v
-- UdayRemoved.v6  WHERE :health_checks = 'Y'
-- UdayRemoved.v6    AND v.col_count > 0

--Uday.PSR.v6: tune later -- 8543770 corrupted histogram
--Uday.PSR.v6: try join order: plan_table, dba_tab_cols, dba_tab_histograms
--             Major perf difference in 11g and 12c ... 12c is worser so test sql in both
--             
--Uday.PSR.v6: tune later INSERT INTO plan_table (id, operation, object_alias, other_tag, remarks, projection)
--Uday.PSR.v6: tune later with /*corrupted histogram*/ chist as 
--Uday.PSR.v6: tune later (
--Uday.PSR.v6: tune later SELECT /*+ MATERIALIZE leading(pt) */ distinct owner, table_name, column_name
--Uday.PSR.v6: tune later           FROM (SELECT c1.owner, c1.table_name, c1.column_name, 
--Uday.PSR.v6: tune later                        CASE WHEN 
--Uday.PSR.v6: tune later                          LAG(endpoint_value) OVER (partition by c1.owner, c1.table_name, c1.column_name ORDER BY c1.column_name, endpoint_number) > c1.endpoint_value
--Uday.PSR.v6: tune later                        THEN 1 else 0 END mycol
--Uday.PSR.v6: tune later                   FROM dba_tab_histograms c1, plan_table pt
--Uday.PSR.v6: tune later                  WHERE :health_checks = 'Y'
--Uday.PSR.v6: tune later                    AND pt.object_type = 'TABLE'
--Uday.PSR.v6: tune later                    AND c1.owner = pt.object_owner
--Uday.PSR.v6: tune later                    AND c1.table_name = pt.object_name
--Uday.PSR.v6: tune later                )
--Uday.PSR.v6: tune later          WHERE mycol = 1
--Uday.PSR.v6: tune later )
--Uday.PSR.v6: tune later SELECT :E_TABLE, 'TABLE', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
--Uday.PSR.v6: tune later        'Table contains '||v.col_count||' column(s) with corrupted histogram.',
--Uday.PSR.v6: tune later        'These columns have buckets with values out of order. Consider dropping those histogram by collecting new CBO statistics while using METHOD_OPT with SIZE 1. Possible Bugs '||
--Uday.PSR.v6: tune later        '<a target="MOS" href="^^bug_link.8543770">8543770</a>, '||
--Uday.PSR.v6: tune later        '<a target="MOS" href="^^bug_link.10267075">10267075</a>, '||
--Uday.PSR.v6: tune later        '<a target="MOS" href="^^bug_link.12819221">12819221</a> or '||
--Uday.PSR.v6: tune later        '<a target="MOS" href="^^bug_link.12876988">12876988</a>.'
--Uday.PSR.v6: tune later   FROM (
--Uday.PSR.v6: tune later SELECT /*+ leading(c) no_merge */
--Uday.PSR.v6: tune later        c.owner object_owner,
--Uday.PSR.v6: tune later        c.table_name object_name,
--Uday.PSR.v6: tune later        COUNT(*) col_count
--Uday.PSR.v6: tune later   FROM dba_tab_cols c, chist
--Uday.PSR.v6: tune later  WHERE :health_checks = 'Y'
--Uday.PSR.v6: tune later    AND c.num_distinct > 0
--Uday.PSR.v6: tune later    AND c.num_buckets > 1
--Uday.PSR.v6: tune later    AND c.histogram <> 'NONE'
--Uday.PSR.v6: tune later    AND chist.owner = c.owner
--Uday.PSR.v6: tune later    AND chist.table_name = c.table_name
--Uday.PSR.v6: tune later    AND chist.column_name = c.column_name
--Uday.PSR.v6: tune later  GROUP BY
--Uday.PSR.v6: tune later        c.owner,
--Uday.PSR.v6: tune later        c.table_name ) v
--Uday.PSR.v6: tune later  WHERE :health_checks = 'Y'
--Uday.PSR.v6: tune later    AND v.col_count > 0;


-- analyze 236935.1
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'CBO statistics were gathered using deprecated ANALYZE command.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned table, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using FND_STATS instead.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned table, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using coe_siebel_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned table, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using pscbo_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'When ANALYZE is used on a non-partitioned table, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using DBMS_STATS instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND t.partitioned = 'NO'
   AND t.global_stats = 'NO';

-- derived stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'CBO statistics are being derived by aggregation from lower level objects.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'When statistics are derived by aggregation from lower level objects, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using FND_STATS instead.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'When statistics are derived by aggregation from lower level objects, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using coe_siebel_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'When statistics are derived by aggregation from lower level objects, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using pscbo_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'When statistics are derived by aggregation from lower level objects, the global_stats column of the table statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using DBMS_STATS instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND t.partitioned = 'YES'
   AND t.global_stats = 'NO';

-- tables with stale statistics
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has stale statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tab_statistics t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   -- AND t.object_type = 'TABLE'  -- uday bug fix
   AND t.stale_stats = 'YES';

-- tables with locked statistics
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'TABLE', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Table has locked statistics.',
       'Review table statistics.'
  FROM plan_table pt,
       dba_tab_statistics t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   -- AND t.object_type = 'TABLE'  -- uday bug fix
   AND t.stattype_locked IN ('ALL', 'DATA');

-- sql with policies as per dba_policies
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'DBA_POLICIES', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Virtual Private Database. There is one or more policies affecting this table.',
       'Review Execution Plans and look for their injected predicates.'
  FROM plan_table pt,
       dba_policies p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = p.object_owner
   AND pt.object_name = p.object_name
 GROUP BY
       pt.object_owner,
       pt.object_name
HAVING COUNT(*) > 0
 ORDER BY
       pt.object_owner,
       pt.object_name;

-- sql with policies as per dba_audit_policies
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE, 'DBA_AUDIT_POLICIES', SYSTIMESTAMP, pt.object_owner||'.'||pt.object_name,
       'Fine-Grained Auditing. There is one or more audit policies affecting this table.',
       'Review Execution Plans and look for their injected predicates.'
  FROM plan_table pt,
       dba_audit_policies p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = p.object_schema
   AND pt.object_name = p.object_name
 GROUP BY
       pt.object_owner,
       pt.object_name
HAVING COUNT(*) > 0
 ORDER BY
       pt.object_owner,
       pt.object_name;

-- table partitions with no stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.no_stats||' out of '||v.par_count||' partition(s) lack(s) CBO statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering statistics using FND_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Consider gathering statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering statistics using DBMS_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count,
       SUM(CASE WHEN p.last_analyzed IS NULL OR p.num_rows IS NULL THEN 1 ELSE 0 END) no_stats
  FROM plan_table pt,
       dba_tables t,
       dba_tab_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = p.table_owner
   AND pt.object_name = p.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.no_stats > 0;

-- table partitions where num rows = 0
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.num_rows_zero||' out of '||v.par_count||' partition(s) with number of rows equal to zero according to partition''s CBO statistics.',
       'If these table partitions are not empty, consider gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count,
       SUM(CASE WHEN p.num_rows = 0 THEN 1 ELSE 0 END) num_rows_zero
  FROM plan_table pt,
       dba_tables t,
       dba_tab_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = p.table_owner
   AND pt.object_name = p.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.num_rows_zero > 0;

-- table partitions with outdated stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains partition(s) with table/partition CBO statistics out of sync for up to '||TRUNC(ABS(v.tbl_last_analyzed - v.par_last_analyzed))||' day(s).',
       'Table and partition statistics were gathered up to '||TRUNC(ABS(v.tbl_last_analyzed - v.par_last_analyzed))||' day(s) appart, so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
       'Consider re-gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.last_analyzed tbl_last_analyzed,
       COUNT(*) par_count,
       MIN(p.last_analyzed) par_last_analyzed
  FROM plan_table pt,
       dba_tables t,
       dba_tab_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
   AND pt.object_owner = p.table_owner
   AND pt.object_name = p.table_name
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.last_analyzed ) v
 WHERE :health_checks = 'Y'
   AND ABS(v.tbl_last_analyzed - v.par_last_analyzed) > 1;

-- partitions with no column stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.no_stats||' column(s) lack(s) partition level CBO statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering statistics using FND_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Consider gathering statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering statistics using DBMS_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       (SELECT COUNT(DISTINCT c.column_name)
          FROM dba_part_col_statistics c
         WHERE :health_checks = 'Y'
           AND c.owner = pt.object_owner
           AND c.table_name = pt.object_name
           AND c.last_analyzed IS NULL) no_stats
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.no_stats > 0;

-- partition columns with outdated stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_TABLE_PART, 'TABLE PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Table contains column(s) with table/partition CBO statistics out of sync for up to '||TRUNC(ABS(v.tbl_last_analyzed - v.col_last_analyzed))||' day(s).',
       'Table and partition statistics were gathered up to '||TRUNC(ABS(v.tbl_last_analyzed - v.col_last_analyzed))||' day(s) appart, so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
       'Consider re-gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       t.last_analyzed tbl_last_analyzed,
       (SELECT MIN(c.last_analyzed)
          FROM dba_part_col_statistics c
         WHERE :health_checks = 'Y'
           AND c.owner = pt.object_owner
           AND c.table_name = pt.object_name
           AND c.last_analyzed IS NOT NULL) col_last_analyzed
  FROM plan_table pt,
       dba_tables t
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND t.num_rows > 0
   AND t.last_analyzed IS NOT NULL
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.last_analyzed ) v
 WHERE :health_checks = 'Y'
   AND ABS(v.tbl_last_analyzed - v.col_last_analyzed) > 1;

/* -------------------------
 *
 * index hc
 *
 * ------------------------- */

-- no stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Index lacks CBO Statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table and index statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table and index statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table and index statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table and index statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND (i.last_analyzed IS NULL OR i.num_rows IS NULL);

-- more rows in index than its table
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Index appears to have more rows ('||i.num_rows||') than its table ('||t.num_rows||') by '||ROUND(100 * (i.num_rows - t.num_rows) / t.num_rows)||'%.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table and index statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table and index statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table and index statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table and index statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.num_rows > t.num_rows
   AND (i.num_rows - t.num_rows) > t.num_rows * 0.1;

-- clustering factor > rows in table
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Clustering factor of '||i.clustering_factor||' is larger than number of rows in its table ('||t.num_rows||') by more than '||ROUND(100 * (i.clustering_factor - t.num_rows) / t.num_rows)||'%.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering table and index statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'If table has more than 15 rows consider gathering table and index statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering table and index statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering table and index statistics using DBMS_STATS.GATHER_TABLE_STATS.'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.clustering_factor > t.num_rows
   AND (i.clustering_factor - t.num_rows) > t.num_rows * 0.1;

-- stats on zero while columns have value
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Index CBO statistics on 0 with indexed columns with value.',
       'This index with zeroes in CBO index statistics contains columns for which there are values, so the index should not have statistics in zeroes.<br>'||CHR(10)||
       'Possible Bug <a target="MOS" href="^^bug_link.4055596">4055596</a>. Consider gathering table statistics, or DROP and RE-CREATE index.'
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.num_rows = 0
   AND i.distinct_keys = 0
   AND i.leaf_blocks = 0
   AND i.blevel = 0
   AND EXISTS (
SELECT NULL
  FROM dba_ind_columns ic,
       dba_tab_cols tc
 WHERE :health_checks = 'Y'
   AND ic.index_owner = i.owner
   AND ic.index_name = i.index_name
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND t.num_rows > tc.num_nulls
   AND (t.num_rows - tc.num_nulls) > t.num_rows * 0.1);

-- Uday: PSR: cols with no stats, but index with stats
-- can happen when function based index is created
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Index statistics without columns statistics',
       'Index has statistics, but column level statistics are not gathered. Could lead to bad execution plans.'
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.num_rows != 0
   AND i.distinct_keys != 0
   AND i.leaf_blocks != 0
   AND EXISTS (
SELECT NULL
  FROM dba_ind_columns ic,
       dba_tab_cols tc
 WHERE :health_checks = 'Y'
   AND ic.index_owner = i.owner
   AND ic.index_name = i.index_name
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND tc.last_analyzed is null);

-- table/index stats out of sync
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Table/Index CBO statistics out of sync.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Table and index statistics were gathered '||TRUNC(ABS(t.last_analyzed - i.last_analyzed))||' day(s) appart,<br>'||CHR(10)||
           'so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
           'Consider gathering table and index statistics using FND_STATS.GATHER_TABLE_STATS or coe_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Table and index statistics were gathered '||TRUNC(ABS(t.last_analyzed - i.last_analyzed))||' day(s) appart,<br>'||CHR(10)||
           'so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
           'If table has more than 15 rows consider gathering table and index statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Table and index statistics were gathered '||TRUNC(ABS(t.last_analyzed - i.last_analyzed))||' day(s) appart,<br>'||CHR(10)||
           'so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
           'Consider gathering table and index statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Table and index statistics were gathered '||TRUNC(ABS(t.last_analyzed - i.last_analyzed))||' day(s) appart,<br>'||CHR(10)||
           'so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
           'Consider gathering table and index statistics using DBMS_STATS.GATHER_TABLE_STATS using CASCADE=>TRUE.'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.last_analyzed IS NOT NULL
   AND t.num_rows > 0
   AND t.temporary = 'N'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND ABS(t.last_analyzed - i.last_analyzed) > 1;

-- analyze 236935.1
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'CBO statistics were either gathered using deprecated ANALYZE command or derived by aggregation from lower level objects.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned index, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using FND_STATS instead.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned index, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using coe_siebel_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'When ANALYZE is used on a non-partitioned index, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using pscbo_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'When ANALYZE is used on a non-partitioned index, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using DBMS_STATS instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type = 'NORMAL'
   AND i.last_analyzed IS NOT NULL
   AND i.partitioned = 'NO'
   AND i.global_stats = 'NO';

-- derived stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'CBO statistics were either gathered using deprecated ANALYZE command or derived by aggregation from lower level objects.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'When statistics are derived by aggregation from lower level objects, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using FND_STATS instead.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'When statistics are derived by aggregation from lower level objects, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using coe_siebel_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'When statistics are derived by aggregation from lower level objects, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using pscbo_stats.sql instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'When statistics are derived by aggregation from lower level objects, the global_stats column of the index statistics receives a value of ''NO''.<br>'||CHR(10)||
           'Consider gathering statistics using DBMS_STATS instead.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type = 'NORMAL'
   AND i.last_analyzed IS NOT NULL
   AND i.partitioned = 'YES'
   AND i.global_stats = 'NO';

-- unusable indexes
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Unusable index.',
       'Unusable indexes cannot be used by the CBO. This may cause Execution Plans to change.'
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.partitioned = 'NO'
   AND i.status = 'UNUSABLE';

-- unusable index partitions
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX_PART, 'INDEX PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Index with '||v.par_count||' unusable partition(s).',
       'Unusable index partitions cannot be used by the CBO. This may cause Execution Plans to change.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
   AND p.status = 'UNUSABLE'
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.par_count > 0;

-- unusable index subpartitions
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX_PART, 'INDEX SUBPARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Index with '||v.par_count||' unusable subpartition(s).',
       'Unusable index subpartitions cannot be used by the CBO. This may cause Execution Plans to change.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_subpartitions sp
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND pt.object_owner = sp.index_owner
   AND pt.object_name = sp.index_name
   AND sp.status = 'UNUSABLE'
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.par_count > 0;

-- invisible indexes
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX, 'INDEX', SYSTIMESTAMP, i.owner||'.'||i.index_name,
       'Invisible index.',
       'Invisible indexes cannot be used by the CBO. This may cause Execution Plans to change.'
  FROM plan_table pt,
       dba_indexes i
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.visibility = 'INVISIBLE';

-- no column stats in single-column index
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_1COL_INDEX, '1-COL INDEX', SYSTIMESTAMP, i.index_name||'('||ic.column_name||')',
       'Lack of CBO statistics in column of this single-column index.',
       'To avoid CBO guessed statistics on this indexed column, gather table statistics and include this column in METHOD_OPT used.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns ic,
       dba_tab_cols tc
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND i.num_rows > 0
   AND i.owner = ic.index_owner
   AND i.index_name = ic.index_name
   AND ic.column_position = 1
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND (tc.last_analyzed IS NULL OR tc.num_distinct IS NULL OR tc.num_nulls IS NULL)
   AND NOT EXISTS (
SELECT NULL
  FROM dba_ind_columns ic2
 WHERE :health_checks = 'Y'
   AND ic2.index_owner = i.owner
   AND ic2.index_name = i.index_name
   AND ic2.column_position = 2 );

-- NDV on column > num_rows in single-column index
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_1COL_INDEX, '1-COL INDEX', SYSTIMESTAMP, i.index_name||'('||ic.column_name||')',
       'Single-column index with number of distinct values greater than number of rows by '||ROUND(100 * (tc.num_distinct - i.num_rows) / i.num_rows)||'%.',
       'There cannot be a larger number of distinct values ('||tc.num_distinct||') in a column than actual rows ('||i.num_rows||') in the index.<br>'||CHR(10)||
       'This is an inconsistency on this indexed column. Consider gathering table statistics using a large sample size.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns ic,
       dba_tab_cols tc
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND i.num_rows > 0
   AND i.owner = ic.index_owner
   AND i.index_name = ic.index_name
   AND ic.column_position = 1
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND tc.num_distinct > i.num_rows
   AND (tc.num_distinct - i.num_rows) > i.num_rows * 0.1
   AND NOT EXISTS (
SELECT NULL
  FROM dba_ind_columns ic2
 WHERE :health_checks = 'Y'
   AND ic2.index_owner = i.owner
   AND ic2.index_name = i.index_name
   AND ic2.column_position = 2 );

-- NDV is zero but column has values in single-column index
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_1COL_INDEX, '1-COL INDEX', SYSTIMESTAMP, i.index_name||'('||ic.column_name||')',
       'Single-column index with number of distinct value equal to zero in column with value.',
       'There should not be columns with value where the number of distinct values for the same column is zero.<br>'||CHR(10)||
       'Column has '||(i.num_rows - tc.num_nulls)||' rows with value while the number of distinct values for it is zero.<br>'||CHR(10)||
       'This is an inconsistency on this indexed column. Consider gathering table statistics using a large sample size.'
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns ic,
       dba_tab_cols tc
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND i.num_rows > 0
   AND i.owner = ic.index_owner
   AND i.index_name = ic.index_name
   AND ic.column_position = 1
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND tc.num_distinct = 0
   AND i.num_rows > tc.num_nulls
   AND (i.num_rows - tc.num_nulls) > i.num_rows * 0.1
   AND NOT EXISTS (
SELECT NULL
  FROM dba_ind_columns ic2
 WHERE :health_checks = 'Y'
   AND ic2.index_owner = i.owner
   AND ic2.index_name = i.index_name
   AND ic2.column_position = 2 );

-- Bugs 4495422 or 9885553 NDV <> NDK in single-column index
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_1COL_INDEX, '1-COL INDEX', SYSTIMESTAMP, i.index_name||'('||ic.column_name||')',
       'Number of distinct values ('||tc.num_distinct||') does not match number of distinct keys ('||i.distinct_keys||') by '||ROUND(100 * (i.distinct_keys - tc.num_distinct) / tc.num_distinct)||'%.',
       CASE
         WHEN tc.data_type LIKE '%CHAR%' AND tc.num_buckets > 1 THEN
           'Possible Bug <a target="MOS" href="^^bug_link.4495422">4495422</a> or <a target="MOS" href="^^bug_link.9885553">9885553</a>.<br>'||CHR(10)||
           'This is an inconsistency on this indexed column. Gather fresh statistics with no histograms or adjusting DISTCNT and DENSITY using SET_COLUMN_statistics APIs.'
         ELSE
           'This is an inconsistency on this indexed column. Gather fresh statistics or adjusting DISTCNT and DENSITY using SET_COLUMN_statistics APIs.'
         END
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns ic,
       dba_tab_cols tc
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.index_type NOT IN ('DOMAIN', 'LOB', 'FUNCTION-BASED DOMAIN')
   AND i.last_analyzed IS NOT NULL
   AND i.num_rows > 0
   AND i.owner = ic.index_owner
   AND i.index_name = ic.index_name
   AND ic.column_position = 1
   AND ic.table_owner = tc.owner
   AND ic.table_name = tc.table_name
   AND ic.column_name = tc.column_name
   AND tc.num_distinct > 0
   AND i.distinct_keys > 0
   AND i.distinct_keys > tc.num_distinct
   AND (i.distinct_keys - tc.num_distinct) > tc.num_distinct * 0.1
   AND NOT EXISTS (
SELECT NULL
  FROM dba_ind_columns ic2
 WHERE :health_checks = 'Y'
   AND ic2.index_owner = i.owner
   AND ic2.index_name = i.index_name
   AND ic2.column_position = 2 );

-- index partitions with no stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX_PART, 'INDEX PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.no_stats||' out of '||v.par_count||' partition(s) lack(s) CBO statistics.',
       CASE
         WHEN '^^is_ebs.' = 'Y' THEN
           'Consider gathering statistics using FND_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See also <a target="MOS" href="^^doc_link.156968.1">156968.1</a>.'
         WHEN '^^is_siebel.' = 'Y' THEN
           'Consider gathering statistics using coe_siebel_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.781927.1">781927.1</a>.'
         WHEN '^^is_psft.' = 'Y' THEN
           'Consider gathering statistics using pscbo_stats.sql.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.1322888.1">1322888.1</a>.'
         ELSE
           'Consider gathering statistics using DBMS_STATS.GATHER_TABLE_STATISTICS.<br>'||CHR(10)||
           'See <a target="MOS" href="^^doc_link.465787.1">465787.1</a>.'
         END
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count,
       SUM(CASE WHEN p.last_analyzed IS NULL OR p.num_rows IS NULL THEN 1 ELSE 0 END) no_stats
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND i.num_rows > 0
   AND i.last_analyzed IS NOT NULL
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.no_stats > 0;

-- index partitions where num rows = 0
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX_PART, 'INDEX PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       v.num_rows_zero||' out of '||v.par_count||' partition(s) with number of rows equal to zero according to partition''s CBO statistics.',
       'If these index partitions are not empty, consider gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       COUNT(*) par_count,
       SUM(CASE WHEN p.num_rows = 0 THEN 1 ELSE 0 END) num_rows_zero
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND i.num_rows > 0
   AND i.last_analyzed IS NOT NULL
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
 GROUP BY
       pt.object_owner,
       pt.object_name ) v
 WHERE :health_checks = 'Y'
   AND v.num_rows_zero > 0;

-- index partitions with outdated stats
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
SELECT :sql_id, :E_INDEX_PART, 'INDEX PARTITION', SYSTIMESTAMP, v.object_owner||'.'||v.object_name,
       'Index contains partition(s) with index/partition CBO statistics out of sync for up to '||TRUNC(ABS(v.idx_last_analyzed - v.par_last_analyzed))||' day(s).',
       'Index and partition statistics were gathered up to '||TRUNC(ABS(v.idx_last_analyzed - v.par_last_analyzed))||' day(s) appart, so they do not offer a consistent view to the CBO.<br>'||CHR(10)||
       'Consider re-gathering table statistics using GRANULARITY=>GLOBAL AND PARTITION.'
  FROM (
SELECT pt.object_owner,
       pt.object_name,
       i.last_analyzed idx_last_analyzed,
       COUNT(*) par_count,
       MIN(p.last_analyzed) par_last_analyzed
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions p
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND i.num_rows > 0
   AND i.last_analyzed IS NOT NULL
   AND pt.object_owner = p.index_owner
   AND pt.object_name = p.index_name
 GROUP BY
       pt.object_owner,
       pt.object_name,
       i.last_analyzed ) v
 WHERE :health_checks = 'Y'
   AND ABS(v.idx_last_analyzed - v.par_last_analyzed) > 1;

-- table and index partitions do not match 14013094
INSERT INTO plan_table (STATEMENT_ID, id, operation, object_alias, other_tag, remarks, projection)
WITH idx AS (
SELECT /*+ MATERIALIZE */
       i.owner index_owner, i.index_name, i.table_owner, i.table_name, COUNT(*) index_partitions
  FROM plan_table pt,
       dba_indexes i,
       dba_ind_partitions ip
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'INDEX'
   AND pt.object_owner = i.owner
   AND pt.object_name = i.index_name
   AND i.partitioned = 'YES'
   AND pt.object_owner = ip.index_owner
   AND pt.object_name = ip.index_name
 GROUP BY
       i.owner, i.index_name, i.table_owner, i.table_name
), tbl AS (
SELECT /*+ MATERIALIZE */
       t.owner table_owner, t.table_name, COUNT(*) table_partitions
  FROM plan_table pt,
       dba_tables t,
       dba_tab_partitions tp
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND pt.object_type = 'TABLE'
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND t.partitioned = 'YES'
   AND pt.object_owner = tp.table_owner
   AND pt.object_name = tp.table_name
 GROUP BY
       t.owner, t.table_name
), idx_tbl AS (
SELECT /*+ MATERIALIZE */
       idx.index_owner, idx.index_name, idx.table_owner, idx.table_name, idx.index_partitions partitions
  FROM idx, tbl
 WHERE idx.table_owner = tbl.table_owner
   AND idx.table_name = tbl.table_name
   AND idx.index_partitions = tbl.table_partitions
)
--SELECT idx_tbl.index_owner, idx_tbl.index_name, idx_tbl.table_owner, idx_tbl.table_name, COUNT(*)
SELECT :sql_id, :E_INDEX_PART, 'INDEX PARTITION', SYSTIMESTAMP, idx_tbl.index_owner||'.'||idx_tbl.index_name,
       'Index contains '||COUNT(*)||' partition(s) where the partition name does not match to corresponding Table partition(s) name.',
       'Review Table and Index partition names and positions, then try to rule out Bug <a target="MOS" href="^^bug_link.14013094">14013094</a>.'
  FROM idx_tbl,
       dba_tab_statistics tps,
       dba_ind_statistics ips
 WHERE tps.owner = idx_tbl.table_owner
   AND tps.table_name = idx_tbl.table_name
   AND tps.object_type = 'PARTITION'
   AND ips.owner = idx_tbl.index_owner
   AND ips.index_name = idx_tbl.index_name
   AND ips.object_type = 'PARTITION'
   AND tps.partition_position = ips.partition_position
   AND tps.partition_name != ips.partition_name
 GROUP BY
       idx_tbl.index_owner, idx_tbl.index_name, idx_tbl.table_owner, idx_tbl.table_name;

-- setup to produce reports
SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF;

/**************************************************************************************************/

COL files_prefix NEW_V files_prefix FOR A40;
--SELECT '^^script._^^database_name_short._^^host_name_short._^^rdbms_version._^^sql_id._^^time_stamp.' files_prefix FROM DUAL
SELECT '^^script._^^time_stamp._^^sql_id.' files_prefix FROM DUAL;
COL sqldx_prefix NEW_V sqldx_prefix FOR A40;
SELECT '^^files_prefix._8_sqldx' sqldx_prefix FROM DUAL;

rem select STATEMENT_ID, object_type, object_owner, object_name from plan_table;
rem pause;

/**************************************************************************************************
 *
 * health-check report
 *
 **************************************************************************************************/

/* -------------------------
 *
 * heading
 *
 * ------------------------- */
SPO ^^files_prefix._1_health_check.html;

PRO <html>
PRO <!-- $Header: pdbcs/no_ship_src/service/scripts/ops/adb_sql/diagsql/sqlhc.sql /main/3 2022/03/07 01:33:04 scharala Exp $ -->
PRO <!-- Copyright (c) 2000-2012, Oracle Corporation. All rights reserved. -->
PRO <!-- Author: carlos.sierra@oracle.com -->
PRO
PRO <head>
PRO <title>^^files_prefix._1_health_check.html</title>
PRO

PRO <style type="text/css">
PRO body {font:10pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
PRO a {font-weight:bold; color:#663300;}
PRO pre {font:8pt Monaco,"Courier New",Courier,monospace;} /* for code */
PRO h1 {font-size:16pt; font-weight:bold; color:#336699;}
PRO h2 {font-size:14pt; font-weight:bold; color:#336699;}
PRO h3 {font-size:12pt; font-weight:bold; color:#336699;}
PRO li {font-size:10pt; font-weight:bold; color:#336699; padding:0.1em 0 0 0;}
PRO table {font-size:8pt; color:black; background:white;}
PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td {text-align:left; background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td.c {text-align:center;} /* center */
PRO td.l {text-align:left;} /* left (default) */
PRO td.r {text-align:right;} /* right */
PRO font.n {font-size:8pt; font-style:italic; color:#336699;} /* table footnote in blue */
PRO font.f {font-size:8pt; color:#999999;} /* footnote in gray */
PRO td.red {font-weight:bold; color:#336699;}
PRO #summary1 {font-weight: bold; font-size: 16pt; color:#336699;}
PRO #summary2 {font-weight: bold; font-size: 14pt; color:#336699;}
PRO #summary3 {font-weight: bold; font-size: 12pt; color:#336699;}
PRO summary:hover {background-color: #FFFF99;}
PRO .button  {cursor: pointer;}
PRO .button1 {border-radius: 8px; background-color: #FFFF99; color: black;}
PRO .button1:hover {background-color: #4CAF50;color: white;}
PRO </style>
PRO

PRO </head>
PRO <body>
PRO <h1><a target="MOS" href="^^doc_link.^^mos_doc.">^^mos_doc.</a> ^^method.
PRO ^^doc_ver. Report: ^^files_prefix._1_health_check.html</h1>
PRO

PRO <pre>
PRO License    : ^^input_license.
PRO Input      : ^^input_parameter.
PRO SIGNATURE  : ^^signature.
PRO SIGNATUREF : ^^signaturef.
PRO RDBMS      : ^^rdbms_version.
PRO Platform   : ^^platform.
PRO Database   : ^^database_name_short.
PRO DBID       : ^^dbid.
PRO Host       : ^^host_name_short.
PRO Instance   : ^^instance_number.
PRO CPU_Count  : ^^sys_cpu.
PRO Num CPUs   : ^^num_cpus.
PRO Num Cores  : ^^num_cores.
PRO Num Sockets: ^^num_sockets.
PRO Block Size : ^^sys_db_block_size.
PRO OFE        : ^^sys_ofe.
PRO DYN_SAMP   : ^^sys_ds.
PRO EBS        : "^^is_ebs."
PRO SIEBEL     : "^^is_siebel."
PRO PSFT       : "^^is_psft."
PRO Date       : ^^time_stamp2.
PRO User       : ^^sessionuser.
PRO </pre><!--Pushkar-->
PRO <ul>
PRO <li><a href="#obs">Observations</a></li>
PRO <li><a href="#text">SQL Text</a></li>
PRO <li><a href="#tbl_sum">Tables Summary</a></li>
PRO <li><a href="#idx_sum">Indexes Summary</a></li>
PRO </ul>

/* -------------------------
 *
 * observations
 *
 * ------------------------- */
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

PRO <a name="obs"></a><details open><br/><summary id="summary2">Observations</summary>
PRO
PRO Observations below are the outcome of several heath-checks on the schema objects accessed by your SQL and its environment.
PRO Review them carefully and take action when appropriate. Then re-execute your SQL and generate this report again.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Type</th>
PRO <th>Name</th>
PRO <th>Observation</th>
PRO <th>Details</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.object_type||'</td>'||CHR(10)||
       '<td>'||v.object_name||'</td>'||CHR(10)||
       '<td>'||v.observation||'</td>'||CHR(10)||
       '<td>'||v.more||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       operation object_type,
       other_tag object_name,
       remarks observation,
       projection more
  FROM plan_table
 WHERE :health_checks = 'Y'
   AND STATEMENT_ID = :sql_id
   AND id IS NOT NULL
   AND operation IS NOT NULL
   AND object_alias IS NOT NULL
   AND other_tag IS NOT NULL
   AND remarks IS NOT NULL
 ORDER BY
       id,
       operation,
       other_tag,
       object_alias ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Type</th>
PRO <th>Name</th>
PRO <th>Observation</th>
PRO <th>Details</th>
PRO </tr>
PRO
PRO </table>
ROLLBACK TO save_point_1;
select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

-- nothing is updated to the db. transaction ends here


/* -------------------------
 *
 * sql_text
 *
 * ------------------------- */
PRO <script language="JavaScript" type="text/JavaScript">
PRO function openInNewWindow(url)
PRO {
PRO   window.open(url,"_blank");
PRO }
PRO </script>
PRO <a name="text"></a><details open><br/><summary id="summary2">SQL Text</summary>
PRO <FORM><BUTTON class="button button1" onclick="openInNewWindow(&quot;https://apex.oraclecorp.com/pls/apex/f?p=28906&quot;)">Analyze SQL Text via PSR Tool [use Upload SQL Button]</BUTTON></FORM> 
PRO
PRO <pre>

DECLARE
  l_sql_text CLOB := :sql_text;
  l_pos NUMBER;
BEGIN
  WHILE NVL(LENGTH(l_sql_text), 0) > 0
  LOOP
    l_pos := INSTR(l_sql_text, CHR(10));
    IF l_pos > 0 THEN
      DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_text, 1, l_pos - 1));
      l_sql_text := SUBSTR(l_sql_text, l_pos + 1);
    ELSE
      DBMS_OUTPUT.PUT_LINE(l_sql_text);
      l_sql_text := NULL;
    END IF;
  END LOOP;
END;
/

PRO </pre>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * Uday.PSR.v6
 * inserting tables used in the plans into PLAN_TABLE to improve performance 
 * - with clause is repeated in all the diagnostic SQLs.
 * - slow performance, especially 'table columns'
 *
 * ------------------------- */

INSERT INTO plan_table(STATEMENT_ID, object_owner, object_type, object_name, cardinality, cost, optimizer, object_alias, operation, options, io_cost, bytes)
  WITH  
    object AS (
       SELECT /*+ MATERIALIZE */
              object_owner owner, object_name name, object_type
         FROM gv$sql_plan
        WHERE inst_id IN (SELECT inst_id FROM gv$instance)
          AND sql_id = :sql_id
          AND object_owner IS NOT NULL
          AND object_name IS NOT NULL
          AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
        UNION
       SELECT object_owner owner, object_name name, object_type
         FROM dba_hist_sql_plan
        WHERE :license IN ('T', 'D')
          AND dbid = ^^dbid.
          AND sql_id = :sql_id
          AND object_owner IS NOT NULL
          AND object_name IS NOT NULL
          AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
    )
    , plan_tables AS (
         SELECT /*+ MATERIALIZE */
                'TABLE' object_type, o.owner object_owner, o.name object_name
           FROM object o
          WHERE (o.object_type like 'TABLE%'
                 OR
                 o.object_type LIKE 'MAT_VIEW')
          UNION
         SELECT /*+ leading (o) */ 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
           FROM dba_indexes i,
                object o
          WHERE o.object_type like 'INDEX%'  --Uday.v6
            AND i.owner = o.owner
            AND i.index_name = o.name
          UNION
         SELECT /*+ leading (o) */ 'TABLE' object_type, t.owner object_owner, t.table_name object_name
           FROM dba_tables t,
                object o
          WHERE t.owner = o.owner
            AND t.table_name = o.name
            AND o.object_type IS NULL /* PUSHKAR 10.8: this helps in insert statement analysis */
    )
         -- (object_owner, object type,    object_name,  cardinality, cost,         
  -- psrv9: added distinct. Some scenarios getting duplicate tables. 
  select distinct :sql_id, t.owner, pt.object_type, t.table_name, t.num_rows,  t.sample_size, 
         -- OPTIMIZER
         TO_CHAR(t.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed, 
         -- object_alias, operation,   options, io_cost,  bytes
         temporary,       partitioned, degree,  t.blocks, t.avg_row_len
    from plan_tables pt, dba_tables t
   where t.table_name = pt.object_name
     and t.owner = pt.object_owner
  ;

/* -------------------------
 *
 * tables summary
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: tables summary - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="tbl_sum"></a><details open><br/><summary id="summary2">Tables Summary</summary>
PRO
PRO Values below have two purposes:<br>
PRO 1. Provide a quick view of the state of Table level CBO statistics, as well as their indexes and columns.<br>
PRO 2. More easily allow the comparison of two systems that are believed to be similar.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Num Rows</th>
PRO <th>Table<br>Sample Size</th>
PRO <th>Last Analyzed</th>
PRO <th>Indexes</th>
PRO <th>Avg Index<br>Sample Size</th>
PRO <th>Table<br>Columns</th>
PRO <th>Columns with<br>Histogram</th>
PRO <th>Avg Column<br>Sample Size</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.table_name||'</td>'||CHR(10)||
       '<td>'||v.owner||'</td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.table_sample_size||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.indexes||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_index_sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.columns||'</td>'||CHR(10)||
       '<td class="r">'||v.columns_with_histograms||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_column_sample_size||'</td>'||CHR(10)||
       '</tr>'
  FROM (
--UdayRemoved.PSR.v6 WITH object AS (
--UdayRemoved.PSR.v6 SELECT /*+ MATERIALIZE */
--UdayRemoved.PSR.v6        object_owner owner, object_name name, object_type
--UdayRemoved.PSR.v6   FROM gv$sql_plan
--UdayRemoved.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--UdayRemoved.PSR.v6    AND sql_id = :sql_id
--UdayRemoved.PSR.v6    AND object_owner IS NOT NULL
--UdayRemoved.PSR.v6    AND object_name IS NOT NULL
--UdayRemoved.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--UdayRemoved.PSR.v6  UNION
--UdayRemoved.PSR.v6 SELECT object_owner owner, object_name name, object_type
--UdayRemoved.PSR.v6   FROM dba_hist_sql_plan
--UdayRemoved.PSR.v6  WHERE :license IN ('T', 'D')
--UdayRemoved.PSR.v6    AND dbid = ^^dbid.
--UdayRemoved.PSR.v6    AND sql_id = :sql_id
--UdayRemoved.PSR.v6    AND object_owner IS NOT NULL
--UdayRemoved.PSR.v6    AND object_name IS NOT NULL
--UdayRemoved.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--UdayRemoved.PSR.v6  ), plan_tables AS (
--UdayRemoved.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--UdayRemoved.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--UdayRemoved.PSR.v6 --UdayRemoved.v6   FROM dba_tab_statistics t, -- include fixed objects
--UdayRemoved.PSR.v6 --UdayRemoved.v6        object o
--UdayRemoved.PSR.v6 --UdayRemoved.v6  WHERE t.owner = o.owner
--UdayRemoved.PSR.v6 --UdayRemoved.v6    AND t.table_name = o.name
--UdayRemoved.PSR.v6  SELECT /*+ MATERIALIZE */
--UdayRemoved.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--UdayRemoved.PSR.v6    FROM object o
--UdayRemoved.PSR.v6   WHERE o.object_type like 'TABLE%'
--UdayRemoved.PSR.v6   UNION
--UdayRemoved.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--UdayRemoved.PSR.v6    FROM dba_indexes i,
--UdayRemoved.PSR.v6         object o
--UdayRemoved.PSR.v6   WHERE o.object_type like 'INDEX%'  -- Uday.v6
--UdayRemoved.PSR.v6     AND i.owner = o.owner
--UdayRemoved.PSR.v6     AND i.index_name = o.name
--UdayRemoved.PSR.v6 ), 
WITH t AS (
SELECT /*+ MATERIALIZE */
       pt.object_owner owner,
       pt.object_name table_name,
       t.num_rows,
       t.sample_size table_sample_size,
       TO_CHAR(t.last_analyzed, 'DD-MON-YY HH24:MI:SS') last_analyzed,
       COUNT(*) indexes,
       ROUND(AVG(i.sample_size)) avg_index_sample_size
  FROM plan_table pt,
       dba_tables t,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = t.owner
   AND pt.object_name = t.table_name
   AND pt.object_owner = i.table_owner(+)
   AND pt.object_name = i.table_name(+)
 GROUP BY
       pt.object_owner,
       pt.object_name,
       t.num_rows,
       t.sample_size,
       t.last_analyzed )
SELECT /*+ MATERIALIZE */
       t.table_name,
       t.owner,
       t.num_rows,
       t.table_sample_size,
       t.last_analyzed,
       t.indexes,
       t.avg_index_sample_size,
       COUNT(*) columns,
       SUM(CASE WHEN NVL(c.histogram, 'NONE') = 'NONE' THEN 0 ELSE 1 END) columns_with_histograms,
       ROUND(AVG(c.sample_size)) avg_column_sample_size
  FROM t,
       dba_tab_cols c
 WHERE t.owner = c.owner
   AND t.table_name = c.table_name
 GROUP BY
       t.table_name,
       t.owner,
       t.num_rows,
       t.table_sample_size,
       t.last_analyzed,
       t.indexes,
       t.avg_index_sample_size
 ORDER BY
       t.table_name,
       t.owner
)v;

--
-- last t & c join causing performance issue
--
--udayRemoved.v6 c AS (
--udayRemoved.v6 SELECT /*+ MATERIALIZE */
--udayRemoved.v6        pt.object_owner owner,
--udayRemoved.v6        pt.object_name table_name,
--udayRemoved.v6        COUNT(*) columns,
--udayRemoved.v6        SUM(CASE WHEN NVL(c.histogram, 'NONE') = 'NONE' THEN 0 ELSE 1 END) columns_with_histograms,
--udayRemoved.v6        ROUND(AVG(c.sample_size)) avg_column_sample_size
--udayRemoved.v6   FROM plan_tables pt,
--udayRemoved.v6        dba_tab_cols c
--udayRemoved.v6  WHERE pt.object_type = 'TABLE'
--udayRemoved.v6    AND pt.object_owner = c.owner
--udayRemoved.v6    AND pt.object_name = c.table_name
--udayRemoved.v6  GROUP BY
--udayRemoved.v6        pt.object_owner,
--udayRemoved.v6        pt.object_name )
--udayRemoved.v6 SELECT /*+ NO_MERGE */
--udayRemoved.v6        t.table_name,
--udayRemoved.v6        t.owner,
--udayRemoved.v6        t.num_rows,
--udayRemoved.v6        t.table_sample_size,
--udayRemoved.v6        t.last_analyzed,
--udayRemoved.v6        t.indexes,
--udayRemoved.v6        t.avg_index_sample_size,
--udayRemoved.v6        c.columns,
--udayRemoved.v6        c.columns_with_histograms,
--udayRemoved.v6        c.avg_column_sample_size
--udayRemoved.v6   FROM t, c
--udayRemoved.v6  WHERE t.table_name = c.table_name
--udayRemoved.v6    AND t.owner = c.owner
--udayRemoved.v6  ORDER BY
--udayRemoved.v6        t.table_name,
--udayRemoved.v6        t.owner ) v

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Num Rows</th>
PRO <th>Table<br>Sample Size</th>
PRO <th>Last Analyzed</th>
PRO <th>Indexes</th>
PRO <th>Avg Index<br>Sample Size</th>
PRO <th>Table<br>Columns</th>
PRO <th>Columns with<br>Histogram</th>
PRO <th>Avg Column<br>Sample Size</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * indexes summary
 * Uday:PSR: added status column
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: indexes summary - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="idx_sum"></a><details open><br/><summary id="summary2">Indexes Summary</summary>
PRO
PRO Values below have two purposes:<br>
PRO 1. Provide a quick view of the state of Index level CBO statistics, as well as their columns.<br>
PRO 2. More easily allow the comparison of two systems that are believed to be similar.<br>
PRO This section includes data captured by AWR. If this is a stand-by read-only database then the AWR information below is from the Primary database.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Table<br>Owner</th>
PRO <th>Index Name</th>
PRO <th>Index<br>Owner</th>
PRO <th>Index<br>Status</th>
PRO <th>In MEM<br>Plan</th>
PRO <th>In AWR<br>Plan</th>
PRO <th>Num Rows</th>
PRO <th>Index<br>Sample Size</th>
PRO <th>Last Analyzed</th>
PRO <th>Index<br>Columns</th>
PRO <th>Columns with<br>Histogram</th>
PRO <th>Avg Column<br>Sample Size</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.table_name||'</td>'||CHR(10)||
       '<td>'||v.table_owner||'</td>'||CHR(10)||
       '<td>'||v.index_name||'</td>'||CHR(10)||
       '<td>'||v.index_owner||'</td>'||CHR(10)||
       '<td>'||v.status||'</td>'||CHR(10)||
       '<td class="c">'||v.in_mem_plan||'</td>'||CHR(10)||
       '<td class="c">'||v.in_awr_plan||'</td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.table_sample_size||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.columns||'</td>'||CHR(10)||
       '<td class="r">'||v.columns_with_histograms||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_column_sample_size||'</td>'||CHR(10)||
       '</tr>'
  FROM (
--Uday.PSR.v6 WITH object AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM gv$sql_plan
--Uday.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM dba_hist_sql_plan
--Uday.PSR.v6  WHERE :license IN ('T', 'D')
--Uday.PSR.v6    AND dbid = ^^dbid.
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  ), plan_tables AS (
--Uday.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--Uday.PSR.v6 --UdayRemoved.v6   FROM dba_tab_statistics t, -- include fixed objects
--Uday.PSR.v6 --UdayRemoved.v6        object o
--Uday.PSR.v6 --UdayRemoved.v6  WHERE t.owner = o.owner
--Uday.PSR.v6 --UdayRemoved.v6    AND t.table_name = o.name
--Uday.PSR.v6  SELECT /*+ MATERIALIZE */
--Uday.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--Uday.PSR.v6    FROM object o
--Uday.PSR.v6   WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6   UNION
--Uday.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6    FROM dba_indexes i,
--Uday.PSR.v6         object o
--Uday.PSR.v6   WHERE o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6     AND i.owner = o.owner
--Uday.PSR.v6     AND i.index_name = o.name
--Uday.PSR.v6 ), 
WITH i AS (
SELECT /*+ MATERIALIZE */
       pt.object_owner table_owner,
       pt.object_name table_name,
       i.owner index_owner,
       i.status,
       i.index_name,
       i.num_rows,
       i.sample_size table_sample_size,
       TO_CHAR(i.last_analyzed, 'DD-MON-YY HH24:MI:SS') last_analyzed,
       (SELECT 'YES'
          FROM gv$sql_plan p1
         WHERE p1.inst_id IN (SELECT inst_id FROM gv$instance)
           AND p1.sql_id = :sql_id
           AND (p1.object_type LIKE '%INDEX%' OR p1.operation LIKE '%INDEX%')
           AND i.owner = p1.object_owner
           AND i.index_name = p1.object_name
           AND ROWNUM = 1) in_mem_plan,
       (SELECT 'YES'
          FROM dba_hist_sql_plan p2
         WHERE :license IN ('T', 'D')
           AND p2.dbid = ^^dbid.
           AND p2.sql_id = :sql_id
           AND (p2.object_type LIKE '%INDEX%' OR p2.operation LIKE '%INDEX%')
           AND i.owner = p2.object_owner
           AND i.index_name = p2.object_name
           AND ROWNUM = 1) in_awr_plan
  FROM plan_table pt,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name ),
c AS (
SELECT /*+ MATERIALIZE */
       ic.index_owner,
       ic.index_name,
       COUNT(*) columns,
       SUM(CASE WHEN NVL(c.histogram, 'NONE') = 'NONE' THEN 0 ELSE 1 END) columns_with_histograms,
       ROUND(AVG(c.sample_size)) avg_column_sample_size
  FROM plan_table pt,
       dba_ind_columns ic,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = ic.table_owner
   AND pt.object_name = ic.table_name
   AND ic.table_owner = c.owner
   AND ic.table_name = c.table_name
   AND ic.column_name = c.column_name
 GROUP BY
       ic.index_owner,
       ic.index_name )
SELECT /*+ NO_MERGE */
       i.table_name,
       i.table_owner,
       i.index_name,
       i.index_owner,
       i.status,
       i.num_rows,
       i.table_sample_size,
       i.last_analyzed,
       i.in_mem_plan,
       i.in_awr_plan,
       c.columns,
       c.columns_with_histograms,
       c.avg_column_sample_size
  FROM i, c
 WHERE i.index_name = c.index_name
   AND i.index_owner = c.index_owner
 ORDER BY
       i.table_name,
       i.table_owner,
       i.index_name,
       i.index_owner ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Table<br>Owner</th>
PRO <th>Index Name</th>
PRO <th>Index<br>Owner</th>
PRO <th>Index<br>Status</th>
PRO <th>In MEM<br>Plan</th>
PRO <th>In AWR<br>Plan</th>
PRO <th>Num Rows</th>
PRO <th>Index<br>Sample Size</th>
PRO <th>Last Analyzed</th>
PRO <th>Index<br>Columns</th>
PRO <th>Columns with<br>Histogram</th>
PRO <th>Avg Column<br>Sample Size</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * footer
 *
 * ------------------------- */
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <hr size="3">
PRO <font class="f">^^mos_doc. ^^method. ^^doc_ver. ^^time_stamp2. tool_date: ^^doc_date. executed by: ^^sessionuser. </font>
PRO </body>
PRO </html>

SPO OFF;

/**************************************************************************************************/

SPO sqlhc.log append
PRO SQL Shared Cursor related SQLs generation
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
SPO OFF;
/* -------------------------
 *
 * gv$sql_shared_cursor cursor_sum
 * Uday: modified to use UNPIVOT to improve performance
 *
 * ------------------------- */
--uday SELECT (CASE WHEN ROWNUM = 1 THEN 'WITH sc AS (SELECT /*+ MATERIALIZE */ /* gv$sql_shared_cursor cursor_sum */ * FROM gv$sql_shared_cursor WHERE :shared_cursor = ''Y'' AND sql_id = ''^^sql_id.'')' ELSE 'UNION ALL' END)||CHR(10)||
--uday        'SELECT '''||v.column_name||''' reason, inst_id, COUNT(*) cursors FROM sc WHERE '||v.column_name||' = ''Y'' GROUP BY inst_id' line
--uday   FROM (
--uday SELECT /*+ NO_MERGE */
--uday        column_name
--uday   FROM dba_tab_cols
--uday  WHERE :shared_cursor = 'Y'
--uday    AND owner = 'SYS'
--uday    AND table_name = 'GV_$SQL_SHARED_CURSOR'
--uday    AND data_type = 'VARCHAR2'
--uday    AND data_length = 1
--uday  ORDER BY
--uday        column_name ) v
--
--
SPO sql_shared_cursor_sum_^^sql_id..sql;
PRO SELECT /* ^^script..sql Cursor Sharing as per Reason */
PRO        CHR(10)||'<tr>'||CHR(10)||
PRO        '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
PRO        '<td>'||v2.reason||'</td>'||CHR(10)||
PRO        '<td class="c">'||v2.inst_id||'</td>'||CHR(10)||
PRO        '<td class="r">'||v2.cursors||'</td>'||CHR(10)||
PRO        '</tr>'
PRO   FROM (
select 'WITH v0 AS (' || chr(10) ||
       '   SELECT * ' || chr(10) ||
       q'[     FROM   gv$sql_shared_cursor where :shared_cursor = 'Y' AND sql_id = '^^sql_id.']' || chr(10) ||
       ')' || chr(10) ||
       ', v1 as (' || chr(10) ||
       '   SELECT inst_id, reason_type , result' || chr(10) ||
       '     FROM   v0' || chr(10) ||
       '   unpivot (result FOR reason_type IN' || chr(10) ||
       '             (' || chr(10) ||
       '               ' || 
       listagg(column_name, ', ') within group(order by column_name) || chr(10) || 
       '             )'|| chr(10) || 
       '           )'|| chr(10) || 
       q'[     where result='Y']'|| chr(10) || 
       ')'|| chr(10) || 
       'select reason_type as reason, inst_id, count(*) cursors '|| chr(10) || 
       '  from v1'|| chr(10) || 
       ' group by inst_id, reason_type'|| chr(10) || 
       ' order by inst_id, reason_type) v2;'       
  from dba_tab_columns 
 where owner = 'SYS'
   AND table_name = 'GV_$SQL_SHARED_CURSOR'
   AND data_type = 'VARCHAR2'
   AND data_length = 1
 group by table_name
;


SELECT 'SELECT ''reason'' reason, 0 inst_id, 0 cursors FROM DUAL WHERE 1 = 0' FROM dual WHERE :shared_cursor <> 'Y';
-- PRO ORDER BY reason, inst_id ) v2;;
SPO OFF;

SPO sqlhc.log append
PRO SQL Shared Cursor related SQLs generation: sql_shared_cursor_sum*.sql created
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
SPO OFF;
/* -------------------------
 *
 * gv$sql_shared_cursor cursor_col
 *
 * ------------------------- */
SPO sql_shared_cursor_col_^^sql_id..sql
select 'WITH v1 AS (' || chr(10) ||
       '   SELECT * ' || chr(10) ||
       q'[     FROM   gv$sql_shared_cursor where :shared_cursor = 'Y' AND sql_id = '^^sql_id.']' || chr(10) ||
       ')' || chr(10) ||
       ', v2 as (' || chr(10) ||
       '   SELECT inst_id, reason_type , result' || chr(10) ||
       '     FROM   v1' || chr(10) ||
       '   unpivot (result FOR reason_type IN' || chr(10) ||
       '             (' || chr(10) ||
       '               ' ||
       listagg(column_name, ', ') within group(order by column_name) || chr(10) ||
       '             )'|| chr(10) ||
       '           )'|| chr(10) ||
       q'[     where result='Y']'|| chr(10) ||
       ')'|| chr(10) ||
       q'[select distinct ', RPAD(' || reason_type || ', 30) "' || reason_type || '"' COLUMN_NAME]' || chr(10) ||
       '  from v2'
  from dba_tab_columns
 where owner = 'SYS'
   AND table_name = 'GV_$SQL_SHARED_CURSOR'
   AND data_type = 'VARCHAR2'
   AND data_length = 1
 group by table_name
;

--uday SELECT (CASE WHEN ROWNUM = 1 THEN 'WITH sc AS (SELECT /*+ MATERIALIZE */ /* gv$sql_shared_cursor cursor_col */ * FROM gv$sql_shared_cursor WHERE :shared_cursor = ''Y'' AND sql_id = ''^^sql_id.'')' ELSE 'UNION ALL' END)||CHR(10)||
--uday        'SELECT '', RPAD('||LOWER(v.column_name)||', 30) "'||v.column_name||'"'' column_name FROM sc WHERE '||v.column_name||' = ''Y'' AND ROWNUM = 1' line
--uday   FROM (
--uday SELECT /*+ NO_MERGE */
--uday        column_name
--uday   FROM dba_tab_cols
--uday  WHERE :shared_cursor = 'Y'
--uday    AND owner = 'SYS'
--uday    AND table_name = 'GV_$SQL_SHARED_CURSOR'
--uday    AND data_type = 'VARCHAR2'
--uday    AND data_length = 1
--uday  ORDER BY
--uday        column_name ) v
SELECT 'SELECT * FROM DUAL WHERE 1 = 0' FROM dual WHERE :shared_cursor <> 'Y';
PRO ;;
SPO OFF;

SPO sqlhc.log append
PRO SQL Shared Cursor related SQLs generation: sql_shared_cursor_col*.sql created
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
SPO OFF;
/* -------------------------
 *
 * gv$sql_shared_cursor cursor_cur
 *
 * ------------------------- */
SPO sql_shared_cursor_cur_^^sql_id..sql
PRO SELECT /* ^^script..sql Cursor Sharing List */
PRO ROWNUM "#", v.* FROM (
PRO SELECT /*+ NO_MERGE */
PRO inst_id
PRO , child_number
@sql_shared_cursor_col_^^sql_id..sql
SELECT ', reason' FROM DUAL WHERE '^^rdbms_version.' >= '11.2%';
PRO FROM gv$sql_shared_cursor
PRO WHERE :shared_cursor = 'Y'
PRO AND sql_id = '^^sql_id.'
PRO ORDER BY 1, 2) v;;
SPO OFF;

SPO sqlhc.log append
PRO SQL Shared Cursor related SQLs generation: sql_shared_cursor_cur*.sql created
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
SPO OFF;
/**************************************************************************************************/

/**************************************************************************************************
 *
 * diagnostics report
 *
 **************************************************************************************************/

/* -------------------------
 *
 * heading
 *
 * ------------------------- */
rem select STATEMENT_ID, object_type, object_owner, object_name from plan_table;
rem pause;
SPO ^^files_prefix._2_diagnostics.html;

PRO <html>
PRO <!-- $Header: pdbcs/no_ship_src/service/scripts/ops/adb_sql/diagsql/sqlhc.sql /main/3 2022/03/07 01:33:04 scharala Exp $ -->
PRO <!-- Copyright (c) 2000-2012, Oracle Corporation. All rights reserved. -->
PRO <!-- Author: carlos.sierra@oracle.com -->
PRO
PRO <head>
PRO <title>^^files_prefix._2_diagnostics.html</title>
PRO

PRO <style type="text/css">
PRO body {font:10pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
PRO a {font-weight:bold; color:#663300;}
PRO pre {font:8pt Monaco,"Courier New",Courier,monospace;} /* for code */
PRO h1 {font-size:16pt; font-weight:bold; color:#336699;}
PRO h2 {font-size:14pt; font-weight:bold; color:#336699;}
PRO h3 {font-size:12pt; font-weight:bold; color:#336699;}
PRO h4 {font-size:12pt; font-weight:bold; color:#336699;}
PRO li {font-size:10pt; font-weight:bold; color:#336699; padding:0.1em 0 0 0;}
PRO table {font-size:8pt; color:black; background:white;}
PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO tr.bg {background:#B3F3B3;}
rem PRO td {text-align:left; background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td {text-align:left; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td.c {text-align:center;} /* center */
PRO td.l {text-align:left;} /* left (default) */
PRO td.r {text-align:right;} /* right */
PRO td.bg_c{text-align:center;background:#DCEEB0;}
PRO font.n {font-size:8pt; font-style:italic; color:#336699;} /* table footnote in blue */
PRO font.f {font-size:8pt; color:#999999;} /* footnote in gray */
PRO #summary1 {font-weight: bold; font-size: 16pt; color:#336699;}
PRO #summary2 {font-weight: bold; font-size: 14pt; color:#336699;}
PRO #summary3 {font-weight: bold; font-size: 12pt; color:#336699;}
PRO summary:hover {background-color: #FFFF99;}
PRO .button  {cursor: pointer;}
PRO .button1 {border-radius: 8px; background-color: #FFFF99; color: black;}
PRO .button1:hover {background-color: #4CAF50;color: white;}
PRO </style>
PRO

PRO </head>
PRO <body>
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff"><a href='#/' id='expAll' class='exp'>Collapse All</a></td></tr></table>
PRO <script>
PRO // Reference the toggle link
PRO var xa = document.getElementById('expAll')
PRO
PRO // Register link on click event
PRO xa.addEventListener('click', function(e) {
PRO
PRO e.target.classList.toggle('exp')
PRO e.target.classList.toggle('col')
PRO 
PRO // Collect all <details> into a NodeList
PRO var details = document.querySelectorAll('details')
PRO 
PRO Array.from(details).forEach(function(obj, idx) {
PRO
PRO if (e.target.classList.contains('exp')) {
PRO   obj.open = true
PRO   xa.innerHTML = "Collapse All"
PRO // Otherwise make it false
PRO } else {
PRO   obj.open = false
PRO   xa.innerHTML = "Expand All"
PRO }
PRO 
PRO })
PRO }, false)
PRO </script>

PRO <h1><a target="MOS" href="^^doc_link.^^mos_doc.">^^mos_doc.</a> ^^method.
PRO ^^doc_ver. Report: ^^files_prefix._2_diagnostics.html</h1>
PRO

/* psrv9
PRO <pre>
PRO License    : ^^input_license.
PRO Input      : ^^input_parameter.
PRO SIGNATURE  : ^^signature.
PRO SIGNATUREF : ^^signaturef.
PRO RDBMS      : ^^rdbms_version.
PRO Platform   : ^^platform.
PRO Database   : ^^database_name_short.
PRO DBID       : ^^dbid.
PRO Host       : ^^host_name_short.
PRO Instance   : ^^instance_number.
PRO CPU_Count  : ^^sys_cpu.
PRO Num CPUs   : ^^num_cpus.
PRO Num Cores  : ^^num_cores.
PRO Num Sockets: ^^num_sockets.
PRO Block Size : ^^sys_db_block_size.
PRO OFE        : ^^sys_ofe.
PRO DYN_SAMP   : ^^sys_ds.
PRO EBS        : "^^is_ebs."
PRO SIEBEL     : "^^is_siebel."
PRO PSFT       : "^^is_psft."
PRO Date       : ^^time_stamp2.
PRO User       : ^^sessionuser.
PRO </pre>

PRO <ul>
PRO <li><a href="#text">SQL Text</a></li>
PRO <li><a href="#spm">SQL Plan Baselines (DBA_SQL_PLAN_BASELINES)</a></li>
PRO <li><a href="#prof">SQL Profiles (DBA_SQL_PROFILES)</a></li>
PRO <li><a href="#patch">SQL Patches (DBA_SQL_PATCHES)</a></li>
PRO <li><a href="#share_r">Cursor Sharing and Reason</a></li>
PRO <li><a href="#share_l">Cursor Sharing List</a></li>
PRO <li><a href="#mem_plans_sum">Current Plans Summary (GV$SQL)</a></li>
PRO <li><a href="#mem_stats">Current SQL Statistics (GV$SQL)</a></li>
PRO <li><a href="#awr_plans_sum">Historical Plans Summary (DBA_HIST_SQLSTAT)</a></li>
PRO <li><a href="#awr_stats_d">Historical SQL Statistics - Delta (DBA_HIST_SQLSTAT)</a></li>
PRO <li><a href="#awr_stats_t">Historical SQL Statistics - Total (DBA_HIST_SQLSTAT)</a></li>
PRO <li><a href="#ash_plan">Active Session History by Plan (GV$ACTIVE_SESSION_HISTORY)</a></li>
PRO <li><a href="#ash_line">Active Session History by Plan Line (GV$ACTIVE_SESSION_HISTORY)</a></li>
PRO <li><a href="#awr_plan">AWR Active Session History by Plan (DBA_HIST_ACTIVE_SESS_HISTORY)</a></li>
PRO <li><a href="#awr_line">AWR Active Session History by Plan Line (DBA_HIST_ACTIVE_SESS_HISTORY)</a></li>
-- PRO <li><a href="#dbms_stats_sys_prefs">DBMS_STATS System Preferences</a></li> --Uday.v6.Aug2016
PRO <li><a href="#tables">Tables</a></li>
PRO <li><a href="#dbms_stats_tab_prefs">DBMS_STATS Table Preferences</a></li>
PRO <li><a href="#tbl_cols">Table Columns</a></li>
PRO <li><a href="#tbl_parts">Table Partitions</a></li>
PRO <li><a href="#tbl_constr">Table Constraints</a></li>
PRO <li><a href="#tbl_stat_ver">Tables Statistics Versions</a></li>
PRO <li><a href="#tbl_modifications">Table Modifications</a></li>
PRO <li><a href="#indexes">Indexes</a></li>
PRO <li><a href="#idx_text">Text Indexes</a></li>
PRO <li><a href="#idx_cols">Index Columns</a></li>
PRO <li><a href="#ind_parts">Index Partitions</a></li>
PRO <li><a href="#idx_stat_ver">Indexes Statistics Versions</a></li>
PRO <li><a href="#sys_params">System Parameters with Non-Default or Modified Values</a></li>
PRO <li><a href="#inst_params">Instance Parameters</a></li>
PRO <li><a href="#vpd_policies">VPD Policies</a></li>
PRO <li><a href="#sql_undo_usage">SQL Undo Usage</a></li>
PRO <li><a href="#sql_stats_hard_parse_time">SQL Statistics based on Last Hard Parse Time</a></li>
PRO <li><a href="#sql_obj_dependency">SQL Object Dependency</a></li>
PRO <li><a href="#sql_views_dependency">View/Synonym Dependency Hierarchy</a></li>
PRO <li><a href="#metadata">Metadata</a></li>
PRO </ul>
psrv9*/ 

PRO <a name="toc"></a>
PRO <table border="0">
PRO  <tr>
PRO   <!-- Column 1 -->
PRO   <td class="lw">
PRO    <h4>Global</h4>
PRO     <ul>
PRO     <li><a href="#text">SQL Text</a></li>
PRO     <li><a href="#sys_params">Parameters (Non-Default Values)</a></li>
PRO     <li><a href="#inst_params">Instance Parameters</a></li>
PRO     </ul>
--PSRv10- moved to Plans section PRO    <h4>Plan Control</h4>
--PSRv10- moved to Plans section PRO     <ul>
--PSRv10- moved to Plans section PRO     <li><a href="#spm">SQL Plan Baselines</a></li>
--PSRv10- moved to Plans section PRO     <li><a href="#prof">SQL Profiles</a></li>
--PSRv10- moved to Plans section PRO     <li><a href="#patch">SQL Patches</a></li>
--PSRv10- moved to Plans section PRO     <!-- <li> <a href="#directives">SQL Plan Directives</a></li> -->
--PSRv10- moved to Plans section PRO    </ul>
--PSRv10- moved to Plans section PRO    
PRO    <h4>Cursor Sharing and Binds</h4>
PRO     <ul>
PRO     <li><a href="#share_r">Cursor Sharing and Reason</a></li>
PRO     <li><a href="#share_l">Cursor Sharing List</a></li>        
PRO     <li>Peeked & Captured Binds<br>(see file: *_13_all_bind_values.txt)</li> 
PRO     </ul>
PRO    </td>
PRO    
PRO    <!-- Column 2 -->
PRO    
PRO    <td class="lw">&nbsp;&nbsp;&nbsp;&nbsp;</td><td class="lw">
PRO    <h4>Plans</h4>
PRO     <ul>
PRO     <li><a href="#planControl">Plan Control</a> (<a href="#planControlHints">Hints</a>)</li>
PRO     <li><a href="#monitored_execs">Monitored Execs</a></li>
PRO     <li><a href="#mem_plans_sum">In Memory Plans Summary</a></li>
PRO     <li><a href="#mem_stats">In Memory SQL Statistics</a></li>
PRO     <li><a href="#reoptimization_hints">Reoptimization Hints</a></li>
PRO     <li><a href="#awr_plans_sum">Historical Plans Summary</a></li>
PRO     <li><a href="#awr_stats_d">Historical SQL Statistics - Delta</a></li>
PRO     <li><a href="#awr_stats_t">Historical SQL Statistics - Total</a></li>
PRO     <li><a href="#spd">SQL Plan Directives</a></li>
PRO    </ul>
PRO    
PRO    <h4>Active Session History (ASH)</h4>
PRO     <ul>
PRO     <li><a href="#ash_plan">In Memory ASH by Plan</a></li>
PRO     <li><a href="#ash_line">In Memory ASH by Plan Line</a></li>
PRO     <li><a href="#awr_plan">AWR ASH by Plan</a></li>
PRO     <li><a href="#awr_line">AWR ASH by Plan Line</a></li>
PRO     </ul>
PRO    </td>
PRO    
PRO    <!-- Column 3 -->
PRO    
PRO    <td class="lw">&nbsp;&nbsp;&nbsp;&nbsp;</td><td class="lw">
PRO    
PRO    <h4>Tables and Indexes</h4>
PRO     <ul>
PRO      <li><a href="#tables">Tables</a>
PRO       <ul>
PRO        <li><a href="#tbl_modifications">Table Modifications</a></li>
PRO        <li><a href="#tbl_stat_ver">Tables Statistics Versions</a></li>
PRO        <li><a href="#bootstrap_joblog">Bootstrap Stats Log</a></li>
PRO        <li><a href="#tbl_cols">Table Columns</a></li>
PRO        <li><a href="#extensions">Table Extensions</a></li>
PRO        <li><a href="#dbms_stats_tab_prefs">DBMS_STATS Table Preferences</a></li>
PRO        <li><a href="#tbl_parts">Table Partitions</a></li>
PRO        <li><a href="#tbl_constr">Table Constraints</a></li>
PRO       </ul>
PRO      </li>
PRO     <li><a href="#indexes">Indexes</a></li>
PRO       <ul>
PRO        <li><a href="#idx_text">Text Indexes</a></li>
PRO        <li><a href="#idx_stat_ver">Indexes Statistics Versions</a></li>
PRO        <li><a href="#idx_cols">Index Columns</a></li>
PRO        <li><a href="#ind_parts">Index Partitions</a></li>
PRO       </ul>
PRO      </li>
PRO     </ul>
PRO    
PRO    <h4>Miscellanious</h4>
PRO     <ul>
PRO      <li><a href="#vpd_policies">VPD Policies</a></li>
PRO      <li><a href="#sql_undo_usage">SQL Undo Usage</a></li>
PRO      <li><a href="#sql_stats_hard_parse_time">SQL Statistics based on Last Hard Parse Time</a></li>
PRO      <li><a href="#sql_obj_dependency">SQL Object Dependency</a></li>
PRO      <li><a href="#sql_views_dependency">View/Synonym Dependency Hierarchy</a></li>
PRO      <li><a href="#metadata">Metadata </a> (<a href="#index_metadata">Index</a> and <a href="#view_metadata">View</a>)</li>
PRO      <li><a href="#indexcontention">Index Contention</a></li>
PRO     </ul>
PRO    </td>
PRO    
PRO    <!-- Column 4 -->
PRO    
--PRO    <td class="lw">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
PRO    <td class="lw">&nbsp;&nbsp;&nbsp;&nbsp;</td>
PRO    <td class="lw">
PRO    <pre>
PRO    SQL_ID     : ^^input_parameter.
PRO    SIGNATURE  : ^^signature.
PRO    SIGNATUREF : ^^signaturef.
-- PSRv10 source
PRO    UI/Batch/..: ^^source_batch_ui.
PRO    Source(Mem): ^^sql_source.
PRO    Source(ASH): 
PRO    Obj   : ^^ash_plsql_entry.
PRO    SubObj: ^^ash_plsql_object.
PRO    
PRO    RDBMS      : ^^rdbms_version.
PRO    DBID       : ^^dbid.
PRO    Database   : ^^database_name_short.
PRO    #Instances : ^^instances.
-- PSRv10 service
PRO    Service    : ^^service_name.
PRO    
PRO    Platform   : ^^platform.
PRO    Host       : ^^host_name_short.
PRO    
PRO    Block Size : ^^sys_db_block_size.
PRO    OFE        : ^^sys_ofe.
PRO    DYN_SAMP   : ^^sys_ds.
PRO    
PRO    Date       : ^^time_stamp2.
PRO
PRO    EBR upgrade: ^^ebr_date.
PRO 
PRO    User       : ^^sessionuser.
PRO    License    : ^^input_license.
PRO    </pre>
PRO    </td>
PRO   
PRO    
PRO    <!-- Column 5 -->
PRO    
--PRO    <td class="lw">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
PRO    <td class="lw">&nbsp;&nbsp;&nbsp;&nbsp;</td>
PRO    <td class="lw">
PRO    <pre>
-- PSRv10 FA Release
--PRO    FA Release : ^^fa_release.
exec dbms_output.put_line('FA Release : ' || :fa_release)
--PRO    POD Size   : ^^pod_size.
exec dbms_output.put_line('POD size   : ' || :pod_size)
PRO    CPU_Count  : ^^sys_cpu.
PRO    Job Queues : ^^jobqp.
PRO    
PRO    Num CPUs   : ^^num_cpus.
PRO    Num Cores  : ^^num_cores.
PRO    Num Sockets: ^^num_sockets.
PRO    
PRO    </pre>
PRO    </td>
PRO   
PRO   </tr>
PRO </table>
/* -------------------------
 *
 * invalid parameters check -- PSRv10
 *
 * ------------------------- */
 
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

with recos as 
(
 select '14545269' name, '0' value from dual
 union all
 select '14764840', '1' value from dual
 union all
 select '6708183', '1' value from dual
 union all
 select '17799716', '1' value from dual
 union all
 select '19710102', '1' value from dual
 union all
 select '18134680', '1' value from dual
 union all
 select '18115594', '1' value from dual
 union all
 select '9633142', '1' value from dual
 union all
 select '20355502', '0' value from dual
 union all
 select '_sql_plan_directive_mgmt_control', '0' value from dual
 union all
 select '_optimizer_dsdir_usage_control', '0' value from dual
 union all
 select '_optimizer_use_feedback', 'FALSE' value from dual
)
, actuals as
(
  select to_char(bugno) name, to_char(value) value 
    from v$system_fix_control 
   where bugno in (14545269, 14764840, 6708183, 17799716, 19710102, 18134680, 18115594, 9633142, 20355502) 
  union all
  select name, value
    from v$parameter
   where name in ('_sql_plan_directive_mgmt_control', '_optimizer_dsdir_usage_control', '_optimizer_use_feedback')
)
, invalidp as
(
  select recos.name, recos.value recommended_value, act.value actual_value, row_number() over(order by recos.name) rn
         --, case when then '<font color="red">***NOT a recommended value***</font>' end comment
    from recos, actuals act
   where recos.name = act.name(+)
     and recos.value <> act.value
     -- and 1=2
   order by recos.name
)
select 
       CHR(10)||'<details open><br/><summary id="summary2"><font color="red">Invalid Parameter Settings:</font></summary>'||CHR(10)||
       q'{
           <table>
           <tr>
           <th>#</th>
           <th>name</th>
           <th>Recommended<br>Value</th>
           <th>Actual<br>Value</th>
           </tr>
         }'
  from invalidp
 where rownum = 1
union all
select 
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td >'|| name               ||'</td>'||CHR(10)||
       '<td >'|| recommended_value  ||'</td>'||CHR(10)||
       '<td >'|| actual_value       ||'</td>'||CHR(10)||
       '</tr>'
  from invalidp
union all
select 
       q'{
           </table>
         }' || chr(10)
  from invalidp
 where rownum = 1
;

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * sql_text
 *
 * ------------------------- */
PRO <script language="JavaScript" type="text/JavaScript">
PRO function openInNewWindow(url)
PRO {
PRO   window.open(url,"_blank");
PRO }
PRO </script>
PRO <a name="text"></a><details open><br/><summary id="summary2">SQL Text</summary>
PRO <FORM><BUTTON class="button button1" onclick="openInNewWindow(&quot;https://apex.oraclecorp.com/pls/apex/f?p=28906&quot;)">Analyze SQL Text via PSR Tool [use Upload SQL Button]</BUTTON></FORM> 
PRO
PRO <pre>

DECLARE
  l_sql_text CLOB := :sql_text;
  l_pos NUMBER;
BEGIN
  WHILE NVL(LENGTH(l_sql_text), 0) > 0
  LOOP
    l_pos := INSTR(l_sql_text, CHR(10));
    IF l_pos > 0 THEN
      DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_text, 1, l_pos - 1));
      l_sql_text := SUBSTR(l_sql_text, l_pos + 1);
    ELSE
      DBMS_OUTPUT.PUT_LINE(l_sql_text);
      l_sql_text := NULL;
    END IF;
  END LOOP;
END;
/

PRO </pre>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * PL/SQL child queries
 *
 * ------------------------- */

var in_ash_memory varchar2(1);
exec :in_ash_memory := NULL;

-- Get sql id from ASH

declare 
  v_sql_opname gv$active_session_history.sql_opname%type;
begin

  select sql_opname
  into v_sql_opname  
  from gv$active_session_history
  where sql_id = '^^sql_id.'
  and rownum = 1;

  if v_sql_opname = 'PL/SQL EXECUTE'
  then
    :in_ash_memory := 'Y';
--    dbms_output.put_line('SQL ID IS A PL/SQL CALL IN ASH MEMORY');
  end if;

exception 
    when others then
     null;
end;
/

-- Get sql id from historical ASH

declare 
  v_sql_opname dba_hist_active_sess_history.sql_opname%type;
begin
  if :in_ash_memory IS NULL 
  then
    select sql_opname
    into v_sql_opname  
    from dba_hist_active_sess_history
    where sql_id = '^^sql_id.'
    and rownum = 1;

    if v_sql_opname = 'PL/SQL EXECUTE'
    then
      :in_ash_memory := 'N';
--      dbms_output.put_line('SQL ID IS A PL/SQL CALL IN HISTORICAL ASH');
      null;
    end if;
  end if;

exception 
    when others then
    null;
end;
/

begin
  if :in_ash_memory = 'Y'
  then
    dbms_output.put_line(CHR(10)||'<details open><br/><summary id="summary2">PL/SQL Child SQLs From In Memory ASH:</summary>'||CHR(10));
  elsif :in_ash_memory = 'N'
  then
    dbms_output.put_line(CHR(10)||'<details open><br/><summary id="summary2">PL/SQL Child SQLs From Historical ASH (AWR):</summary>'||CHR(10));
  end if;
end;
/

begin
  if :in_ash_memory is not null
  then
    dbms_output.put_line('EXEC ELAPSED TIME is only shown if executions = 1');
    dbms_output.put_line('<table>');
    dbms_output.put_line('<tr>');
    dbms_output.put_line('<th>#</th>');
    dbms_output.put_line('<th>SQL ID</th>');
    dbms_output.put_line('<th>PLAN HASH VALUE</th>');
    dbms_output.put_line('<th>EXECUTIONS</th>');
    dbms_output.put_line('<th>SQL OPNAME</th>');
    dbms_output.put_line('<th>SQL FIRST SAMPLE</th>');
    dbms_output.put_line('<th>SQL LAST SAMPLE</th>');
    dbms_output.put_line('<th>EXEC ELAPSED TIME</th>');
    dbms_output.put_line('<th>ECID COUNT</th>');
    dbms_output.put_line('<th>SESSION COUNT</th>');
    dbms_output.put_line('<th>SAMPLE COUNT</th>');
    dbms_output.put_line('<th>% OF TOTAL TIME</th>');
    dbms_output.put_line('</tr>');
  end if;
end;
/

WITH IN_ASH AS
(
    SELECT
           CHR(10)||'<tr>'||CHR(10)||
           '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
           '<td class="r">'||sql_id      ||'</td>'||CHR(10)||
           '<td class="r">'||phv         ||'</td>'||CHR(10)||
           '<td class="r">'||execs       ||'</td>'||CHR(10)||
           '<td class="r">'||sql_opname  ||'</td>'||CHR(10)||
           '<td class="r">'||sql_first_sample  ||'</td>'||CHR(10)||
           '<td class="r">'||sql_last_sample  ||'</td>'||CHR(10)||
           '<td class="r">'||elatime_allexecs  ||'</td>'||CHR(10)||
           '<td class="r">'||ecid_count  ||'</td>'||CHR(10)||
           '<td class="r">'||sesscnt  ||'</td>'||CHR(10)||
           '<td class="r">'||cnt  ||'</td>'||CHR(10)||
           '<td class="r">'||pct         ||'</td>'||CHR(10)||
           '</tr>'
    FROM (
             select sql_id,
                    phv,
                    execs,
                    sql_opname,
                    sql_first_sample,
                    sql_last_sample,
                    elatime_allexecs,
                    ecid_count,
                    sesscnt,
                    cnt,
                    pct
             from
             (
                 select sql_id,
                        phv,
                        execs,
                        sql_opname,
                        sql_first_sample,
                        sql_last_sample,
                        decode(execs,1,regexp_replace(to_char(elatime_allexecs),'^\+[0]+'),'N/A') as elatime_allexecs,
                        ecid_count,
                        sesscnt,
                        cnt,
                        round(cnt/sum(cnt) over () * 100,2) as pct
                 from
                 (
                     select nvl(sql_id,'NULL') sql_id,
                            sql_plan_hash_value phv,
                            count(distinct sql_exec_id || '-' || sql_exec_start) execs,
                            count(*) cnt,
                            sql_opname,
                            min(sample_time) sql_first_sample,
                            max(sample_time) sql_last_sample,
                            max(sample_time)-min(sample_time) elatime_allexecs,
                           count(distinct ECID) ecid_count,
                           count(distinct session_id||'/'||session_serial#||'/'|| inst_id) sesscnt
                     from gv$active_session_history
                     where top_level_sql_id = '^^sql_id.'
                     and :in_ash_memory = 'Y'
                     group by nvl(sql_id,'NULL'), sql_plan_hash_value, sql_opname
                 )
                 order by pct desc
            )
            where pct >= 5
         ) v
    ),
    IN_AWR AS
    (
    SELECT
           CHR(10)||'<tr>'||CHR(10)||
           '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
           '<td class="r">'||sql_id      ||'</td>'||CHR(10)||
           '<td class="r">'||phv         ||'</td>'||CHR(10)||
           '<td class="r">'||execs       ||'</td>'||CHR(10)||
           '<td class="r">'||sql_opname  ||'</td>'||CHR(10)||
           '<td class="r">'||sql_first_sample  ||'</td>'||CHR(10)||
           '<td class="r">'||sql_last_sample  ||'</td>'||CHR(10)||
           '<td class="r">'||elatime_allexecs  ||'</td>'||CHR(10)||
           '<td class="r">'||ecid_count  ||'</td>'||CHR(10)||
           '<td class="r">'||sesscnt  ||'</td>'||CHR(10)||
           '<td class="r">'||cnt  ||'</td>'||CHR(10)||
           '<td class="r">'||pct         ||'</td>'||CHR(10)||
           '</tr>'
    FROM (
             select sql_id,
                    phv,
                    execs,
                    sql_opname,
                    sql_first_sample,
                    sql_last_sample,
                    elatime_allexecs,
                    ecid_count,
                    sesscnt,
                    cnt,
                    pct
             from
             (
                 select sql_id,
                        phv,
                        execs,
                        sql_opname,
                        sql_first_sample,
                        sql_last_sample,
                        decode(execs,1,regexp_replace(to_char(elatime_allexecs),'^\+[0]+'),'N/A') as elatime_allexecs,
                        ecid_count,
                        sesscnt,
                        cnt,
                        round(cnt/sum(cnt) over () * 100,2) as pct
                 from
                 (
                     select nvl(sql_id,'NULL') sql_id,
                            sql_plan_hash_value phv,
                            count(distinct sql_exec_id || '-' || sql_exec_start) execs,
                            count(*) cnt,
                            sql_opname,
                            min(sample_time) sql_first_sample,
                            max(sample_time) sql_last_sample,
                            max(sample_time)-min(sample_time) elatime_allexecs,
                           count(distinct ECID) ecid_count,
                           count(distinct session_id||'/'||session_serial#||'/'|| instance_number) sesscnt
                     from dba_hist_active_sess_history
                     where top_level_sql_id = '^^sql_id.'
                     and :in_ash_memory = 'N'
                     group by nvl(sql_id,'NULL'), sql_plan_hash_value, sql_opname
                 )
                 order by pct desc
           )
           where pct >= 5
         ) v
    )
SELECT * FROM IN_ASH
UNION ALL
SELECT * FROM IN_AWR
;

begin
  if :in_ash_memory is not null
  then
    dbms_output.put_line('<tr>');
    dbms_output.put_line('<th>#</th>');
    dbms_output.put_line('<th>SQL ID</th>');
    dbms_output.put_line('<th>PLAN HASH VALUE</th>');
    dbms_output.put_line('<th>EXECUTIONS</th>');
    dbms_output.put_line('<th>SQL OPNAME</th>');
    dbms_output.put_line('<th>SQL FIRST SAMPLE</th>');
    dbms_output.put_line('<th>SQL LAST SAMPLE</th>');
    dbms_output.put_line('<th>EXEC ELAPSED TIME</th>');
    dbms_output.put_line('<th>ECID COUNT</th>');
    dbms_output.put_line('<th>SESSION COUNT</th>');
    dbms_output.put_line('<th>SAMPLE COUNT</th>');
    dbms_output.put_line('<th>% OF TOTAL TIME</th>');
    dbms_output.put_line('</tr>');
    dbms_output.put_line('</table>'); -- Pushkar
  end if;
end;
/

begin
  if :in_ash_memory in ('N','Y')
  then
    dbms_output.put_line(CHR(10)||'<table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: '||round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400)||' seconds</td></tr></table></details>'||CHR(10));
  end if;
end;
/
REM special case -- Pushkar

exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * Plan Control Objects
 *
 * ------------------------- */
PRO <a name="planControl"></a><details open><br/><summary id="summary2">Plan Control Objects (DBA_SQL_PLAN_BASELINES/DBA_SQL_PROFILES/DBA_SQL_PATCHES)</summary>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

COL signature FOR 99999999999999999999;

--KDRUPARE AH-3084 Beg
PRO If ALTERNATE_PLAN_BASELINE is AUTO, AUTO SPM is enabled
PRO


PRO
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>PARAMETER_NAME</th>
PRO <th>PARAMETER_VALUE</th>
PRO </tr>
PRO

SELECT 
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||PARAMETER_NAME||'</td>'||CHR(10)||
       '<td >'||PARAMETER_VALUE      ||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ 
               PARAMETER_NAME,
			   PARAMETER_VALUE
          FROM DBA_ADVISOR_PARAMETERS 
         WHERE  TASK_NAME = 'SYS_AUTO_SPM_EVOLVE_TASK'
		 AND PARAMETER_VALUE <> 'UNUSED'
		 ORDER BY 1) v
;

PRO <tr>
PRO <th>PARAMETER_NAME</th>
PRO <th>PARAMETER_VALUE</th>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

PRO <!-- Please Wait -->
PRO
PRO
PRO Auto Tasks
PRO <table>
PRO
PRO <tr>
PRO <th>DBID</th>
PRO <th>TASK ID</th>
PRO <th>Task Name</th>
PRO <th>ENABLED</th>
PRO <th>LAST SCHEDULE TIME</th>
PRO </tr>
PRO

SELECT 
       CHR(10)||'<tr>'||CHR(10)||
       '<td >'||DBID||'</td>'||CHR(10)||
       '<td >'||TASK_ID||'</td>'||CHR(10)||
	   '<td >'||TASK_NAME||'</td>'||CHR(10)||
	   '<td >'||ENABLED||'</td>'||CHR(10)||
	   '<td >'||LAST_SCHEDULE_TIME||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ 
               DBID, TASK_ID, TASK_NAME, ENABLED, LAST_SCHEDULE_TIME 
			   from dba_autotask_schedule_control 
			   where dbid in (select dbid from v$PDBs)) v
;

PRO <tr>
PRO <th>DBID</th>
PRO <th>TASK ID</th>
PRO <th>Task Name</th>
PRO <th>ENABLED</th>
PRO <th>LAST SCHEDULE TIME</th>
PRO
PRO </table>
PRO

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

PRO <!-- Please Wait -->
PRO
PRO
PRO Auto Task Interval
PRO <table>
PRO
PRO <tr>
PRO <th>DBID</th>
PRO <th>Task Name</th>
PRO <th>Task Interval<br>in Seconds</th>
PRO </tr>
PRO

SELECT 
       CHR(10)||'<tr>'||CHR(10)||
       '<td >'||DBID||'</td>'||CHR(10)||
       '<td >'||Task_Name||'</td>'||CHR(10)||
	   '<td >'||INTERVAL||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ 
               DBID, Task_Name, Interval 
			   From DBA_AutoTask_Schedule_Control
			   Where Task_Name = 'Auto STS Capture Task'
			   and dbid in (select dbid from v$pdbs)) v
;

PRO <tr>
PRO <th>DBID</th>
PRO <th>Task Name</th>
PRO <th>Task Interval<br>in Seconds</th>
PRO
PRO </table>
PRO

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
--KDRUPARE AH-3084 END

PRO <!-- Please Wait -->
PRO
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan Control<br>Object</th>
PRO <th>Hints</th>
PRO <th>Name</th>
PRO <th>Origin</th>
PRO <th>Signature</th>
PRO <th>Created</th>
PRO <th>Last<br>Modified</th>
PRO <th>Description</th>
PRO <th>Enabled</th>
PRO <th>Type</th>
PRO <th>Force<br>Matching</th>
PRO <th>Category</th>
PRO <th>Last<br>Executed</th>
PRO <th>Last<br>Verified</th>
PRO <th>Accepted</th>
PRO <th>Reproduced</th>
PRO <th>Auto<br>Purge</th>
PRO <th>Adaptive</th>
PRO <th>Optimizer<br>Cost</th>
PRO <th>Executions</th>
PRO <th>Elapsed<br>Time</th>
PRO <th>CPU<br>Time</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Direct Writes</th>
PRO <th>Rows Processed</th>
PRO <th>Fetches</th>
PRO <th>EndOf<br>FetchCount</th>
PRO <th>SQL Handle</th>
PRO </tr>
PRO

SELECT 
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td >'||plan_control        ||'</td>'||CHR(10)||
       '<td class="c"><a href="#' || name || '">Hints</a></td>'||CHR(10)||
       '<td >'||name                ||'</td>'||CHR(10)||
       '<td >'||origin              ||'</td>'||CHR(10)||
       '<td >'||SIGNATURE           ||'</td>'||CHR(10)||
       '<td >'||CREATED             ||'</td>'||CHR(10)||
       '<td >'||LAST_MODIFIED       ||'</td>'||CHR(10)||
       '<td >'||DESCRIPTION         ||'</td>'||CHR(10)||
       '<td >'||ENABLED             ||'</td>'||CHR(10)||
       '<td >'||type                ||'</td>'||CHR(10)||
       '<td >'||FORCE_MATCHING      ||'</td>'||CHR(10)||
       '<td >'||category            ||'</td>'||CHR(10)||
       '<td >'||last_executed       ||'</td>'||CHR(10)||
	   '<td >'||last_verified       ||'</td>'||CHR(10)|| --kdrupare AH-3084
       '<td >'||ACCEPTED            ||'</td>'||CHR(10)||
       '<td >'||REPRODUCED          ||'</td>'||CHR(10)||
       '<td >'||AUTOPURGE           ||'</td>'||CHR(10)||
       '<td >'||ADAPTIVE            ||'</td>'||CHR(10)||
       '<td >'||OPTIMIZER_COST      ||'</td>'||CHR(10)||
       '<td >'||EXECUTIONS          ||'</td>'||CHR(10)||
       '<td >'||ELAPSED_TIME        ||'</td>'||CHR(10)||
       '<td >'||CPU_TIME            ||'</td>'||CHR(10)||
       '<td >'||BUFFER_GETS         ||'</td>'||CHR(10)||
       '<td >'||DISK_READS          ||'</td>'||CHR(10)||
       '<td >'||DIRECT_WRITES       ||'</td>'||CHR(10)||
       '<td >'||ROWS_PROCESSED      ||'</td>'||CHR(10)||
       '<td >'||FETCHES             ||'</td>'||CHR(10)||
       '<td >'||END_OF_FETCH_COUNT  ||'</td>'||CHR(10)||
       '<td >'||SQL_HANDLE          ||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ 
               'Baseline' Plan_control,
               PLAN_NAME name,
               origin,
               SIGNATURE, 
               to_char(CREATED, 'dd-mon-yy hh24:mi:ss') CREATED,
               to_char(LAST_MODIFIED, 'dd-mon-yy hh24:mi:ss') LAST_MODIFIED,
               DESCRIPTION,
               ENABLED,
               decode(FIXED, 'YES', 'Fixed', 'Not Fixed') type,
               'n/a' FORCE_MATCHING,
               'n/a' category,
               to_char(LAST_EXECUTED, 'dd-mon-yy hh24:mi:ss') last_executed,
			   to_char(LAST_VERIFIED, 'dd-mon-yy hh24:mi:ss') last_verified, --KDRUPARE AH-3084
               ACCEPTED,
               REPRODUCED,
               AUTOPURGE,
               ADAPTIVE,
               to_char(OPTIMIZER_COST) OPTIMIZER_COST,
               to_char(EXECUTIONS) EXECUTIONS,
               to_char(ELAPSED_TIME) ELAPSED_TIME,
               to_char(CPU_TIME) CPU_TIME,
               to_char(BUFFER_GETS) BUFFER_GETS,
               to_char(DISK_READS) DISK_READS,
               to_char(DIRECT_WRITES) DIRECT_WRITES,
               to_char(ROWS_PROCESSED) ROWS_PROCESSED,
               to_char(FETCHES) FETCHES,
               to_char(END_OF_FETCH_COUNT) END_OF_FETCH_COUNT,  
               SQL_HANDLE
          FROM dba_sql_plan_baselines 
         WHERE signature IN (^^signature., ^^signaturef.) 
        UNION ALL
         SELECT /*+ NO_MERGE */  
               'SQL Profile' Plan_control,
                NAME,
                'n/a' origin,                
                SIGNATURE,
                to_char(CREATED, 'dd-mon-yy hh24:mi:ss') CREATED,
                to_char(LAST_MODIFIED, 'dd-mon-yy hh24:mi:ss') LAST_MODIFIED,
                DESCRIPTION,
                STATUS,
                TYPE,
                FORCE_MATCHING,
                CATEGORY,
                'n/a' LAST_EXECUTED,
				'n/a' LAST_VERIFIED, --KDRUPARE AH-3084
                'n/a' ACCEPTED,
                'n/a' REPRODUCED,
                'n/a' AUTOPURGE,
                'n/a' ADAPTIVE,
                'n/a' OPTIMIZER_COST,
                'n/a' EXECUTIONS,
                'n/a' ELAPSED_TIME,
                'n/a' CPU_TIME,
                'n/a' BUFFER_GETS,
                'n/a' DISK_READS,
                'n/a' DIRECT_WRITES,
                'n/a' ROWS_PROCESSED,
                'n/a' FETCHES,
                'n/a' END_OF_FETCH_COUNT,
                'n/a' SQL_HANDLE
           FROM dba_sql_profiles 
          WHERE signature IN (^^signature., ^^signaturef.) 
        UNION ALL
         SELECT /*+ NO_MERGE */
               'SQL Patch' Plan_control,
                NAME,
                'n/a' origin,
                SIGNATURE,
                to_char(CREATED, 'dd-mon-yy hh24:mi:ss') CREATED,
                to_char(LAST_MODIFIED, 'dd-mon-yy hh24:mi:ss') LAST_MODIFIED,
                DESCRIPTION,
                STATUS,
                'n/a' TYPE,
                FORCE_MATCHING,
                CATEGORY,
                'n/a' LAST_EXECUTED,
				'n/a' LAST_VERIFIED, --KDRUPARE AH-3084
                'n/a' ACCEPTED,
                'n/a' REPRODUCED,
                'n/a' AUTOPURGE,
                'n/a' ADAPTIVE,
                'n/a' OPTIMIZER_COST,
                'n/a' EXECUTIONS,
                'n/a' ELAPSED_TIME,
                'n/a' CPU_TIME,
                'n/a' BUFFER_GETS,
                'n/a' DISK_READS,
                'n/a' DIRECT_WRITES,
                'n/a' ROWS_PROCESSED,
                'n/a' FETCHES,
                'n/a' END_OF_FETCH_COUNT,
                'n/a' SQL_HANDLE
          FROM dba_sql_patches
         WHERE signature IN (^^signature., ^^signaturef.)
         ORDER BY created desc, plan_control, name
        ) v
;


PRO <tr>
PRO <th>#</th>
PRO <th>Plan Control<br>Object</th>
PRO <th>Hints</th>
PRO <th>Name</th>
PRO <th>Origin</th>
PRO <th>Signature</th>
PRO <th>Created</th>
PRO <th>Last<br>Modified</th>
PRO <th>Description</th>
PRO <th>Enabled</th>
PRO <th>Type</th>
PRO <th>Force<br>Matching</th>
PRO <th>Category</th>
PRO <th>Last<br>Executed</th>
PRO <th>Last<br>Verified</th>
PRO <th>Accepted</th>
PRO <th>Reproduced</th>
PRO <th>Auto<br>Purge</th>
PRO <th>Adaptive</th>
PRO <th>Optimizer<br>Cost</th>
PRO <th>Executions</th>
PRO <th>Elapsed<br>Time</th>
PRO <th>CPU<br>Time</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Direct Writes</th>
PRO <th>Rows Processed</th>
PRO <th>Fetches</th>
PRO <th>EndOf<br>FetchCount</th>
PRO <th>SQL Handle</th>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

--KDRUPARE AH-3084 Beg

PRO <!-- Please Wait -->
PRO
PRO
PRO Auto Task run details for ORA$_ATSK_AUTOSMT
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>STATUS</th>
PRO <th>ERRORS</th>
PRO <th>SESSION ID</th>
PRO <th>ACTUAL START DATE</th>
PRO <th>REQUESTED START DATE</th>
PRO <th>RUN DURATION</th>
PRO </tr>
PRO

SELECT 
       CHR(10)||'<tr>'||CHR(10)||
       '<td >'||status||'</td>'||CHR(10)||
       '<td >'||errors||'</td>'||CHR(10)||
	   '<td >'||session_id||'</td>'||CHR(10)||
	   '<td >'||actual_start_date||'</td>'||CHR(10)||
	   '<td >'||req_start_date||'</td>'||CHR(10)||
	   '<td >'||run_duration||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ 
               status, errors, session_id, actual_start_date, req_start_date, run_duration 
			   from  (select status, errors, session_id, actual_start_date,  req_start_date, run_duration
                         from   dba_scheduler_job_run_details
                         where job_name =  'ORA$_ATSK_AUTOSMT'
                         order by   ACTUAL_START_DATE desc)
						 where rownum < 50) v order by actual_start_date desc
;

PRO <tr>
PRO <th>STATUS</th>
PRO <th>ERRORS</th>
PRO <th>SESSION ID</th>
PRO <th>ACTUAL START DATE</th>
PRO <th>REQUESTED START DATE</th>
PRO <th>RUN DURATION</th>
PRO
PRO </table>
PRO

--KDRUPARE AH-3084 end

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

--KDRUPARE AH-3084 Beg

PRO <!-- Please Wait -->
PRO
PRO
PRO DBA_SQLSET_STATEMENTS
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>SQLSET_NAME</th>
PRO <th>SQLSET_OWNER</th>
PRO <th>SQLSET_ID</th>
PRO <th>CON_DBID</th>
PRO <th>SQL_ID</th>
PRO <th>FORCE_MATCHING<br>SIGNATURE</th>
PRO <th>SQL_TEXT</th>
PRO <th>PARSING_SCHEMA<br>NAME</th>
PRO <th>PARSING_SCHEMA_ID</th>
PRO <th>PLAN_HASH_VALUE</th>
PRO <th>BIND_DATA</th>
PRO <th>BINDS_CAPTURED</th>
PRO <th>MODULE</th>
PRO <th>ACTION</th>
PRO <th>ELAPSED_TIME</th>
PRO <th>CPU_TIME</th>
PRO <th>BUFFER_GETS</th>
PRO <th>DISK_READS</th>
PRO <th>DIRECT_WRITES</th>
PRO <th>ROWS_PROCESSED</th>
PRO <th>FETCHES</th>
PRO <th>EXECUTIONS</th>
PRO <th>END OF<br>FETCH COUNT</th>
PRO <th>OPTIMIZER_COST</th>
PRO <th>OPTIMIZER_ENV</th>
PRO <th>PRIORITY</th>
PRO <th>COMMAND_TYPE</th>
PRO <th>FIRST_LOAD_TIME</th>
PRO <th>STAT_PERIOD</th>
PRO <th>ACTIVE_STAT_PERIOD</th>
PRO <th>OTHER</th>
PRO <th>PLAN_TIMESTAMP</th>
PRO <th>SQL_SEQ</th>
PRO <th>LAST EXEC<br>START TIME</th>
PRO <th>SHARABLE_MEM</th>
PRO <th>EXACT_MATCHING_SIGNATURE</th>
PRO <th>RESULT_CACHE_EXECUTIONS</th>
PRO <th>SQL_PROFILE</th> 
PRO </tr>
PRO

SELECT 
       CHR(10)||'<tr>'||CHR(10)||
       '<td >'||SQLSET_NAME||'</td>'||CHR(10)||
       '<td >'||SQLSET_OWNER||'</td>'||CHR(10)||
       '<td >'||SQLSET_ID||'</td>'||CHR(10)||
       '<td >'||CON_DBID||'</td>'||CHR(10)||
       '<td >'||SQL_ID||'</td>'||CHR(10)||
       '<td >'||FORCE_MATCHING_SIGNATURE||'</td>'||CHR(10)||
       '<td >'||SQL_TEXT||'</td>'||CHR(10)||
       '<td >'||PARSING_SCHEMA_NAME||'</td>'||CHR(10)||
       '<td >'||PARSING_SCHEMA_ID||'</td>'||CHR(10)||
       '<td >'||PLAN_HASH_VALUE||'</td>'||CHR(10)||
       '<td >'||BIND_DATA||'</td>'||CHR(10)||
       '<td >'||BINDS_CAPTURED||'</td>'||CHR(10)||
       '<td >'||MODULE||'</td>'||CHR(10)||
       '<td >'||ACTION||'</td>'||CHR(10)||
       '<td >'||ELAPSED_TIME||'</td>'||CHR(10)||
       '<td >'||CPU_TIME||'</td>'||CHR(10)||
       '<td >'||BUFFER_GETS||'</td>'||CHR(10)||
       '<td >'||DISK_READS||'</td>'||CHR(10)||
       '<td >'||DIRECT_WRITES||'</td>'||CHR(10)||
       '<td >'||ROWS_PROCESSED||'</td>'||CHR(10)||
       '<td >'||FETCHES||'</td>'||CHR(10)||
       '<td >'||EXECUTIONS||'</td>'||CHR(10)||
       '<td >'||END_OF_FETCH_COUNT||'</td>'||CHR(10)||
       '<td >'||OPTIMIZER_COST||'</td>'||CHR(10)||
       '<td >'||OPTIMIZER_ENV||'</td>'||CHR(10)||
       '<td >'||PRIORITY||'</td>'||CHR(10)||
       '<td >'||COMMAND_TYPE||'</td>'||CHR(10)||
       '<td >'||FIRST_LOAD_TIME||'</td>'||CHR(10)||
       '<td >'||STAT_PERIOD||'</td>'||CHR(10)||
       '<td >'||ACTIVE_STAT_PERIOD||'</td>'||CHR(10)||
       '<td >'||OTHER||'</td>'||CHR(10)||
       '<td >'||PLAN_TIMESTAMP||'</td>'||CHR(10)||
       '<td >'||SQL_SEQ||'</td>'||CHR(10)||
       '<td >'||LAST_EXEC_START_TIME||'</td>'||CHR(10)||
       '<td >'||SHARABLE_MEM||'</td>'||CHR(10)||
       '<td >'||EXACT_MATCHING_SIGNATURE||'</td>'||CHR(10)||
       '<td >'||RESULT_CACHE_EXECUTIONS||'</td>'||CHR(10)||
       '<td >'||SQL_PROFILE||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ 
               SQLSET_NAME,
               SQLSET_OWNER,
               SQLSET_ID,
               CON_DBID,
               SQL_ID,
               FORCE_MATCHING_SIGNATURE,
               SQL_TEXT,
               PARSING_SCHEMA_NAME,
               PARSING_SCHEMA_ID,
               PLAN_HASH_VALUE,
               BIND_DATA,
               BINDS_CAPTURED,
               MODULE,
               ACTION,
               ELAPSED_TIME,
               CPU_TIME,
               BUFFER_GETS,
               DISK_READS,
               DIRECT_WRITES,
               ROWS_PROCESSED,
               FETCHES,
               EXECUTIONS,
               END_OF_FETCH_COUNT,
               OPTIMIZER_COST,
               OPTIMIZER_ENV,
               PRIORITY,
               COMMAND_TYPE,
               FIRST_LOAD_TIME,
               STAT_PERIOD,
               ACTIVE_STAT_PERIOD,
               OTHER,
               PLAN_TIMESTAMP,
               SQL_SEQ,
               LAST_EXEC_START_TIME,
               SHARABLE_MEM,
               EXACT_MATCHING_SIGNATURE,
               RESULT_CACHE_EXECUTIONS,
               SQL_PROFILE
			   from DBA_SQLSET_STATEMENTS
			   where sql_id= '^^sql_id.') v order by LAST_EXEC_START_TIME desc
;

PRO <tr>
PRO <th>SQLSET_NAME</th>
PRO <th>SQLSET_OWNER</th>
PRO <th>SQLSET_ID</th>
PRO <th>CON_DBID</th>
PRO <th>SQL_ID</th>
PRO <th>FORCE_MATCHING<br>SIGNATURE</th>
PRO <th>SQL_TEXT</th>
PRO <th>PARSING_SCHEMA<br>NAME</th>
PRO <th>PARSING_SCHEMA_ID</th>
PRO <th>PLAN_HASH_VALUE</th>
PRO <th>BIND_DATA</th>
PRO <th>BINDS_CAPTURED</th>
PRO <th>MODULE</th>
PRO <th>ACTION</th>
PRO <th>ELAPSED_TIME</th>
PRO <th>CPU_TIME</th>
PRO <th>BUFFER_GETS</th>
PRO <th>DISK_READS</th>
PRO <th>DIRECT_WRITES</th>
PRO <th>ROWS_PROCESSED</th>
PRO <th>FETCHES</th>
PRO <th>EXECUTIONS</th>
PRO <th>END OF<br>FETCH COUNT</th>
PRO <th>OPTIMIZER_COST</th>
PRO <th>OPTIMIZER_ENV</th>
PRO <th>PRIORITY</th>
PRO <th>COMMAND_TYPE</th>
PRO <th>FIRST_LOAD_TIME</th>
PRO <th>STAT_PERIOD</th>
PRO <th>ACTIVE_STAT_PERIOD</th>
PRO <th>OTHER</th>
PRO <th>PLAN_TIMESTAMP</th>
PRO <th>SQL_SEQ</th>
PRO <th>LAST EXEC<br>START TIME</th>
PRO <th>SHARABLE_MEM</th>
PRO <th>EXACT_MATCHING_SIGNATURE</th>
PRO <th>RESULT_CACHE_EXECUTIONS</th>
PRO <th>SQL_PROFILE</th>
PRO
PRO </table>
PRO

--KDRUPARE AH-3084 end

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

--KDRUPARE AH-3084 Beg

PRO <!-- Please Wait -->
PRO
PRO
PRO DBA_ADVISOR_OBJECTS
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>OWNER</th>
PRO <th>OBJECT_ID</th>
PRO <th>TYPE</th>
PRO <th>TYPE_ID</th>
PRO <th>TASK_ID</th>
PRO <th>TASK_NAME</th>
PRO <th>EXECUTION_NAME</th>
PRO <th>ATTR1</th>
PRO <th>ATTR2</th>
PRO <th>ATTR3</th>
PRO <th>ATTR4</th>
PRO <th>ATTR5</th>
PRO <th>ATTR6</th>
PRO <th>ATTR7</th>
PRO <th>ATTR8</th>
PRO <th>ATTR9</th>
PRO <th>ATTR10</th>
PRO <th>ATTR11</th>
PRO <th>ATTR16</th>
PRO <th>ATTR17</th>
PRO <th>ATTR18</th>
PRO <th>OTHER</th>
PRO <th>ADV_SQL_ID</th>
PRO </tr>
PRO

SELECT 
       CHR(10)||'<tr>'||CHR(10)||
       '<td >'||OWNER||CHR(10)||
       '<td >'||OBJECT_ID||CHR(10)||
       '<td >'||TYPE||CHR(10)||
       '<td >'||TYPE_ID||CHR(10)||
       '<td >'||TASK_ID||CHR(10)||
       '<td >'||TASK_NAME||CHR(10)||
       '<td >'||EXECUTION_NAME||CHR(10)||
       '<td >'||ATTR1||CHR(10)||
       '<td >'||ATTR2||CHR(10)||
       '<td >'||ATTR3||CHR(10)||
       '<td >'||ATTR4||CHR(10)||
       '<td >'||ATTR5||CHR(10)||
       '<td >'||ATTR6||CHR(10)||
       '<td >'||ATTR7||CHR(10)||
       '<td >'||ATTR8||CHR(10)||
       '<td >'||ATTR9||CHR(10)||
       '<td >'||ATTR10||CHR(10)||
       '<td >'||ATTR11||CHR(10)||
       '<td >'||ATTR16||CHR(10)||
       '<td >'||ATTR17||CHR(10)||
       '<td >'||ATTR18||CHR(10)||
       '<td >'||OTHER||CHR(10)||
       '<td >'||ADV_SQL_ID||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ 
               OWNER,
               OBJECT_ID,
               TYPE,
               TYPE_ID,
               TASK_ID,
               TASK_NAME,
               EXECUTION_NAME,
               ATTR1,
               ATTR2,
               ATTR3,
               ATTR4,
               ATTR5,
               ATTR6,
               ATTR7,
               ATTR8,
               ATTR9,
               ATTR10,
               ATTR11,
               ATTR16,
               ATTR17,
               ATTR18,
               OTHER,
               ADV_SQL_ID
			   from DBA_ADVISOR_OBJECTS
			   where ATTR1= '^^sql_id.') v
;

PRO <tr>
PRO <th>OWNER</th>
PRO <th>OBJECT_ID</th>
PRO <th>TYPE</th>
PRO <th>TYPE_ID</th>
PRO <th>TASK_ID</th>
PRO <th>TASK_NAME</th>
PRO <th>EXECUTION_NAME</th>
PRO <th>ATTR1</th>
PRO <th>ATTR2</th>
PRO <th>ATTR3</th>
PRO <th>ATTR4</th>
PRO <th>ATTR5</th>
PRO <th>ATTR6</th>
PRO <th>ATTR7</th>
PRO <th>ATTR8</th>
PRO <th>ATTR9</th>
PRO <th>ATTR10</th>
PRO <th>ATTR11</th>
PRO <th>ATTR16</th>
PRO <th>ATTR17</th>
PRO <th>ATTR18</th>
PRO <th>OTHER</th>
PRO <th>ADV_SQL_ID</th>
PRO
PRO </table>
PRO

--KDRUPARE AH-3084 end


select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

--PSRv10 Replaced with PlanControl section /* -------------------------
--PSRv10 Replaced with PlanControl section  *
--PSRv10 Replaced with PlanControl section  * dba_sql_plan_baselines
--PSRv10 Replaced with PlanControl section  *
--PSRv10 Replaced with PlanControl section  * ------------------------- */
--PSRv10 Replaced with PlanControl section PRO <a name="spm"></a><br/><summary id="summary2">SQL Plan Baselines (DBA_SQL_PLAN_BASELINES)</summary>
--PSRv10 Replaced with PlanControl section PRO
--PSRv10 Replaced with PlanControl section PRO Available on 11g or higher. If this section is empty that means there are no plans in plan history for this SQL.
--PSRv10 Replaced with PlanControl section PRO
--PSRv10 Replaced with PlanControl section SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
--PSRv10 Replaced with PlanControl section PRO <!-- Please Wait -->
--PSRv10 Replaced with PlanControl section 
--PSRv10 Replaced with PlanControl section SET HEA ON PAGES 50 MARK HTML ON TABLE "" SPOOL OFF;
--PSRv10 Replaced with PlanControl section COL signature FOR 99999999999999999999;
--PSRv10 Replaced with PlanControl section SELECT ROWNUM "#", v.* FROM (SELECT /*+ NO_MERGE */ * FROM dba_sql_plan_baselines WHERE signature IN (^^signature., ^^signaturef.) ORDER BY created, plan_name) v;
--PSRv10 Replaced with PlanControl section SET HEA OFF PAGES 0 MARK HTML OFF;
--PSRv10 Replaced with PlanControl section 
--PSRv10 Replaced with PlanControl section /* -------------------------
--PSRv10 Replaced with PlanControl section  *
--PSRv10 Replaced with PlanControl section  * dba_sql_profiles
--PSRv10 Replaced with PlanControl section  *
--PSRv10 Replaced with PlanControl section  * ------------------------- */
--PSRv10 Replaced with PlanControl section PRO <a name="prof"></a><br/><summary id="summary2">SQL Profiles (DBA_SQL_PROFILES)</summary>
--PSRv10 Replaced with PlanControl section PRO
--PSRv10 Replaced with PlanControl section PRO Available on 10g or higher. If this section is empty that means there are no profiles for this SQL.
--PSRv10 Replaced with PlanControl section PRO
--PSRv10 Replaced with PlanControl section SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
--PSRv10 Replaced with PlanControl section PRO <!-- Please Wait -->
--PSRv10 Replaced with PlanControl section 
--PSRv10 Replaced with PlanControl section SET HEA ON PAGES 50 MARK HTML ON TABLE "" SPOOL OFF;
--PSRv10 Replaced with PlanControl section COL signature FOR 99999999999999999999;
--PSRv10 Replaced with PlanControl section SELECT ROWNUM "#", v.* FROM (SELECT /*+ NO_MERGE */ * FROM dba_sql_profiles WHERE signature IN (^^signature., ^^signaturef.) ORDER BY created, name) v;
--PSRv10 Replaced with PlanControl section SET HEA OFF PAGES 0 MARK HTML OFF;
--PSRv10 Replaced with PlanControl section 
--PSRv10 Replaced with PlanControl section /* -------------------------
--PSRv10 Replaced with PlanControl section  *
--PSRv10 Replaced with PlanControl section  * dba_sql_patches
--PSRv10 Replaced with PlanControl section  *
--PSRv10 Replaced with PlanControl section  * ------------------------- */
--PSRv10 Replaced with PlanControl section PRO <a name="patch"></a><br/><summary id="summary2">SQL Patches (DBA_SQL_PATCHES)</summary>
--PSRv10 Replaced with PlanControl section PRO
--PSRv10 Replaced with PlanControl section PRO Available on 11g or higher. If this section is empty that means there are no patches for this SQL.
--PSRv10 Replaced with PlanControl section PRO
--PSRv10 Replaced with PlanControl section SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
--PSRv10 Replaced with PlanControl section PRO <!-- Please Wait -->
--PSRv10 Replaced with PlanControl section 
--PSRv10 Replaced with PlanControl section SET HEA ON PAGES 50 MARK HTML ON TABLE "" SPOOL OFF;
--PSRv10 Replaced with PlanControl section COL signature FOR 99999999999999999999;
--PSRv10 Replaced with PlanControl section SELECT ROWNUM "#", v.* FROM (SELECT /*+ NO_MERGE */ * FROM dba_sql_patches WHERE signature IN (^^signature., ^^signaturef.) ORDER BY created, name) v;
--PSRv10 Replaced with PlanControl section SET HEA OFF PAGES 0 MARK HTML OFF;


/* -------------------------
 *
 * Monitored Execution
 * top 10 by status (desc order by sql exec start)
 * PSR v10
 *
 * ------------------------- */
PRO <a name="monitored_execs"></a><details open><br/><summary id="summary2">Monitored Executions</summary>
PRO
PRO Recent 10 executions by Status
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Status</th>
PRO <th>SQL Exec Start</th>
PRO <th>SQL Exec ID</th>
PRO <th>PHV</th>
PRO <th>Last Refresh Time</th>
PRO <th>BufferGets</th>
PRO <th>Rows Proc.<br>All Lines</th>
PRO <th>Rows Selected<br>Final Result Set</th>
PRO <th>Elapsed<br>Sec</th>
PRO <th>CPU<br>Sec</th>
PRO <th>CPU<br>%</th>
PRO <th>Appl<br>Sec</th>
PRO <th>Appl<br>%</th>
PRO <th>Conc<br>Sec</th>
PRO <th>Conc<br>%</th>
PRO <th>Cluster<br>Sec</th>
PRO <th>Cluster<br>%</th>
PRO <th>IO<br>Sec</th>
PRO <th>IO<br>%</th>
PRO <th>PL/SQL<br>Sec</th>
PRO <th>PL/SQL<br>%</th>
PRO <th>Error Message</th>
PRO </tr>
PRO

SELECT 
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       case when status like '%ERROR%' then
         '<td style="color: red;">'||Status        ||'</td>'
            when status like '%EXECU%' then
         '<td style="color: green;">'||Status        ||'</td>'
       else
         '<td >'||Status        ||'</td>'
       end || chr(10)||
       '<td >'||sql_exec_start      ||'</td>'||CHR(10)||
       '<td class="r">'||sql_exec_id         ||'</td>'||CHR(10)||
       '<td class="r">'||phv         ||'</td>'||CHR(10)||
       '<td >'||last_refresh_time   ||'</td>'||CHR(10)||
       '<td class="r">'||buffer_gets         ||'</td>'||CHR(10)||
       '<td class="r">'||rowsp               ||'</td>'||CHR(10)||
       '<td class="r">'||rowsel              ||'</td>'||CHR(10)||
       '<td class="r">'||elapsed_sec         ||'</td>'||CHR(10)||
       '<td class="r">'||cpu_sec             ||'</td>'||CHR(10)||
       '<td class="r">'||pct_cpu             ||'</td>'||CHR(10)||
       '<td class="r">'||applwt_sec          ||'</td>'||CHR(10)||
       '<td class="r">'||pct_applwt          ||'</td>'||CHR(10)||
       '<td class="r">'||concwt_sec          ||'</td>'||CHR(10)||
       '<td class="r">'||pct_concwt          ||'</td>'||CHR(10)||
       '<td class="r">'||cluswt_sec          ||'</td>'||CHR(10)||
       '<td class="r">'||pct_cluswt          ||'</td>'||CHR(10)||
       '<td class="r">'||iowt_sec            ||'</td>'||CHR(10)||
       '<td class="r">'||pct_iowt            ||'</td>'||CHR(10)||
       '<td class="r">'||plsqlwt_sec         ||'</td>'||CHR(10)||
       '<td class="r">'||pct_plsqlwt         ||'</td>'||CHR(10)||
       '<td >'||error_message       ||'</td>'||CHR(10)||
       '</tr>'
  FROM ( 
          select status,
                 sql_exec_start,
                 sql_exec_id,
                 phv,
                 last_refresh_time,
                 buffer_gets,
                 rowsp,
                 rowsel,
                 elapsed_sec,
                 cpu_sec,
                 pct_cpu,
                 applwt_sec,
                 pct_applwt,
                 concwt_sec,
                 pct_concwt,
                 cluswt_sec,
                 pct_cluswt,
                 iowt_sec,
                 pct_iowt,
                 plsqlwt_sec,
                 pct_plsqlwt,
                 error_message
          from (
                select status,
                       to_char(sql_exec_start,'DD-MON-YY HH24:MI:SS') sql_exec_start,
                       sql_exec_id,
                       sql_plan_hash_value phv,
                       to_char(last_refresh_time, 'DD-MON-YY HH24:MI:SS') last_refresh_time,
                       to_char(buffer_gets,'999,999,999,999,999') buffer_gets,
                       round(elapsed_time/1000000,2) elapsed_sec,
                       round(cpu_time/1000000,2) cpu_sec,
                       round(application_wait_time/1000000,2) applwt_sec,
                       round(concurrency_wait_time/1000000,2) concwt_sec,
                       round(cluster_wait_time/1000000,2) cluswt_sec,
                       round(user_io_wait_time/1000000,2) iowt_sec,
                       round(plsql_exec_time/1000000,2) plsqlwt_sec,
                       round(100*cpu_time/elapsed_time, 2) pct_cpu,
                       round(100*application_wait_time/elapsed_time, 2) pct_applwt,
                       round(100*concurrency_wait_time/elapsed_time, 2) pct_concwt,
                       round(100*cluster_wait_time/elapsed_time, 2) pct_cluswt,
                       round(100*user_io_wait_time/elapsed_time, 2) pct_iowt,
                       round(100*plsql_exec_time/elapsed_time, 2) pct_plsqlwt,
                       (select to_char(sum(nvl(output_rows,0)),'999,999,999,999,999')
                          from gv$sql_plan_monitor pm
                          where pm.inst_id = sm.inst_id and pm.key = pm.key and pm.sql_id = sm.sql_id and pm.SQL_PLAN_HASH_VALUE = sm.SQL_PLAN_HASH_VALUE
                          and pm.sql_exec_start = sm.sql_exec_start
                          and rownum = 1
                       ) rowsp,
                       (select to_char(nvl(output_rows,0),'999,999,999,999,999')
                          from gv$sql_plan_monitor pm
                          where pm.inst_id = sm.inst_id and pm.key = pm.key and pm.sql_id = sm.sql_id and pm.SQL_PLAN_HASH_VALUE = sm.SQL_PLAN_HASH_VALUE
                          and pm.sql_exec_start = sm.sql_exec_start
                          and pm.plan_line_id = 0
                          and rownum = 1
                       ) rowsel,
                       error_message,
                       sm.inst_id||'/'||sm.sid||'/'||sm.session_serial#,
                       rank() over (partition by status order by sql_exec_start desc) rk
                  from gv$sql_monitor sm
                  where sm.sql_id = :sql_id
                  and sm.sql_exec_start is not null
               )
         where rk <= 10
         order by (case when status = 'EXECUTING' then '1' when status = 'DONE (ERROR)' then '2' else status end)
                   , sql_exec_start desc
       ) v
;
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Status</th>
PRO <th>SQL Exec Start</th>
PRO <th>SQL Exec ID</th>
PRO <th>PHV</th>
PRO <th>Last Refresh Time</th>
PRO <th>BufferGets</th>
PRO <th>Rows Proc.<br>All Lines</th>
PRO <th>Rows Selected<br>Final Result Set</th>
PRO <th>Elapsed<br>Sec</th>
PRO <th>CPU<br>Sec</th>
PRO <th>CPU<br>%</th>
PRO <th>Appl<br>Sec</th>
PRO <th>Appl<br>%</th>
PRO <th>Conc<br>Sec</th>
PRO <th>Conc<br>%</th>
PRO <th>Cluster<br>Sec</th>
PRO <th>Cluster<br>%</th>
PRO <th>IO<br>Sec</th>
PRO <th>IO<br>%</th>
PRO <th>PL/SQL<br>Sec</th>
PRO <th>PL/SQL<br>%</th>
PRO <th>Error Message</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * cursor sharing reason
 *
 * ------------------------- */
PRO <a name="share_r"></a><details open><br/><summary id="summary2">Cursor Sharing and Reason (GV$SQL_SHARED_CURSOR)</summary>
PRO
PRO Collected from GV$SQL_SHARED_CURSOR.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Reason</th>
PRO <th>Inst</th>
PRO <th>Cursors</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

@sql_shared_cursor_sum_^^sql_id..sql;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Reason</th>
PRO <th>Inst</th>
PRO <th>Cursors</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * cursor sharing list
 *
 * ------------------------- */
PRO <a name="share_l"></a><details open><br/><summary id="summary2">Cursor Sharing List (GV$SQL_SHARED_CURSOR)</summary>
PRO
PRO Collected from GV$SQL_SHARED_CURSOR.
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SET HEA ON PAGES 50 MARK HTML ON TABLE "" SPOOL OFF;

@sql_shared_cursor_cur_^^sql_id..sql;

SET HEA OFF PAGES 0 MARK HTML OFF;


select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details> <!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * gv$sql plans summary
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Plans Summary and Plan Statistics - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="mem_plans_sum"></a><details open><br/><summary id="summary2">Current Plans Summary (GV$SQL)</summary>
PRO
PRO Execution Plans performance metrics for ^^sql_id. while still in memory. Plans ordered by average elapsed time.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan HV</th>
PRO <th>Avg<br>Elapsed<br>Time<br>(secs)</th>
PRO <th>Avg<br>CPU<br>Time<br>(secs)</th>
PRO <th>Avg<br>IO<br>Time<br>(secs)</th>
PRO <th>Avg<br>Conc<br>Time<br>(secs)</th>
PRO <th>Avg<br>Appl<br>Time<br>(secs)</th>
PRO <th>Avg<br>Clus<br>Time<br>(secs)</th>
PRO <th>Avg<br>PLSQL<br>Time<br>(secs)</th>
PRO <th>Avg<br>Java<br>Time<br>(secs)</th>
PRO <th>Avg<br>Buffer<br>Gets</th>
PRO <th>Avg<br>Disk<br>Reads</th>
PRO <th>Avg<br>Direct<br>Writes</th>
PRO <th>Avg<br>Rows<br>Proc</th>
PRO <th>Total<br>Execs</th>
PRO <th>Total<br>Fetch</th>
PRO <th>Total<br>Loads</th>
PRO <th>Total<br>Inval</th>
PRO <th>Total<br>Parse<br>Calls</th>
PRO <th>Total<br>Child<br>Cursors</th>
PRO <th>Min<br>Cost</th>
PRO <th>Max<br>Cost</th>
PRO <th>Min<br>Opt Env HV</th>
PRO <th>Max<br>Opt Env HV</th>
PRO <th>First Load</th>
PRO <th>Last Load</th>
PRO <th>Last Active</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_elapsed_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_cpu_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_user_io_wait_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_concurrency_wait_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_application_wait_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_cluster_wait_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_plsql_exec_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_java_exec_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_buffer_gets||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_disk_reads||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_direct_writes||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_rows_processed||'</td>'||CHR(10)||
       '<td class="r">'||v.total_executions||'</td>'||CHR(10)||
       '<td class="r">'||v.total_fetches||'</td>'||CHR(10)||
       '<td class="r">'||v.total_loads||'</td>'||CHR(10)||
       '<td class="r">'||v.total_invalidations||'</td>'||CHR(10)||
       '<td class="r">'||v.total_parse_calls||'</td>'||CHR(10)||
       '<td class="r">'||v.child_cursors||'</td>'||CHR(10)||
       '<td class="r">'||v.min_optimizer_cost||'</td>'||CHR(10)||
       '<td class="r">'||DECODE(v.min_optimizer_cost, v.max_optimizer_cost, NULL, v.max_optimizer_cost)||'</td>'||CHR(10)||
       '<td class="r">'||v.min_optimizer_env_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||DECODE(v.min_optimizer_env_hash_value, v.max_optimizer_env_hash_value, NULL, v.max_optimizer_env_hash_value)||'</td>'||CHR(10)||
       '<td nowrap>'||v.first_load_time||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_load_time||'</td>'||CHR(10)||
       '<td nowrap>'||TO_CHAR(v.last_active_time, 'YYYY-MM-DD/HH24:MI:SS')||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       plan_hash_value,
       ROUND((SUM(elapsed_time)/SUM(GREATEST(executions, 1))) / 1e6, 3) avg_elapsed_time_secs,
       ROUND((SUM(cpu_time)/SUM(GREATEST(executions, 1))) / 1e6, 3) avg_cpu_time_secs,
       ROUND((SUM(user_io_wait_time)/SUM(GREATEST(executions, 1))) / 1e6, 3) avg_user_io_wait_time_secs,
       ROUND((SUM(concurrency_wait_time)/SUM(GREATEST(executions, 1))) / 1e6, 3) avg_concurrency_wait_time_secs,
       ROUND((SUM(application_wait_time)/SUM(GREATEST(executions, 1))) / 1e6, 3) avg_application_wait_time_secs,
       ROUND((SUM(cluster_wait_time)/SUM(GREATEST(executions, 1))) / 1e6, 3) avg_cluster_wait_time_secs,
       ROUND((SUM(plsql_exec_time)/SUM(GREATEST(executions, 1))) / 1e6, 3) avg_plsql_exec_time_secs,
       ROUND((SUM(java_exec_time)/SUM(GREATEST(executions, 1))) / 1e6, 3) avg_java_exec_time_secs,
       ROUND(SUM(buffer_gets)/SUM(GREATEST(executions, 1))) avg_buffer_gets,
       ROUND(SUM(disk_reads)/SUM(GREATEST(executions, 1))) avg_disk_reads,
       ROUND(SUM(direct_writes)/SUM(GREATEST(executions, 1))) avg_direct_writes,
       ROUND(SUM(rows_processed)/SUM(GREATEST(executions, 1))) avg_rows_processed,
       SUM(GREATEST(executions, 1)) total_executions,
       SUM(fetches) total_fetches,
       SUM(loads) total_loads,
       SUM(invalidations) total_invalidations,
       SUM(parse_calls) total_parse_calls,
       COUNT(*) child_cursors,
       MIN(optimizer_cost) min_optimizer_cost,
       MAX(optimizer_cost) max_optimizer_cost,
       MIN(optimizer_env_hash_value) min_optimizer_env_hash_value,
       MAX(optimizer_env_hash_value) max_optimizer_env_hash_value,
       MIN(first_load_time) first_load_time,
       MAX(last_load_time) last_load_time,
       MAX(last_active_time) last_active_time
  FROM gv$sql
 WHERE sql_id = :sql_id
 GROUP BY
       plan_hash_value
 ORDER BY
       2) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan HV</th>
PRO <th>Avg<br>Elapsed<br>Time<br>(secs)</th>
PRO <th>Avg<br>CPU<br>Time<br>(secs)</th>
PRO <th>Avg<br>IO<br>Time<br>(secs)</th>
PRO <th>Avg<br>Conc<br>Time<br>(secs)</th>
PRO <th>Avg<br>Appl<br>Time<br>(secs)</th>
PRO <th>Avg<br>Clus<br>Time<br>(secs)</th>
PRO <th>Avg<br>PLSQL<br>Time<br>(secs)</th>
PRO <th>Avg<br>Java<br>Time<br>(secs)</th>
PRO <th>Avg<br>Buffer<br>Gets</th>
PRO <th>Avg<br>Disk<br>Reads</th>
PRO <th>Avg<br>Direct<br>Writes</th>
PRO <th>Avg<br>Rows<br>Proc</th>
PRO <th>Total<br>Execs</th>
PRO <th>Total<br>Fetch</th>
PRO <th>Total<br>Loads</th>
PRO <th>Total<br>Inval</th>
PRO <th>Total<br>Parse<br>Calls</th>
PRO <th>Total<br>Child<br>Cursors</th>
PRO <th>Min<br>Cost</th>
PRO <th>Max<br>Cost</th>
PRO <th>Min<br>Opt Env HV</th>
PRO <th>Max<br>Opt Env HV</th>
PRO <th>First Load</th>
PRO <th>Last Load</th>
PRO <th>Last Active</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * gv$sql sql statistics
 *
 * ------------------------- */
PRO <a name="mem_stats"></a><details open><br/><summary id="summary2">Current SQL Statistics (GV$SQL)</summary>
PRO
PRO Performance metrics of child cursors of ^^sql_id. while still in memory.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Inst<br>ID</th>
PRO <th>Child<br>Num</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Execs</th>
PRO <th>Fetch</th>
PRO <th>Loads<br>(Hard<br>Parses)</th>
PRO <th>Inval</th>
PRO <th>Parse<br>Calls</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Avg<br>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Direct<br>Writes</th>
PRO <th>Rows<br>Proc</th>
PRO <th>Elapsed<br>Time<br>(secs)</th>
PRO <th>CPU<br>Time<br>(secs)</th>
PRO <th>Avg<br>Elapsed<br>Time<br>(secs)</th>
PRO <th>Avg<br>CPU<br>Time<br>(secs)</th>
PRO <th>Avg Hard<br>Parse Time<br>(secs)<br>-AHP-</th>
PRO <th>Hard<br>Parses<br>for AHP</th>
PRO <th>IO<br>Time<br>(secs)</th>
PRO <th>Conc<br>Time<br>(secs)</th>
PRO <th>Appl<br>Time<br>(secs)</th>
PRO <th>Clus<br>Time<br>(secs)</th>
PRO <th>PLSQL<br>Time<br>(secs)</th>
PRO <th>Java<br>Time<br>(secs)</th>
PRO <th>Module</th>
PRO <th>Action</th>
PRO <th>Profile</th>
PRO <th>Patch</th>
PRO <th>Sql<br>Plan<br>Baseline</th>
PRO <th>First Hard Parse</th>
PRO <th>Last Hard Parse</th>
PRO <th>Last Active</th>
PRO <th>Optimizer<br>Mode</th>
PRO <th>Cost</th>
PRO <th>Opt Env HV</th>
PRO <th>Parsing<br>Schema<br>Name</th>
PRO <th>End<br>Of<br>Fetch<br>Count</th>
PRO <th>Obsolete?</th>
PRO <th>Bind<br>Sensitive?</th>
PRO <th>Bind<br>Aware?</th>
PRO <th>Shareable?</th>
PRO <th>Reoptimizable?</th>
PRO <th>Resolved<br>Adaptive<br>Plan?</th>
PRO <th>Plan<br>Notes</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

with hp as
(select /*+ materialize */ inst_id, loads, TO_CHAR(ROUND(avg_hard_parse_time / 1e6, 3), '99999999999990D990') hpt 
   from gv$sqlstats ss 
  where ss.sql_id = :sql_id
)
SELECT /*+ leading(s) */  
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||s.inst_id||'</td>'||CHR(10)||
       '<td class="r">'||s.child_number||'</td>'||CHR(10)||
       '<td class="r">'||s.plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||s.executions||'</td>'||CHR(10)||
       '<td class="r">'||s.fetches||'</td>'||CHR(10)||
       '<td class="r">'||s.loads||'</td>'||CHR(10)||
       '<td class="r">'||s.invalidations||'</td>'||CHR(10)||
       '<td class="r">'||s.parse_calls||'</td>'||CHR(10)||
       '<td class="r">'||s.buffer_gets||'</td>'||CHR(10)||
       '<td class="r">'||round(s.buffer_gets/GREATEST(executions, 1))||'</td>'||CHR(10)||
       '<td class="r">'||s.disk_reads||'</td>'||CHR(10)||
       '<td class="r">'||s.direct_writes||'</td>'||CHR(10)||
       '<td class="r">'||s.rows_processed||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.elapsed_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.cpu_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.elapsed_time / 1e6/GREATEST(executions, 1), 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.cpu_time / 1e6/GREATEST(executions, 1), 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||hp.hpt||'</td>'||CHR(10)||
       '<td class="r">'||hp.loads||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.user_io_wait_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.concurrency_wait_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.application_wait_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.cluster_wait_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.plsql_exec_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(s.java_exec_time / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td>'||s.module||'</td>'||CHR(10)||
       '<td>'||s.action||'</td>'||CHR(10)||
       '<td>'||s.sql_profile||'</td>'||CHR(10)||
       '<td>'||s.sql_patch||'</td>'||CHR(10)||
       '<td>'||s.sql_plan_baseline||'</td>'||CHR(10)||
       '<td nowrap>'||s.first_load_time||'</td>'||CHR(10)||
       '<td nowrap>'||s.last_load_time||'</td>'||CHR(10)||
       '<td nowrap>'||TO_CHAR(s.last_active_time, 'YYYY-MM-DD/HH24:MI:SS')||'</td>'||CHR(10)||
       '<td>'||s.optimizer_mode||'</td>'||CHR(10)||
       '<td class="r">'||s.optimizer_cost||'</td>'||CHR(10)||
       '<td class="r">'||s.optimizer_env_hash_value||'</td>'||CHR(10)||
       '<td>'||s.parsing_schema_name||'</td>'||CHR(10)||
--PSRv10 start
      '<td class="r">'||s.END_OF_FETCH_COUNT||'</td>'||CHR(10)||
       '<td>'||IS_OBSOLETE||'</td>'||CHR(10)||
       '<td>'||IS_BIND_SENSITIVE||'</td>'||CHR(10)||
       '<td>'||IS_BIND_AWARE||'</td>'||CHR(10)||
       '<td>'||IS_SHAREABLE||'</td>'||CHR(10)||
       '<td>'||IS_REOPTIMIZABLE||'</td>'||CHR(10)||
       '<td>'||IS_RESOLVED_ADAPTIVE_PLAN||'</td>'||CHR(10)||
       '<td nowrap>'||(select listagg(type,'<br>') within group (order by 1)
                       from gv$sql_plan a, xmltable('other_xml/info[@note="y"]' passing xmltype(other_xml) 
                             columns type clob path  '@type') b
                      where inst_id=s.inst_id
                        and sql_id=s.sql_id
                        and plan_hash_value=s.plan_hash_value
                        and child_number=s.child_number
                        and other_xml is NOT null
                   group by inst_id, sql_id, plan_hash_value, child_number) ||'</td>'||CHR(10)||       
--PSRv10 end
       '</tr>'
  FROM gv$sql s, hp
 WHERE sql_id = :sql_id
   and s.inst_id = hp.inst_id
 ORDER BY
       s.inst_id,
       s.child_number;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Inst<br>ID</th>
PRO <th>Child<br>Num</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Execs</th>
PRO <th>Fetch</th>
PRO <th>Loads<br>(Hard<br>Parses)</th>
PRO <th>Inval</th>
PRO <th>Parse<br>Calls</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Avg<br>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Direct<br>Writes</th>
PRO <th>Rows<br>Proc</th>
PRO <th>Elapsed<br>Time<br>(secs)</th>
PRO <th>CPU<br>Time<br>(secs)</th>
PRO <th>Avg<br>Elapsed<br>Time<br>(secs)</th>
PRO <th>Avg<br>CPU<br>Time<br>(secs)</th>
PRO <th>Avg Hard<br>Parse Time<br>(secs)<br>-AHP-</th>
PRO <th>Hard<br>Parses<br>for AHP</th>
PRO <th>IO<br>Time<br>(secs)</th>
PRO <th>Conc<br>Time<br>(secs)</th>
PRO <th>Appl<br>Time<br>(secs)</th>
PRO <th>Clus<br>Time<br>(secs)</th>
PRO <th>PLSQL<br>Time<br>(secs)</th>
PRO <th>Java<br>Time<br>(secs)</th>
PRO <th>Module</th>
PRO <th>Action</th>
PRO <th>Profile</th>
PRO <th>Patch</th>
PRO <th>Sql<br>Plan<br>Baseline</th>
PRO <th>First Hard Parse</th>
PRO <th>Last Hard Parse</th>
PRO <th>Last Active</th>
PRO <th>Optimizer<br>Mode</th>
PRO <th>Cost</th>
PRO <th>Opt Env HV</th>
PRO <th>Parsing<br>Schema<br>Name</th>
PRO <th>End<br>Of<br>Fetch<br>Count</th>
PRO <th>Obsolete?</th>
PRO <th>Bind<br>Sensitive?</th>
PRO <th>Bind<br>Aware?</th>
PRO <th>Shareable?</th>
PRO <th>Reoptimizable?</th>
PRO <th>Resolved<br>Adaptive<br>Plan?</th>
PRO <th>Plan<br>Notes</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

REM Pushkar
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: gv$sql_reoptimization_hints - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="reoptimization_hints"></a><details open><br/><summary id="summary2">Reoptimization Hints (GV$SQL_REOPTIMIZATION_HINTS)</summary>
PRO
PRO Reoptimization Hints for ^^sql_id. (Currently limited to Cardinality Estimates).
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>Inst<br>ID</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Child<br>Number</th>
PRO <th>Hint ID</th>
PRO <th>Hint Text</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||v.inst_id||'</td>'||CHR(10)||
       '<td class="r">'||v.HASH_VALUE||'</td>'||CHR(10)||
       '<td class="r">'||v.CHILD_NUMBER||'</td>'||CHR(10)||
       '<td class="r">'||v.HINT_ID||'</td>'||CHR(10)||
       '<td>'          ||v.HINT_TEXT||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        select
          INST_ID      ,
          ADDRESS      ,
          HASH_VALUE   ,
          SQL_ID       ,
          CHILD_NUMBER ,
          HINT_ID      ,
          HINT_TEXT    ,
          CLIENT_ID    ,
          REPARSE      ,
          CON_ID       
        from gv$sql_reoptimization_hints
        where sql_id=:sql_id
      ) v
  ORDER BY v.inst_id, v.child_number, v.hint_id;
  
PRO
PRO <tr>
PRO <th>Inst<br>ID</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Child<br>Number</th>
PRO <th>Hint ID</th>
PRO <th>Hint Text</th>
PRO </tr>
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * dba_hist_sqlstat plans summary
 *
 * ------------------------- */
PRO <a name="awr_plans_sum"></a><details open><br/><summary id="summary2">Historical Plans Summary (DBA_HIST_SQLSTAT)</summary>
PRO
PRO Performance metrics of Execution Plans of ^^sql_id.. Plans ordered by average elapsed time.<br>
PRO This section includes data captured by AWR. If this is a stand-by read-only database then the AWR information below is from the Primary database.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan HV</th>
PRO <th>Avg<br>Elapsed<br>Time<br>(secs)</th>
PRO <th>Avg<br>CPU<br>Time<br>(secs)</th>
PRO <th>Avg<br>IO<br>Time<br>(secs)</th>
PRO <th>Avg<br>Conc<br>Time<br>(secs)</th>
PRO <th>Avg<br>Appl<br>Time<br>(secs)</th>
PRO <th>Avg<br>Clus<br>Time<br>(secs)</th>
PRO <th>Avg<br>PLSQL<br>Time<br>(secs)</th>
PRO <th>Avg<br>Java<br>Time<br>(secs)</th>
PRO <th>Avg<br>Buffer<br>Gets</th>
PRO <th>Avg<br>Disk<br>Reads</th>
PRO <th>Avg<br>Direct<br>Writes</th>
PRO <th>Avg<br>Rows<br>Proc</th>
PRO <th>Total<br>Execs</th>
--PRO <th>Total<br>Fetch</th>
--PRO <th>Total<br>Loads</th>
--PRO <th>Total<br>Inval</th>
--PRO <th>Total<br>Parse<br>Calls</th>
PRO <th>Min<br>Cost</th>
PRO <th>Max<br>Cost</th>
PRO <th>Min<br>Opt Env HV</th>
PRO <th>Max<br>Opt Env HV</th>
PRO <th>First Snapshot</th>
PRO <th>Last Snapshot</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_elapsed_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_cpu_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_user_io_wait_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_concurrency_wait_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_application_wait_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_cluster_wait_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_plsql_exec_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(v.avg_java_exec_time_secs, '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_buffer_gets||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_disk_reads||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_direct_writes||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_rows_processed||'</td>'||CHR(10)||
       '<td class="r">'||v.delta_executions||'</td>'||CHR(10)||
       --'<td class="r">'||v.delta_fetches||'</td>'||CHR(10)||
       --'<td class="r">'||v.delta_loads||'</td>'||CHR(10)||
       --'<td class="r">'||v.delta_invalidations||'</td>'||CHR(10)||
       --'<td class="r">'||v.delta_parse_calls||'</td>'||CHR(10)||
       '<td class="r">'||v.min_optimizer_cost||'</td>'||CHR(10)||
       '<td class="r">'||DECODE(v.min_optimizer_cost, v.max_optimizer_cost, NULL, v.max_optimizer_cost)||'</td>'||CHR(10)||
       '<td class="r">'||v.min_optimizer_env_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||DECODE(v.min_optimizer_env_hash_value, v.max_optimizer_env_hash_value, NULL, v.max_optimizer_env_hash_value)||'</td>'||CHR(10)||
       '<td nowrap>'||TO_CHAR(v.first_snap_time, 'YYYY-MM-DD/HH24:MI:SS')||'</td>'||CHR(10)||
       '<td nowrap>'||TO_CHAR(v.last_snap_time, 'YYYY-MM-DD/HH24:MI:SS')||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       h.plan_hash_value,
       ROUND((SUM(h.elapsed_time_delta)/SUM(GREATEST(h.executions_delta, 1))) / 1e6, 3) avg_elapsed_time_secs,
       ROUND((SUM(h.cpu_time_delta)/SUM(GREATEST(h.executions_delta, 1))) / 1e6, 3) avg_cpu_time_secs,
       ROUND((SUM(h.iowait_delta)/SUM(GREATEST(h.executions_delta, 1))) / 1e6, 3) avg_user_io_wait_time_secs,
       ROUND((SUM(h.ccwait_delta)/SUM(GREATEST(h.executions_delta, 1))) / 1e6, 3) avg_concurrency_wait_time_secs,
       ROUND((SUM(h.apwait_delta)/SUM(GREATEST(h.executions_delta, 1))) / 1e6, 3) avg_application_wait_time_secs,
       ROUND((SUM(h.clwait_delta)/SUM(GREATEST(h.executions_delta, 1))) / 1e6, 3) avg_cluster_wait_time_secs,
       ROUND((SUM(h.plsexec_time_delta)/SUM(GREATEST(h.executions_delta, 1))) / 1e6, 3) avg_plsql_exec_time_secs,
       ROUND((SUM(h.javexec_time_delta)/SUM(GREATEST(h.executions_delta, 1))) / 1e6, 3) avg_java_exec_time_secs,
       ROUND(SUM(h.buffer_gets_delta)/SUM(GREATEST(h.executions_delta, 1))) avg_buffer_gets,
       ROUND(SUM(h.disk_reads_delta)/SUM(GREATEST(h.executions_delta, 1))) avg_disk_reads,
       ROUND(SUM(h.direct_writes_delta)/SUM(GREATEST(h.executions_delta, 1))) avg_direct_writes,
       ROUND(SUM(h.rows_processed_delta)/SUM(GREATEST(h.executions_delta, 1))) avg_rows_processed,
       SUM(GREATEST(h.executions_delta, 1)) delta_executions,
       --SUM(h.fetches_delta) delta_fetches,
       --SUM(h.loads_delta) delta_loads,
       --SUM(h.invalidations_delta) delta_invalidations,
       --SUM(h.parse_calls_delta) delta_parse_calls,
       MIN(h.optimizer_cost) min_optimizer_cost,
       MAX(h.optimizer_cost) max_optimizer_cost,
       MIN(h.optimizer_env_hash_value) min_optimizer_env_hash_value,
       MAX(h.optimizer_env_hash_value) max_optimizer_env_hash_value,
       MIN(s.end_interval_time) first_snap_time,
       MAX(s.end_interval_time) last_snap_time
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license IN ('T', 'D')
   AND h.dbid = ^^dbid.
   AND h.sql_id = :sql_id
   AND h.snap_id = s.snap_id
   AND h.dbid = s.dbid
   AND h.instance_number = s.instance_number
 GROUP BY
       h.plan_hash_value
 ORDER BY
       2) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan HV</th>
PRO <th>Avg<br>Elapsed<br>Time<br>(secs)</th>
PRO <th>Avg<br>CPU<br>Time<br>(secs)</th>
PRO <th>Avg<br>IO<br>Time<br>(secs)</th>
PRO <th>Avg<br>Conc<br>Time<br>(secs)</th>
PRO <th>Avg<br>Appl<br>Time<br>(secs)</th>
PRO <th>Avg<br>Clus<br>Time<br>(secs)</th>
PRO <th>Avg<br>PLSQL<br>Time<br>(secs)</th>
PRO <th>Avg<br>Java<br>Time<br>(secs)</th>
PRO <th>Avg<br>Buffer<br>Gets</th>
PRO <th>Avg<br>Disk<br>Reads</th>
PRO <th>Avg<br>Direct<br>Writes</th>
PRO <th>Avg<br>Rows<br>Proc</th>
PRO <th>Total<br>Execs</th>
--PRO <th>Total<br>Fetch</th>
--PRO <th>Total<br>Loads</th>
--PRO <th>Total<br>Inval</th>
--PRO <th>Total<br>Parse<br>Calls</th>
PRO <th>Min<br>Cost</th>
PRO <th>Max<br>Cost</th>
PRO <th>Min<br>Opt Env HV</th>
PRO <th>Max<br>Opt Env HV</th>
PRO <th>First Snapshot</th>
PRO <th>Last Snapshot</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * dba_hist_sqlstat sql statistics
 * psrv9: fixed error ORA-06502 while extracting other_xml. 
 *        Other_XML could be present on any line, not necessarity on id=1
 *
 * ------------------------- */
PRO <a name="awr_stats_d"></a><details open><br/><summary id="summary2">Historical SQL Statistics - Delta (DBA_HIST_SQLSTAT)</summary>
PRO
PRO Performance metrics of Execution Plans of ^^sql_id..<br>
PRO This section includes data captured by AWR. If this is a stand-by read-only database then the AWR information below is from the Primary database.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Snap<br>ID</th>
PRO <th>Pre/Post<br>EBR</th>
PRO <th>Snaphot</th>
PRO <th>Inst<br>ID</th>
PRO <th>Plan HV</th>
PRO <th>Vers<br>Cnt</th>
PRO <th>Execs</th>
PRO <th>Fetch</th>
PRO <th>Loads</th>
PRO <th>Inval</th>
PRO <th>Parse<br>Calls</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Avg<br>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Avg<br>Disk<br>Reads</th>
PRO <th>Direct<br>Writes</th>
PRO <th>Rows<br>Proc</th>
PRO <th>Avg<br>Rows</th>
PRO <th>Elapsed<br>Time<br>(secs)</th>
PRO <th>Avg<br>Elapsed<br>Time<br>(secs)</th>
PRO <th>CPU<br>Time<br>(secs)</th>
PRO <th>Avg<br>CPU<br>Time<br>(secs)</th>
PRO <th>%CPU</th>
PRO <th>IO<br>Time<br>(secs)</th>
PRO <th>%IO</th>
PRO <th>Conc<br>Time<br>(secs)</th>
PRO <th>%Conc</th>
PRO <th>Appl<br>Time<br>(secs)</th>
PRO <th>%Appl</th>
PRO <th>Clus<br>Time<br>(secs)</th>
PRO <th>%Clus</th>
PRO <th>PLSQL<br>Time<br>(secs)</th>
PRO <th>%PLSQL</th>
PRO <th>Java<br>Time<br>(secs)</th>
PRO <th>Optimizer<br>Mode</th>
PRO <th>Cost</th>
PRO <th>Opt Env HV</th>
PRO <th>Parsing<br>Schema<br>Name</th>
PRO <th>Module</th>
PRO <th>Action</th>
PRO <th>Profile</th>
PRO <th>Patch</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.snap_id||'</td>'||CHR(10)||
       '<td>'
             ||case when v.begin_interval_time < to_date('^^ebr_date.','YYYY-MM-DD/HH24:MI:SS') then 'pre-ebr' 
                    else 'post-ebr' end ||'</td>'||CHR(10)||        
       '<td nowrap>'||TO_CHAR(v.end_interval_time, 'YYYY-MM-DD/HH24:MI:SS')||'</td>'||CHR(10)||
       '<td class="r">'||v.instance_number||'</td>'||CHR(10)||
       '<td class="r">'||v.plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||v.version_count||'</td>'||CHR(10)||
       '<td class="r">'||v.executions_delta||'</td>'||CHR(10)||
       '<td class="r">'||v.fetches_delta||'</td>'||CHR(10)||
       '<td class="r">'||v.loads_delta||'</td>'||CHR(10)||
       '<td class="r">'||v.invalidations_delta||'</td>'||CHR(10)||
       '<td class="r">'||v.parse_calls_delta||'</td>'||CHR(10)||
       '<td class="r">'||v.buffer_gets_delta||'</td>'||CHR(10)||
       '<td class="r">'||round(v.buffer_gets_delta/GREATEST(v.executions_delta, 1))||'</td>'||CHR(10)||
       '<td class="r">'||v.disk_reads_delta||'</td>'||CHR(10)||
       '<td class="r">'||round(v.disk_reads_delta/GREATEST(v.executions_delta, 1))||'</td>'||CHR(10)||
       '<td class="r">'||v.direct_writes_delta||'</td>'||CHR(10)||
       '<td class="r">'||v.rows_processed_delta||'</td>'||CHR(10)||
       '<td class="r">'||round(v.rows_processed_delta/GREATEST(v.executions_delta, 1))||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.elapsed_time_delta / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.elapsed_time_delta / 1e6 / GREATEST(v.executions_delta, 1), 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.cpu_time_delta / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.cpu_time_delta / 1e6 / GREATEST(v.executions_delta, 1), 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(100*(v.cpu_time_delta/GREATEST(v.elapsed_time_delta, 1)), 2), '990D90')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.iowait_delta / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(100*(v.iowait_delta/GREATEST(v.elapsed_time_delta, 1)), 2), '990D90')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.ccwait_delta / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(100*(v.ccwait_delta/GREATEST(v.elapsed_time_delta, 1)), 2), '990D90')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.apwait_delta / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(100*(v.apwait_delta/GREATEST(v.elapsed_time_delta, 1)), 2), '990D90')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.clwait_delta / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(100*(v.clwait_delta/GREATEST(v.elapsed_time_delta, 1)), 2), '990D90')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.plsexec_time_delta / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(100*(v.plsexec_time_delta/GREATEST(v.elapsed_time_delta, 1)), 2), '990D90')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.javexec_time_delta / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td>'||v.optimizer_mode||'</td>'||CHR(10)||
       '<td class="r">'||v.optimizer_cost||'</td>'||CHR(10)||
       '<td class="r">'||v.optimizer_env_hash_value||'</td>'||CHR(10)||
       '<td>'||v.parsing_schema_name||'</td>'||CHR(10)||
       '<td>'||v.module||'</td>'||CHR(10)||
       '<td>'||v.action||'</td>'||CHR(10)||
       '<td>'||v.sql_profile||'</td>'||CHR(10)||
       '<td>'||v.sql_patch||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       h.snap_id,
       s.begin_interval_time,
       s.end_interval_time,
       h.instance_number,
       h.plan_hash_value,
       h.optimizer_cost,
       h.optimizer_mode,
       h.optimizer_env_hash_value,
       h.version_count,
       h.module,
       h.action,
       h.sql_profile,
       (select replace(extractvalue(xmltype(other_xml), '/*/info[@type = "sql_patch"]'), '"', '') from dba_hist_sql_plan sp where sp.sql_id = h.sql_id and other_xml is not null and sp.plan_hash_value = h.plan_hash_value and rownum=1) sql_patch,
       h.parsing_schema_name,
       h.fetches_delta,
       h.executions_delta,
       h.loads_delta,
       h.invalidations_delta,
       h.parse_calls_delta,
       h.disk_reads_delta,
       h.buffer_gets_delta,
       h.rows_processed_delta,
       h.cpu_time_delta,
       h.elapsed_time_delta,
       h.iowait_delta,
       h.clwait_delta,
       h.apwait_delta,
       h.ccwait_delta,
       h.direct_writes_delta,
       h.plsexec_time_delta,
       h.javexec_time_delta
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license IN ('T', 'D')
   AND h.dbid = ^^dbid.
   AND h.sql_id = :sql_id
   AND h.snap_id = s.snap_id
   AND h.dbid = s.dbid
   AND h.instance_number = s.instance_number
 ORDER BY
       s.end_interval_time,
       h.instance_number,
       h.plan_hash_value ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Snap<br>ID</th>
PRO <th>Pre/Post<br>EBR</th>
PRO <th>Snaphot</th>
PRO <th>Inst<br>ID</th>
PRO <th>Plan HV</th>
PRO <th>Vers<br>Cnt</th>
PRO <th>Execs</th>
PRO <th>Fetch</th>
PRO <th>Loads</th>
PRO <th>Inval</th>
PRO <th>Parse<br>Calls</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Avg<br>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Avg<br>Disk<br>Reads</th>
PRO <th>Direct<br>Writes</th>
PRO <th>Rows<br>Proc</th>
PRO <th>Avg<br>Rows</th>
PRO <th>Elapsed<br>Time<br>(secs)</th>
PRO <th>Avg<br>Elapsed<br>Time<br>(secs)</th>
PRO <th>CPU<br>Time<br>(secs)</th>
PRO <th>Avg<br>CPU<br>Time<br>(secs)</th>
PRO <th>%CPU</th>
PRO <th>IO<br>Time<br>(secs)</th>
PRO <th>%IO</th>
PRO <th>Conc<br>Time<br>(secs)</th>
PRO <th>%Conc</th>
PRO <th>Appl<br>Time<br>(secs)</th>
PRO <th>%Appl</th>
PRO <th>Clus<br>Time<br>(secs)</th>
PRO <th>%Clus</th>
PRO <th>PLSQL<br>Time<br>(secs)</th>
PRO <th>%PLSQL</th>
PRO <th>Java<br>Time<br>(secs)</th>
PRO <th>Optimizer<br>Mode</th>
PRO <th>Cost</th>
PRO <th>Opt Env HV</th>
PRO <th>Parsing<br>Schema<br>Name</th>
PRO <th>Module</th>
PRO <th>Action</th>
PRO <th>Profile</th>
PRO <th>Patch</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * dba_hist_sqlstat sql statistics
 *
 * ------------------------- */
PRO <a name="awr_stats_t"></a><details><br/><summary id="summary2">Historical SQL Statistics - Total (DBA_HIST_SQLSTAT)</summary>
PRO
PRO Performance metrics of Execution Plans of ^^sql_id..<br>
PRO This section includes data captured by AWR. If this is a stand-by read-only database then the AWR information below is from the Primary database.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Snap<br>ID</th>
PRO <th>Pre/Post<br>EBR</th>
PRO <th>Snaphot</th>
PRO <th>Inst<br>ID</th>
PRO <th>Plan HV</th>
PRO <th>Vers<br>Cnt</th>
PRO <th>Execs</th>
PRO <th>Fetch</th>
PRO <th>Loads</th>
PRO <th>Inval</th>
PRO <th>Parse<br>Calls</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Direct<br>Writes</th>
PRO <th>Rows<br>Proc</th>
PRO <th>Elapsed<br>Time<br>(secs)</th>
PRO <th>CPU<br>Time<br>(secs)</th>
PRO <th>IO<br>Time<br>(secs)</th>
PRO <th>Conc<br>Time<br>(secs)</th>
PRO <th>Appl<br>Time<br>(secs)</th>
PRO <th>Clus<br>Time<br>(secs)</th>
PRO <th>PLSQL<br>Time<br>(secs)</th>
PRO <th>Java<br>Time<br>(secs)</th>
PRO <th>Optimizer<br>Mode</th>
PRO <th>Cost</th>
PRO <th>Opt Env HV</th>
PRO <th>Parsing<br>Schema<br>Name</th>
PRO <th>Module</th>
PRO <th>Action</th>
PRO <th>Profile</th>
PRO <th>Patch</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.snap_id||'</td>'||CHR(10)||
       '<td>'
             ||case when v.begin_interval_time < to_date('^^ebr_date.','YYYY-MM-DD/HH24:MI:SS') then 'pre-ebr' 
                    else 'post-ebr' end ||'</td>'||CHR(10)||        
       '<td nowrap>'||TO_CHAR(v.end_interval_time, 'YYYY-MM-DD/HH24:MI:SS')||'</td>'||CHR(10)||
       '<td class="r">'||v.instance_number||'</td>'||CHR(10)||
       '<td class="r">'||v.plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||v.version_count||'</td>'||CHR(10)||
       '<td class="r">'||v.executions_total||'</td>'||CHR(10)||
       '<td class="r">'||v.fetches_total||'</td>'||CHR(10)||
       '<td class="r">'||v.loads_total||'</td>'||CHR(10)||
       '<td class="r">'||v.invalidations_total||'</td>'||CHR(10)||
       '<td class="r">'||v.parse_calls_total||'</td>'||CHR(10)||
       '<td class="r">'||v.buffer_gets_total||'</td>'||CHR(10)||
       '<td class="r">'||v.disk_reads_total||'</td>'||CHR(10)||
       '<td class="r">'||v.direct_writes_total||'</td>'||CHR(10)||
       '<td class="r">'||v.rows_processed_total||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.elapsed_time_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.cpu_time_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.iowait_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.ccwait_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.apwait_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.clwait_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.plsexec_time_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.javexec_time_total / 1e6, 3), '99999999999990D990')||'</td>'||CHR(10)||
       '<td>'||v.optimizer_mode||'</td>'||CHR(10)||
       '<td class="r">'||v.optimizer_cost||'</td>'||CHR(10)||
       '<td class="r">'||v.optimizer_env_hash_value||'</td>'||CHR(10)||
       '<td>'||v.parsing_schema_name||'</td>'||CHR(10)||
       '<td>'||v.module||'</td>'||CHR(10)||
       '<td>'||v.action||'</td>'||CHR(10)||
       '<td>'||v.sql_profile||'</td>'||CHR(10)||
       '<td>'||v.sql_patch||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       h.snap_id,
       s.begin_interval_time,
       s.end_interval_time,
       h.instance_number,
       h.plan_hash_value,
       h.optimizer_cost,
       h.optimizer_mode,
       h.optimizer_env_hash_value,
       h.version_count,
       h.module,
       h.action,
       h.sql_profile,
       (select replace(extractvalue(xmltype(other_xml), '/*/info[@type = "sql_patch"]'), '"', '') from dba_hist_sql_plan sp where sp.sql_id = h.sql_id and other_xml is not null and sp.plan_hash_value = h.plan_hash_value and rownum=1) sql_patch,
       h.parsing_schema_name,
       h.fetches_total,
       h.executions_total,
       h.loads_total,
       h.invalidations_total,
       h.parse_calls_total,
       h.disk_reads_total,
       h.buffer_gets_total,
       h.rows_processed_total,
       h.cpu_time_total,
       h.elapsed_time_total,
       h.iowait_total,
       h.clwait_total,
       h.apwait_total,
       h.ccwait_total,
       h.direct_writes_total,
       h.plsexec_time_total,
       h.javexec_time_total
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license IN ('T', 'D')
   AND h.dbid = ^^dbid.
   AND h.sql_id = :sql_id
   AND h.snap_id = s.snap_id
   AND h.dbid = s.dbid
   AND h.instance_number = s.instance_number
 ORDER BY
       s.end_interval_time,
       h.instance_number,
       h.plan_hash_value ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Snap<br>ID</th>
PRO <th>Pre/Post<br>EBR</th>
PRO <th>Snaphot</th>
PRO <th>Inst<br>ID</th>
PRO <th>Plan HV</th>
PRO <th>Vers<br>Cnt</th>
PRO <th>Execs</th>
PRO <th>Fetch</th>
PRO <th>Loads</th>
PRO <th>Inval</th>
PRO <th>Parse<br>Calls</th>
PRO <th>Buffer<br>Gets</th>
PRO <th>Disk<br>Reads</th>
PRO <th>Direct<br>Writes</th>
PRO <th>Rows<br>Proc</th>
PRO <th>Elapsed<br>Time<br>(secs)</th>
PRO <th>CPU<br>Time<br>(secs)</th>
PRO <th>IO<br>Time<br>(secs)</th>
PRO <th>Conc<br>Time<br>(secs)</th>
PRO <th>Appl<br>Time<br>(secs)</th>
PRO <th>Clus<br>Time<br>(secs)</th>
PRO <th>PLSQL<br>Time<br>(secs)</th>
PRO <th>Java<br>Time<br>(secs)</th>
PRO <th>Optimizer<br>Mode</th>
PRO <th>Cost</th>
PRO <th>Opt Env HV</th>
PRO <th>Parsing<br>Schema<br>Name</th>
PRO <th>Module</th>
PRO <th>Action</th>
PRO <th>Profile</th>
PRO <th>Patch</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * gv$active_session_history by plan
 *
 * Uday: added percentage column
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: GV$ASH by Plan - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="ash_plan"></a><details open><br/><summary id="summary2">Active Session History by Plan (GV$ACTIVE_SESSION_HISTORY)</summary>
PRO
PRO Snapshots counts per Plan and Wait Event for ^^sql_id..<br>
PRO This section includes data captured by AWR.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Phase</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV</th>
PRO <th>% PHV+Event</th>
PRO <th>Sampled<br>Executions</th>
PRO <th>Max PGA<br>(MB)</th>
PRO <th>Max Temp<br>(MB)</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.sql_plan_hash_value||'</td>'||CHR(10)||
       '<td>'||v.session_state||'</td>'||CHR(10)||
       '<td>'||v.wait_class||'</td>'||CHR(10)||
       '<td>'||v.event||'</td>'||CHR(10)||
       '<td>'||v.phase||'</td>'||CHR(10)||
       '<td class="r">'||v.snaps_count||'</td>'||CHR(10)||
       '<td class="r">'||v.phv_pct||'</td>'||CHR(10)||
       '<td class="r">'||v.phv_event_pct||'</td>'||CHR(10)||
       '<td class="r">'||v.sampled_execs||'</td>'||CHR(10)||
       '<td class="r">'||v.max_pga||'</td>'||CHR(10)||
       '<td class="r">'||v.max_temp||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       ash.sql_plan_hash_value,
       ash.session_state,
       ash.wait_class,
       nvl(ash.event, 'On CPU/Waiting for CPU') event
       , CASE WHEN IN_CONNECTION_MGMT     = 'Y' THEN 'CONNECTION_MGMT '     END ||
         CASE WHEN IN_PARSE               = 'Y' THEN 'PARSE '               END ||
         CASE WHEN IN_HARD_PARSE          = 'Y' THEN 'HARD_PARSE '          END ||
         CASE WHEN IN_SQL_EXECUTION       = 'Y' THEN 'SQL_EXECUTION '       END ||
         CASE WHEN IN_PLSQL_EXECUTION     = 'Y' THEN 'PLSQL_EXECUTION '     END ||
         CASE WHEN IN_PLSQL_RPC           = 'Y' THEN 'PLSQL_RPC '           END ||
         CASE WHEN IN_PLSQL_COMPILATION   = 'Y' THEN 'PLSQL_COMPILATION '   END ||
         CASE WHEN IN_JAVA_EXECUTION      = 'Y' THEN 'JAVA_EXECUTION '      END ||
         CASE WHEN IN_BIND                = 'Y' THEN 'BIND '                END ||
         CASE WHEN IN_CURSOR_CLOSE        = 'Y' THEN 'CURSOR_CLOSE '        END ||
         CASE WHEN IN_SEQUENCE_LOAD       = 'Y' THEN 'SEQUENCE_LOAD '       END phase,
       COUNT(*) snaps_count,
       -- ROUND((RATIO_TO_REPORT(COUNT(*)) over())*100, 2) PCT
       round((sum(COUNT(*)) over(partition by ash.sql_plan_hash_value)/sum(COUNT(*)) over())*100, 2) phv_pct,
       ROUND((RATIO_TO_REPORT(COUNT(*)) over(partition by ash.sql_plan_hash_value))*100, 2) phv_event_pct
       , count(distinct ash.inst_id||ash.sql_exec_start) sampled_execs  -- uday psrv10
       , max(pga_allocated/1024/1024) max_pga  -- uday psrv10
       , max(temp_space_allocated/1024/1024) max_temp  -- uday psrv10
  FROM gv$active_session_history ash
 WHERE :license IN ('T', 'D')
   AND ash.sql_id = :sql_id
 GROUP BY
       ash.sql_plan_hash_value,
       ash.session_state,
       ash.wait_class,
       nvl(ash.event, 'On CPU/Waiting for CPU') 
       , CASE WHEN IN_CONNECTION_MGMT     = 'Y' THEN 'CONNECTION_MGMT '     END ||
         CASE WHEN IN_PARSE               = 'Y' THEN 'PARSE '               END ||
         CASE WHEN IN_HARD_PARSE          = 'Y' THEN 'HARD_PARSE '          END ||
         CASE WHEN IN_SQL_EXECUTION       = 'Y' THEN 'SQL_EXECUTION '       END ||
         CASE WHEN IN_PLSQL_EXECUTION     = 'Y' THEN 'PLSQL_EXECUTION '     END ||
         CASE WHEN IN_PLSQL_RPC           = 'Y' THEN 'PLSQL_RPC '           END ||
         CASE WHEN IN_PLSQL_COMPILATION   = 'Y' THEN 'PLSQL_COMPILATION '   END ||
         CASE WHEN IN_JAVA_EXECUTION      = 'Y' THEN 'JAVA_EXECUTION '      END ||
         CASE WHEN IN_BIND                = 'Y' THEN 'BIND '                END ||
         CASE WHEN IN_CURSOR_CLOSE        = 'Y' THEN 'CURSOR_CLOSE '        END ||
         CASE WHEN IN_SEQUENCE_LOAD       = 'Y' THEN 'SEQUENCE_LOAD '       END 
 ORDER BY
       ash.sql_plan_hash_value,
       5 DESC,
       ash.session_state,
       ash.wait_class,
       event ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Phase</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV</th>
PRO <th>% PHV+Event</th>
PRO <th>Sampled<br>Executions</th>
PRO <th>Max PGA<br>(MB)</th>
PRO <th>Max Temp<br>(MB)</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * gv$active_session_history by plan line
 *
 * Uday: added percentage column
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: GV$ASH by Plan Line - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="ash_line"></a><details open><br/><summary id="summary2">Active Session History by Plan Line (GV$ACTIVE_SESSION_HISTORY)</summary>
PRO
PRO Snapshots counts per Plan Line and Wait Event for ^^sql_id..<br>
PRO This section includes data captured by AWR.<br>
PRO Available on 11g or higher..
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Plan<br>Line<br>ID</th>
PRO <th>Plan<br>Operation</th>
PRO <th>Plan<br>Options</th>
PRO <th>Plan<br>Object<br>Owner</th>
PRO <th>Plan<br>Object<br>Name</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Curr<br>Obj<br>ID</th>
PRO <th>Curr<br>Object<br>Name</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV+Plan Line</th>
PRO <th>Sampled<br>Executions</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.sql_plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||v.sql_plan_line_id||'</td>'||CHR(10)||
       '<td>'||v.sql_plan_operation||'</td>'||CHR(10)||
       '<td>'||v.sql_plan_options||'</td>'||CHR(10)||
       '<td>'||v.object_owner||'</td>'||CHR(10)||
       '<td>'||v.object_name||'</td>'||CHR(10)||
       '<td>'||v.session_state||'</td>'||CHR(10)||
       '<td>'||v.wait_class||'</td>'||CHR(10)||
       '<td>'||v.event||'</td>'||CHR(10)||
       '<td class="r">'||v.current_obj#||'</td>'||CHR(10)||
       '<td>'||v.current_obj_name||'</td>'||CHR(10)||
       '<td class="r">'||v.snaps_count||'</td>'||CHR(10)||
       '<td class="r">'||v.pct||'</td>'||CHR(10)||
       '<td class="r">'||v.sampled_execs||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       ash.sql_plan_hash_value,
       ash.sql_plan_line_id,
       ash.sql_plan_operation,
       ash.sql_plan_options,
       ash.object_owner,
       ash.object_name,
       ash.current_obj#,
       CASE
         WHEN ash.current_obj# IS NOT NULL THEN
           (SELECT obj.owner||'.'||obj.object_name||NVL2(obj.subobject_name, '.'||obj.subobject_name, NULL)
              FROM dba_objects obj
             WHERE obj.object_id = ash.current_obj#)
       END current_obj_name,
       ash.session_state,
       ash.wait_class,
       ash.event,
       COUNT(*) snaps_count,
       -- ROUND((RATIO_TO_REPORT(COUNT(*)) over())*100, 2) PCT
       ROUND((RATIO_TO_REPORT(COUNT(*)) over(partition by ash.sql_plan_hash_value))*100, 2) PCT
       , count(distinct ash.inst_id||ash.sql_exec_start) sampled_execs  -- uday psrv10
  FROM (
        SELECT /*+ NO_MERGE */
               sh.inst_id,
               sh.sql_exec_start,
               sh.sql_plan_hash_value,
               sh.sql_plan_line_id,
               sh.sql_plan_operation,
               sh.sql_plan_options,
               CASE
                 WHEN sh.wait_class IN ('Application', 'Cluster', 'Concurrency', 'User I/O') THEN
                   sh.current_obj#
               END current_obj#,
               sh.session_state,
               sh.wait_class,
               nvl(sh.event, 'On CPU/Waiting for CPU') event,
               sp.object_owner,
               sp.object_name
          FROM gv$active_session_history sh,
               gv$sql_plan sp
         WHERE :license IN ('T', 'D')
           AND sh.sql_id = :sql_id
           AND sh.sql_plan_line_id > 0
           AND sp.inst_id(+) = sh.inst_id
           AND sp.sql_id(+) = sh.sql_id
           AND sp.child_number(+) = sh.sql_child_number
           AND sp.plan_hash_value(+) = sh.sql_plan_hash_value
           AND sp.id(+) = sh.sql_plan_line_id 
       ) ash
 GROUP BY
       ash.sql_plan_hash_value,
       ash.sql_plan_line_id,
       ash.sql_plan_operation,
       ash.sql_plan_options,
       ash.object_owner,
       ash.object_name,
       ash.session_state,
       ash.wait_class,
       ash.current_obj#,
       ash.event
 ORDER BY
       ash.sql_plan_hash_value,
       ash.sql_plan_line_id,
       12 DESC,
       ash.sql_plan_operation,
       ash.sql_plan_options,
       ash.object_owner,
       ash.object_name,
       ash.session_state,
       ash.wait_class,
       ash.current_obj#,
       ash.event ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Plan<br>Line<br>ID</th>
PRO <th>Plan<br>Operation</th>
PRO <th>Plan<br>Options</th>
PRO <th>Plan<br>Object<br>Owner</th>
PRO <th>Plan<br>Object<br>Name</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Curr<br>Obj<br>ID</th>
PRO <th>Curr<br>Object<br>Name</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV+Plan Line</th>
PRO <th>Sampled<br>Executions</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * dba_hist_active_sess_history by plan
 *
 * Uday: added percentage column
 * Uday.v6.Aug2016: added snaps subquery to improve performance
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: DBA_HIST_ASH by Plan - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="awr_plan"></a><details open><br/><summary id="summary2">AWR Active Session History by Plan (DBA_HIST_ACTIVE_SESS_HISTORY)</summary>
PRO
PRO Snapshots counts per Plan and Wait Event for ^^sql_id..<br>
PRO This section includes data captured by AWR. If this is a stand-by read-only database then the AWR information below is from the Primary database.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Phase</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV</th>
PRO <th>% PHV+Event</th>
PRO <th>Sampled<br>Executions</th>
PRO <th>Max PGA<br>(MB)</th>
PRO <th>Max Temp<br>(MB)</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

-- Uday.PSR.v6
-- added below plsql block to fetch ASH in AWR using snap_id range
-- otherwise, we are doing FTS of dba_hist_active_sess_history that has 172m rows in crmap
--
variable minsnap number
variable maxsnap number

exec :minsnap := -1;
exec :maxsnap := -1;

begin
  select min(snap_id) minsnap, max(snap_id) maxsnap
    into :minsnap, :maxsnap
    from dba_hist_sqlstat 
   where sql_id = :sql_id
     and :license IN ('T', 'D')
     and dbid = ^^dbid.
   group by sql_id;
exception 
  when others then null;
end;
/


SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.sql_plan_hash_value||'</td>'||CHR(10)||
       '<td>'||v.session_state||'</td>'||CHR(10)||
       '<td>'||v.wait_class||'</td>'||CHR(10)||
       '<td>'||v.event||'</td>'||CHR(10)||
       '<td>'||v.phase||'</td>'||CHR(10)||
       '<td class="r">'||v.snaps_count||'</td>'||CHR(10)||
       '<td class="r">'||v.phv_pct||'</td>'||CHR(10)||
       '<td class="r">'||v.phv_event_pct||'</td>'||CHR(10)||
       '<td class="r">'||v.sampled_execs||'</td>'||CHR(10)||
       '<td class="r">'||v.max_pga||'</td>'||CHR(10)||
       '<td class="r">'||v.max_temp||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       ash.sql_plan_hash_value,
       ash.session_state,
       ash.wait_class,
       nvl(ash.event, 'On CPU/Waiting for CPU') event
       , CASE WHEN IN_CONNECTION_MGMT     = 'Y' THEN 'CONNECTION_MGMT '     END ||
         CASE WHEN IN_PARSE               = 'Y' THEN 'PARSE '               END ||
         CASE WHEN IN_HARD_PARSE          = 'Y' THEN 'HARD_PARSE '          END ||
         CASE WHEN IN_SQL_EXECUTION       = 'Y' THEN 'SQL_EXECUTION '       END ||
         CASE WHEN IN_PLSQL_EXECUTION     = 'Y' THEN 'PLSQL_EXECUTION '     END ||
         CASE WHEN IN_PLSQL_RPC           = 'Y' THEN 'PLSQL_RPC '           END ||
         CASE WHEN IN_PLSQL_COMPILATION   = 'Y' THEN 'PLSQL_COMPILATION '   END ||
         CASE WHEN IN_JAVA_EXECUTION      = 'Y' THEN 'JAVA_EXECUTION '      END ||
         CASE WHEN IN_BIND                = 'Y' THEN 'BIND '                END ||
         CASE WHEN IN_CURSOR_CLOSE        = 'Y' THEN 'CURSOR_CLOSE '        END ||
         CASE WHEN IN_SEQUENCE_LOAD       = 'Y' THEN 'SEQUENCE_LOAD '       END phase,
       COUNT(*) snaps_count,
       -- ROUND((RATIO_TO_REPORT(COUNT(*)) over())*100, 2) PCT
       round((sum(COUNT(*)) over(partition by ash.sql_plan_hash_value)/sum(COUNT(*)) over())*100, 2) phv_pct,
       ROUND((RATIO_TO_REPORT(COUNT(*)) over(partition by ash.sql_plan_hash_value))*100, 2) phv_event_pct
       , count(distinct ash.instance_number||ash.sql_exec_start) sampled_execs  -- uday psrv10
       , max(pga_allocated/1024/1024) max_pga  -- uday psrv10
       , max(temp_space_allocated/1024/1024) max_temp  -- uday psrv10
  FROM dba_hist_active_sess_history ash
 WHERE :license IN ('T', 'D')
   AND ash.dbid = ^^dbid.
   and ash.sql_id = :sql_id
   and ash.snap_id between :minsnap and :maxsnap
 GROUP BY
       ash.sql_plan_hash_value,
       ash.session_state,
       ash.wait_class,
       nvl(ash.event, 'On CPU/Waiting for CPU') 
       , CASE WHEN IN_CONNECTION_MGMT     = 'Y' THEN 'CONNECTION_MGMT '     END ||
         CASE WHEN IN_PARSE               = 'Y' THEN 'PARSE '               END ||
         CASE WHEN IN_HARD_PARSE          = 'Y' THEN 'HARD_PARSE '          END ||
         CASE WHEN IN_SQL_EXECUTION       = 'Y' THEN 'SQL_EXECUTION '       END ||
         CASE WHEN IN_PLSQL_EXECUTION     = 'Y' THEN 'PLSQL_EXECUTION '     END ||
         CASE WHEN IN_PLSQL_RPC           = 'Y' THEN 'PLSQL_RPC '           END ||
         CASE WHEN IN_PLSQL_COMPILATION   = 'Y' THEN 'PLSQL_COMPILATION '   END ||
         CASE WHEN IN_JAVA_EXECUTION      = 'Y' THEN 'JAVA_EXECUTION '      END ||
         CASE WHEN IN_BIND                = 'Y' THEN 'BIND '                END ||
         CASE WHEN IN_CURSOR_CLOSE        = 'Y' THEN 'CURSOR_CLOSE '        END ||
         CASE WHEN IN_SEQUENCE_LOAD       = 'Y' THEN 'SEQUENCE_LOAD '       END 
 ORDER BY
       ash.sql_plan_hash_value,
       5 DESC,
       ash.session_state,
       ash.wait_class,
       event ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Phase</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV</th>
PRO <th>% PHV+Event</th>
PRO <th>Sampled<br>Executions</th>
PRO <th>Max PGA<br>(MB)</th>
PRO <th>Max Temp<br>(MB)</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * dba_hist_active_sess_history by plan line
 *
 * Uday: added percentage column
 * Uday.v6.Aug2016: added snaps subquery to improve performance
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: DBA_HIST_ASH by Plan Line - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="awr_line"></a><details open><br/><summary id="summary2">AWR Active Session History by Plan Line (DBA_HIST_ACTIVE_SESS_HISTORY)</summary>
PRO
PRO Snapshots counts per Plan Line and Wait Event for ^^sql_id..<br>
PRO This section includes data captured by AWR. If this is a stand-by read-only database then the AWR information below is from the Primary database.<br>
PRO Available on 11g or higher..
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Plan<br>Line<br>ID</th>
PRO <th>Plan<br>Operation</th>
PRO <th>Plan<br>Options</th>
PRO <th>Plan<br>Object<br>Owner</th>
PRO <th>Plan<br>Object<br>Name</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Curr<br>Obj<br>ID</th>
PRO <th>Curr<br>Object<br>Name</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV+Plan Line</th>
PRO <th>Sampled<br>Executions</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.sql_plan_hash_value||'</td>'||CHR(10)||
       '<td class="r">'||v.sql_plan_line_id||'</td>'||CHR(10)||
       '<td>'||v.sql_plan_operation||'</td>'||CHR(10)||
       '<td>'||v.sql_plan_options||'</td>'||CHR(10)||
       '<td>'||v.object_owner||'</td>'||CHR(10)||
       '<td>'||v.object_name||'</td>'||CHR(10)||
       '<td>'||v.session_state||'</td>'||CHR(10)||
       '<td>'||v.wait_class||'</td>'||CHR(10)||
       '<td>'||v.event||'</td>'||CHR(10)||
       '<td class="r">'||v.current_obj#||'</td>'||CHR(10)||
       '<td>'||v.current_obj_name||'</td>'||CHR(10)||
       '<td class="r">'||v.snaps_count||'</td>'||CHR(10)||
       '<td class="r">'||v.pct||'</td>'||CHR(10)||
       '<td class="r">'||v.sampled_execs||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       ash.sql_plan_hash_value,
       ash.sql_plan_line_id,
       ash.sql_plan_operation,
       ash.sql_plan_options,
       ash.object_owner,
       ash.object_name,
       ash.current_obj#,
       CASE
         WHEN ash.current_obj# IS NOT NULL THEN
           (SELECT obj.owner||'.'||obj.object_name||NVL2(obj.subobject_name, '.'||obj.subobject_name, NULL)
              FROM dba_hist_seg_stat_obj obj
             WHERE obj.obj# = ash.current_obj#
               AND obj.dbid = ^^dbid.
               AND ROWNUM = 1)
       END current_obj_name,
       ash.session_state,
       ash.wait_class,
       ash.event,
       COUNT(*) snaps_count,
       -- ROUND((RATIO_TO_REPORT(COUNT(*)) over())*100, 2) PCT
       ROUND((RATIO_TO_REPORT(COUNT(*)) over(partition by ash.sql_plan_hash_value))*100, 2) PCT
       , count(distinct ash.instance_number||ash.sql_exec_start) sampled_execs  -- uday psrv10
  FROM (
        SELECT /*+ leading(ash sh) NO_MERGE */ /* NO_MERGE */
               sh.instance_number,
               sh.sql_exec_start,
               sh.sql_plan_hash_value,
               sh.sql_plan_line_id,
               sh.sql_plan_operation,
               sh.sql_plan_options,
               CASE
                 WHEN sh.wait_class IN ('Application', 'Cluster', 'Concurrency', 'User I/O') THEN
                   sh.current_obj#
               END current_obj#,
               sh.session_state,
               sh.wait_class,
               nvl(sh.event, 'On CPU/Waiting for CPU') event,
               sp.object_owner,
               sp.object_name
          FROM dba_hist_active_sess_history sh,
               dba_hist_sql_plan sp
         WHERE :license IN ('T', 'D')
           AND sh.dbid = ^^dbid.
           AND sh.sql_id = :sql_id
           and sh.snap_id between :minsnap and :maxsnap
           AND sh.sql_plan_line_id > 0
           AND sp.dbid(+) = sh.dbid
           AND sp.sql_id(+) = sh.sql_id
           AND sp.plan_hash_value(+) = sh.sql_plan_hash_value
           AND sp.id(+) = sh.sql_plan_line_id 
               ) ash
 GROUP BY
       ash.sql_plan_hash_value,
       ash.sql_plan_line_id,
       ash.sql_plan_operation,
       ash.sql_plan_options,
       ash.object_owner,
       ash.object_name,
       ash.session_state,
       ash.wait_class,
       ash.current_obj#,
       ash.event
 ORDER BY
       ash.sql_plan_hash_value,
       ash.sql_plan_line_id,
       12 DESC,
       ash.sql_plan_operation,
       ash.sql_plan_options,
       ash.object_owner,
       ash.object_name,
       ash.session_state,
       ash.wait_class,
       ash.current_obj#,
       ash.event ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Plan<br>Line<br>ID</th>
PRO <th>Plan<br>Operation</th>
PRO <th>Plan<br>Options</th>
PRO <th>Plan<br>Object<br>Owner</th>
PRO <th>Plan<br>Object<br>Name</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Curr<br>Obj<br>ID</th>
PRO <th>Curr<br>Object<br>Name</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV+Plan Line</th>
PRO <th>Sampled<br>Executions</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
--Uday.PSR.v6: rewrite of above...above was taking time in 12c when rows to process are quite high
--Uday.PSR.v6 with
--Uday.PSR.v6 ash as 
--Uday.PSR.v6 (
--Uday.PSR.v6 SELECT /*+ materialize */ /* NO_MERGE */
--Uday.PSR.v6        ash.dbid,
--Uday.PSR.v6        ash.sql_id,
--Uday.PSR.v6        ash.sql_plan_hash_value,
--Uday.PSR.v6        ash.sql_plan_line_id,
--Uday.PSR.v6        ash.sql_plan_operation,
--Uday.PSR.v6        ash.sql_plan_options,
--Uday.PSR.v6        CASE
--Uday.PSR.v6          WHEN ash.wait_class IN ('Application', 'Cluster', 'Concurrency', 'User I/O') THEN
--Uday.PSR.v6            ash.current_obj#
--Uday.PSR.v6        END current_obj#,
--Uday.PSR.v6        ash.session_state,
--Uday.PSR.v6        ash.wait_class,
--Uday.PSR.v6        ash.event,
--Uday.PSR.v6        COUNT(*) snaps_count,
--Uday.PSR.v6        ROUND((RATIO_TO_REPORT(COUNT(*)) over(partition by ash.sql_plan_hash_value))*100, 2) PCT
--Uday.PSR.v6   FROM dba_hist_active_sess_history ash
--Uday.PSR.v6  WHERE :license IN ('T', 'D')
--Uday.PSR.v6    AND ash.dbid = dbid.
--Uday.PSR.v6    AND ash.sql_id = :sql_id
--Uday.PSR.v6    and ash.snap_id between minsnap and maxsnap
--Uday.PSR.v6    AND ash.sql_plan_line_id > 0
--Uday.PSR.v6  GROUP BY
--Uday.PSR.v6        ash.dbid, ash.sql_id, ash.sql_plan_hash_value, ash.sql_plan_line_id, ash.sql_plan_operation, ash.sql_plan_options, ash.session_state, ash.wait_class, 
--Uday.PSR.v6        CASE
--Uday.PSR.v6          WHEN ash.wait_class IN ('Application', 'Cluster', 'Concurrency', 'User I/O') THEN
--Uday.PSR.v6            ash.current_obj#
--Uday.PSR.v6        END current_obj#,
--Uday.PSR.v6        ash.event
--Uday.PSR.v6 )
--Uday.PSR.v6 SELECT /*+ NO_MERGE */
--Uday.PSR.v6        ash.sql_plan_hash_value,
--Uday.PSR.v6        ash.sql_plan_line_id,
--Uday.PSR.v6        ash.sql_plan_operation,
--Uday.PSR.v6        ash.sql_plan_options,
--Uday.PSR.v6        sp.object_owner,
--Uday.PSR.v6        sp.object_name,
--Uday.PSR.v6        ash.current_obj#,
--Uday.PSR.v6        CASE
--Uday.PSR.v6          WHEN ash.current_obj# IS NOT NULL THEN
--Uday.PSR.v6            (SELECT obj.owner||'.'||obj.object_name||NVL2(obj.subobject_name, '.'||obj.subobject_name, NULL)
--Uday.PSR.v6               FROM dba_hist_seg_stat_obj obj
--Uday.PSR.v6              WHERE obj.obj# = ash.current_obj#
--Uday.PSR.v6                AND obj.dbid = dbid.
--Uday.PSR.v6                AND ROWNUM = 1)
--Uday.PSR.v6        END current_obj_name,
--Uday.PSR.v6        ash.session_state,
--Uday.PSR.v6        ash.wait_class,
--Uday.PSR.v6        ash.event,
--Uday.PSR.v6        snaps_count,
--Uday.PSR.v6        pct
--Uday.PSR.v6   FROM ash, dba_hist_sql_plan sp
--Uday.PSR.v6  where sp.dbid(+) = ash.dbid
--Uday.PSR.v6    AND sp.sql_id(+) = ash.sql_id
--Uday.PSR.v6    AND sp.plan_hash_value(+) = ash.sql_plan_hash_value
--Uday.PSR.v6    AND sp.id(+) = ash.sql_plan_line_id
--Uday.PSR.v6  ORDER BY
--Uday.PSR.v6        ash.sql_plan_hash_value, ash.sql_plan_line_id, snaps_count DESC, ash.sql_plan_operation, ash.sql_plan_options, sp.object_owner, sp.object_name, ash.session_state, ash.wait_class, ash.current_obj#, ash.event 
--Uday.PSR.v6 ;
--Uday.PSR.v6 
--udayRemoved /* -------------------------
--udayRemoved  *
--udayRemoved  * DBMS_STATS System Preferences
--udayRemoved  *
--udayRemoved  * ------------------------- */
--udayRemoved EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: DBMS_STATS System Preferences - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
--udayRemoved PRO <a name="dbms_stats_sys_prefs"></a><br/><summary id="summary2">DBMS_STATS System Preferences</summary>
--udayRemoved PRO
--udayRemoved PRO DBMS_STATS System Preferences.
--udayRemoved PRO
--udayRemoved PRO < table>
--udayRemoved PRO
--udayRemoved PRO <tr>
--udayRemoved PRO <th>#</th>
--udayRemoved PRO <th>Parameter Name</th>
--udayRemoved PRO <th>Parameter Value</th>
--udayRemoved PRO </tr>
--udayRemoved PRO
--udayRemoved SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
--udayRemoved PRO <!-- Please Wait --> 
--udayRemoved 
--udayRemoved SELECT /* ^^script..sql DBMS_STATS System Preferences */
--udayRemoved        CHR(10)||'<tr>'||CHR(10)||
--udayRemoved        '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
--udayRemoved        '<td>'||v.sname||'</td>'||CHR(10)||
--udayRemoved        '<td>'||v.spare4||'</td>'||CHR(10)||
--udayRemoved 	   '</tr>'
--udayRemoved   FROM sys.optstat_hist_control$ v
--udayRemoved  WHERE v.sname IN ('AUTOSTATS_TARGET', 
--udayRemoved                    'ESTIMATE_PERCENT',
--udayRemoved                    'DEGREE',
--udayRemoved                    'CASCADE',
--udayRemoved                    'NO_INVALIDATE',
--udayRemoved                    'METHOD_OPT',
--udayRemoved                    'GRANULARITY',
--udayRemoved                    'STATS_RETENTION',
--udayRemoved                    'PUBLISH',
--udayRemoved                    'INCREMENTAL',
--udayRemoved                    'STALE_PERCENT',
--udayRemoved                    'APPROXIMATE_NDV',
--udayRemoved                    'INCREMENTAL_INTERNAL_CONTROL',
--udayRemoved                    'CONCURRENT')
--udayRemoved ORDER BY v.sname;
--udayRemoved 
--udayRemoved PRO
--udayRemoved PRO <tr>
--udayRemoved PRO <th>#</th>
--udayRemoved PRO <th>Preference Name</th>
--udayRemoved PRO <th>Preference Value</th>
--udayRemoved PRO </tr>
PRO
rem PRO < table> -- pushkar removed
/* -------------------------
 *
 * tables
 * PSRv7: added modifications link
 *
 * ------------------------- */
                               
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Tables Stats and Attributes - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="tables"></a><details open><br/><summary id="summary2">Tables</summary>
PRO
PRO CBO Statistics and relevant attributes.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Part</th>
PRO <th>Temp</th>
PRO <th>On Commit</th>
PRO <th>Num Rows</th>
PRO <th>Sample<br>Size</th>
PRO <th>Perc</th>
PRO <th>Last Analyzed</th>
PRO <th>Blocks</th>
PRO <th>Avg<br>Row<br>Len</th>
PRO <th>Global<br>Stats</th>
PRO <th>User<br>Stats</th>
PRO <th>Stat<br>Type<br>Locked</th>
PRO <th>Stale<br>Stats</th>
PRO <th>Perc</th>
PRO <th>Table<br>Cols</th>
PRO <th>Indexes</th>
PRO <th>Index<br>Cols</th>
PRO <th>Stat<br>Versions</th>
PRO <th>Tab<br>Modifications</th>
PRO <th>Partition<br>Type</th>
PRO <th>Partition<br>Columns</th>
PRO <th>Partition<br>Count</th>
PRO <th>Subpartition<br>Type</th>
PRO <th>Subpartition<br>Columns</th>
PRO <th>DoP</th>
PRO <th>BootStrap<br>Table<br>Size</th>
PRO <th>Candidate<br>for next<br>BootStrap<br>Stats</th>
PRO <th>Occupied<br>[KB]</th>
PRO <th>Allocated<br>[KB]</th>
PRO </tr>

var no_of_inserts number; 
var row_count_threshold number;
var stale_row_count_threshold number;
var insert_percent_below_threshold number;
var insert_percent_above_threshold number;
exec :no_of_inserts:=1000; :row_count_threshold:=20000; :stale_row_count_threshold:=500000; :insert_percent_below_threshold:=50; :insert_percent_above_threshold:=100;

PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT /* ^^script..sql Tables */
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.table_name||'</td>'||CHR(10)||
       '<td>'||v.owner||'</td>'||CHR(10)||
       CASE WHEN v.partitioned = 'YES' 
	     THEN '<td class="c"><a href="#tp_'||LOWER(v.table_name||'_'||v.owner)||'">'||v.partitioned||'</a></td>'
		 ELSE '<td class="c">'||v.partitioned||'</td>'
	   END||CHR(10)||
       '<td class="c">'||v.temporary||'</td>'||CHR(10)||
       '<td>'||case when v.duration='SYS$TRANSACTION' then 'DELETE' 
                    when v.duration='SYS$SESSION'     then 'PRESERVE'
                end ||'</td>'||CHR(10)||         
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size_perc||'</td>'||CHR(10)||
       '<td nowrap>'   ||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.blocks||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_row_len||'</td>'||CHR(10)||
       '<td class="c">'||v.global_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.user_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.stattype_locked||'</td>'||CHR(10)||
       '<td class="c">'||v.stale_stats||'</td>'||CHR(10)||
       '<td class="r">'||TO_CHAR(ROUND(v.modifications * 100/nvl(nullif(v.num_rows,0),1)), '99999990D0')||'</td>'||CHR(10)||
       '<td class="c"><a href="#c_'||LOWER(v.table_name||'_'||v.owner)||'">&nbsp;'||v.columns||'&nbsp;</a></td>'||CHR(10)||
       '<td class="c"><a href="#i_'||LOWER(v.table_name||'_'||v.owner)||'">&nbsp;'||v.indexes||'&nbsp;</a></td>'||CHR(10)||
       '<td class="c"><a href="#ic_'||LOWER(v.table_name||'_'||v.owner)||'">&nbsp;'||v.index_columns||'&nbsp;</a></td>'||CHR(10)||
       '<td class="c"><a href="#tbl_stat_ver">Versions</a></td>'||CHR(10)||
       '<td class="c"><a href="#tbl_modifications">Modifications</a></td>'||CHR(10)||
	     '<td class="c">'||case
	                         when v.p_subp_type is NOT null then
	                            regexp_substr(v.p_subp_type,'(.*)##',1,1,'im',1)||'</td>'||CHR(10)
	                         else '</td>'||CHR(10)
	                       end ||CHR(10)||
	     '<td>'||case
	                         when v.p_part_keys is NOT null then
	                           v.p_part_keys||'</td>'||CHR(10)
	                         else '</td>'||CHR(10)
	                       end ||CHR(10)||
	     '<td class="r">'||case
	                         when v.p_subp_type is NOT null then
	                            regexp_substr(v.p_subp_type,'##(.*)~~',1,1,'im',1)||'</td>'||CHR(10)||
	     '<td class="c">'||     regexp_substr(v.p_subp_type,'~~(.*)',1,1,'im',1)
	                         else '</td><td>'
	                       end ||'</td>'||CHR(10)||
	     '<td>'||case
	                         when v.p_subpart_keys is NOT null then
	                           v.p_subpart_keys||'</td>'||CHR(10)
	                         else '</td>'||CHR(10)
	                       end ||CHR(10)||
       '<td class="c">'||v.degree||'</td>'||CHR(10)|| 
       '<td class="c">'||
          case when v.temporary='N' and ((v.num_rows <= :row_count_threshold or v.num_rows is null) 
                or  (v.num_rows=0 or v.num_rows is null)
                or  (v.num_rows=0)) then 'Small'
               when v.temporary='N' and (v.num_rows between :row_count_threshold and :stale_row_count_threshold) then 'Medium'
               when v.temporary='N' and (v.num_rows > :stale_row_count_threshold) then 'Large'
          end ||'</td>'||CHR(10)||                 
          case when ((v.num_rows <= :row_count_threshold or v.num_rows is null) and abs(v.modifications) > :no_of_inserts) 
                or  (v.num_rows > :row_count_threshold and abs(v.modifications)*100/nvl(nullif(v.num_rows,0),1) >= :insert_percent_below_threshold)               
                or  ((v.num_rows=0 or v.num_rows is null) and v.modifications > 0)
                or  (v.num_rows=0)
          then '<td class="bg_c">'||'YES'
          else '<td class="c">'   ||'NO'
          end ||'</td>'||CHR(10)||       
       '<td class="r">'||v.occupied_size||'</td>'||CHR(10)||
       '<td class="r">'||v.allocated_size||'</td>'||CHR(10)||
       '</tr>' 
  FROM (
--Uday.PSR.v6 WITH object AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM gv$sql_plan
--Uday.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM dba_hist_sql_plan
--Uday.PSR.v6  WHERE :license IN ('T', 'D')
--Uday.PSR.v6    AND dbid = ^^dbid.
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  ), plan_tables AS (
--Uday.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--Uday.PSR.v6 --UdayRemoved.v6   FROM dba_tab_statistics t, -- include fixed objects
--Uday.PSR.v6 --UdayRemoved.v6        object o
--Uday.PSR.v6 --UdayRemoved.v6  WHERE t.owner = o.owner
--Uday.PSR.v6 --UdayRemoved.v6    AND t.table_name = o.name
--Uday.PSR.v6  SELECT /*+ MATERIALIZE */
--Uday.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--Uday.PSR.v6    FROM object o
--Uday.PSR.v6   WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6   UNION
--Uday.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6    FROM dba_indexes i,
--Uday.PSR.v6         object o
--Uday.PSR.v6   WHERE o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6     AND i.owner = o.owner
--Uday.PSR.v6     AND i.index_name = o.name
--Uday.PSR.v6 )
SELECT /*+ NO_MERGE LEADING(pt s t) */
       s.table_name,
       s.owner,
       t.partitioned,
       case /* Pushkar - added below for partitioned tables */
         when t.partitioned = 'YES' then (select partitioning_type||'##'||partition_count||'~~'||regexp_replace(subpartitioning_type,'NONE',null,1,0,'i') 
                                          from dba_part_tables dt 
                                          where dt.owner = s.owner and dt.table_name = s.table_name)
       end p_subp_type,
       case
         when t.partitioned = 'YES' then (select /*'PARTITION on: '||*/listagg(column_name,'<br>') within group (order by owner, name, object_type, column_position)
                                           from dba_part_key_columns
                                           where owner=s.owner
                                             and name=s.table_name
                                             and object_type='TABLE'
                                           group by owner, name, object_type)
       end p_part_keys,
       case
         when t.partitioned = 'YES' then (select /*'SUBPARTITION on: '||*/listagg(column_name,'<br>') within group (order by owner, name, object_type, column_position)
                                           from dba_subpart_key_columns
                                           where owner=s.owner
                                             and name=s.table_name
                                             and object_type='TABLE'
                                           group by owner, name, object_type)
       end p_subpart_keys,       
       t.degree,
       t.temporary,
       t.duration,
       s.num_rows,
       s.sample_size,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND(s.sample_size * 100 / s.num_rows, 1), '99999990D0') END sample_size_perc,
       TO_CHAR(s.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       s.blocks,
       s.avg_row_len,
       s.global_stats,
       s.user_stats,
       s.stattype_locked,
       s.stale_stats,
       -- Uday: causing performance issue in 12c DB when below view is in the from clause
       --       Did not spend time on the RCA so simply making this scalar subquery
       -- , CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND((m.inserts + m.updates + m.deletes) * 100 / s.num_rows, 1), '99999990D0') END stale_stats_perc
       CASE WHEN s.num_rows >= 0 THEN
           (
            select m.inserts + m.updates + m.deletes
              from dba_tab_modifications m
             where t.owner = m.table_owner
               AND t.table_name = m.table_name
               AND m.partition_name IS NULL
           )
         END modifications,
       (SELECT COUNT(*)
          FROM dba_tab_cols c
         WHERE c.owner = s.owner
           AND c.table_name = s.table_name) columns,
       (SELECT COUNT(*)
          FROM dba_indexes i
         WHERE i.table_owner = s.owner
           AND i.table_name = s.table_name) indexes,
       (SELECT COUNT(*)
          FROM dba_ind_columns ic
         WHERE ic.table_owner = s.owner
           AND ic.table_name = s.table_name) index_columns,
        round((s.num_rows*s.avg_row_len/1024),2) occupied_size,
        round(s.blocks*8.192,2) allocated_size
  FROM plan_table pt,
       dba_tab_statistics s,
       dba_tables t
       -- sys.dba_tab_modifications m -- requires sys on 10g
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.owner
   AND pt.object_name = s.table_name
   AND pt.object_type = s.object_type
   AND s.owner = t.owner
   AND s.table_name = t.table_name
   -- AND t.owner = m.table_owner(+)
   -- AND t.table_name = m.table_name(+)
   -- AND m.partition_name IS NULL
 ORDER BY
       s.table_name,
       s.owner) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Part</th>
PRO <th>Temp</th>
PRO <th>On Commit</th>
PRO <th>Num Rows</th>
PRO <th>Sample<br>Size</th>
PRO <th>Perc</th>
PRO <th>Last Analyzed</th>
PRO <th>Blocks</th>
PRO <th>Avg<br>Row<br>Len</th>
PRO <th>Global<br>Stats</th>
PRO <th>User<br>Stats</th>
PRO <th>Stat<br>Type<br>Locked</th>
PRO <th>Stale<br>Stats</th>
PRO <th>Perc</th>
PRO <th>Table<br>Cols</th>
PRO <th>Indexes</th>
PRO <th>Index<br>Cols</th>
PRO <th>Stat<br>Versions</th>
PRO <th>Tab<br>Modifications</th>
PRO <th>Partition<br>Type</th>
PRO <th>Partition<br>Columns</th>
PRO <th>Partition<br>Count</th>
PRO <th>Subpartition<br>Type</th>
PRO <th>Subpartition<br>Columns</th>
PRO <th>DoP</th>
PRO <th>BootStrap<br>Table<br>Size</th>
PRO <th>Candidate<br>for next<br>BootStrap<br>Stats</th>
PRO <th>Occupied<br>[KB]</th>
PRO <th>Allocated<br>[KB]</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * DBMS_STATS Table Preferences
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: DBMS_STATS Table Preferences - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="dbms_stats_tab_prefs"></a><details open><br/><summary id="summary2">DBMS_STATS Table Preferences</summary>
PRO
PRO DBMS_STATS Table Preferences.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Owner</th>
PRO <th>Table Name</th>
-- PRO <th>Obj#</th>
PRO <th>Parameter Name</th>
PRO <th>Parameter Value</th>
-- PRO <th>Change Time</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait --> 

--udayRemoved SELECT /* ^^script..sql DBMS_STATS Table Preferences */
--udayRemoved        CHR(10)||'<tr>'||CHR(10)||
--udayRemoved 	   '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
--udayRemoved        '<td>'||o.object_owner||'</td>'||CHR(10)||
--udayRemoved 	   '<td>'||o.object_name||'</td>'||CHR(10)||
--udayRemoved 	   '<td>'||v.obj#||'</td>'||CHR(10)||
--udayRemoved        '<td>'||v.pname||'</td>'||CHR(10)||
--udayRemoved        '<td>'||v.valchar||'</td>'||CHR(10)||
--udayRemoved 	   '<td>'||v.chgtime||'</td>'||CHR(10)||
--udayRemoved 	   '</tr>'
--udayRemoved   -- FROM sys.optstat_user_prefs$ v,
--udayRemoved 
SELECT /* ^^script..sql DBMS_STATS Table Preferences */
       CHR(10)||'<tr>'||CHR(10)||
	   '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||o.object_owner||'</td>'||CHR(10)||
	   '<td>'||o.object_name||'</td>'||CHR(10)||
       '<td>'||v.PREFERENCE_NAME||'</td>'||CHR(10)||
       '<td>'||regexp_replace(regexp_replace(regexp_replace(v.PREFERENCE_VALUE,'\s+',' ',1,0,'in'),'\s*,\s*',','),' FOR ','</br>FOR ')||'</td>'||CHR(10)||
	   '</tr>'
  FROM DBA_TAB_STAT_PREFS v,
       plan_table o
 WHERE o.object_owner = v.owner (+)
   AND o.object_name = v.table_name (+)
   AND STATEMENT_ID = :sql_id
ORDER BY o.object_owner, o.object_name, v.PREFERENCE_NAME;

--Uday.PSR.v6       (WITH object AS (
--Uday.PSR.v6          SELECT /*+ MATERIALIZE */
--Uday.PSR.v6                 object_owner owner, object_name name, object# obj#, object_type
--Uday.PSR.v6            FROM gv$sql_plan
--Uday.PSR.v6           WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6             AND sql_id = :sql_id
--Uday.PSR.v6             AND object_owner IS NOT NULL
--Uday.PSR.v6             AND object_name IS NOT NULL
--Uday.PSR.v6             AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6           UNION
--Uday.PSR.v6          SELECT object_owner owner, object_name name, object# obj#, object_type
--Uday.PSR.v6            FROM dba_hist_sql_plan
--Uday.PSR.v6           WHERE :license IN ('T', 'D')
--Uday.PSR.v6             AND dbid = ^^dbid.
--Uday.PSR.v6             AND sql_id = :sql_id
--Uday.PSR.v6             AND object_owner IS NOT NULL
--Uday.PSR.v6             AND object_name IS NOT NULL
--Uday.PSR.v6             AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6           ), plan_tables AS (
--Uday.PSR.v6           --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6           --UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--Uday.PSR.v6           --UdayRemoved.v6   FROM dba_tab_statistics t, -- include fixed objects
--Uday.PSR.v6           --UdayRemoved.v6        object o
--Uday.PSR.v6           --UdayRemoved.v6  WHERE t.owner = o.owner
--Uday.PSR.v6           --UdayRemoved.v6    AND t.table_name = o.name
--Uday.PSR.v6            SELECT /*+ MATERIALIZE */
--Uday.PSR.v6                   'TABLE' object_type, o.owner object_owner, o.name object_name, o.obj#
--Uday.PSR.v6              FROM object o
--Uday.PSR.v6             WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6            UNION
--Uday.PSR.v6           SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name, 
--Uday.PSR.v6		          null obj#
--Uday.PSR.v6                          /* Uday.v6 no longer needed
--Uday.PSR.v6		          (SELECT object_id
--Uday.PSR.v6					 FROM dba_objects io
--Uday.PSR.v6					WHERE io.owner = i.table_owner
--Uday.PSR.v6					  AND io.object_name = i.table_name
--Uday.PSR.v6					  AND io.object_type = 'TABLE') obj#
--Uday.PSR.v6                          */
--Uday.PSR.v6             FROM dba_indexes i,
--Uday.PSR.v6                  object o
--Uday.PSR.v6            WHERE o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6              AND i.owner = o.owner
--Uday.PSR.v6              AND i.index_name = o.name
--Uday.PSR.v6          ) 
--Uday.PSR.v6		  SELECT object_owner, object_name, obj#
--Uday.PSR.v6		    FROM plan_tables
--Uday.PSR.v6          )	o	  
--Uday.PSR.v6 -- WHERE v.obj# = o.obj#

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Owner</th>
PRO <th>Table Name</th>
-- PRO <th>Obj#</th>
PRO <th>Parameter Name</th>
PRO <th>Parameter Value</th>
-- PRO <th>Change Time</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');


/* -------------------------
 *
 * Table Extensions -- PSRv10
 * Uday
 * ------------------------- */
REM EXEC DBMS_SPD.FLUSH_SQL_PLAN_DIRECTIVE;

PRO
PRO <a name="extensions"></a><details open><br/><summary id="summary2">Table Extensions (DBA_STAT_EXTENSIONS)</summary>
PRO
PRO Table Extensions on objects used in ^^sql_id. 
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Owner</th>
PRO <th>Table Name</th>
PRO <th>Extension<br>Name</th>
PRO <th>Extension</th>
PRO <th>Creator</th>
PRO <th>Droppable</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM  ||'</td>'||CHR(10)||
       '<td >'||OWNER            ||'</td>'||CHR(10)||
       '<td >'||TABLE_NAME       ||'</td>'||CHR(10)||
       '<td >'||EXTENSION_NAME   ||'</td>'||CHR(10)||
       '<td >'||EXTENSION        ||'</td>'||CHR(10)||
       '<td >'||CREATOR          ||'</td>'||CHR(10)||
       '<td >'||DROPPABLE        ||'</td>'||CHR(10)
  FROM (
         SELECT /*+ ORDERED  leading(t) cardinality(t 1) */ 
                e.OWNER,
                e.TABLE_NAME,
                e.EXTENSION_NAME,
                e.EXTENSION,
                e.CREATOR,
                e.DROPPABLE
           FROM plan_table t, dba_stat_extensions e
          WHERE t.object_name is not null and t.object_owner is not null
            AND e.table_name = t.object_name
            AND STATEMENT_ID = :sql_id
          ORDER BY e.table_name, e.EXTENSION_NAME 
       ) v
;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Owner</th>
PRO <th>Table Name</th>
PRO <th>Extension<br>Name</th>
PRO <th>Extension</th>
PRO <th>Creator</th>
PRO <th>Droppable</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');


/* -------------------------
 *
 * table columns
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Table Columns - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="tbl_cols"></a><details open><br/><summary id="summary2">Table Columns</summary>

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT /* ^^script..sql Table Columns */
       v2.line_text
  FROM (
WITH ic as
 (SELECT /*+ MATERIALIZE leading(pt i)  */
         pt.object_owner table_owner,
         pt.object_name  table_name,
         i.column_name,
         COUNT(*) index_count
    FROM dba_ind_columns i, plan_table pt
   WHERE i.table_owner(+) = pt.object_owner
     AND i.table_name(+) = pt.object_name 
     AND STATEMENT_ID = :sql_id
   GROUP BY
         pt.object_owner,
         pt.object_name,
         i.column_name )
SELECT object_name table_name,
       object_owner owner,
       1 line_type,
       1 row_num,
       '<a name="c_'||LOWER(object_name||'_'||object_owner)||'"></a><details open><br/><summary id="summary3">Table Columns: '||object_name||' ('||object_owner||')</summary>'||CHR(10)||CHR(10)||
       'CBO Statistics and relevant attributes.'||CHR(10)||CHR(10)||
       '<table>'||CHR(10)||CHR(10)||
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       --'<th>Table Name</th>'||CHR(10)||
       --'<th>Owner</th>'||CHR(10)||
       '<th>Indexes</th>'||CHR(10)||
       '<th>Col<br>ID</th>'||CHR(10)||
       '<th>Column Name</th>'||CHR(10)||
       '<th>Expression</th>'||CHR(10)||       
       '<th>Data<br>Type</th>'||CHR(10)||
       '<th>Null<br>able</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Num<br>Nulls</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Num<br>Distinct</th>'||CHR(10)||
       '<th>Low Value</th>'||CHR(10)||
       '<th>High Value</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Avg<br>Col<br>Len</th>'||CHR(10)||
       '<th>Density</th>'||CHR(10)||
       '<th>Num<br>Buckets</th>'||CHR(10)||
       '<th>Histogram</th>'||CHR(10)||
       '<th>Hidden</th>'||CHR(10)||
       '<th>Virtual</th>'||CHR(10)||       
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT v.table_name,
       v.owner,
       2 line_type,
       ROWNUM row_num,
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       --'<td>'||v.table_name||'</td>'||CHR(10)||
       --'<td>'||v.owner||'</td>'||CHR(10)||
       '<td class="c">'||v.indexes||'</td>'||CHR(10)||
       '<td class="c">'||v.column_id||'</td>'||CHR(10)||
       '<td>'||v.column_name||'</td>'||CHR(10)||
       '<td>'||CASE WHEN v.column_name LIKE 'SYS%' THEN 
               (SELECT To_Char(extension) 
                  FROM dba_stat_extensions
                 WHERE v.table_name = table_name 
                   AND v.owner = owner
                   AND v.column_name= extension_name) END||'</td>'||CHR(10)||       
       '<td>'||v.data_type||'</td>'||CHR(10)||
       '<td class="c">'||v.nullable||'</td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.num_nulls||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size_perc||'</td>'||CHR(10)||
       '<td class="r">'||v.num_distinct||'</td>'||CHR(10)||
       '<td nowrap>'||v.low_value||'</td>'||CHR(10)||
       '<td nowrap>'||v.high_value||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_col_len||'</td>'||CHR(10)||
       '<td class="r">'||v.density||'</td>'||CHR(10)||
       '<td class="r">'||v.num_buckets||'</td>'||CHR(10)||
       '<td>'||v.histogram||'</td>'||CHR(10)||
       '<td class="c">'||v.hidden_column||'</td>'||CHR(10)||
       '<td class="c">'||v.virtual_column||'</td>'||CHR(10)||
       '<td class="c">'||v.global_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.user_stats||'</td>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM (
--Uday.PSR.v6: replace 't' (dba_tables) with 'pt' (plan_table)
SELECT /*+ NO_MERGE LEADING(pt) */
       -- t.table_name,
       -- t.owner,
       pt.object_name table_name,
       pt.object_owner owner,
       NVL(ic.index_count,0) indexes,
       c.column_id,
       c.column_name,
       c.data_type,
       c.data_default,
       c.nullable,
       -- t.num_rows,
       pt.cardinality num_rows,
       c.num_nulls,
       c.sample_size,
       -- CASE
       -- WHEN t.num_rows > c.num_nulls THEN TO_CHAR(LEAST(100, ROUND(c.sample_size * 100 / (t.num_rows - c.num_nulls), 1)), '99999990D0')
       -- WHEN t.num_rows = c.num_nulls THEN TO_CHAR(100, '99999990D0')
       -- END sample_size_perc,
       CASE
         WHEN pt.cardinality > c.num_nulls THEN TO_CHAR(LEAST(100, ROUND(c.sample_size * 100 / (pt.cardinality - c.num_nulls), 1)), '99999990D0')
         WHEN pt.cardinality = c.num_nulls THEN TO_CHAR(100, '99999990D0')
       END sample_size_perc,
       c.num_distinct
       /* uday.psr.v6: getting actual values
       c.low_value,
       c.high_value high_value,
       */
       --Uday.PSR.v6
       -- appending ||'' to avoid ORA-29275: partial multibyte character
       -- sometimes sessions crosses with buffer overflow
       -- 
       ,decode(substr(c.data_type,1,9) -- as there are several timestamp types
          ,'NUMBER'       ,to_char(utl_raw.cast_to_number(c.low_value)) ||''
          ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(c.low_value)) ||''
          ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(c.low_value)) ||''
          ,'BINARY_DO'    ,to_char(utl_raw.cast_to_binary_double(c.low_value)) ||''
          ,'BINARY_FL'    ,to_char(utl_raw.cast_to_binary_float(c.low_value)) ||''
          ,'DATE'         ,decode(c.low_value, NULL, NULL, rtrim(
                                to_char(100*(to_number(substr(c.low_value,1,2),'XX')-100)
                                       + (to_number(substr(c.low_value,3,2),'XX')-100),'fm0000')||'-'||
                                to_char(to_number(substr(c.low_value,5,2),'XX'),'fm00')||'-'||
                                to_char(to_number(substr(c.low_value,7,2),'XX'),'fm00')||' '||
                                to_char(to_number(substr(c.low_value,9,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(c.low_value,11,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(c.low_value,13,2),'XX')-1,'fm00'))) ||''
          ,'TIMESTAMP'    ,decode(c.low_value, NULL, NULL, rtrim(
                           to_char(100*(to_number(substr(c.low_value,1,2),'XX')-100)
                                  + (to_number(substr(c.low_value,3,2),'XX')-100),'fm0000')||'-'||
                           to_char(to_number(substr(c.low_value,5,2),'XX'),'fm00')||'-'||
                           to_char(to_number(substr(c.low_value,7,2),'XX'),'fm00')||' '||
                           to_char(to_number(substr(c.low_value,9,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(c.low_value,11,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(c.low_value,13,2),'XX')-1,'fm00')
                          ||'.'||to_number(substr(c.low_value,15,8),'XXXXXXXX')  )) ||''
          , c.low_value
        ) low_value
       ,decode(substr(c.data_type,1,9) -- as there are several timestamp types
          ,'NUMBER'       ,to_char(utl_raw.cast_to_number(c.high_value)) ||''
          ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(c.high_value)) ||''
          ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(c.high_value)) ||''
          ,'BINARY_DO'    ,to_char(utl_raw.cast_to_binary_double(c.high_value)) ||''
          ,'DATE'         ,decode(c.high_value, NULL, NULL, rtrim(
                                to_char(100*(to_number(substr(c.high_value,1,2),'XX')-100)
                                       + (to_number(substr(c.high_value,3,2),'XX')-100),'fm0000')||'-'||
                                to_char(to_number(substr(c.high_value,5,2),'XX'),'fm00')||'-'||
                                to_char(to_number(substr(c.high_value,7,2),'XX'),'fm00')||' '||
                                to_char(to_number(substr(c.high_value,9,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(c.high_value,11,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(c.high_value,13,2),'XX')-1,'fm00'))) ||''
          ,'TIMESTAMP'    ,decode(c.high_value, NULL, NULL, rtrim(
                           to_char(100*(to_number(substr(c.high_value,1,2),'XX')-100)
                                  + (to_number(substr(c.high_value,3,2),'XX')-100),'fm0000')||'-'||
                           to_char(to_number(substr(c.high_value,5,2),'XX'),'fm00')||'-'||
                           to_char(to_number(substr(c.high_value,7,2),'XX'),'fm00')||' '||
                           to_char(to_number(substr(c.high_value,9,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(c.high_value,11,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(c.high_value,13,2),'XX')-1,'fm00')
                          ||'.'||to_char(to_number(substr(c.high_value,15,8),'XXXXXXXX')))) ||''
          , c.high_value
       ) high_value,
       TO_CHAR(c.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       c.avg_col_len,
       LOWER(TO_CHAR(c.density, '0D000000EEEE')) density,
       c.num_buckets,
       c.histogram,
       c.hidden_column,
       c.virtual_column,
       c.global_stats,
       c.user_stats
  FROM plan_table pt,
       --Uday.PSR.v6 dba_tables t,
       dba_tab_cols c,
       ic
/* udayRemoved.v6: now this query is in the with clause to improve perf
       (SELECT i.table_owner,
               i.table_name,
               i.column_name,
               COUNT(*) index_count
          FROM dba_ind_columns i
         GROUP BY
               i.table_owner,
               i.table_name,
               i.column_name ) ic
*/
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = c.owner
   AND pt.object_name = c.table_name
   AND ic.table_owner (+) = c.owner
   AND ic.table_name (+) = c.table_name
   AND ic.column_name (+) = c.column_name
 ORDER BY
       -- t.table_name,
       -- t.owner,
       pt.object_name,
       pt.object_owner,
       NVL(ic.index_count,0) DESC,
       c.column_id NULLS LAST,
       c.column_name) v
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       3 line_type,
       1 row_num,
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       --'<th>Table Name</th>'||CHR(10)||
       --'<th>Owner</th>'||CHR(10)||
       '<th>Indexes</th>'||CHR(10)||
       '<th>Col<br>ID</th>'||CHR(10)||
       '<th>Column Name</th>'||CHR(10)||
       '<th>Expression</th>'||CHR(10)||       
       '<th>Data<br>Type</th>'||CHR(10)||
       '<th>Null<br>able</th>'||CHR(10)||       
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Num<br>Nulls</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Num<br>Distinct</th>'||CHR(10)||
       '<th>Low Value</th>'||CHR(10)||
       '<th>High Value</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Avg<br>Col<br>Len</th>'||CHR(10)||
       '<th>Density</th>'||CHR(10)||
       '<th>Num<br>Buckets</th>'||CHR(10)||
       '<th>Histogram</th>'||CHR(10)||
       '<th>Hidden</th>'||CHR(10)||
       '<th>Virtual</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       4 line_type,
       1 row_num,
       CHR(10)||'</table></details><!--Pushkar-->'||CHR(10)||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id) v2
 ORDER BY
       v2.table_name,
       v2.owner,
       v2.line_type,
       v2.row_num;
   
PRO

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details> <!--Pushkar-->	
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * table partitions
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Table Partitions - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="tbl_parts"></a><details><br/><summary id="summary2">Table Partitions</summary>

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->	

SELECT /* ^^script..sql Table Partitions */
       v2.line_text
  FROM (
--Uday.PSR.v6WITH object AS (
--Uday.PSR.v6SELECT /*+ MATERIALIZE */
--Uday.PSR.v6       object_owner owner, object_name name, object_type
--Uday.PSR.v6  FROM gv$sql_plan
--Uday.PSR.v6 WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6   AND sql_id = :sql_id
--Uday.PSR.v6   AND object_owner IS NOT NULL
--Uday.PSR.v6   AND object_name IS NOT NULL
--Uday.PSR.v6   AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6 UNION
--Uday.PSR.v6SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6  FROM dba_hist_sql_plan
--Uday.PSR.v6 WHERE :license IN ('T', 'D')
--Uday.PSR.v6   AND dbid = ^^dbid.
--Uday.PSR.v6   AND sql_id = :sql_id
--Uday.PSR.v6   AND object_owner IS NOT NULL
--Uday.PSR.v6   AND object_name IS NOT NULL
--Uday.PSR.v6   AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6 ), plan_tables AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        'TABLE' object_type, p.table_owner object_owner, p.table_name object_name
--Uday.PSR.v6   FROM dba_tab_partitions p, -- include fixed objects
--Uday.PSR.v6        object o
--Uday.PSR.v6  WHERE p.table_owner = o.owner
--Uday.PSR.v6    AND p.table_name = o.name
--Uday.PSR.v6    AND o.object_type like 'TABLE%'  --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6   FROM dba_indexes i,
--Uday.PSR.v6        dba_ind_partitions p,
--Uday.PSR.v6        object o
--Uday.PSR.v6  WHERE i.owner = o.owner
--Uday.PSR.v6    AND o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6    AND i.index_name = o.name
--Uday.PSR.v6	AND i.owner = p.index_owner(+)  -- partitioned table but not part index in the plan
--Uday.PSR.v6	AND i.index_name = p.index_name(+)  -- same as above
--Uday.PSR.v6)
SELECT object_name table_name,
       object_owner owner,
       1 line_type,
       1 row_num,
       '<a name="tp_'||LOWER(object_name||'_'||object_owner)||'"></a><details><br/><summary id="summary3">Table Partitions: '||object_name||' ('||object_owner||')</summary>'||CHR(10)||CHR(10)||
       'Table partitions and relevant attributes (only the first and last 100).'||CHR(10)||CHR(10)||
       '<table>'||CHR(10)||CHR(10)||
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Partition<br>Position</th>'||CHR(10)||
       '<th>Partition<br>Name</th>'||CHR(10)||
       '<th>Composite</th>'||CHR(10)||
       '<th>Subpartition<br>Count</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Blocks</th>'||CHR(10)||    
       '<th>Avg<br>Row<br>Len</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '<th>Staleness<br>Perc</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT v.table_name,
       v.table_owner,
       2 line_type,
       ROWNUM row_num,
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
	   '<td class="c">'||v.partition_position||'</td>'||CHR(10)||
       '<td class="c">'||v.partition_name||'</td>'||CHR(10)||
       '<td class="c">'||v.composite||'</td>'||CHR(10)||
       '<td class="r">'||v.subpartition_count||'</td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size_perc||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.blocks||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_row_len||'</td>'||CHR(10)||
       '<td class="c">'||v.global_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.user_stats||'</td>'||CHR(10)||
       '<td class="r">'||v.staleness_perc||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT DISTINCT v.table_name,
       v.table_owner,
	   v.partition_name,
	   v.partition_position,
	   v.subpartition_count,
	   v.composite,
       v.num_rows,
       v.sample_size,
       v.sample_size_perc,
       v.last_analyzed,
       v.blocks,
       v.avg_row_len,
       v.global_stats,
       v.user_stats,
       v.staleness_perc
  FROM (  
SELECT /*+ NO_MERGE LEADING(pt s m) */
       s.table_name,
       s.table_owner,
	   s.partition_name,
	   s.partition_position,
	   s.subpartition_count,
	   s.composite,
       s.num_rows,
       s.sample_size,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND(s.sample_size * 100 / s.num_rows, 1), '99999990D0') END sample_size_perc,
       TO_CHAR(s.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       s.blocks,
       s.avg_row_len,
       s.global_stats,
       s.user_stats,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND((m.inserts + m.updates + m.deletes) * 100 / s.num_rows, 1), '99999990D0') END staleness_perc,
	   ROW_NUMBER() OVER (PARTITION BY s.table_owner, s.table_name ORDER BY s.partition_position DESC) row_num 
  FROM plan_table pt,
       dba_tab_partitions s,
       sys.dba_tab_modifications m -- requires sys on 10g
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
   AND s.table_owner = m.table_owner(+)
   AND s.table_name = m.table_name(+)
   AND s.partition_name = m.partition_name(+)
UNION 
SELECT /*+ NO_MERGE LEADING(pt s m) */
       s.table_name,
       s.table_owner,
	   s.partition_name,
	   s.partition_position,
	   s.subpartition_count,
	   s.composite,
       s.num_rows,
       s.sample_size,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND(s.sample_size * 100 / s.num_rows, 1), '99999990D0') END sample_size_perc,
       TO_CHAR(s.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       s.blocks,
       s.avg_row_len,
       s.global_stats,
       s.user_stats,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND((m.inserts + m.updates + m.deletes) * 100 / s.num_rows, 1), '99999990D0') END staleness_perc,
	   ROW_NUMBER() OVER (PARTITION BY s.table_owner, s.table_name ORDER BY s.partition_position ASC) row_num 
  FROM plan_table pt,
       dba_tab_partitions s,
       sys.dba_tab_modifications m -- requires sys on 10g
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
   AND s.table_owner = m.table_owner(+)
   AND s.table_name = m.table_name(+)
   AND s.partition_name = m.partition_name(+)   
   ) v
 WHERE v.row_num BETWEEN 1 AND 100
 ORDER BY
       v.table_name,
       v.table_owner,
	   v.partition_position DESC) v
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       3 line_type,
       1 row_num,
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Partition<br>Position</th>'||CHR(10)||
       '<th>Partition<br>Name</th>'||CHR(10)||
       '<th>Composite</th>'||CHR(10)||
       '<th>Subpartition<br>Count</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Blocks</th>'||CHR(10)||    
       '<th>Avg<br>Row<br>Len</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '<th>Staleness<br>Perc</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       4 line_type,
       1 row_num,
       CHR(10)||'</table></details><!--Pushkar-->'||CHR(10)||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id) v2
 ORDER BY
       v2.table_name,
       v2.owner,
       v2.line_type,
       v2.row_num;	      


select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details> <!--Pushkar-->	 
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');  
/* -------------------------
 *
 * table constraints
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Table Constraints - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="tbl_constr"></a><details><br/><summary id="summary2">Table Constraints</summary>

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->	

SELECT /* ^^script..sql Table Constraints */
       v2.line_text
  FROM (
--Uday.PSR.v6 WITH object AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM gv$sql_plan
--Uday.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM dba_hist_sql_plan
--Uday.PSR.v6  WHERE dbid = ^^dbid.
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  ), plan_tables AS (
--Uday.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, p.owner object_owner, p.table_name object_name
--Uday.PSR.v6 --UdayRemoved.v6   FROM dba_tables p, -- include fixed objects
--Uday.PSR.v6 --UdayRemoved.v6        object o
--Uday.PSR.v6 --UdayRemoved.v6  WHERE p.owner = o.owner
--Uday.PSR.v6 --UdayRemoved.v6    AND p.table_name = o.name
--Uday.PSR.v6  SELECT /*+ MATERIALIZE */
--Uday.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--Uday.PSR.v6    FROM object o
--Uday.PSR.v6   WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6   UNION
--Uday.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6    FROM dba_indexes i,
--Uday.PSR.v6         object o
--Uday.PSR.v6   WHERE o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6     AND i.owner = o.owner
--Uday.PSR.v6     AND i.index_name = o.name
--Uday.PSR.v6 )
SELECT object_name table_name,
       object_owner owner,
       1 line_type,
       1 row_num,
       '<a name="tc_'||LOWER(object_name||'_'||object_owner)||'"></a><details><br/><summary id="summary3">Table Constraints: '||object_name||' ('||object_owner||')</summary>'||CHR(10)||CHR(10)||
       'Table constraints and relevant attributes.'||CHR(10)||CHR(10)||
       '<table>'||CHR(10)||CHR(10)||
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Constraint<br>Name</th>'||CHR(10)||
       '<th>Constraint<br>Type</th>'||CHR(10)||
    --  '<th>Search<br>Condition</th>'||CHR(10)||
       '<th>R Owner</th>'||CHR(10)||
       '<th>R Constraint<br>Name</th>'||CHR(10)||
       '<th>Delete<br>Rule</th>'||CHR(10)||
       '<th>Status</th>'||CHR(10)||
       '<th>Defferable</th>'||CHR(10)||    
       '<th>Deferred</th>'||CHR(10)||
       '<th>Validated</th>'||CHR(10)||
       '<th>Generated</th>'||CHR(10)||
       '<th>Rely</th>'||CHR(10)||
	   '<th>Last<br>Change</th>'||CHR(10)||
	   '<th>Index<br>Owner</th>'||CHR(10)||
	   '<th>Index<br>Name</th>'||CHR(10)||
	   '<th>Invalid</th>'||CHR(10)||
	   '<th>View<br>Related</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT v.table_name,
       v.owner,
       2 line_type,
       ROWNUM row_num,
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
	   '<td class="c">'||v.constraint_name||'</td>'||CHR(10)||
       '<td class="c">'||v.constraint_type||'</td>'||CHR(10)||
     --  '<td class="c">'||v.search_condition||'</td>'||CHR(10)||
       '<td class="r">'||v.r_owner||'</td>'||CHR(10)||
       '<td class="r">'||v.r_constraint_name||'</td>'||CHR(10)||
       '<td class="r">'||v.delete_rule||'</td>'||CHR(10)||
       '<td class="r">'||v.status||'</td>'||CHR(10)||
       '<td class="r">'||v.deferrable||'</td>'||CHR(10)||
       '<td class="r">'||v.deferred||'</td>'||CHR(10)||
       '<td class="r">'||v.validated||'</td>'||CHR(10)||
       '<td class="c">'||v.generated||'</td>'||CHR(10)||
       '<td class="c">'||v.rely||'</td>'||CHR(10)||
       '<td class="r">'||v.last_change||'</td>'||CHR(10)||
	   '<td class="r">'||v.index_owner||'</td>'||CHR(10)||
	   '<td class="r">'||v.index_name||'</td>'||CHR(10)||
	   '<td class="r">'||v.invalid||'</td>'||CHR(10)||
	   '<td class="r">'||v.view_related||'</td>'||CHR(10)||
       '</tr>'
  FROM (  
SELECT /*+ NO_MERGE LEADING(pt s) */
       s.table_name,
       s.owner,
       s.constraint_name,
	   s.constraint_type,
	  -- dbms_lob.substr(s.search_condition,1,100) search_condition,
	   s.r_owner,
	   s.r_constraint_name,
       s.delete_rule,
       s.status,
       s.deferrable,
       s.deferred,
       s.validated,
       s.generated,
       s.rely,
       s.last_change,
       s.index_owner,
	   s.index_name,
	   s.invalid,
	   s.view_related
  FROM plan_table pt,
       dba_constraints s
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.owner
   AND pt.object_name = s.table_name) v
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       3 line_type,
       1 row_num,
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Constraint<br>Name</th>'||CHR(10)||
       '<th>Constraint<br>Type</th>'||CHR(10)||
     --  '<th>Search<br>Condition</th>'||CHR(10)||
       '<th>R Owner</th>'||CHR(10)||
       '<th>R Constraint<br>Name</th>'||CHR(10)||
       '<th>Delete<br>Rule</th>'||CHR(10)||
       '<th>Status</th>'||CHR(10)||
       '<th>Defferable</th>'||CHR(10)||    
       '<th>Deferred</th>'||CHR(10)||
       '<th>Validated</th>'||CHR(10)||
       '<th>Generated</th>'||CHR(10)||
       '<th>Rely</th>'||CHR(10)||
	   '<th>Last<br>Change</th>'||CHR(10)||
	   '<th>Index<br>Owner</th>'||CHR(10)||
	   '<th>Index<br>Name</th>'||CHR(10)||
	   '<th>Invalid</th>'||CHR(10)||
	   '<th>View<br>Related</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       4 line_type,
       1 row_num,
       CHR(10)||'</table></details><!--Pushkar-->'||CHR(10)||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 ) v2
 ORDER BY
       v2.table_name,
       v2.owner,
       v2.line_type,
       v2.row_num;		 


select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details> <!--Pushkar--> 
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * tables statistics version
 * psrv9: added row change, %-row change columns
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Tables Statistics versions - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="tbl_stat_ver"></a><details open><br/><summary id="summary2">Tables Statistics Versions</summary>
PRO
PRO CBO Statistics and relevant attributes.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Version Type</th>
PRO <th>Save Time</th>
PRO <th>Last Analyzed</th>
PRO <th>Num Rows</th>
PRO <th>Row Change</th>
PRO <th>%-<br>Row Change</th>
PRO <th>Sample<br>Size</th>
PRO <th>Sample<br>Perc</th>
PRO <th>Blocks</th>
PRO <th>Avg<br>Row<br>Len</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->
	   
SELECT /* ^^script..sql Tables Statistics Versions */
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.object_name||'</td>'||CHR(10)||
       '<td>'||v.owner||'</td>'||CHR(10)||
       '<td>'||v.version_type||'</td>'||CHR(10)||	   
       '<td nowrap>'||v.savtime||'</td>'||CHR(10)||
       '<td nowrap>'||v.analyzetime||'</td>'||CHR(10)||
       '<td class="r">'||v.rowcnt||'</td>'||CHR(10)||
       '<td class="r">'||v.rowchange||'</td>'||CHR(10)||
       '<td class="r">'||v.pctrowchange||'</td>'||CHR(10)||
       '<td class="r">'||v.samplesize||'</td>'||CHR(10)||
       '<td class="c">'||v.perc||'</td>'||CHR(10)||
       '<td class="c">'||v.blkcnt||'</td>'||CHR(10)||
       '<td class="c">'||v.avgrln||'</td>'||CHR(10)||
       '</tr>'
  FROM (
--Uday.PSR.v6 WITH object AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM gv$sql_plan
--Uday.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM dba_hist_sql_plan
--Uday.PSR.v6  WHERE :license IN ('T', 'D')
--Uday.PSR.v6    AND dbid = ^^dbid.
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  ), plan_tables AS (
--Uday.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--Uday.PSR.v6 --UdayRemoved.v6   FROM dba_tab_statistics t, -- include fixed objects
--Uday.PSR.v6 --UdayRemoved.v6        object o
--Uday.PSR.v6 --UdayRemoved.v6  WHERE t.owner = o.owner
--Uday.PSR.v6 --UdayRemoved.v6    AND t.table_name = o.name
--Uday.PSR.v6  SELECT /*+ MATERIALIZE */
--Uday.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--Uday.PSR.v6    FROM object o
--Uday.PSR.v6   WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6   UNION
--Uday.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6    FROM dba_indexes i,
--Uday.PSR.v6         object o
--Uday.PSR.v6   WHERE o.object_type like 'INDEX%'
--Uday.PSR.v6     AND i.owner = o.owner
--Uday.PSR.v6     AND i.index_name = o.name
--Uday.PSR.v6 )
SELECT 
       object_name,
       owner,
       version_type,
       savtime,
       analyzetime,
       rowcnt,
       case when lead(rowcnt) over(partition by object_name order by savtime desc nulls first) is null then '-'
            else to_char(rowcnt - nvl(lead(rowcnt) over(partition by object_name order by savtime desc nulls first), 0))
       end rowchange,
       case when lead(rowcnt) over(partition by object_name order by savtime desc nulls first) is null then '-'
            when lead(rowcnt) over(partition by object_name order by savtime desc nulls first) = 0 then to_char(100*rowcnt)
       else to_char(round(100*(rowcnt - (lead(rowcnt) over(partition by object_name order by savtime desc nulls first)))/(lead(rowcnt) over(partition by object_name order by savtime desc nulls first)), 1), '99999990D0')
       end pctrowchange,
       samplesize,
       perc,
       blkcnt,
       avgrln
  FROM (
--Uday.PSR.v6 SELECT /*+ NO_MERGE LEADING(pt t) */
--Uday.PSR.v6        t.table_name object_name,
--Uday.PSR.v6        t.owner,
--Uday.PSR.v6        'CURRENT' version_type,
--Uday.PSR.v6        NULL savtime, 
--Uday.PSR.v6        t.last_analyzed analyzetime, 
--Uday.PSR.v6        t.num_rows rowcnt, 
--Uday.PSR.v6        t.sample_size samplesize, 
--Uday.PSR.v6        CASE WHEN t.num_rows > 0 THEN TO_CHAR(ROUND(t.sample_size * 100 / t.num_rows, 1), '99999990D0') END perc, 
--Uday.PSR.v6        t.blocks blkcnt, 
--Uday.PSR.v6        t.avg_row_len avgrln
SELECT /*+ NO_MERGE LEADING(pt t) */
       pt.object_name,
       pt.object_owner owner,
       'CURRENT' version_type,
       NULL savtime, 
       pt.optimizer analyzetime, 
       pt.cardinality rowcnt, 
       pt.cost samplesize, 
       CASE WHEN pt.cardinality > 0 THEN TO_CHAR(ROUND(pt.cost * 100 / pt.cardinality, 1), '99999990D0') END perc, 
       pt.io_cost blkcnt, 
       pt.bytes avgrln
  FROM plan_table pt
       -- dba_tables t
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   -- AND pt.object_owner = t.owner
   -- AND pt.object_name = t.table_name
UNION ALL
SELECT /*+ NO_MERGE LEADING(pt t h) index(h I_WRI$_OPTSTAT_TAB_OBJ#_ST) */
       t.object_name,
       t.owner,
       'HISTORY' version_type,
       TO_CHAR(h.savtime, 'YYYY-MM-DD/HH24:MI:SS') savtime, 
       TO_CHAR(h.analyzetime, 'YYYY-MM-DD/HH24:MI:SS') analyzetime, 
       h.rowcnt, 
       h.samplesize, 
       CASE WHEN h.rowcnt > 0 THEN TO_CHAR(ROUND(h.samplesize * 100 / h.rowcnt, 1), '99999990D0') END perc, 
       h.blkcnt, 
       h.avgrln
  FROM plan_table pt,
       dba_objects t,
       sys.WRI$_OPTSTAT_TAB_HISTORY h
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = t.owner
   AND pt.object_name = t.object_name
   AND t.object_type = 'TABLE'
   AND t.object_id = h.obj#
   AND h.savtime > systimestamp - interval '30' day
)
 ORDER BY
       object_name,
       owner,
	   savtime DESC NULLS FIRST
) v;	   

PRO
PRO **** ORA-942 ERROR on sys.wri$_OPTSTAT_%_HISTORY can be ignored ****

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Version Type</th>
PRO <th>Save Time</th>
PRO <th>Last Analyzed</th>
PRO <th>Num Rows</th>
PRO <th>Row Change</th>
PRO <th>%-Row Change</th>
PRO <th>Sample<br>Size</th>
PRO <th>Perc</th>
PRO <th>Blocks</th>
PRO <th>Avg<br>Row<br>Len</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
 
PRO<table>
PRO
PRO <tr>
PRO <th>Table Name</th>
PRO <th>Job</th>
PRO <th>Operation</th>
PRO <th>ID</th>
PRO <th>Notes/Parameters to dbms_stats.gather_table_stata</th>
PRO <th>Stats Gather Time</th>
PRO <th>Duration</th>
rem PRO <th>Target #_of_blocks</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

select 
  '<tr>'||
  '<td>'|| v.object_name||'</td>'||
  '<td>'|| v.job_name||'</td>'||
  '<td>'|| v.operation||'</td>'||
  '<td>'|| v.id||'</td>'||
  '<td>'|| v.notes||'</td>'|| 
  '<td nowrap>'|| to_char(v.start_time,'YYYY-MM-DD/HH24:MI:SS')||'</td>'||
  '<td nowrap>'|| to_char(v.end_time - v.start_time) ||'</td>'||
--  '<td>'|| (select target_size from dba_optstat_operation_tasks t where t.opid = v.id and upper(t.target)=o.target and t.target_type = 'TABLE') ||'</td>'||  
  '</tr>'
from
( 
select /*+ leading(pt) */
   pt.object_name,
   start_time,
   end_time,
   o.job_name,
   o.operation,
   o.id,
   listagg(v.param_name||'=>'||v.param_val,', ') within group (order by v.param_name desc) notes
from dba_optstat_operations o, plan_table pt,
     xmltable ('params/param' passing xmltype (o.notes) 
               columns
                 param_name varchar2(128) path '@name',
                 param_val  varchar2(128) path '@val'
              ) v
where pt.object_type= 'TABLE'
and pt.statement_id = :sql_id
and regexp_substr(lower(replace(o.target,'"')),'^(.*?)\.([a-z0-9$_#]+)',1,1,'i',2) = pt.object_name
and o.status   = 'COMPLETED'
and o.operation= 'gather_table_stats'
and (param_name NOT LIKE 'st%' and param_name <> 'method_opt')
group by pt.object_name, start_time, end_time, o.job_name, o.operation, o.id
) v
order by v.object_name, v.id desc;

PRO
PRO <tr>
PRO <th>Table Name</th>
PRO <th>Job</th>
PRO <th>Operation</th>
PRO <th>ID</th>
PRO <th>Notes/Parameters to dbms_stats.gather_table_stata</th>
PRO <th>Stats Gather Time</th>
PRO <th>Duration</th>
rem PRO <th>Target #_of_blocks</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');


/* -------------------------
 *
 * table modifications
 *
 * Uday
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Tables modifications - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="tbl_modifications"></a><details open><br/><summary id="summary2">Table Modifications</summary>
PRO
PRO Table Modifications
PRO
PRO <table>
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Num Rows</th>
PRO <th>Partition</th>
PRO <th>Sub-Partition</th>
PRO <th>Inserts</th>
PRO <th>Updates</th>
PRO <th>Deletes</th>
PRO <th>Truncated</th>
PRO <th>Dropped Segments</th>
PRO <th>Last Analyzed</th>
PRO <th>Last Modified</th>
PRO <th>Percent<br>Modifications</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->
	   
SELECT /* ^^script..sql Tables modifications */
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.table_name||'</td>'||CHR(10)||
       '<td>'||v.table_owner||'</td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td>'||v.partition_name||'</td>'||CHR(10)||	   
       '<td>'||v.subpartition_name||'</td>'||CHR(10)||	   
       '<td class="r">'||v.inserts||'</td>'||CHR(10)||
       '<td class="r">'||v.updates||'</td>'||CHR(10)||
       '<td class="r">'||v.deletes||'</td>'||CHR(10)||
       '<td class="c">'||v.truncated||'</td>'||CHR(10)||	   
       '<td class="r">'||v.drop_segments||'</td>'||CHR(10)||
       '<td>'||v.last_analyzed||'</td>'||CHR(10)||	   
       '<td>'||v.timestamp||'</td>'||CHR(10)||	   
       '<td class="r">'||v.modpct||'</td>'||CHR(10)||
       '</tr>'
  FROM (
 SELECT /*+ leading(t rm) */
       tm.table_name, tm.table_owner, t.cardinality num_rows, tm.partition_name, tm.subpartition_name, 
       tm.inserts, tm.updates, tm.deletes, tm.truncated, tm.drop_segments, 
       t.optimizer last_analyzed, to_char(tm.timestamp,'YYYY-MM-DD/HH24:MI:SS') timestamp,
       round((Nvl((tm.inserts + tm.updates + tm.deletes),0)/decode(nvl(t.cardinality,0),0,1,t.cardinality))* 100, 2) modpct
   FROM dba_tab_modifications tm, 
	plan_table t
  WHERE tm.table_owner = t.object_owner
    AND tm.table_name = t.object_name
    AND STATEMENT_ID = :sql_id
 ORDER BY tm.table_name, tm.table_owner, tm.partition_name, tm.subpartition_name
) v
;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Table Name</th>
PRO <th>Owner</th>
PRO <th>Num Rows</th>
PRO <th>Partition</th>
PRO <th>Sub-Partition</th>
PRO <th>Inserts</th>
PRO <th>Updates</th>
PRO <th>Deletes</th>
PRO <th>Truncated</th>
PRO <th>Dropped Segments</th>
PRO <th>Last Analyzed</th>
PRO <th>Last Modified</th>
PRO <th>Percent<br>Modifications</th>
PRO </tr>
PRO </table>
PRO
PRO <details><br/><summary id="summary3">Modules Contributing to Table Modifications</summary>
PRO
PRO Modules Contributing to Table Modifications
PRO
pro <table>
pro <tr>
PRO <th>#</th>
pro <th>Table Name</th>
pro <th>Table Owner</th>
pro <th>Module</th>
pro </tr>

WITH pl AS
(
  SELECT /*+ leading(pt) */ distinct inst_id, sql_id, plan_hash_value, child_number,
       sqlplan.object_owner, sqlplan.object_name
  from gv$sql_plan sqlplan, plan_table pt
  where sqlplan.operation in ('LOAD TABLE CONVENTIONAL','LOAD AS SELECT','MERGE','UPDATE','DELETE')
  and sqlplan.parent_id=0
  and sqlplan.object_name=pt.object_name
  AND sqlplan.object_owner=pt.object_owner
  AND STATEMENT_ID=:sql_id
)
select
       '<tr>'||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||object_name||'</td>'||CHR(10)||
       '<td>'||object_owner||'</td>'||CHR(10)||
       '<td>'||module||'</td>'||CHR(10)||
       '<tr>'
  from (
          SELECT /*+ leading (pl) */ DISTINCT pl.object_name, pl.object_owner, module
          FROM   gv$sql gvsql, pl
          WHERE  gvsql.inst_id=pl.inst_id
          AND    gvsql.sql_id=pl.sql_id
          AND    gvsql.plan_hash_value=pl.plan_hash_value
          AND    gvsql.child_number=pl.child_number
          ORDER  BY object_name, object_owner, module
       ) v
;
pro <tr>
PRO <th>#</th>
pro <th>Table Name</th>
pro <th>Table Owner</th>
pro <th>Module</th>
pro </tr>
pro </table>
pro </details>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar--> 
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * indexes
 * Uday:PSR: added status column
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Indexes details - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="indexes"></a><details open><br/><summary id="summary2">Indexes</summary>

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

/* Pushkar 10.9 */
commit;
INSERT INTO plan_table(STATEMENT_ID, object_owner, object_type, object_name)
  WITH  
    object AS (
       SELECT /*+ MATERIALIZE */
              object_owner owner, object_name name, object_type
         FROM gv$sql_plan
        WHERE inst_id IN (SELECT inst_id FROM gv$instance)
          AND sql_id = :sql_id
          AND object_owner IS NOT NULL
          AND object_name IS NOT NULL
          AND object_type like 'INDEX%'
        UNION
       SELECT object_owner owner, object_name name, object_type
         FROM dba_hist_sql_plan
        WHERE :license IN ('T', 'D')
          AND dbid = ^^dbid.
          AND sql_id = :sql_id
          AND object_owner IS NOT NULL
          AND object_name IS NOT NULL
          AND object_type like 'INDEX%'
    )
    , plan_tables AS (
         SELECT /*+ MATERIALIZE leading (o) */ 'INDEX' object_type, i.owner object_owner, i.index_name object_name
           FROM dba_indexes i,
                object o
          WHERE o.object_type like 'INDEX%'  --Uday.v6
            AND i.owner = o.owner
            AND i.index_name = o.name            
    )
    select distinct :sql_id, object_owner, object_type, object_name
    from  plan_tables
  ;
  
rem select object_owner, object_type, object_name from plan_table;
rem pause;
  
SELECT /* ^^script..sql Indexes */
       v2.line_text
  FROM (
--Uday.PSR.v6 WITH object AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM gv$sql_plan
--Uday.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM dba_hist_sql_plan
--Uday.PSR.v6  WHERE :license IN ('T', 'D')
--Uday.PSR.v6    AND dbid = ^^dbid.
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  ), plan_tables AS (
--Uday.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--Uday.PSR.v6 --UdayRemoved.v6   FROM dba_tab_statistics t, -- include fixed objects
--Uday.PSR.v6 --UdayRemoved.v6        object o
--Uday.PSR.v6 --UdayRemoved.v6  WHERE t.owner = o.owner
--Uday.PSR.v6 --UdayRemoved.v6    AND t.table_name = o.name
--Uday.PSR.v6  SELECT /*+ MATERIALIZE */
--Uday.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--Uday.PSR.v6    FROM object o
--Uday.PSR.v6   WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6   UNION
--Uday.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6    FROM dba_indexes i,
--Uday.PSR.v6         object o
--Uday.PSR.v6   WHERE o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6     AND i.owner = o.owner
--Uday.PSR.v6     AND i.index_name = o.name
--Uday.PSR.v6 )
SELECT object_name table_name,
       object_owner owner,
       1 line_type,
       1 row_num,
       '<a name="i_'||LOWER(object_name||'_'||object_owner)||'"></a><details open><br/><summary id="summary3">Indexes: '||object_name||' ('||object_owner||')</summary>'||CHR(10)||CHR(10)||
       'CBO Statistics and relevant attributes.'||CHR(10)||CHR(10)||
       '<table>'||CHR(10)||CHR(10)||
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       --'<th>Table Name</th>'||CHR(10)||
       --'<th>Owner</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       '<th>Owner</th>'||CHR(10)||
       '<th>Index Type</th>'||CHR(10)||      
       '<th>Part</th>'||CHR(10)||
       '<th>DoP</th>'||CHR(10)||
       '<th>Temp</th>'||CHR(10)||
       '<th>Uniqueness</th>'||CHR(10)||
       '<th>Cols</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Distinct<br>Keys</th>'||CHR(10)||
       '<th>Blevel</th>'||CHR(10)||
       '<th>Leaf<br>Blocks</th>'||CHR(10)||
       '<th>Avg<br>Leaf<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Avg<br>Data<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Clustering<br>Factor</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '<th>Stat<br>Type<br>Locked</th>'||CHR(10)||
       '<th>Stale<br>Stats</th>'||CHR(10)||
       '<th>Stats<br>Versions</th>'||CHR(10)||
       '<th>Partition<br>Type</th>'||CHR(10)||
       '<th>Partition<br>Columns</th>'||CHR(10)||
       '<th>Partition<br>Count</th>'||CHR(10)||
       '<th>Locality</th>'||CHR(10)||
       '<th>Subpartition<br>Type</th>'||CHR(10)||
       '<th>Subpartition<br>Columns</th>'||CHR(10)||    
       '<th>Status</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT v.table_name,
       v.table_owner owner,
       2 line_type,
       ROWNUM row_num,
       CHR(10)||
       CASE WHEN v.used = 'Y' THEN '<tr class="bg">'
       ELSE '<tr>'
       END
       ||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       --'<td>'||v.table_name||'</td>'||CHR(10)||
       --'<td>'||v.table_owner||'</td>'||CHR(10)||
       '<td><a href="#ic_'||LOWER(v.index_name||'_'||v.owner)||'">'||v.index_name||'</a></td>'||CHR(10)||
       '<td>'||v.owner||'</td>'||CHR(10)||
       '<td>'||v.index_type||'</td>'||CHR(10)||
	   CASE WHEN v.partitioned = 'YES' 
	     THEN '<td class="c"><a href="#ip_'||LOWER(v.table_name||'_'||v.table_owner)||'">'||v.partitioned||'</a></td>'
		 ELSE '<td class="c">'||v.partitioned||'</td>'
	   END||CHR(10)||
       '<td class="c">'||v.degree||'</td>'||CHR(10)||
       '<td class="c">'||v.temporary||'</td>'||CHR(10)||
       '<td>'||v.uniqueness||'</td>'||CHR(10)||
       '<td class="c"><a href="#ic_'||LOWER(v.index_name||'_'||v.owner)||'">'||v.columns||'</a></td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size_perc||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.distinct_keys||'</td>'||CHR(10)||
       '<td class="r">'||v.blevel||'</td>'||CHR(10)||
       '<td class="r">'||v.leaf_blocks||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_leaf_blocks_per_key||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_data_blocks_per_key||'</td>'||CHR(10)||
       '<td class="r">'||v.clustering_factor||'</td>'||CHR(10)||
       '<td class="c">'||v.global_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.user_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.stattype_locked||'</td>'||CHR(10)||
       '<td class="c">'||v.stale_stats||'</td>'||CHR(10)||
       '<td class="c"><a href="#i_stat_ver_'||LOWER(v.table_name||'_'||v.table_owner)||'">Versions</a></td>'||CHR(10)||
	     '<td class="c">'||case
	                         when v.p_subp_type is NOT null then
	                            regexp_substr(v.p_subp_type,'(.*)##',1,1,'im',1)||'</td>'||CHR(10)
	                         else '</td>'||CHR(10)
	                       end ||CHR(10)||
	     '<td>'||case
	                         when v.p_part_keys is NOT null then
	                           v.p_part_keys||'</td>'||CHR(10)
	                         else '</td>'||CHR(10)
	                       end ||CHR(10)||
	     '<td class="r">'||case
	                         when v.p_subp_type is NOT null then
	                            regexp_substr(v.p_subp_type,'##(.*)#~#',1,1,'im',1)||'</td>'||CHR(10)||
	     '<td class="c">'||     regexp_substr(v.p_subp_type,'#~#(.*)~~',1,1,'im',1)||'</td>'||CHR(10)||
	     '<td class="c">'||     regexp_substr(v.p_subp_type,'~~(.*)',1,1,'im',1)
	                         else '</td><td></td><td>'
	                       end ||'</td>'||CHR(10)||
	     '<td>'||case
	                         when v.p_subpart_keys is NOT null then
	                           v.p_subpart_keys||'</td>'||CHR(10)
	                         else '</td>'||CHR(10)
	                       end ||CHR(10)||
       '<td class="c">'||v.status||'</td>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM (
SELECT /*+ NO_MERGE LEADING(pt s i) */
       CASE WHEN (SELECT count(1) FROM plan_table p WHERE p.object_name=s.index_name AND p.object_type='INDEX') > 0 THEN 'Y'
            ELSE 'N' END used, /* Pushkar 10.9 */
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner,
       i.index_type,
       i.partitioned,
       case /* Pushkar - added below for partitioned indexes */
         when i.partitioned = 'YES' then (select partitioning_type||'##'||partition_count||'#~#'||locality||'~~'||regexp_replace(subpartitioning_type,'NONE',null,1,0,'i')
                                          from dba_part_indexes dt 
                                          where dt.owner = s.owner and dt.index_name = s.index_name)
       end p_subp_type,
       case
         when i.partitioned = 'YES' then (select /*'PARTITION on: '||*/listagg(column_name,'<br>') within group (order by owner, name, object_type, column_position)
                                           from dba_part_key_columns
                                           where owner=s.owner
                                             and name=s.index_name
                                             and object_type='INDEX'
                                           group by owner, name, object_type)
       end p_part_keys,
       case
         when i.partitioned = 'YES' then (select /*'SUBPARTITION on: '||*/listagg(column_name,'<br>') within group (order by owner, name, object_type, column_position)
                                           from dba_subpart_key_columns
                                           where owner=s.owner
                                             and name=s.index_name
                                             and object_type='INDEX'
                                           group by owner, name, object_type)
       end p_subpart_keys,       
       i.degree,
       i.temporary,
       i.uniqueness,
       (SELECT COUNT(*)
          FROM dba_ind_columns c
         WHERE c.index_owner = s.owner
           AND c.index_name = s.index_name
           AND c.table_owner = s.table_owner
           AND c.table_name = s.table_name) columns,
       s.num_rows,
       s.sample_size,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND(s.sample_size * 100 / s.num_rows, 1), '99999990D0') END sample_size_perc,
       TO_CHAR(s.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       s.distinct_keys,
       s.blevel,
       s.leaf_blocks,
       s.avg_leaf_blocks_per_key,
       s.avg_data_blocks_per_key,
       s.clustering_factor,
       s.global_stats,
       s.user_stats,
       s.stattype_locked,
       s.stale_stats,
       i.status
  FROM plan_table pt,
       dba_ind_statistics s,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
   AND s.object_type = 'INDEX'
   AND s.owner = i.owner
   AND s.index_name = i.index_name
   AND s.table_owner = i.table_owner
   AND s.table_name = i.table_name
 ORDER BY
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner) v
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       3 line_type,
       1 row_num,
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       --'<th>Table Name</th>'||CHR(10)||
       --'<th>Owner</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       '<th>Owner</th>'||CHR(10)||
       '<th>Index Type</th>'||CHR(10)||
       '<th>Part</th>'||CHR(10)||
       '<th>DoP</th>'||CHR(10)||
       '<th>Temp</th>'||CHR(10)||
       '<th>Uniqueness</th>'||CHR(10)||
       '<th>Cols</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Distinct<br>Keys</th>'||CHR(10)||
       '<th>Blevel</th>'||CHR(10)||
       '<th>Leaf<br>Blocks</th>'||CHR(10)||
       '<th>Avg<br>Leaf<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Avg<br>Data<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Clustering<br>Factor</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '<th>Stat<br>Type<br>Locked</th>'||CHR(10)||
       '<th>Stale<br>Stats</th>'||CHR(10)||
   	   '<th>Stats<br>Versions</th>'||CHR(10)||
       '<th>Partition<br>Type</th>'||CHR(10)||
       '<th>Partition<br>Columns</th>'||CHR(10)||
       '<th>Partition<br>Count</th>'||CHR(10)||
       '<th>Locality</th>'||CHR(10)||
       '<th>Subpartition<br>Type</th>'||CHR(10)||
       '<th>Subpartition<br>Columns</th>'||CHR(10)||       
   	   '<th>Status</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       4 line_type,
       1 row_num,
       CHR(10)||'</table></details><!--Pushkar-->'||CHR(10)||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id) v2
 ORDER BY
       v2.table_name,
       v2.owner,
       v2.line_type,
       v2.row_num;	   


select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details> <!--Pushkar-->	
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------------------------------------------------*/	   
/* Text indexes     added by  Vivek Jha on 10/17/19     STARTS        */ 
/* -------------------------------------------------------------------*/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Text Indexes - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="idx_text"></a><details open><br/><summary id="summary2">Text Indexes</summary>

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

set pages 500 lines 1500 verify off feedback off  
SET HEAD OFF serverout on

PRO Text Indexes

PRO <a name="top"></a>

pro <table>
pro <tbody><tr>
pro <th>Index Owner</th>
pro <th>Index Name</th>
pro <th>Table Owner</th>
pro <th>Table Name</th>
pro <th>Index Type</th>
pro <th>Index Status</th>
pro <th>Idx Docid Cnt</th>
pro <th>Idx Sync Type</th>
pro <th>Idx Synch Interval</th>
pro <th>Uniqueness</th>
pro <th>Compression</th>
pro <th>Last Analyzed</th>
pro <th>Degree</th>
pro <th>Partitioned</th>
pro <th>Small_r_Row</th>
pro </tr>


DECLARE 
   type tabmod is RECORD (
	idx_owner		VARCHAR(128),
	idx_name		VARCHAR(128),
	table_owner		VARCHAR(128),
	table_name		VARCHAR(128),
	Index_Type		VARCHAR(50),
	Index_Status		VARCHAR(50),
	idx_docid_count		NUMBER,
	idx_sync_type		VARCHAR(20),
	idx_sync_interval	VARCHAR(2000),
	uniqueness		VARCHAR(9),
	compression		VARCHAR(13),
	last_analyzed		DATE,
	degree			VARCHAR(40),
	partitioned		VARCHAR2(3));
   vtabmod tabmod;
   sqlqry varchar2(1000);
   vsmallrrowcnt  number(3);
   vsmallrrow  varchar2(3);

   CURSOR c_indexnames is 
	select t1.idx_owner, t1.idx_name, t2.table_owner, t2.table_name, (t2.index_type||'-'||t1.idx_type) Index_Type, (t2.domidx_status||'-'||t1.idx_status) Index_Status,
	t1.idx_docid_count, t1.idx_sync_type, t1.idx_sync_interval, t2.uniqueness, t2.compression, t2.last_analyzed, t2.degree, t2.partitioned
	from ctxsys.ctx_indexes t1, dba_indexes t2, plan_table t
	where t1.idx_owner = t2.owner
	and t1.idx_name = t2.index_name
        AND t2.table_owner = t.object_owner
	AND t2.table_name = t.object_name
	AND STATEMENT_ID = :sql_id
	and t1.idx_owner = 'FUSION';

BEGIN 
	OPEN c_indexnames; 
   LOOP 
	   FETCH c_indexnames into vtabmod.idx_owner, vtabmod.idx_name, vtabmod.table_owner, vtabmod.table_name, vtabmod.Index_Type, vtabmod.Index_Status, vtabmod.idx_docid_count, vtabmod.idx_sync_type, 
		vtabmod.idx_sync_interval, vtabmod.uniqueness  , vtabmod.compression , vtabmod.last_analyzed , vtabmod.degree , vtabmod.partitioned ;
		/*dbms_output.put_line('Cursor  '||vtabmod.idx_name|| ' ' || vtabmod.table_name );  */
	      EXIT WHEN c_indexnames%notfound; 

	sqlqry := 'select count(*) from (select row_no, length(data) from DR$'||vtabmod.idx_name||'$R order by row_no)' ;
	/*DBMS_OUTPUT.PUT_LINE('Query Text: ' || sqlqry);*/

	EXECUTE IMMEDIATE sqlqry into vsmallrrowcnt;
	/*dbms_output.put_line (vSmallrRowcnt);*/
        /*dbms_output.put_line('Cursor  '||vtabmod.idx_name|| ' ' || vtabmod.table_name );  */
	IF vSmallrRowcnt < 2
		THEN vSmallrRow := 'No';
	ELSE vSmallrRow := 'Yes';
	END IF;

	 /* DBMS_OUTPUT.PUT_LINE('Table Owner'||chr(9)||chr(9)||chr(9)||'Table Name'||chr(9)||chr(9)||'Module'); */
	 /* DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'); */

	DBMS_OUTPUT.PUT_LINE(
        CHR(10)||'<tr>'||CHR(10)
          ||'<td class="r">'||vtabmod.idx_owner||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.idx_name||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.table_owner||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.table_name||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.Index_Type||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.Index_Status||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.idx_docid_count||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.idx_sync_type||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.idx_sync_interval||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.uniqueness||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.compression||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.last_analyzed||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.degree||'</td>'||CHR(10)
          ||'<td class="r">'||vtabmod.partitioned||'</td>'||CHR(10)
          ||'<td class="r">'||vSmallrRow||'</td>'||CHR(10)
          ||'</tr>'
        );
	
	dbms_output.put(CHR(10));

   END LOOP; 
   CLOSE c_indexnames; 

END; 
/


pro <tr>
pro <th>Index Owner</th>
pro <th>Index Name</th>
pro <th>Table Owner</th>
pro <th>Table Name</th>
pro <th>Index Type</th>
pro <th>Index Status</th>
pro <th>Idx Docid Cnt</th>
pro <th>Idx Sync Type</th>
pro <th>Idx Synch Interval</th>
pro <th>Uniqueness</th>
pro <th>Compression</th>
pro <th>Last Analyzed</th>
pro <th>Degree</th>
pro <th>Partitioned</th>
pro <th>Small_r_Row</th>
pro </tbody></tr>
pro </table>
pro

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details> <!--Pushkar--> 
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');



/* -------------------------------------------------------------------*/	   
/* Text indexes     added by  Vivek Jha on 10/17/19     ENDS          */
/* -------------------------------------------------------------------*/



/* -------------------------
 *
 * index columns
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Index Columns - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="idx_cols"></a><details open><br/><summary id="summary2">Index Columns</summary>

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

rem select object_owner, object_type, object_name from plan_table;
rem pause;

SELECT /* ^^script..sql Index Columns */
       v2.line_text
  FROM (
--Uday.PSR.v6 WITH object AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM gv$sql_plan
--Uday.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM dba_hist_sql_plan
--Uday.PSR.v6  WHERE :license IN ('T', 'D')
--Uday.PSR.v6    AND dbid = ^^dbid.
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  ), plan_tables AS (
--Uday.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--Uday.PSR.v6 --UdayRemoved.v6   FROM dba_tab_statistics t, -- include fixed objects
--Uday.PSR.v6 --UdayRemoved.v6        object o
--Uday.PSR.v6 --UdayRemoved.v6  WHERE t.owner = o.owner
--Uday.PSR.v6 --UdayRemoved.v6    AND t.table_name = o.name
--Uday.PSR.v6  SELECT /*+ MATERIALIZE */
--Uday.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--Uday.PSR.v6    FROM object o
--Uday.PSR.v6   WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6   UNION
--Uday.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6    FROM dba_indexes i,
--Uday.PSR.v6         object o
--Uday.PSR.v6   WHERE o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6     AND i.owner = o.owner
--Uday.PSR.v6     AND i.index_name = o.name
--Uday.PSR.v6 )
SELECT object_name table_name,
       object_owner owner,
       1 line_type,
       1 row_num,
       '<a name="ic_'||LOWER(object_name||'_'||object_owner)||'"></a><details open><br/><summary id="summary3">Index Columns: '||object_name||' ('||object_owner||')</summary>'||CHR(10)||CHR(10)||
       'CBO Statistics and relevant attributes.'||CHR(10)||CHR(10)||
       '<table>'||CHR(10)||CHR(10)||
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       --'<th>Table Name</th>'||CHR(10)||
       --'<th>Owner</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       --'<th>Index Owner</th>'||CHR(10)||
       '<th>Col<br>Pos</th>'||CHR(10)||
       '<th>Col<br>ID</th>'||CHR(10)||
       '<th>Column Name</th>'||CHR(10)||
       '<th>Expression</th>'||CHR(10)||       
       '<th>Descend</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Num<br>Nulls</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Num<br>Distinct</th>'||CHR(10)||
       '<th>Low Value</th>'||CHR(10)||
       '<th>High Value</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Avg<br>Col<br>Len</th>'||CHR(10)||
       '<th>Density</th>'||CHR(10)||
       '<th>Num<br>Buckets</th>'||CHR(10)||
       '<th>Histogram</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT v.table_name,
       v.table_owner,
       2 line_type,
       ROWNUM row_num,
       CHR(10)||
       CASE WHEN v.used = 'Y' THEN '<tr class="bg">'
       ELSE '<tr>'
       END
       ||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       --'<td>'||v.table_name||'</td>'||CHR(10)||
       --'<td>'||v.table_owner||'</td>'||CHR(10)||
       '<td>'||
       (CASE WHEN v.column_position = 1 THEN '<a name="ic_'||LOWER(v.index_name||'_'||v.index_owner)||'"></a>' END)||
       v.index_name||'</td>'||CHR(10)||
       --'<td>'||v.index_owner||'</td>'||CHR(10)||
       '<td class="r">'||v.column_position||'</td>'||CHR(10)||
       '<td class="c">'||v.column_id||'</td>'||CHR(10)||
       '<td>'||v.column_name||'</td>'||CHR(10)||
       '<td>'||CASE WHEN v.column_name LIKE 'SYS%' THEN 
               (SELECT To_Char(extension) 
                  FROM dba_stat_extensions
                 WHERE v.table_name = table_name 
                   AND v.table_owner= owner
                   AND v.column_name= extension_name) END||'</td>'||CHR(10)||
       '<td>'||v.descend||'</td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.num_nulls||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size_perc||'</td>'||CHR(10)||
       '<td class="r">'||v.num_distinct||'</td>'||CHR(10)||
       '<td nowrap>'||v.low_value||'</td>'||CHR(10)||
       '<td nowrap>'||v.high_value||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_col_len||'</td>'||CHR(10)||
       '<td class="r">'||v.density||'</td>'||CHR(10)||
       '<td class="r">'||v.num_buckets||'</td>'||CHR(10)||
       '<td>'||v.histogram||'</td>'||CHR(10)||
       '<td class="c">'||v.global_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.user_stats||'</td>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM (
SELECT /*+ NO_MERGE LEADING(pt i c c2) */
       CASE WHEN (SELECT count(1) FROM plan_table p WHERE p.object_name=i.index_name AND p.object_type='INDEX') > 0 THEN 'Y'
            ELSE 'N' END used, /* Pushkar 10.9 */
       i.table_name,
       i.table_owner,
       i.index_name,
       i.index_owner,
       i.column_position,
       c.column_id,
       i.column_name,     
       i.descend,
       pt.cardinality num_rows,
       c.num_nulls,
       c.sample_size,
       -- CASE
       -- WHEN t.num_rows > c.num_nulls THEN TO_CHAR(LEAST(100, ROUND(c.sample_size * 100 / (t.num_rows - c.num_nulls), 1)), '99999990D0')
       -- WHEN t.num_rows = c.num_nulls THEN TO_CHAR(100, '99999990D0')
       -- END sample_size_perc,
       CASE
         WHEN pt.cardinality > c.num_nulls THEN TO_CHAR(LEAST(100, ROUND(c.sample_size * 100 / (pt.cardinality - c.num_nulls), 1)), '99999990D0')
         WHEN pt.cardinality = c.num_nulls THEN TO_CHAR(100, '99999990D0')
       END sample_size_perc,
       c.num_distinct
       /* uday.psr.v6: getting actual values
       c.low_value,
       c.high_value high_value,
       */
       --Uday.PSR.v6
       -- appending ||'' to avoid ORA-29275: partial multibyte character
       -- sometimes sessions crosses with buffer overflow
       -- 
       ,decode(substr(c.data_type,1,9) -- as there are several timestamp types
          ,'NUMBER'       ,to_char(utl_raw.cast_to_number(c.low_value)) ||''
          ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(c.low_value)) ||''
          ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(c.low_value)) ||''
          ,'BINARY_DO'    ,to_char(utl_raw.cast_to_binary_double(c.low_value)) ||''
          ,'BINARY_FL'    ,to_char(utl_raw.cast_to_binary_float(c.low_value)) ||''
          ,'DATE'         ,decode(c.low_value, NULL, NULL, rtrim(
                                to_char(100*(to_number(substr(c.low_value,1,2),'XX')-100)
                                       + (to_number(substr(c.low_value,3,2),'XX')-100),'fm0000')||'-'||
                                to_char(to_number(substr(c.low_value,5,2),'XX'),'fm00')||'-'||
                                to_char(to_number(substr(c.low_value,7,2),'XX'),'fm00')||' '||
                                to_char(to_number(substr(c.low_value,9,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(c.low_value,11,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(c.low_value,13,2),'XX')-1,'fm00'))) ||''
          ,'TIMESTAMP'    ,decode(c.low_value, NULL, NULL, rtrim(
                           to_char(100*(to_number(substr(c.low_value,1,2),'XX')-100)
                                  + (to_number(substr(c.low_value,3,2),'XX')-100),'fm0000')||'-'||
                           to_char(to_number(substr(c.low_value,5,2),'XX'),'fm00')||'-'||
                           to_char(to_number(substr(c.low_value,7,2),'XX'),'fm00')||' '||
                           to_char(to_number(substr(c.low_value,9,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(c.low_value,11,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(c.low_value,13,2),'XX')-1,'fm00')
                          ||'.'||to_number(substr(c.low_value,15,8),'XXXXXXXX')  )) ||''
          , c.low_value
        ) low_value
       ,decode(substr(c.data_type,1,9) -- as there are several timestamp types
          ,'NUMBER'       ,to_char(utl_raw.cast_to_number(c.high_value)) ||''
          ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(c.high_value)) ||''
          ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(c.high_value)) ||''
          ,'BINARY_DO'    ,to_char(utl_raw.cast_to_binary_double(c.high_value)) ||''
          ,'DATE'         ,decode(c.high_value, NULL, NULL, rtrim(
                                to_char(100*(to_number(substr(c.high_value,1,2),'XX')-100)
                                       + (to_number(substr(c.high_value,3,2),'XX')-100),'fm0000')||'-'||
                                to_char(to_number(substr(c.high_value,5,2),'XX'),'fm00')||'-'||
                                to_char(to_number(substr(c.high_value,7,2),'XX'),'fm00')||' '||
                                to_char(to_number(substr(c.high_value,9,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(c.high_value,11,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(c.high_value,13,2),'XX')-1,'fm00'))) ||''
          ,'TIMESTAMP'    ,decode(c.high_value, NULL, NULL, rtrim(
                           to_char(100*(to_number(substr(c.high_value,1,2),'XX')-100)
                                  + (to_number(substr(c.high_value,3,2),'XX')-100),'fm0000')||'-'||
                           to_char(to_number(substr(c.high_value,5,2),'XX'),'fm00')||'-'||
                           to_char(to_number(substr(c.high_value,7,2),'XX'),'fm00')||' '||
                           to_char(to_number(substr(c.high_value,9,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(c.high_value,11,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(c.high_value,13,2),'XX')-1,'fm00')
                          ||'.'||to_char(to_number(substr(c.high_value,15,8),'XXXXXXXX')))) ||''
          , c.high_value
       ) high_value,
       TO_CHAR(c.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       c.avg_col_len,
       LOWER(TO_CHAR(c.density, '0D000000EEEE')) density,
       c.num_buckets,
       c.histogram,
       c.global_stats,
       c.user_stats
  FROM plan_table pt,
       -- dba_tables t,
       dba_ind_columns i,
       dba_tab_cols c
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   -- AND pt.object_owner = t.owner
   -- AND pt.object_name = t.table_name
   -- AND t.owner = i.table_owner
   -- AND t.table_name = i.table_name
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND i.table_owner = c.owner
   AND i.table_name = c.table_name
   AND i.column_name = c.column_name
 ORDER BY
       i.table_name,
       i.table_owner,
       i.index_name,
       i.index_owner,
       i.column_position) v
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       3 line_type,
       1 row_num,
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       --'<th>Table Name</th>'||CHR(10)||
       --'<th>Owner</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       --'<th>Index Owner</th>'||CHR(10)||
       '<th>Col<br>Pos</th>'||CHR(10)||
       '<th>Col<br>ID</th>'||CHR(10)||
       '<th>Column Name</th>'||CHR(10)||
       '<th>Expression</th>'||CHR(10)||
       '<th>Descend</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Num<br>Nulls</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Num<br>Distinct</th>'||CHR(10)||
       '<th>Low Value</th>'||CHR(10)||
       '<th>High Value</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Avg<br>Col<br>Len</th>'||CHR(10)||
       '<th>Density</th>'||CHR(10)||
       '<th>Num<br>Buckets</th>'||CHR(10)||
       '<th>Histogram</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       4 line_type,
       1 row_num,
       CHR(10)||'</table></details><!--Pushkar-->'||CHR(10)||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id) v2
 ORDER BY
       v2.table_name,
       v2.owner,
       v2.line_type,
       v2.row_num;

rollback;	  
rem select object_owner, object_type, object_name from plan_table;
rem pause; 


select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details> <!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * index partitions
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Index Partitions - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="ind_parts"></a><details><br/><summary id="summary2">Index Partitions</summary>

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->		

SELECT /* ^^script..sql Index Partitions */
       v2.line_text
  FROM (
--Uday.PSR.v6 WITH object AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM gv$sql_plan
--Uday.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM dba_hist_sql_plan
--Uday.PSR.v6  WHERE :license IN ('T', 'D')
--Uday.PSR.v6    AND dbid = ^^dbid.
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  ), plan_tables AS (
--Uday.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, p.table_owner object_owner, p.table_name object_name
--Uday.PSR.v6 --UdayRemoved.v6   FROM dba_tab_partitions p, -- include fixed objects
--Uday.PSR.v6 --UdayRemoved.v6        object o
--Uday.PSR.v6 --UdayRemoved.v6  WHERE p.table_owner = o.owner
--Uday.PSR.v6 --UdayRemoved.v6    AND p.table_name = o.name
--Uday.PSR.v6  SELECT /*+ MATERIALIZE */
--Uday.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--Uday.PSR.v6    FROM object o
--Uday.PSR.v6   WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6   UNION
--Uday.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6    FROM dba_indexes i,
--Uday.PSR.v6         dba_ind_partitions p,
--Uday.PSR.v6         object o
--Uday.PSR.v6   WHERE o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6     AND i.owner = o.owner
--Uday.PSR.v6     AND i.index_name = o.name
--Uday.PSR.v6     AND i.owner = p.index_owner(+)  -- partitioned table but not part index in the plan
--Uday.PSR.v6     AND i.index_name = p.index_name(+)  -- same as above
--Uday.PSR.v6 )
SELECT object_name table_name,
       object_owner owner,
       1 line_type,
       1 row_num,
       '<a name="ip_'||LOWER(object_name||'_'||object_owner)||'"></a><details><br/><summary id="summary3">Index Partitions: '||object_name||' ('||object_owner||')</summary>'||CHR(10)||CHR(10)||
       'CBO Statistics and relevant attributes.'||CHR(10)||CHR(10)||
       '<table>'||CHR(10)||CHR(10)||
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       '<th>Owner</th>'||CHR(10)||
       '<th>Partition<br>Position</th>'||CHR(10)||
       '<th>Partition<br>Name</th>'||CHR(10)||
       '<th>Subpartition<br>Count</th>'||CHR(10)||	   
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Distinct<br>Keys</th>'||CHR(10)||
       '<th>Blevel</th>'||CHR(10)||
       '<th>Leaf<br>Blocks</th>'||CHR(10)||
       '<th>Avg<br>Leaf<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Avg<br>Data<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Clustering<br>Factor</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT v.table_name,
       v.table_owner owner,
       2 line_type,
       ROWNUM row_num,
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.index_name||'</td>'||CHR(10)||
       '<td>'||v.owner||'</td>'||CHR(10)||
	   '<td class="c">'||v.partition_position||'</td>'||CHR(10)||
       '<td class="c">'||v.partition_name||'</td>'||CHR(10)||
       '<td class="r">'||v.subpartition_count||'</td>'||CHR(10)||	   
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size_perc||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.distinct_keys||'</td>'||CHR(10)||
       '<td class="r">'||v.blevel||'</td>'||CHR(10)||
       '<td class="r">'||v.leaf_blocks||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_leaf_blocks_per_key||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_data_blocks_per_key||'</td>'||CHR(10)||
       '<td class="r">'||v.clustering_factor||'</td>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM (
SELECT DISTINCT v.table_name,
       v.table_owner,
       v.index_name,
       v.owner,
	   v.subpartition_count,
	   v.partition_name,
	   v.partition_position,
       v.num_rows,
       v.sample_size,
       v.sample_size_perc,
       v.last_analyzed,
       v.distinct_keys,
       v.blevel,
       v.leaf_blocks,
       v.avg_leaf_blocks_per_key,
       v.avg_data_blocks_per_key,
       v.clustering_factor
  FROM (  
SELECT /*+ NO_MERGE LEADING(pt s i) */
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner,
	   i.subpartition_count,
	   i.partition_name,
	   i.partition_position,
       i.num_rows,
       i.sample_size,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND(i.sample_size * 100 / i.num_rows, 1), '99999990D0') END sample_size_perc,
       TO_CHAR(i.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       i.distinct_keys,
       i.blevel,
       i.leaf_blocks,
       i.avg_leaf_blocks_per_key,
       i.avg_data_blocks_per_key,
       i.clustering_factor,
	   ROW_NUMBER() OVER (PARTITION BY s.owner, s.index_name ORDER BY i.partition_position DESC) row_num
  FROM plan_table pt,
       dba_indexes s,
       dba_ind_partitions i
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
   AND s.index_name = i.index_name
   AND s.owner = i.index_owner
UNION
SELECT /*+ NO_MERGE LEADING(pt s i) */
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner,
	   i.subpartition_count,
	   i.partition_name,
	   i.partition_position,
       i.num_rows,
       i.sample_size,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND(i.sample_size * 100 / i.num_rows, 1), '99999990D0') END sample_size_perc,
       TO_CHAR(i.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       i.distinct_keys,
       i.blevel,
       i.leaf_blocks,
       i.avg_leaf_blocks_per_key,
       i.avg_data_blocks_per_key,
       i.clustering_factor,
	   ROW_NUMBER() OVER (PARTITION BY s.owner, s.index_name ORDER BY i.partition_position ASC) row_num
  FROM plan_table pt,
       dba_indexes s,
       dba_ind_partitions i
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
   AND s.index_name = i.index_name
   AND s.owner = i.index_owner 
	  ) v 
 WHERE v.row_num BETWEEN 1 AND 100
 ORDER BY
       v.index_name,
       v.owner,
	   v.partition_position DESC	  
	  ) v
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       3 line_type,
       1 row_num,
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       '<th>Owner</th>'||CHR(10)||
       '<th>Partition<br>Position</th>'||CHR(10)||
       '<th>Partition<br>Name</th>'||CHR(10)||
       '<th>Subpartition<br>Count</th>'||CHR(10)||	   
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Distinct<br>Keys</th>'||CHR(10)||
       '<th>Blevel</th>'||CHR(10)||
       '<th>Leaf<br>Blocks</th>'||CHR(10)||
       '<th>Avg<br>Leaf<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Avg<br>Data<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Clustering<br>Factor</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       4 line_type,
       1 row_num,
       CHR(10)||'</table></details><!--Pushkar-->'||CHR(10)||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id) v2
 ORDER BY
       v2.table_name,
       v2.owner,
       v2.line_type,
       v2.row_num;   

PRO </details> <!--Pushkar-->
/* -------------------------
 *
 * index statistics versions
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Indexes Statistics Versions - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="idx_stat_ver"></a><details open><br/><summary id="summary2">Indexes Statistics Versions</summary>

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT /* ^^script..sql Indexes Statistics Versions */
       v2.line_text
  FROM (
--Uday.PSR.v6 WITH object AS (
--Uday.PSR.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6        object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM gv$sql_plan
--Uday.PSR.v6  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  UNION
--Uday.PSR.v6 SELECT object_owner owner, object_name name, object_type
--Uday.PSR.v6   FROM dba_hist_sql_plan
--Uday.PSR.v6  WHERE :license IN ('T', 'D')
--Uday.PSR.v6    AND dbid = ^^dbid.
--Uday.PSR.v6    AND sql_id = :sql_id
--Uday.PSR.v6    AND object_owner IS NOT NULL
--Uday.PSR.v6    AND object_name IS NOT NULL
--Uday.PSR.v6    AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
--Uday.PSR.v6  ) , plan_tables AS (
--Uday.PSR.v6 --UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--Uday.PSR.v6 --UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--Uday.PSR.v6 --UdayRemoved.v6   FROM dba_tab_statistics t, -- include fixed objects
--Uday.PSR.v6 --UdayRemoved.v6        object o
--Uday.PSR.v6 --UdayRemoved.v6  WHERE t.owner = o.owner
--Uday.PSR.v6 --UdayRemoved.v6    AND t.table_name = o.name
--Uday.PSR.v6  SELECT /*+ MATERIALIZE */
--Uday.PSR.v6         'TABLE' object_type, o.owner object_owner, o.name object_name
--Uday.PSR.v6    FROM object o
--Uday.PSR.v6   WHERE o.object_type like 'TABLE%'
--Uday.PSR.v6   UNION
--Uday.PSR.v6  SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
--Uday.PSR.v6    FROM dba_indexes i,
--Uday.PSR.v6         object o
--Uday.PSR.v6   WHERE o.object_type like 'INDEX%'  --Uday.v6
--Uday.PSR.v6     AND i.owner = o.owner
--Uday.PSR.v6     AND i.index_name = o.name
--Uday.PSR.v6 )
SELECT object_name table_name,
       object_owner owner,
       1 line_type,
       1 row_num,
       '<a name="i_stat_ver_'||LOWER(object_name||'_'||object_owner)||'"></a><details open><br/><summary id="summary3">Indexes Statistics Versions: '||object_name||' ('||object_owner||')</summary>'||CHR(10)||CHR(10)||
       'CBO Statistics and relevant attributes.'||CHR(10)||CHR(10)||
       '<table>'||CHR(10)||CHR(10)||
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       '<th>Owner</th>'||CHR(10)||
	   '<th>Version Type</th>'||CHR(10)||
	   '<th>Save Time</th>'||CHR(10)||
	   '<th>Last Analyzed</th>'||CHR(10)||	   
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Distinct<br>Keys</th>'||CHR(10)||
       '<th>Blevel</th>'||CHR(10)||
       '<th>Leaf<br>Blocks</th>'||CHR(10)||
       '<th>Avg<br>Leaf<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Avg<br>Data<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Clustering<br>Factor</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL 
SELECT v.object_name,
       v.object_owner owner,
       2 line_type,
       ROWNUM row_num,
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.index_name||'</td>'||CHR(10)||
       '<td>'||v.owner||'</td>'||CHR(10)||
	   '<td>'||v.version_type||'</td>'||CHR(10)||
	   '<td nowrap>'||v.save_time||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||	   
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size_perc||'</td>'||CHR(10)||
       '<td class="r">'||v.distinct_keys||'</td>'||CHR(10)||
       '<td class="r">'||v.blevel||'</td>'||CHR(10)||
       '<td class="r">'||v.leaf_blocks||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_leaf_blocks_per_key||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_data_blocks_per_key||'</td>'||CHR(10)||
       '<td class="r">'||v.clustering_factor||'</td>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM (
SELECT * 
  FROM (  
SELECT /*+ NO_MERGE LEADING(pt i o s) index(s I_WRI$_OPTSTAT_IND_OBJ#_ST) */
       i.table_name object_name,
       i.table_owner object_owner,
       i.index_name,
       i.owner,
	   'HISTORY' version_type,
	   s.savtime save_time,
       TO_CHAR(s.analyzetime, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,	   
       s.rowcnt num_rows,
       s.samplesize sample_size,
       CASE WHEN s.rowcnt > 0 THEN TO_CHAR(ROUND(s.samplesize * 100 / s.rowcnt, 1), '99999990D0') END sample_size_perc,
       s.distkey distinct_keys,
       s.blevel,
       s.leafcnt leaf_blocks,
       s.lblkkey avg_leaf_blocks_per_key,
       s.dblkkey avg_data_blocks_per_key,
       s.clufac clustering_factor
  FROM plan_table pt,
       sys.wri$_optstat_ind_history s,
       dba_indexes i,
       dba_objects o
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = i.table_owner
   AND pt.object_name = i.table_name
   AND o.object_type = 'INDEX'
   AND o.owner = i.owner
   AND o.object_name = i.index_name 
   AND s.obj# = o.object_id
   AND s.savtime > systimestamp - interval '30' day
UNION ALL  
SELECT /*+ NO_MERGE LEADING(pt s) */
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner,
	   'CURRENT' version_type,
	   NULL save_time,
       TO_CHAR(s.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,	   
       s.num_rows,
       s.sample_size,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND(s.sample_size * 100 / s.num_rows, 1), '99999990D0') END sample_size_perc,      
       s.distinct_keys,
       s.blevel,
       s.leaf_blocks,
       s.avg_leaf_blocks_per_key,
       s.avg_data_blocks_per_key,
       s.clustering_factor
  FROM plan_table pt,
       dba_ind_statistics s
       -- , dba_indexes i  -- Uday.v6
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
   AND s.object_type = 'INDEX'
   --UdayRemoved.v6 AND s.owner = i.owner
   --UdayRemoved.v6 AND s.index_name = i.index_name
   --UdayRemoved.v6 AND s.table_owner = i.table_owner
   --UdayRemoved.v6 AND s.table_name = i.table_name) 
 )
 ORDER BY
       index_name,
       owner,
	   save_time DESC NULLS FIRST) v
UNION ALL
SELECT object_name table_name,
       object_owner owner,
       3 line_type,
       1 row_num,
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       '<th>Owner</th>'||CHR(10)||
	   '<th>Version Type</th>'||CHR(10)||
	   '<th>Save Time</th>'||CHR(10)||
	   '<th>Last Analyzed</th>'||CHR(10)||	   
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Distinct<br>Keys</th>'||CHR(10)||
       '<th>Blevel</th>'||CHR(10)||
       '<th>Leaf<br>Blocks</th>'||CHR(10)||
       '<th>Avg<br>Leaf<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Avg<br>Data<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Clustering<br>Factor</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       4 line_type,
       1 row_num,
       CHR(10)||'</table></details><!--Pushkar-->'||CHR(10)||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id)  v2
 ORDER BY
       v2.table_name,
       v2.owner,
       v2.line_type,
       v2.row_num;	  

PRO
PRO **** ORA-942 ERROR on sys.wri$_OPTSTAT_TAB_HISTORY can be ignored ****
         

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details> <!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * system parameters
 *
 * ------------------------- */
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: System Parameters - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="sys_params"></a><details><br/><summary id="summary2">System Parameters with Non-Default or Modified Values</summary>
PRO
PRO Collected from GV$SYSTEM_PARAMETER2 where isdefault = 'FALSE' OR ismodified != 'FALSE'.
PRO "Is Default" = FALSE means the parameter was set in the spfile.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Name</th>
PRO <th>Inst</th>
PRO <th>Ord</th>
PRO <th>Is<br>Default</th>
PRO <th>Is<br>Modified</th>
PRO <th>Value</th>
PRO <th>Display<br>Value</th>
PRO <th>Description</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT /* ^^script..sql System Parameters */
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.name||'</td>'||CHR(10)||
       '<td class="c">'||v.inst_id||'</td>'||CHR(10)||
       '<td class="r">'||v.ordinal||'</td>'||CHR(10)||
       '<td>'||v.isdefault||'</td>'||CHR(10)||
       '<td>'||v.ismodified||'</td>'||CHR(10)||
       '<td>'||v.value||'</td>'||CHR(10)||
       '<td>'||DECODE(v.display_value, v.value, NULL, v.display_value)||'</td>'||CHR(10)||
       '<td>'||v.description||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */ *
  FROM gv$system_parameter2
 WHERE (isdefault = 'FALSE' OR ismodified <> 'FALSE')
 ORDER BY
       name,
       inst_id,
       ordinal ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Name</th>
PRO <th>Inst</th>
PRO <th>Ord</th>
PRO <th>Is<br>Default</th>
PRO <th>Is<br>Modified</th>
PRO <th>Value</th>
PRO <th>Display<br>Value</th>
PRO <th>Description</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * instance parameters
 *
 * ------------------------- */
PRO <a name="inst_params"></a><details><br/><summary id="summary2">Instance Parameters</summary>
PRO
PRO System Parameters collected from V$SYSTEM_PARAMETER2 for Instance number ^^instance_number..
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Name</th>
PRO <th>Ord</th>
PRO <th>Is<br>Default</th>
PRO <th>Is<br>Modified</th>
PRO <th>Value</th>
PRO <th>Display<br>Value</th>
PRO <th>Description</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT /* ^^script..sql System Parameters */
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td>'||v.name||'</td>'||CHR(10)||
       '<td class="r">'||v.ordinal||'</td>'||CHR(10)||
       '<td>'||v.isdefault||'</td>'||CHR(10)||
       '<td>'||v.ismodified||'</td>'||CHR(10)||
       '<td>'||v.value||'</td>'||CHR(10)||
       '<td>'||DECODE(v.display_value, v.value, NULL, v.display_value)||'</td>'||CHR(10)||
       '<td>'||v.description||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */ *
  FROM v$system_parameter2
 ORDER BY
       name,
       ordinal ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Name</th>
PRO <th>Ord</th>
PRO <th>Is<br>Default</th>
PRO <th>Is<br>Modified</th>
PRO <th>Value</th>
PRO <th>Display<br>Value</th>
PRO <th>Description</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * VPD Policies
 * Uday
 * ------------------------- */
PRO
PRO <a name="vpd_policies"></a><details open><br/><summary id="summary2">VPD Policies (GV$VPD_POLICY)</summary>
PRO
PRO VPD Policies applied on objects used in ^^sql_id. while still in memory.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Policy</th>
PRO <th>Count</th>
PRO <th>#of Objects</th>
PRO <th>Predicate</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td >'||v.policy||'</td>'||CHR(10)||
       '<td class="r">'||v.cnt||'</td>'||CHR(10)||
       '<td class="r">'||v.cntobj||'</td>'||CHR(10)||
       '<td >'||v.predicate||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ distinct 
               policy, 
               count(distinct object_name) over(partition by sql_id, policy) cntobj, 
               count(*) over(partition by sql_id, policy, predicate) cnt, 
               substr(predicate, 1, 4000-150) predicate 
          from gv$vpd_policy 
         where sql_id = :sql_id
         order by policy, predicate
       ) v
;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Policy</th>
PRO <th>Count</th>
PRO <th>#of Objects</th>
PRO <th>Predicate</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------  SQL Undo Usage - Vivek Jha 9/20/19 ------------------------- */
PRO
PRO <a name="sql_undo_usage"></a><details open><br/><summary id="summary2">SQL Undo Usage</summary>
PRO
PRO I/O Type Usage in ^^sql_id. (includes Undo)
PRO

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

pro <table>
pro <tr>
pro <th>sql_plan_hash_value</th>
pro <th>I/O type</th>
pro <th>DB time%</th>
pro </tr>

	SELECT  CHR(10)||'<tr>'||CHR(10)
	    || '<td class="r">'||sql_plan_hash_value||'</td>'||CHR(10)
	    || '<td class="r">'||"I/O type"||'</td>'||CHR(10)
	    || '<td class="r">'||"DB time%"||'</td>'||CHR(10)
		||'</TR>'
	from (	SELECT ash.sql_plan_hash_value,
		    nvl(ts.contents,'not in I/O') "I/O type",
		    round(100 * COUNT(sample_time) / SUM(COUNT(sample_time) ) OVER(),1) "DB time%"
		FROM
		    gv$active_session_history ash,
		    dba_data_files df,
		    dba_tablespaces ts
		WHERE
		    ash.p1 = df.file_id (+)
		    AND df.tablespace_name = ts.tablespace_name (+)
        AND ash.sample_time between sysdate - 1 and sysdate
		    AND ash.sql_id = :sql_id
   		GROUP BY
		    ash.sql_plan_hash_value, ts.contents
		ORDER BY
		    ash.sql_plan_hash_value);

pro <tr>
pro <th>sql_plan_hash_value</th>
pro <th>I/O type</th>
pro <th>DB time%</th>
pro </tr>
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
PRO




/* ------------------------------------------------------------------------------------------------------------------------
-- Vivek Jha v10.5  2019/06/24
-- DESCRIPTION
--  This script generates the Table Stats, Column Stats, Index Stats, Index Column Stats
--  and Bind values for a given SQL ID and PLAN HASH VALUE based on the last HARD PARSE TIME
--  (current stats might be different from the time when the SQL was last hard parsed)
--  
--  Data is fetched from tables in memory. Depending on the Retention period for those tables, 
--  not all tables used in the execution plan might show up in the output
 ------------------------------------------------------------------------------------------------------------------------ */

PRO <a name="sql_stats_hard_parse_time"></a><details open><br/><summary id="summary2">SQL Statistics based on Last Hard Parse Time</summary>
PRO
PRO This section includes Table/Column/Index/IndexColumn Stats and Bind values for a given SQL ID and PLAN HASH VALUE based on the Last Hard Parse Time<br />
PRO (current stats might be different from the time when the SQL was last hard parsed) <br />
PRO Data is fetched from tables in memory. Depending on the Retention period for those tables, not all tables used in the execution plan might show up in the output 
pro <br></br>

var  l_last_load_time varchar2(50) ;
var  l_plan_hash_value number;

begin
select plan_hash_value into :l_plan_hash_value from gv$sql where sql_id = :sql_id order by last_load_time desc FETCH FIRST 1 ROW ONLY;
select last_load_time into :l_last_load_time from gv$sql where sql_id = :sql_id order by last_load_time desc FETCH FIRST 1 ROW ONLY;
end;
/


--PRO <h5>SQL ID: &&sql_id    <br>  Plan Hash Value : &&plan_hash_value  </h5>
--PRO SQL ID: &&sql_id   Plan Hash Value: &&plan_hash_value  
--PRO SQL ID: :sql_id   
--SELECT 'Hard Parse Time: ' || :l_last_load_time from dual;
SELECT '         Plan Hash Value:' ||:l_plan_hash_value ||'        Hard Parse Time: ' || :l_last_load_time from dual;

pro <br></br>

-- Start of Table Stats
PRO <br/><summary id="summary3">Table Statistics </summary>

-- column headers
pro <table>
pro <tbody><tr>
pro <th>Table Name</th>
pro <th>Rowcount</th>
pro <th>Block Cnt</th>
pro <th>Avg Length</th>
pro <th>Analyze Time</th>
pro </tr>

--prompt
--PROMPT ========================================================================================================================================================================
--PROMPT This script provides Table Stats, Column Stats, Index Stats and Index Column Stats for all tables and Indexes used for a particular SQL_ID and Plan_hash_Value
--PROMPT ========================================================================================================================================================================
--prompt
--Prompt **** SQL_ID : &1
--Prompt **** PLAN HASH VALUE : &2
--prompt
--prompt
--Prompt ***** TABLE STATS *****
--prompt

--pro <bluea>Table Stats</bluea>
--PRO <bluea><a name="TABLE_STATS">Table Stats</a></bluea>
--pro <br></br>


   with tablist as
    ( select distinct sql_id, plan_hash_value, object_owner table_owner, object_name table_name, object_type
      from gv$sql_plan where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value
      and object_type = 'TABLE' )
SELECT  CHR(10)||'<tr>'||CHR(10)
    || '<td class="r">'||table_name||'</td>'||CHR(10)
    || '<td class="r">'||rowcnt||'</td>'||CHR(10)
    || '<td class="r">'||blkcnt||'</td>'||CHR(10)
    || '<td class="r">'||avgrln||'</td>'||CHR(10)
    || '<td class="r">'||analyze_time||'</td>'||CHR(10)
        ||'</TR>'
from (select t2.object_name table_name, t1.rowcnt, t1.blkcnt, t1.avgrln, to_char(analyzetime, 'yyyy-mm-dd hh24:mi:ss') Analyze_time, row_number() over (partition by t2.object_name order by analyzetime desc) r
   from SYS.WRI$_OPTSTAT_TAB_HISTORY t1,
   dba_objects t2,
   tablist t3
   where t1.obj# = t2.object_id
   and t2.object_name = t3.table_name
   and t2.owner =  t3.table_owner
   and analyzetime < (select to_date(last_load_time,'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value order by last_load_time desc FETCH FIRST 1 ROW ONLY)
   order by t2.object_name)
   where r=1;

PRO
PRO **** ORA-942 ERROR on sys.wri$_OPTSTAT_%_HISTORY can be ignored ****

pro <tr>
pro <th>Table Name</th>
pro <th>Rowcount</th>
pro <th>Block Cnt</th>
pro <th>Avg Length</th>
pro <th>Analyze Time</th>
pro </tr>

pro </tbody>
PRO </table>
-- End of Table Stats


-- start of Column Stats SQL
PRO <br/><summary id="summary3">Column Statistics </summary>

-- column headers
pro <table>
pro <tbody><tr>
pro <th>Table Name</th>
pro <th>CP</th>
pro <th>Column Name</th>
pro <th>Data Type</th>
pro <th>DISTCNT</th>
pro <th>NULL_CNT</th>
pro <th>AVGCLN</th>
pro <th>Sample Size</th>
pro <th>Low Value</th>
pro <th>High Value</th>
pro <th>Last Analyzed</th>
pro </tr>

--prompt 
--prompt 
--Prompt ***** COLUMN STATS *****
--prompt 



SELECT  CHR(10)||'<tr>'||CHR(10) 
	|| '<td class="r">'||table_name||'</td>'||CHR(10)
	|| '<td class="r">'||cp||'</td>'||CHR(10)
	|| '<td class="r">'||cname||'</td>'||CHR(10)
	|| '<td class="r">'||dty||'</td>'||CHR(10)
	|| '<td class="r">'||distcnt||'</td>'||CHR(10)
	|| '<td class="r">'||null_cnt||'</td>'||CHR(10)
	|| '<td class="r">'||avgcln||'</td>'||CHR(10)
	|| '<td class="r">'||sample_size||'</td>'||CHR(10)
	|| '<td class="r">'||low_value||'</td>'||CHR(10)
	|| '<td class="r">'||high_value||'</td>'||CHR(10)
	|| '<td class="r">'||last_analyzed||'</td>'||CHR(10)
    ||'</TR>'
from (
with tablist as 
    ( select distinct sql_id, plan_hash_value, object_owner table_owner, object_name table_name, object_type
      from gv$sql_plan where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value
      and object_type = 'TABLE' )
SELECT   /*+ OPT_PARAM('_optimizer_adaptive_plans','false') */ tab.table_name, C.COL# CP, RPAD(C.NAME,30) CNAME,  TC.DATA_TYPE DTY,
          nvl(CSH.DISTCNT, TC.NUM_DISTINCT) DISTCNT,
          nvl(CSH.NULL_CNT, TC.NUM_NULLS)  NULL_CNT,
          NVL(CSH.AVGCLN, TC.AVG_COL_LEN) AVGCLN,
          NVL(CSH.SAMPLE_SIZE, TC.SAMPLE_SIZE) SAMPLE_SIZE,
       decode(substr(tc.data_type,1,9)
          ,'NUMBER'       ,to_char(utl_raw.cast_to_number(NVL(NVL(CSH.LOWVAL, TC.LOW_VALUE), TC.LOW_VALUE))) 
          ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(NVL(CSH.LOWVAL, TC.LOW_VALUE))) 
          ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(NVL(CSH.LOWVAL, TC.LOW_VALUE))) 
          ,'BINARY_DO'    ,to_char(utl_raw.cast_to_binary_double(NVL(CSH.LOWVAL, TC.LOW_VALUE))) 
          ,'BINARY_FL'    ,to_char(utl_raw.cast_to_binary_float(NVL(CSH.LOWVAL, TC.LOW_VALUE))) 
          ,'DATE'         ,decode(NVL(CSH.LOWVAL, TC.LOW_VALUE), NULL, NULL, rtrim(
                                to_char(100*(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),1,2),'XX')-100)
                                       + (to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),3,2),'XX')-100),'fm0000')||'-'||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),5,2),'XX'),'fm00')||'-'||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),7,2),'XX'),'fm00')||' '||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),9,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),11,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),13,2),'XX')-1,'fm00'))) 
          ,'TIMESTAMP'    ,decode(NVL(CSH.LOWVAL, TC.LOW_VALUE), NULL, NULL, rtrim(
                           to_char(100*(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),1,2),'XX')-100)
                                  + (to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),3,2),'XX')-100),'fm0000')||'-'||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),5,2),'XX'),'fm00')||'-'||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),7,2),'XX'),'fm00')||' '||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),9,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),11,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),13,2),'XX')-1,'fm00')||'.'||
                           to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),15,8),'XXXXXXXX')  )) 
                           , NVL(CSH.LOWVAL, TC.LOW_VALUE) ) low_value,
       decode(substr(tc.data_type,1,9)
          ,'NUMBER'       ,to_char(utl_raw.cast_to_number(NVL(NVL(csh.hival, tc.high_value), tc.high_value))) 
          ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(NVL(csh.hival, tc.high_value))) 
          ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(NVL(csh.hival, tc.high_value))) 
          ,'BINARY_DO'    ,to_char(utl_raw.cast_to_binary_double(NVL(csh.hival, tc.high_value))) 
          ,'BINARY_FL'    ,to_char(utl_raw.cast_to_binary_float(NVL(csh.hival, tc.high_value))) 
          ,'DATE'         ,decode(NVL(csh.hival, tc.high_value), NULL, NULL, rtrim(
                                to_char(100*(to_number(substr(NVL(csh.hival, tc.high_value),1,2),'XX')-100)
                                       + (to_number(substr(NVL(csh.hival, tc.high_value),3,2),'XX')-100),'fm0000')||'-'||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),5,2),'XX'),'fm00')||'-'||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),7,2),'XX'),'fm00')||' '||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),9,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),11,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),13,2),'XX')-1,'fm00'))) 
          ,'TIMESTAMP'    ,decode(NVL(csh.hival, tc.high_value), NULL, NULL, rtrim(
                           to_char(100*(to_number(substr(NVL(csh.hival, tc.high_value),1,2),'XX')-100)
                                  + (to_number(substr(NVL(csh.hival, tc.high_value),3,2),'XX')-100),'fm0000')||'-'||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),5,2),'XX'),'fm00')||'-'||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),7,2),'XX'),'fm00')||' '||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),9,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),11,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),13,2),'XX')-1,'fm00')||'.'||
                           to_number(substr(NVL(csh.hival, tc.high_value),15,8),'XXXXXXXX')  )) 
                           , NVL(csh.hival, tc.high_value) ) high_value,
          NVL(LPAD(TO_CHAR(CSH.TIMESTAMP#,'YYYY-MM-DD/HH24:MI:SS'),20), LPAD(TO_CHAR(TC.LAST_ANALYZED,'YYYY-MM-DD/HH24:MI:SS'),20)) LAST_ANALYZED
          FROM tablist tab,
               DBA_OBJECTS T,
               SYS.COL$ C,
               SYS.WRI$_OPTSTAT_HISTHEAD_HISTORY CSH,
               DBA_TAB_COLUMNS TC
          WHERE T.OBJECT_ID    = CSH.OBJ#(+)
          AND   C.OBJ#         = T.OBJECT_ID
          AND   C.INTCOL#      = CSH.INTCOL#(+)
          AND T.OBJECT_NAME = tab.TABLE_NAME AND T.OBJECT_TYPE = 'TABLE'
          AND   TC.OWNER = T.OWNER
          AND   TC.TABLE_NAME = T.OBJECT_NAME
          AND   TC.COLUMN_NAME = C.NAME
          and timestamp# < (select to_date(last_load_time,'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value order by last_load_time desc FETCH FIRST 1 ROW ONLY)
          ORDER BY tab.table_name, CSH.INTCOL#, CSH.TIMESTAMP# DESC );


PRO
PRO **** ORA-942 ERROR on sys.wri$_OPTSTAT_%_HISTORY can be ignored ****

pro <tr>
pro <th>Table Name</th>
pro <th>CP</th>
pro <th>Column Name</th>
pro <th>Data Type</th>
pro <th>DISTCNT</th>
pro <th>NULL_CNT</th>
pro <th>AVGCLN</th>
pro <th>Sample Size</th>
pro <th>Low Value</th>
pro <th>High Value</th>
pro <th>Last Analyzed</th>
pro </tr>


pro </tbody>
pro  </table>

-- end of column Stats SQL



-- start of index Stats SQL
PRO <br/><summary id="summary3">Index Statistics </summary>

-- column headers
pro <table>
pro <tbody><tr>
pro <th>Owner</th>
pro <th>Table Name</th>
pro <th>Index Name</th>
pro <th>Flags</th>
pro <th>Rowcount</th>
pro <th>BLevel</th>
pro <th>Leaf Cnt</th>
pro <th>Dist Key</th>
pro <th>Lblk Key</th>
pro <th>Dblk Key</th>
pro <th>Clustering Factor/th>
pro <th>Sample Size</th>
pro <th>Analyze Time</th>
pro </tr>

--Prompt ***** INDEX STATS *****
--prompt 

   with indlist as 
    ( select distinct sql_id, plan_hash_value, object_owner index_owner, object_name index_name, object_type
           from gv$sql_plan where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value
      and object_type like 'INDEX%' )
SELECT  CHR(10)||'<tr>'||CHR(10) 
	|| '<td class="r">'||owner||'</td>'||CHR(10)
	|| '<td class="r">'||table_name||'</td>'||CHR(10)
	|| '<td class="r">'||index_name||'</td>'||CHR(10)
	|| '<td class="r">'||flags||'</td>'||CHR(10)
	|| '<td class="r">'||rowcnt||'</td>'||CHR(10)
	|| '<td class="r">'||blevel||'</td>'||CHR(10)
	|| '<td class="r">'||leafcnt||'</td>'||CHR(10)
	|| '<td class="r">'||distkey||'</td>'||CHR(10)
	|| '<td class="r">'||lblkkey||'</td>'||CHR(10)
	|| '<td class="r">'||dblkkey||'</td>'||CHR(10)
	|| '<td class="r">'||clufac||'</td>'||CHR(10)
	|| '<td class="r">'||samplesize||'</td>'||CHR(10)
	|| '<td class="r">'||analyze_time||'</td>'||CHR(10)
        ||'</TR>'
 from (select ind.owner, ind.table_name, ind.index_name, flags, rowcnt, hist.blevel , hist.leafcnt, hist.distkey, hist.lblkkey, hist.dblkkey, hist.clufac,hist.samplesize, to_char(analyzetime, 'yyyy-mm-dd hh24:mi:ss') analyze_time, row_number() over (partition by ind.owner, ind.table_name, ind.index_name order by analyzetime desc) r
   from sys.wri$_optstat_ind_history hist, 
   dba_objects obj,
   dba_indexes ind,
   indlist i
   where hist.obj# = obj.object_id 
   and ind.index_name = obj.object_name
   and ind.owner = obj.owner
   and obj.object_type ='INDEX'
   and ind.index_name = i.index_name
   and ind.owner =  i.index_owner
--   and analyzetime < (select to_date(max(last_load_time),'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = '&&sql_id' and plan_hash_value = &&plan_hash_value)
   and analyzetime < (select to_date(last_load_time,'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value order by last_load_time desc FETCH FIRST 1 ROW ONLY)
   order by ind.table_name, ind.index_name)
   where r=1;

pro <tr>
pro <th>Owner</th>
pro <th>Table Name</th>
pro <th>Index Name</th>
pro <th>Flags</th>
pro <th>Rowcount</th>
pro <th>BLevel</th>
pro <th>Leaf Cnt</th>
pro <th>Dist Key</th>
pro <th>Lblk Key</th>
pro <th>Dblk Key</th>
pro <th>Clustering Factor/th>
pro <th>Sample Size</th>
pro <th>Analyze Time</th>
pro </tr>

pro </tbody>
pro  </table>

-- END OF INDEX STATS SQL



-- START OF INDEX COLUMN STATS SQL
PRO <br/><summary id="summary3">Index Column Statistics </summary>

pro <table>
pro <tbody><tr>
pro <th>Table Name</th>
pro <th>Index Owner</th>
pro <th>Index Name</th>
pro <th>CP</th>
pro <th>Column Name</th>
pro <th>Data Type</th>
pro <th># of Distinct<br>Values</th>
pro <th># of NULLs</th>
pro <th>Avg Column Length</th>
pro <th>Sample Size</th>
pro <th>Low Value</th>
pro <th>High Value</th>
pro <th>Last Analyzed</th>
pro </tr>


SELECT  CHR(10)||'<tr>'||CHR(10) 
	|| '<td class="r">'||table_name||'</td>'||CHR(10)
	|| '<td class="r">'||index_owner||'</td>'||CHR(10)
	|| '<td class="r">'||index_name||'</td>'||CHR(10)
	|| '<td class="r">'||cp||'</td>'||CHR(10)
	|| '<td class="r">'||cname||'</td>'||CHR(10)
	|| '<td class="r">'||dty||'</td>'||CHR(10)
	|| '<td class="r">'||distcnt||'</td>'||CHR(10)
	|| '<td class="r">'||null_cnt||'</td>'||CHR(10)
	|| '<td class="r">'||avgcln||'</td>'||CHR(10)
	|| '<td class="r">'||sample_size||'</td>'||CHR(10)
	|| '<td class="r">'||low_value||'</td>'||CHR(10)
	|| '<td class="r">'||high_value||'</td>'||CHR(10)
	|| '<td class="r">'||last_analyzed||'</td>'||CHR(10)
    ||'</TR>'
FROM (
with indlist as 
	    ( select distinct sql_id, plan_hash_value, object_owner index_owner, object_name index_name, object_type
	      from gv$sql_plan where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value
	      and object_type like 'INDEX%' )
	SELECT   /*+ OPT_PARAM('_optimizer_adaptive_plans','false') */ TC.TABLE_NAME, IC.INDEX_OWNER, IC.INDEX_NAME, IC.COLUMN_POSITION CP, RPAD(C.NAME,30) CNAME, TC.DATA_TYPE DTY, 
		  nvl(CSH.DISTCNT, TC.NUM_DISTINCT) DISTCNT,
		  nvl(CSH.NULL_CNT, TC.NUM_NULLS)  NULL_CNT,
		  NVL(CSH.AVGCLN, TC.AVG_COL_LEN) AVGCLN,
		  NVL(CSH.SAMPLE_SIZE, TC.SAMPLE_SIZE) SAMPLE_SIZE,
       decode(substr(tc.data_type,1,9)
          ,'NUMBER'       ,to_char(utl_raw.cast_to_number(NVL(NVL(CSH.LOWVAL, TC.LOW_VALUE), TC.LOW_VALUE))) 
          ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(NVL(CSH.LOWVAL, TC.LOW_VALUE))) 
          ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(NVL(CSH.LOWVAL, TC.LOW_VALUE))) 
          ,'BINARY_DO'    ,to_char(utl_raw.cast_to_binary_double(NVL(CSH.LOWVAL, TC.LOW_VALUE))) 
          ,'BINARY_FL'    ,to_char(utl_raw.cast_to_binary_float(NVL(CSH.LOWVAL, TC.LOW_VALUE))) 
          ,'DATE'         ,decode(NVL(CSH.LOWVAL, TC.LOW_VALUE), NULL, NULL, rtrim(
                                to_char(100*(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),1,2),'XX')-100)
                                       + (to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),3,2),'XX')-100),'fm0000')||'-'||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),5,2),'XX'),'fm00')||'-'||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),7,2),'XX'),'fm00')||' '||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),9,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),11,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),13,2),'XX')-1,'fm00'))) 
          ,'TIMESTAMP'    ,decode(NVL(CSH.LOWVAL, TC.LOW_VALUE), NULL, NULL, rtrim(
                           to_char(100*(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),1,2),'XX')-100)
                                  + (to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),3,2),'XX')-100),'fm0000')||'-'||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),5,2),'XX'),'fm00')||'-'||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),7,2),'XX'),'fm00')||' '||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),9,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),11,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),13,2),'XX')-1,'fm00')||'.'||
                           to_number(substr(NVL(CSH.LOWVAL, TC.LOW_VALUE),15,8),'XXXXXXXX')  )) 
                           , NVL(CSH.LOWVAL, TC.LOW_VALUE) ) low_value,
       decode(substr(tc.data_type,1,9)
          ,'NUMBER'       ,to_char(utl_raw.cast_to_number(NVL(NVL(csh.hival, tc.high_value), tc.high_value))) 
          ,'VARCHAR2'     ,to_char(utl_raw.cast_to_varchar2(NVL(csh.hival, tc.high_value))) 
          ,'NVARCHAR2'    ,to_char(utl_raw.cast_to_nvarchar2(NVL(csh.hival, tc.high_value))) 
          ,'BINARY_DO'    ,to_char(utl_raw.cast_to_binary_double(NVL(csh.hival, tc.high_value))) 
          ,'BINARY_FL'    ,to_char(utl_raw.cast_to_binary_float(NVL(csh.hival, tc.high_value))) 
          ,'DATE'         ,decode(NVL(csh.hival, tc.high_value), NULL, NULL, rtrim(
                                to_char(100*(to_number(substr(NVL(csh.hival, tc.high_value),1,2),'XX')-100)
                                       + (to_number(substr(NVL(csh.hival, tc.high_value),3,2),'XX')-100),'fm0000')||'-'||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),5,2),'XX'),'fm00')||'-'||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),7,2),'XX'),'fm00')||' '||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),9,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),11,2),'XX')-1,'fm00')||':'||
                                to_char(to_number(substr(NVL(csh.hival, tc.high_value),13,2),'XX')-1,'fm00'))) 
          ,'TIMESTAMP'    ,decode(NVL(csh.hival, tc.high_value), NULL, NULL, rtrim(
                           to_char(100*(to_number(substr(NVL(csh.hival, tc.high_value),1,2),'XX')-100)
                                  + (to_number(substr(NVL(csh.hival, tc.high_value),3,2),'XX')-100),'fm0000')||'-'||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),5,2),'XX'),'fm00')||'-'||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),7,2),'XX'),'fm00')||' '||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),9,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),11,2),'XX')-1,'fm00')||':'||
                           to_char(to_number(substr(NVL(csh.hival, tc.high_value),13,2),'XX')-1,'fm00')||'.'||
                           to_number(substr(NVL(csh.hival, tc.high_value),15,8),'XXXXXXXX')  )) 
                           , NVL(csh.hival, tc.high_value) ) high_value,
		  NVL(LPAD(TO_CHAR(CSH.TIMESTAMP#,'YYYY-MM-DD/HH24:MI:SS'),20), LPAD(TO_CHAR(TC.LAST_ANALYZED,'YYYY-MM-DD/HH24:MI:SS'),20)) LAST_ANALYZED
		  FROM indlist indl,
		       DBA_IND_COLUMNS IC, DBA_OBJECTS T, SYS.COL$ C, SYS.WRI$_OPTSTAT_HISTHEAD_HISTORY CSH,
		       DBA_TAB_COLUMNS TC
		  WHERE IC.TABLE_NAME  = T.OBJECT_NAME
		  AND   IC.TABLE_OWNER = T.OWNER
		  AND   IC.COLUMN_NAME = C.NAME
		  AND   T.OBJECT_ID    = CSH.OBJ#(+)
		  AND   C.OBJ#         = T.OBJECT_ID
		  AND   C.INTCOL#      = CSH.INTCOL#(+)
		  AND  T.OWNER = indl.INDEX_OWNER  AND   IC.index_name = indl.index_name AND T.OBJECT_TYPE = 'TABLE'
		  AND TC.OWNER = T.OWNER
		  AND TC.TABLE_NAME = T.OBJECT_NAME
		  and csh.timestamp# < (select to_date(last_load_time,'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id and plan_hash_value =  :l_plan_hash_value order by last_load_time desc FETCH FIRST 1 ROW ONLY)
		 AND TC.COLUMN_NAME = C.NAME
		  ORDER BY IC.INDEX_OWNER, IC.INDEX_NAME, IC.COLUMN_POSITION, CSH.INTCOL#, CSH.TIMESTAMP# DESC 
);


PRO
PRO **** ORA-942 ERROR on sys.wri$_OPTSTAT_%_HISTORY can be ignored ****

pro <tr>
pro <th>Table Name</th>
pro <th>Index Owner</th>
pro <th>Index Name</th>
pro <th>CP</th>
pro <th>Column Name</th>
pro <th>Data Type</th>
pro <th># of Distinct<br>Values</th>
pro <th># of NULLs</th>
pro <th>Avg Column Length</th>
pro <th>Sample Size</th>
pro <th>Low Value</th>
pro <th>High Value</th>
pro <th>Last Analyzed</th>
pro </tr>

pro </tbody>
pro  </table>

-- end of Index Column Stats SQL



------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------- BIND VALUES   -----------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- START OF BINDS : Peeked Vs Monitored Bind Values - In Memory
PRO <br/><summary id="summary3">Peeked Vs Monitored Bind Values - In Memory</summary>

pro <table>
pro <tbody><tr>
pro <th>Instance #</th>
pro <th>SQL Exec ID</th>
pro <th>SQL Exec Start</th>
pro <th>SQL Plan Hash Value</th>
pro <th>Ch#</th>
pro <th>Plan Gen Timestamp</th>
pro <th>SQLMon Elapsed Time</th>
pro <th>SQLMon Buffer Gets</th>
pro <th>Position</th>
pro <th>Bind Name</th>
pro <th>Data Type</th>
pro <th>Peeked Bind Value</th>
pro <th>SQLMon Bind Value</th>
pro </tr>

SELECT  CHR(10)||'<tr>'||CHR(10) 
	|| '<td class="r">'||inst_id||'</td>'||CHR(10)
	|| '<td class="r">'||sql_exec_id||'</td>'||CHR(10)
	|| '<td class="r">'||sql_exec_start||'</td>'||CHR(10)
	|| '<td class="r">'||sql_plan_hash_value||'</td>'||CHR(10)
	|| '<td class="r">'||ch#||'</td>'||CHR(10)
	|| '<td class="r">'||plan_gen_ts||'</td>'||CHR(10)
	|| '<td class="r">'||sqlmon_et||'</td>'||CHR(10)
	|| '<td class="r">'||sqlmon_bg||'</td>'||CHR(10)
	|| '<td class="r">'||position||'</td>'||CHR(10)
	|| '<td class="r">'||name||'</td>'||CHR(10)
	|| '<td class="r">'||datatype_string||'</td>'||CHR(10)
	|| '<td class="r">'||peeked_value||'</td>'||CHR(10)
	|| '<td class="r">'||sqlmon_val||'</td>'||CHR(10)
from (
with peeked as
(
  SELECT /*+ materialize */ inst_id, sql_id, plan_hash_value, address, child_address, child_number, timestamp,
         to_number(extractValue(value(d), '/bind/@pos')) position,
         extractValue(value(d), '/bind/@nam') name,
         max(extractValue(value(d), '/bind')) over(partition by inst_id, sql_id, plan_hash_value, address, child_address, child_number, extractValue(value(d), '/bind/@nam')) value,
         to_number(extractValue(value(d), '/bind/@ppo')) dup_pos,
         extractValue(value(d), '/bind/@dty') dtype,
         to_number(extractValue(value(d), '/bind/@mxl')) max_length
    FROM
         gv$sql_plan c
         , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.other_xml ), '/*/peeked_binds/bind'))) D
   where c.sql_id = :sql_id
     and c.other_xml is not null
   -- order by sql_id, to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos'))
),
peeked_val as
(
  select peeked.*,
         (case when dtype = 1 then 'VARCHAR2(' || max_length || ')'
               when dtype = 2 then 'NUMBER(' || max_length || ')'
               when dtype = 12 then 'Date(' || max_length || ')'
               when dtype in (180, 181) then 'TIMESTAMP(' || max_length || ')'
          end
         ) datatype_string,
         case
           when dtype = 1  -- VARCHAR2
             then to_char(utl_raw.cast_to_varchar2(value))
           when dtype = 2  -- NUMBER
             then to_char(utl_raw.cast_to_number(value))
           when dtype = 12 -- Date
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                           + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00'))
           when dtype in (180, 181)  -- Timestamp and Timestamp with tz
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                            + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(value,15,8),'XXXXXXXX')  )
           else
              value
         end cvalue
    from peeked
   -- order by position
),
captured_binds as
(
  select sm.key, sm.inst_id, sm.sql_id, sm.sql_exec_id, sm.sql_exec_start, sm.sql_plan_hash_value, sm.sql_child_address, 
         round(sm.elapsed_time/1000000,2) elapsed_time, buffer_gets,
         to_number(extractvalue(value(b), '/bind/@pos')) position,
         extractvalue(value(b), '/bind/@name') name, 
         extractvalue(value(b), '/bind') captured_value,
         extractvalue(value(b), '/bind/@dtystr') datatype_string
   from
         gv$sql_monitor sm
         , table(xmlsequence(extract(xmltype(sm.binds_xml ), '/binds/bind'))) b
   where sm.sql_id = :sql_id
     and sm.binds_xml is not null
   -- ORDER BY inst_id, child_number, position, dup_position
)
select cb.inst_id, cb.sql_exec_id, to_char(cb.sql_exec_start, 'yyyy-mm-dd hh24:mi:ss') sql_exec_start, cb.sql_plan_hash_value
       , max(pv.child_number) over(partition by cb.key) ch# 
       , to_char(max(pv.timestamp) over(partition by cb.key), 'yyyy-mm-dd hh24:mi:ss') plan_gen_ts 
       , cb.elapsed_time sqlmon_et, cb.buffer_gets sqlmon_bg
       , cb.position, cb.name
       , cb.datatype_string
       , pv.cvalue peeked_value
       , case when cb.datatype_string like 'TIMEST%' THEN
               rtrim(
                    to_char(100*(to_number(substr(cb.captured_value,1,2),'XX')-100)
                            + (to_number(substr(cb.captured_value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(cb.captured_value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(cb.captured_value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(cb.captured_value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(cb.captured_value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(cb.captured_value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(cb.captured_value,15,8),'XXXXXXXX')  
               )
              else cb.captured_value 
         end sqlmon_val 
  from peeked_val pv, captured_binds cb
 where 1 = 1
   and cb.inst_id = pv.inst_id
   and cb.sql_id  = pv.sql_id
   and cb.sql_child_address = pv.child_address
   and cb.sql_plan_hash_value = pv.plan_hash_value
   and cb.position = pv.position
   and cb.name = pv.name
-- and sql_exec_start < (select to_date(max(last_load_time),'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = '&&sql_id' and plan_hash_value = :l_plan_hash_value)
   and sql_exec_start < (select to_date(last_load_time,'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value order by last_load_time desc FETCH FIRST 1 ROW ONLY)
 order by cb.inst_id, cb.sql_exec_id, cb.sql_exec_start, cb.sql_plan_hash_value, ch#, plan_gen_ts, cb.elapsed_time, cb.buffer_gets, cb.position)
;


pro <tr>
pro <th>Instance #</th>
pro <th>SQL Exec ID</th>
pro <th>SQL Exec Start</th>
pro <th>SQL Plan Hash Value</th>
pro <th>Ch#</th>
pro <th>Plan Gen Timestamp</th>
pro <th>SQLMon Elapsed Time</th>
pro <th>SQLMon Buffer Gets</th>
pro <th>Position</th>
pro <th>Bind Name</th>
pro <th>Data Type</th>
pro <th>Peeked Bind Value</th>
pro <th>SQLMon Bind Value</th>
pro </tr>


pro </tbody>
pro  </table>

-- END OF BINDS : Peeked Vs Monitored Bind Values - In Memory


-- START OF BINDS : Peeked Vs Captured Bind Values - In Memory 
PRO <br/><summary id="summary3">Peeked Vs Captured Bind Values - In Memory </summary>

pro <table>
pro <tbody><tr>
pro <th>Instance #</th>
pro <th>Plan Hash Value</th>
pro <th>Ch#</th>
pro <th>Plan Gen Ttmestamp</th>
pro <th>Avg Elapsed Time</th>
pro <th>Avg Buffer Gets</th>
pro <th>Position</th>
pro <th>Bind Name</th>
pro <th>Data Type</th>
pro <th>Peeked Bind Value</th>
pro <th>Captured Bind Value</th>
pro <th>Last Captured Date</th>
pro </tr>

SELECT  CHR(10)||'<tr>'||CHR(10) 
	|| '<td class="r">'||inst_id||'</td>'||CHR(10)
	|| '<td class="r">'||plan_hash_value||'</td>'||CHR(10)
	|| '<td class="r">'||ch#||'</td>'||CHR(10)
	|| '<td class="r">'||plan_gen_ts||'</td>'||CHR(10)
	|| '<td class="r">'||Avg_et||'</td>'||CHR(10)
	|| '<td class="r">'||avg_bg||'</td>'||CHR(10)
	|| '<td class="r">'||position||'</td>'||CHR(10)
	|| '<td class="r">'||name||'</td>'||CHR(10)
	|| '<td class="r">'||datatype_string||'</td>'||CHR(10)
	|| '<td class="r">'||peeked_value||'</td>'||CHR(10)
	|| '<td class="r">'||captured_value||'</td>'||CHR(10)
	|| '<td class="r">'||last_captured||'</td>'||CHR(10)
from
(with peeked as
(
  SELECT /*+ materialize */ inst_id, sql_id, plan_hash_value, address, child_address, child_number, timestamp,
         to_number(extractValue(value(d), '/bind/@pos')) position,
         extractValue(value(d), '/bind/@nam') name,
         extractValue(value(d), '/bind') value,
         to_number(extractValue(value(d), '/bind/@ppo')) dup_pos,
         extractValue(value(d), '/bind/@dty') dtype,
         to_number(extractValue(value(d), '/bind/@mxl')) max_length
    FROM
         gv$sql_plan c
         , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.other_xml ), '/*/peeked_binds/bind'))) D
   where c.sql_id = :sql_id
    and c.other_xml is not null
  -- order by sql_id, to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos'))
)
,
peeked_val as
(
  select peeked.*,
         (case when dtype = 1 then 'VARCHAR2'
               when dtype = 2 then 'NUMBER'
               when dtype = 12 then 'Date'
               when dtype in (180, 181) then 'TIMESTAMP'
          end
         ) datatype_string,
         case
           when dtype = 1  -- VARCHAR2
             then to_char(utl_raw.cast_to_varchar2(value))
           when dtype = 2  -- NUMBER
             then to_char(utl_raw.cast_to_number(value))
           when dtype = 12 -- Date
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                           + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00'))
           when dtype in (180, 181)  -- Timestamp and Timestamp with tz
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                            + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(value,15,8),'XXXXXXXX')  )
           else
              value
         end cvalue
    from peeked
   -- order by position
)
,
captured_binds as
(
  SELECT s.inst_id, s.sql_id, s.plan_hash_value, s.CHILD_ADDRESS, s.CHILD_NUMBER, s.address
         , s.first_load_time, s.last_active_time, s.executions, s.buffer_gets
         , round(s.elapsed_time/1000000/decode(s.executions, 0, 1, s.executions), 3) avg_et
         , round(s.buffer_gets/decode(s.executions, 0, 1, s.executions)) avg_bg
         , b.position, b.name
         , case when b.datatype_string like 'TIMESTAM%' then
                  substr(anydata.accesstimestamp(b.value_anydata),1,50)
                else b.value_string
           end captured_value
         , b.datatype_string
         , b.LAST_CAPTURED
    FROM gv$sql s, gv$sql_bind_capture b
   WHERE s.sql_id = :sql_id
     and b.inst_id = s.inst_id
     and b.sql_id  = s.sql_id
     and b.address = s.address
     and b.child_address = s.child_address
     and b.child_number = s.child_number
   -- ORDER BY inst_id, child_number, position, dup_position
)
select pv.inst_id, pv.plan_hash_value, pv.child_number ch#, to_char(pv.timestamp, 'yyyy-mm-dd hh24:mi:ss') plan_gen_ts, cb.avg_et, cb.avg_bg
       , pv.position, pv.name 
       -- , pv.datatype_string
       , case when cb.datatype_string is not null then cb.datatype_string else pv.datatype_string end datatype_string
       , pv.cvalue peeked_value
       , cb.captured_value
       -- , cb.last_captured
       , to_char(cb.last_captured, 'yyyy-mm-dd hh24:mi:ss') last_captured
  from peeked_val pv, captured_binds cb
 where 1 = 1
   and cb.inst_id = pv.inst_id
   and cb.sql_id  = pv.sql_id
   and cb.address = pv.address
   and cb.child_address = pv.child_address
   and cb.child_number = pv.child_number
   and cb.position = pv.position
   and cb.name = pv.name
-- and last_captured < (select to_date(max(last_load_time),'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = '&&sql_id' and plan_hash_value = :l_plan_hash_value)
   and last_captured < (select to_date(last_load_time,'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value order by last_load_time desc FETCH FIRST 1 ROW ONLY)
 order by pv.timestamp, pv.plan_hash_value, pv.child_number, to_number(pv.position))
;

pro <tr>
pro <th>Instance #</th>
pro <th>Plan Hash Value</th>
pro <th>Ch#</th>
pro <th>Plan Gen Ttmestamp</th>
pro <th>Avg Elapsed Time</th>
pro <th>Avg Buffer Gets</th>
pro <th>Position</th>
pro <th>Bind Name</th>
pro <th>Data Type</th>
pro <th>Peeked Bind Value</th>
pro <th>Captured Bind Value</th>
pro <th>Last Captured Date</th>
pro </tr>

pro </tbody>
pro  </table>

-- END OF BINDS : Peeked Vs Captured Bind Values - In Memory


-- START OF BINDS : Peeked Vs Captured Bind Values - In AWR 
PRO <br/><summary id="summary3">Peeked Vs Captured Bind Values - In AWR </summary>

pro <table>
pro <tbody><tr>
pro <th>Instance #</th>
pro <th>Snap ID</th>
pro <th>End Interval Time</th>
pro <th>Plan Hash Value</th>
pro <th>Plan Gen Timestamp</th>
pro <th>Avg Elapsed Time</th>
pro <th>Avg Buffer Gets</th>
pro <th>Position</th>
pro <th>Bind Name</th>
pro <th>Peeked Bind Value</th>
pro <th>Captured Bind Value</th>
pro <th>Last Captured Date</th>
pro </tr>

SELECT  CHR(10)||'<tr>'||CHR(10) 
	|| '<td class="r">'||instance_number||'</td>'||CHR(10)
	|| '<td class="r">'||snap_id||'</td>'||CHR(10)
	|| '<td class="r">'||end_interval_time||'</td>'||CHR(10)
	|| '<td class="r">'||plan_hash_value||'</td>'||CHR(10)
	|| '<td class="r">'||plan_gen_ts||'</td>'||CHR(10)
	|| '<td class="r">'||avg_et||'</td>'||CHR(10)
	|| '<td class="r">'||avg_bg||'</td>'||CHR(10)
	|| '<td class="r">'||position||'</td>'||CHR(10)
	|| '<td class="r">'||name||'</td>'||CHR(10)
	|| '<td class="r">'||peeked_value||'</td>'||CHR(10)
	|| '<td class="r">'||captured_value||'</td>'||CHR(10)
	|| '<td class="r">'||last_captured||'</td>'||CHR(10)
from
(with peeked as
(
  SELECT /*+ materialize */ sql_id, plan_hash_value, timestamp,
         to_number(extractValue(value(d), '/bind/@pos')) position,
         extractValue(value(d), '/bind/@nam') name,
         extractValue(value(d), '/bind') value,
         to_number(extractValue(value(d), '/bind/@ppo')) dup_pos,
         extractValue(value(d), '/bind/@dty') dtype,
         to_number(extractValue(value(d), '/bind/@mxl')) max_length
    FROM
         dba_hist_sql_plan c
         , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.other_xml ), '/*/peeked_binds/bind'))) D
   where 1=1
     and :license IN ('T', 'D')
     and c.dbid = ^^dbid.
     and c.sql_id = :sql_id
    and c.other_xml is not null
  -- order by sql_id, to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos'))
)
,
peeked_binds as 
(
  select /*+ materialize */ peeked.*,
         (case when dtype = 1 then 'VARCHAR2'
               when dtype = 2 then 'NUMBER'
               when dtype = 12 then 'Date'
               when dtype in (180, 181) then 'TIMESTAMP'
          end
         ) datatype_string, 
         case 
           when dtype = 1  -- VARCHAR2
             then to_char(utl_raw.cast_to_varchar2(value))    
           when dtype = 2  -- NUMBER
             then to_char(utl_raw.cast_to_number(value))
           when dtype = 12 -- Date
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                           + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00'))
           when dtype in (180, 181)  -- Timestamp and Timestamp with tz
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                            + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(value,15,8),'XXXXXXXX')  )
           else
              value
         end cvalue
    from peeked
   -- order by position
)
,
captured_binds as
(
  select /*+ materialize */ s.dbid, s.instance_number, s.snap_id, s.sql_id, s.plan_hash_value, s.executions_delta, s.buffer_gets_delta,
         round(s.elapsed_time_delta/1000000/decode(s.executions_delta, 0, 1, s.executions_delta), 3) avg_et,
         round(s.buffer_gets_delta/decode(s.executions_delta, 0, 1, s.executions_delta)) avg_bg
         , b.position
         -- , bm.name -- PSRv7 - moved to main select to improve performance
         , case when b.datatype_string like 'TIMESTAM%' then
                  substr(anydata.accesstimestamp(b.value_anydata),1,50) 
                else b.value_string
           end captured_value
         , b.datatype_string
         , b.LAST_CAPTURED
         , ss.END_INTERVAL_TIME
    from dba_hist_sqlstat s, table(dbms_sqltune.extract_binds(s.bind_data)) b
         -- , dba_hist_sql_bind_metadata bm  -- PSRv7 - using only to get name, which we are already getting from peeked binds
         , dba_hist_snapshot ss
   where 1 = 1
     and :license IN ('T', 'D')
     and s.dbid = ^^dbid.
     and s.sql_id = :sql_id
     and s.bind_data is not null
     and s.dbid = ss.dbid
     and s.instance_number = ss.instance_number
     and s.snap_id = ss.snap_id
     and s.dbid = ss.dbid
     -- and bm.sql_id = s.sql_id      -- PSRv7
     -- AND bm.position = b.position  -- PSRv7
)
select cb.instance_number, cb.snap_id, cb.end_interval_time, pv.plan_hash_value, to_char(pv.timestamp, 'dd-mon-yy hh24:mi:ss') plan_gen_ts, cb.avg_et, cb.avg_bg, pv.position, pv.name 
       , case when cb.datatype_string is not null then cb.datatype_string else pv.datatype_string end datatype_string
       , pv.cvalue peeked_value
       , cb.captured_value, to_char(cb.last_captured, 'dd-mon-yy hh24:mi:ss') last_captured 
  from peeked_binds pv, captured_binds cb
 where 1 = 1
   and pv.plan_hash_value = cb.plan_hash_value
   and cb.position = pv.position
-- and last_captured < (select to_date(max(last_load_time),'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = '&&sql_id' and plan_hash_value = :l_plan_hash_value)
   and last_captured < (select to_date(last_load_time,'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value order by last_load_time desc FETCH FIRST 1 ROW ONLY)
 order by pv.plan_hash_value, cb.instance_number, cb.snap_id, pv.timestamp, to_number(pv.position));

pro <tr>
pro <th>Instance #</th>
pro <th>Snap ID</th>
pro <th>End Interval Time</th>
pro <th>Plan Hash Value</th>
pro <th>Plan Gen Timestamp</th>
pro <th>Avg Elapsed Time</th>
pro <th>Avg Buffer Gets</th>
pro <th>Position</th>
pro <th>Bind Name</th>
pro <th>Peeked Bind Value</th>
pro <th>Captured Bind Value</th>
pro <th>Last Captured Date</th>
pro </tr>

pro </tbody>
pro </table>

-- END OF BINDS : Peeked Vs Captured Bind Values - In AWR 

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

-- END OF SQL Statistics based on Last Hard Parse Time 




/* -------------------------
 *
 * SQL Plan Directives -- PSRv10
 * Uday
 * ------------------------- */
REM EXEC DBMS_SPD.FLUSH_SQL_PLAN_DIRECTIVE;

PRO
PRO <a name="spd"></a><details><br/><summary id="summary2">SQL Plan Directives</summary>
PRO
PRO SQL Plan Directives on objects used in ^^sql_id. order by LAST_USED desc 
PRO
PRO <table>
PRO <tr><td>Commented Out for now</td></tr>
/*
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Owner</th>
PRO <th>ObjTyp</th>
PRO <th>Object Name</th>
PRO <th>SubObject<br>Name</th>
PRO <th>DirectiveID</th>
PRO <th>Created</th>
PRO <th>Last Modified</th>
PRO <th>Last Used</th>
PRO <th>Auto<br>Drop?</th>
PRO <th>Enabled?</th>
PRO <th>Type</th>
PRO <th>State</th>
PRO <th>Reason</th>
PRO <th>SPD Text</th>
PRO <th>Internal<br>State</th>
PRO <th>Redundant?</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM    ||'</td>'||CHR(10)||
       '<td >'||object_owner       ||'</td>'||CHR(10)||
       '<td >'||object_type        ||'</td>'||CHR(10)||
       '<td >'||object_name        ||'</td>'||CHR(10)||
       '<td >'||subobject_name     ||'</td>'||CHR(10)||
       '<td >'||DIRECTIVE_ID       ||'</td>'||CHR(10)||
       '<td >'||CREATED            ||'</td>'||CHR(10)||
       '<td >'||LAST_MODIFIED      ||'</td>'||CHR(10)||
       '<td >'||LAST_USED          ||'</td>'||CHR(10)||
       '<td >'||auto_drop          ||'</td>'||CHR(10)||
       '<td >'||enabled            ||'</td>'||CHR(10)||
       '<td >'||TYPE               ||'</td>'||CHR(10)||
       '<td >'||state              ||'</td>'||CHR(10)||
       '<td >'||reason             ||'</td>'||CHR(10)||
       '<td >'||spd_text           ||'</td>'||CHR(10)||
       '<td >'||internal_state     ||'</td>'||CHR(10)||
       '<td >'||redundant          ||'</td>'||CHR(10)||
       '</tr>'
  FROM (
         SELECT /*+ ORDERED  leading(t) cardinality(t 1) * / 
                t.object_owner, t.object_type, t.object_name, spdo.subobject_name,
                spd.DIRECTIVE_ID,
                spd.CREATED, spd.LAST_MODIFIED, spd.LAST_USED, spd.auto_drop,
                spd.enabled,
                spd.TYPE, spd.state, spd.reason,
                extract(spd.notes, '/spd_note/spd_text/text()' )       spd_text,
                extract(spd.notes, '/spd_note/internal_state/text()' ) internal_state,
                extract(spd.notes, '/spd_note/redundant/text()')       redundant 
           FROM plan_table t,
                dba_sql_plan_dir_objects spdo,
                dba_sql_plan_directives spd
          WHERE t.object_name is not null and t.object_owner is not null
            AND spdo.owner = t.object_owner
            AND spdo.object_name = t.object_name
            AND spd.directive_id = spdo.directive_id
            AND STATEMENT_ID = :sql_id
          ORDER BY spd.last_used desc, t.object_owner, t.object_name
       ) v
;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Owner</th>
PRO <th>ObjTyp</th>
PRO <th>Object Name</th>
PRO <th>SubObject<br>Name</th>
PRO <th>DirectiveID</th>
PRO <th>Created</th>
PRO <th>Last Modified</th>
PRO <th>Last Used</th>
PRO <th>Auto<br>Drop?</th>
PRO <th>Enabled?</th>
PRO <th>Type</th>
PRO <th>State</th>
PRO <th>Reason</th>
PRO <th>SPD Text</th>
PRO <th>Internal<br>State</th>
PRO <th>Redundant?</th>
PRO </tr>
PRO
PRO <b>SPD Text Notation:</b><pre> E:equality_predicates_only, C:simple_column_predicates_only, J:index_access_by_join_predicates, F:filter_on_joining_object</pre>
*/
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
PRO

/* -------------------------
 *
 * SQL Object Dependency
 * Uday: PSRv10
 * ------------------------- */
PRO
PRO <a name="sql_obj_dependency"></a><details open><br/><summary id="summary2">SQL Object Dependency (GV$OBJECT_DEPENDENCY)</summary>
PRO
PRO Objects accessed by the SQL ^^sql_id.. Displayed only if SQL is in memory.
PRO For Views and Synonyms, dependecy hierarchy extracted from DBA_DEPENDENCIES is in the next section.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Owner</th>
PRO <th>Object Name</th>
PRO <th>object_type</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td >'||v.to_owner||'</td>'||CHR(10)||
       case when v.type <> 'VIEW' THEN '<td class="r">'||v.to_name||'</td>'
            when v.type =  'VIEW' THEN '<td class="r">'||q'{<a href="#}'||v.to_owner||'.'||v.to_name||q'{">}'||v.to_name||'</a></td>'
       END ||CHR(10)||
       '<td class="r">'||v.type||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        SELECT /*+ NO_MERGE */ to_owner, to_name, to_type,
               decode(to_type, 
                       0,'CURSOR',
                       1,'INDEX',
                       2,'TABLE', 
                       3,'CLUSTER',
                       4,'VIEW', 
                       5,'SYNONYM',
                       6,'SEQUENCE',
                       7,'PROCEDURE',
                       8,'FUNCTION',
                       9,'PACKAGE',
                       10,'NON-EXISTENT',
                       11,'PACKAGE BODY',
                       12,'TRIGGER',
                       13,'TYPE',
                       14,'TYPE BODY', 
                       15,'OBJECT',
                       16,'USER',
                       17,'DBLINK',
                       18,'PIPE',
                       19,'TABLE PARTITION', 
                       20,'INDEX PARTITION',
                       21,'LOB',
                       22,'LIBRARY',
                       23,'DIRECTORY',
                       24,'QUEUE', 
                       25,'INDEX-ORGANIZED TABLE',
                       26,'REPLICATION OBJECT GROUP',
                       27,'REPLICATION PROPAGATOR', 
                       28,'JAVA SOURCE',
                       29,'JAVA CLASS',
                       30,'JAVA RESOURCE',
                       31,'JAVA JAR',
                       32,'INDEX TYPE',
                       33, 'OPERATOR',
                       34,'TABLE SUBPARTITION',
                       35,'INDEX SUBPARTITION', 
                       36, 'REPLICATED TABLE OBJECT',
                       37,'REPLICATION INTERNAL PACKAGE', 
                       38, 'CONTEXT POLICY',
                       39,'PUB_SUB',
                       40,'LOB PARTITION',
                       41,'LOB SUBPARTITION',
                       42,'SUMMARY',
                       43,'DIMENSION',
                       44,'APP CONTEXT',
                       45,'STORED OUTLINE',
                       46,'RULESET', 
                       47,'RSRC PLAN',
                       48,'RSRC CONSUMER GROUP',
                       49,'PENDING RSRC PLAN', 
                       50,'PENDING RSRC CONSUMER GROUP',
                       51,'SUBSCRIPTION',
                       52,'LOCATION', 
                       53,'REMOTE OBJECT', 
                       54,'SNAPSHOT METADATA',
                       55,'XDB', 
                       56,'JAVA SHARED DATA',
                       57,'SECURITY PROFILE',
                       'UNDEFINED/INVALID'
                     ) type
          FROM gv$object_dependency
         WHERE 1=1
           -- and to_owner <> 'SYS'
           and (inst_id, from_address, from_hash) IN
               (SELECT inst_id, address, hash_value
                  FROM gv$sql
                 WHERE sql_id = :sql_id
                   AND inst_id IN (SELECT inst_id FROM gv$instance)
               )
         order by to_type desc, to_owner, to_name
       ) v
;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Owner</th>
PRO <th>Object Name</th>
PRO <th>object_type</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * Views/Synonyms Dependency
 * Uday: PSRv10
 * ------------------------- */
PRO
PRO <a name="sql_views_dependency"></a><details open><br/><summary id="summary2">View/Synonym Dependency Hierarchy (GV$OBJECT_DEPENDENCY/DBA_DEPENDENCIES)</summary>
PRO
PRO Dependecy hierarchy of Views & Synonyms accessed by the SQL ^^sql_id.. 
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Name</th>
PRO <th>Type</th>
PRO <th>Depth</th>
PRO <th>Tree</th>
PRO <th>Dependent Object Name</th>
PRO <th>Dependent Type</th>
PRO <th>IsCycle</th>
PRO <th>Path</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

-- PARENT_NAME	TYPE	DEPTH	TREE	REFNAME	REFTYPE	ISCYCLE	PATH
SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td >'||v.PARENT_NAME||'</td>'||CHR(10)||
       '<td class="r">'||v.TYPE||'</td>'||CHR(10)||
       '<td class="r">'||v.DEPTH||'</td>'||CHR(10)||
       '<td >'||v.TREE||'</td>'||CHR(10)||
       '<td class="r">'||v.REFNAME||'</td>'||CHR(10)||
       '<td class="r">'||v.REFTYPE||'</td>'||CHR(10)||
       '<td class="r">'||v.ISCYCLE||'</td>'||CHR(10)||
       '<td >'||v.PATH||'</td>'||CHR(10)||
       '</tr>'
  FROM (
        select /*+ no_merge */ connect_by_root name parent_name, type, LEVEL-1 depth, 
                -- case when (connect_by_root name = dep.name) 
                --      then '.'
                --      else RPAD('.', (level-1)*2, '.') ||dep.name 
                -- end tree, 
                RPAD('.', (level-1)*2, '.') ||dep.name tree,
                referenced_name refname, referenced_type reftype, 
                CONNECT_BY_ISCYCLE iscycle,
                LPAD(' ', 2*level-1)||SYS_CONNECT_BY_PATH(name, ' / ') ||'/'||referenced_name||'('||referenced_type||')' Path
           FROM dba_dependencies dep
          WHERE 1=1
          start with 1=1
            and owner = 'FUSION'
            and name in (select distinct  to_name 
                           from gv$object_dependency 
                          where (inst_id, from_address, from_hash) in 
                                 (select inst_id, address, hash_value 
                                    from gv$sql 
                                   where sql_id = :sql_id and to_type in (4,5) /* views,synonym */
                                     AND inst_id IN (SELECT inst_id FROM gv$instance)
                                 )
                        )
            and type <> 'PACKAGE BODY'
          connect by NOCYCLE prior referenced_name = name
                 and prior referenced_owner = 'FUSION'
                 and owner not in ('FUSION_RO','FUSION_ERO') 
                 and prior referenced_type not like 'PACKAGE%'
                 and type not like 'PACKAGE%'
                 and type <> 'NON-EXISTENT'
        ORDER SIBLINGS BY dep.name, reftype, refname desc
       ) v
;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Name</th>
PRO <th>Type</th>
PRO <th>Depth</th>
PRO <th>Tree</th>
PRO <th>Dependent Object Name</th>
PRO <th>Dependent Type</th>
PRO <th>IsCycle</th>
PRO <th>Path</th>
PRO </tr>
PRO
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * Plan Control Hints -- PSRv10
 * Uday
 * ------------------------- */
PRO <a name="planControlHints"></a><details open><br/><summary id="summary2">Plan Control Hints</summary>
PRO SQL Patches/Profiles/Baselines Hints

SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

with hints as (
SELECT /*+ materialize */ decode(od.obj_type, 1, 'SQL Profile', 2, 'SQL Plan Baseline', 3, 'SQL Patch') Type, so.name, extractValue(value(h),'.') AS hint
  FROM sys.sqlobj$data od, 
       sys.sqlobj$ so,
       table(xmlsequence(extract(xmltype(od.comp_data),'/outline_data/*'))) h
 WHERE so.signature = :signaturef
   AND so.signature = od.signature
   AND so.category = od.category
   AND so.obj_type = od.obj_type
   AND so.plan_id = od.plan_id
-- ORDER BY type, name
)
-- select chr(10) || chr(10) || 'SQL Patch: ' || name || chr(10) || chr(10) 
select chr(10) || chr(10) || q'{<a name="}' || name || q'{"></a>}' ||'<details open><br/><summary id="summary3">SQL Patch: '|| name ||'</summary>'|| chr(10) || chr(10)
  from hints
 where type = 'SQL Patch'
   and rownum=1 
union all
select '<pre>' from hints
 where type = 'SQL Patch'
   and rownum=1 
union all
select chr(9)||hint
  from hints
 where type = 'SQL Patch'
union all
select '</pre></details>' from hints
 where type = 'SQL Patch'
   and rownum=1 
union all
-- select chr(10) || chr(10) || 'SQL Profile: ' || name || chr(10) || chr(10) 
select chr(10) || chr(10) || q'{<a name="}' || name || q'{"></a>}' ||'<details open><br/><summary id="summary3">SQL Profile: '|| name ||'</summary>'|| chr(10) || chr(10)
  from hints
 where type = 'SQL Profile'
   and rownum=1 
union all
select '<pre>' from hints
 where type = 'SQL Profile'
   and rownum=1 
union all
select chr(9)||hint
  from hints
 where type = 'SQL Profile'
union all
select '</pre></details>' from hints
 where type = 'SQL Profile'
   and rownum=1 
union all
-- select chr(10) || chr(10) || 'SQL Plan Baseline: ' || name || chr(10) || chr(10) 
select chr(10) || chr(10) || q'{<a name="}' || name || q'{"></a>}' ||'<details open><br/><summary id="summary3">SQL Plan Baseline: '|| name ||'</summary>'|| chr(10) || chr(10)
  from hints
 where type = 'SQL Plan Baseline'
   and rownum=1 
union all
select '<pre>' from hints
 where type = 'SQL Plan Baseline'
   and rownum=1 
union all
select chr(9)||hint
  from hints
 where type = 'SQL Plan Baseline'
union all
select '</pre></details>' from hints
 where type = 'SQL Plan Baseline'
   and rownum=1 
;

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');


/* -------------------------
 *
 * Metadata
 *
 * ------------------------- */
PRO <a name="metadata"></a><details><br/><summary id="summary2">Metadata</summary>
-- PRO Table and Index Metadata of the objects involved in the plan and their dependent objects
PRO Index and View Metadata of the objects involved in the plan and their dependent objects
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->
--PSRv10: compact index definitions
PRO <a name="index_metadata"></a><details><br/><summary id="summary3">Indexes Metadata</summary>
PRO
PRO <pre>
SET LONG 1000000 LONGCHUNKSIZE 1000000

exec dbms_metadata.set_transform_param( dbms_metadata.session_transform, 'STORAGE', FALSE);
exec dbms_metadata.set_transform_param( dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false );
exec dbms_metadata.set_transform_param( dbms_metadata.session_transform, 'SQLTERMINATOR', FALSE);
exec dbms_metadata.set_transform_param( dbms_metadata.session_transform, 'TABLESPACE', FALSE);

--
-- tables: FA tables are too long so not fetching tables metadata
--
--psrv10 WITH object AS (
--psrv10 SELECT /*+ MATERIALIZE */
--psrv10        object_owner owner, object_name name
--psrv10   FROM gv$sql_plan
--psrv10  WHERE inst_id IN (SELECT inst_id FROM gv$instance)
--psrv10    AND sql_id = :sql_id
--psrv10    AND object_owner IS NOT NULL
--psrv10    AND object_name IS NOT NULL
--psrv10    AND 1=2  --uday: disabling for Fusion Apps as tables are very long
--psrv10  UNION
--psrv10 SELECT object_owner owner, object_name name
--psrv10   FROM dba_hist_sql_plan
--psrv10  WHERE :license IN ('T', 'D')
--psrv10    AND dbid = ^^dbid.
--psrv10    AND sql_id = :sql_id
--psrv10    AND object_owner IS NOT NULL
--psrv10    AND object_name IS NOT NULL
--psrv10    AND 1=2  --uday: disabling for Fusion Apps as tables are very long
--psrv10  )
--psrv10  SELECT '<br/><summary id="summary3">Table: '||t.object_owner||'.'||t.object_name||'</summary>'||REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DBMS_METADATA.GET_DDL('TABLE',t.object_name,t.object_owner), '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;'), '''', CHR(38)||'#39;'), '"', CHR(38)||'quot;'), CHR(10), '<br>'||CHR(10))
--psrv10    FROM (SELECT t.owner object_owner, t.table_name object_name
--psrv10            FROM dba_tables t, -- include fixed objects
--psrv10                 object o
--psrv10           WHERE t.owner = o.owner
--psrv10             AND t.table_name = o.name
--psrv10           UNION
--psrv10          SELECT i.table_owner object_owner, i.table_name object_name
--psrv10            FROM dba_indexes i,
--psrv10                 object o
--psrv10           WHERE i.owner = o.owner
--psrv10             AND i.index_name = o.name) t;
			
WITH object AS (
SELECT /*+ MATERIALIZE */
       object_owner owner, object_name name, object_type
  FROM gv$sql_plan
 WHERE inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
 UNION
SELECT object_owner owner, object_name name, object_type
  FROM dba_hist_sql_plan
 WHERE :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
 )
, plan_tables AS (
--UdayRemoved.v6 SELECT /*+ MATERIALIZE */
--UdayRemoved.v6        'TABLE' object_type, t.owner object_owner, t.table_name object_name
--UdayRemoved.v6   FROM dba_tables t, -- include fixed objects
--UdayRemoved.v6        object o
--UdayRemoved.v6  WHERE t.owner = o.owner
--UdayRemoved.v6    AND t.table_name = o.name
 SELECT /*+ MATERIALIZE */
        object_type, o.owner object_owner, o.name object_name
   FROM object o
  WHERE (o.object_type like 'TABLE%' OR o.object_type = 'VIEW')
  UNION
 SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
   FROM dba_indexes i,
        object o
  WHERE o.object_type like 'INDEX%'  --Uday.v6
    AND i.owner = o.owner
    AND i.index_name = o.name
  UNION
 SELECT /*+ leading (o) */ 'TABLE' object_type, t.owner object_owner, t.table_name object_name
   FROM dba_tables t,
        object o
  WHERE t.owner = o.owner
    AND t.table_name = o.name
    AND o.object_type IS NULL /* PUSHKAR 10.8: this helps in insert statement analysis */     
)
--PSRv10 SELECT '<br/><summary id="summary3">Index: '||s.owner||'.'||s.index_name||'</summary>'||REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DBMS_METADATA.GET_DDL('INDEX',s.index_name,s.owner), '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;'), '''', CHR(38)||'#39;'), '"', CHR(38)||'quot;'), CHR(10), '<br>'||CHR(10))
SELECT REPLACE(REPLACE(REPLACE(REPLACE(DBMS_METADATA.GET_DDL('INDEX',s.index_name,s.owner), '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;'), '''', CHR(38)||'#39;'), '"', CHR(38)||'quot;')
  FROM plan_tables pt,
       dba_indexes s
 WHERE pt.object_type = 'TABLE'
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
   AND s.index_type not like 'LOB%' --Uday.v6
 ORDER BY
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner;
PRO </pre>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
--
-- view metadata -- uday
--
--PSRv10: below line
PRO <a name="view_metadata"></a><details><br/><summary id="summary3">View Metadata</summary>
PRO <pre>
WITH object AS (
SELECT /*+ MATERIALIZE */
       object_owner owner, object_name view_name, object_type, 'GV_SQL_PLAN' source
  FROM gv$sql_plan
 WHERE inst_id IN (SELECT inst_id FROM gv$instance)
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND object_type in ('VIEW','MAT_VIEW')
 UNION
SELECT object_owner owner, object_name view_name, object_type, 'DBA_HIST_SQL_PLAN' source
  FROM dba_hist_sql_plan
 WHERE :license IN ('T', 'D')
   AND dbid = ^^dbid.
   AND sql_id = :sql_id
   AND object_owner IS NOT NULL
   AND object_name IS NOT NULL
   AND object_type in ('VIEW','MAT_VIEW')
UNION
--PSRv10
SELECT to_owner owner, to_name view_name, decode(to_type,2,'MAT_VIEW',4,'VIEW'), 'OBJ_DEPENDENCY' source
  FROM gv$object_dependency
 WHERE to_owner <> 'SYS'
   and to_type IN (2, 4)-- 2.materialized view, 4=views
   and (inst_id, from_address, from_hash) IN
        (SELECT inst_id, address, hash_value
           FROM gv$sql
          WHERE inst_id IN (SELECT inst_id FROM gv$instance)
            and sql_id = :sql_id
        )
), 
views AS (
 SELECT /*+ MATERIALIZE */ distinct owner, view_name, object_type
   FROM object o
  WHERE exists (select 1 from dba_objects v where v.object_name = o.view_name and v.owner = o.owner and v.object_type like '%VIEW%')
UNION
--SELECT /*+ MATERIALIZE */ distinct d.owner, d.referenced_name
--   FROM object o, dba_dependencies d
-- where d.owner = o.owner and d.name = o.view_name and d.referenced_type = 'VIEW'
--   and not exists (select null from object od where od.owner = o.owner and od.view_name = o.view_name and od.source = 'OBJ_DEPENDENCY') -- PSRv10
        select  referenced_owner, referenced_name, referenced_type
           FROM dba_dependencies dep
          WHERE 1=1
            and referenced_type in ('VIEW', 'MATERIALIZED VIEW')
          start with 1=1
            and owner = 'FUSION'
            and name in (select view_name from object)
            and type in ('VIEW', 'MATERIALIZED VIEW')
            and referenced_type in ('VIEW', 'MATERIALIZED VIEW')
          connect by NOCYCLE prior referenced_name = name
                 and prior referenced_owner = 'FUSION'                  
                 and prior referenced_type = type
),
dviews AS (SELECT DISTINCT owner, view_name, Decode(object_type,'MATERIALIZED VIEW','MAT_VIEW',object_type) object_type FROM views)
SELECT q'{<a name="}' || s.owner||'.'||s.view_name || q'{"></a>}'
       -- ||'<br/><summary id="summary3">View: '||s.owner||'.'||s.view_name||'</summary>'||REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(DBMS_METADATA.GET_DDL('VIEW',s.view_name,s.owner), '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;'), '''', CHR(38)||'#39;'), '"', CHR(38)||'quot;'), CHR(10), '<br>'||CHR(10))
       ||'<details open><br/><summary id="summary3">View: '||s.owner||'.'||s.view_name||'</summary>'||
       REPLACE(REPLACE(REPLACE(REPLACE(DBMS_METADATA.GET_DDL(case when s.object_type='VIEW' then 'VIEW' when s.object_type='MAT_VIEW' then 'MATERIALIZED_VIEW' end,s.view_name,s.owner), '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;'), '''', CHR(38)||'#39;'), '"', CHR(38)||'quot;')
       ||'</details>'
  FROM dviews s
 ORDER BY
       s.owner,
       s.view_name
;
PRO </pre>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

PRO </details> <!--Pushkar - complete metadata -->
/* -------------------------
 *
 * Index Contention / GC Buffer busy waits
 * Srini Kasam:PSR
 *
 * ------------------------- */




-- Display Index Contention summary from ASH.

/* -------------------------
 *
 * gv$active_session_history
 *
 * ------------------------- */



EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: GV$ASH by Plan - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO <a name="indexcontention"></a><details open><br/><summary id="summary2">Index Contention details from Active Session History (GV$ACTIVE_SESSION_HISTORY)</summary>
PRO
PRO Snapshots counts per Plan and Wait Event for ^^sql_id..<br>
PRO This section includes data captured by AWR.
PRO
PRO <table>
PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Phase</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV</th>
PRO <th>% PHV+Event</th>
PRO <th>Sampled<br>Executions</th>
PRO <th>Max PGA<br>(MB)</th>
PRO <th>Max Temp<br>(MB)</th>
PRO </tr>
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

SELECT CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td class="r">'||v.sql_plan_hash_value||'</td>'||CHR(10)||
       '<td>'||v.session_state||'</td>'||CHR(10)||
       '<td>'||v.wait_class||'</td>'||CHR(10)||
       '<td>'||v.event ||'</td>'||CHR(10)||
       '<td>'||v.phase ||'</td>'||CHR(10)||
       '<td class="r">'||v.snaps_count||'</td>'||CHR(10)||
       '<td class="r">'||v.phv_pct||'</td>'||CHR(10)||
       '<td class="r">'||v.phv_event_pct||'</td>'||CHR(10)||
       '<td class="r">'||v.sampled_execs||'</td>'||CHR(10)||
       '<td class="r">'||v.max_pga||'</td>'||CHR(10)||
       '<td class="r">'||v.max_temp||'</td>'||CHR(10)||
       '</tr>'
  FROM (
SELECT /*+ NO_MERGE */
       ash.sql_plan_hash_value,
       ash.session_state,
       ash.wait_class,
       nvl(ash.event, 'On CPU/Waiting for CPU') event
       , CASE WHEN IN_CONNECTION_MGMT     = 'Y' THEN 'CONNECTION_MGMT '     END ||
         CASE WHEN IN_PARSE               = 'Y' THEN 'PARSE '               END ||
         CASE WHEN IN_HARD_PARSE          = 'Y' THEN 'HARD_PARSE '          END ||
         CASE WHEN IN_SQL_EXECUTION       = 'Y' THEN 'SQL_EXECUTION '       END ||
         CASE WHEN IN_PLSQL_EXECUTION     = 'Y' THEN 'PLSQL_EXECUTION '     END ||
         CASE WHEN IN_PLSQL_RPC           = 'Y' THEN 'PLSQL_RPC '           END ||
         CASE WHEN IN_PLSQL_COMPILATION   = 'Y' THEN 'PLSQL_COMPILATION '   END ||
         CASE WHEN IN_JAVA_EXECUTION      = 'Y' THEN 'JAVA_EXECUTION '      END ||
         CASE WHEN IN_BIND                = 'Y' THEN 'BIND '                END ||
         CASE WHEN IN_CURSOR_CLOSE        = 'Y' THEN 'CURSOR_CLOSE '        END ||
         CASE WHEN IN_SEQUENCE_LOAD       = 'Y' THEN 'SEQUENCE_LOAD '       END phase,
       COUNT(*) snaps_count,
       round((sum(COUNT(*)) over(partition by ash.sql_plan_hash_value)/sum(COUNT(*)) over())*100, 2) phv_pct,
       ROUND((RATIO_TO_REPORT(COUNT(*)) over(partition by ash.sql_plan_hash_value))*100, 2) phv_event_pct
       , count(distinct ash.inst_id||ash.sql_exec_start) sampled_execs  
       , max(pga_allocated/1024/1024) max_pga  
       , max(temp_space_allocated/1024/1024) max_temp  
  FROM gv$active_session_history ash
 WHERE 
   ash.sql_id = :sql_id
   AND ash.event like '%buffer busy%'
 GROUP BY
       ash.sql_plan_hash_value,
       ash.session_state,
       ash.wait_class,
       nvl(ash.event, 'On CPU/Waiting for CPU') 
       , CASE WHEN IN_CONNECTION_MGMT     = 'Y' THEN 'CONNECTION_MGMT '     END ||
         CASE WHEN IN_PARSE               = 'Y' THEN 'PARSE '               END ||
         CASE WHEN IN_HARD_PARSE          = 'Y' THEN 'HARD_PARSE '          END ||
         CASE WHEN IN_SQL_EXECUTION       = 'Y' THEN 'SQL_EXECUTION '       END ||
         CASE WHEN IN_PLSQL_EXECUTION     = 'Y' THEN 'PLSQL_EXECUTION '     END ||
         CASE WHEN IN_PLSQL_RPC           = 'Y' THEN 'PLSQL_RPC '           END ||
         CASE WHEN IN_PLSQL_COMPILATION   = 'Y' THEN 'PLSQL_COMPILATION '   END ||
         CASE WHEN IN_JAVA_EXECUTION      = 'Y' THEN 'JAVA_EXECUTION '      END ||
         CASE WHEN IN_BIND                = 'Y' THEN 'BIND '                END ||
         CASE WHEN IN_CURSOR_CLOSE        = 'Y' THEN 'CURSOR_CLOSE '        END ||
         CASE WHEN IN_SEQUENCE_LOAD       = 'Y' THEN 'SEQUENCE_LOAD '       END 
 ORDER BY
       ash.sql_plan_hash_value,
       5 DESC,
       ash.session_state,
       ash.wait_class,
       event ) v;

PRO
PRO <tr>
PRO <th>#</th>
PRO <th>Plan<br>Hash<br>Value</th>
PRO <th>Session<br>State</th>
PRO <th>Wait<br>Class</th>
PRO <th>Event</th>
PRO <th>Phase</th>
PRO <th>Snaps<br>Count</th>
PRO <th>% PHV</th>
PRO <th>% PHV+Event</th>
PRO <th>Sampled<br>Executions</th>
PRO <th>Max PGA<br>(MB)</th>
PRO <th>Max Temp<br>(MB)</th>
PRO </tr>
PRO </table>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Srini-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');


EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Indexes Contention - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->


SELECT /* ^^script..sql Indexes */
       v2.line_text
  FROM (
SELECT object_name table_name,
       object_owner owner,
       1 line_type,
       1 row_num,
       '<a name="i_'||LOWER(object_name||'_'||object_owner)||'"></a><details open><br/><summary id="summary3">Indexes: '||object_name||' ('||object_owner||')</summary>'||CHR(10)||CHR(10)||
       'CBO Statistics and relevant attributes.'||CHR(10)||CHR(10)||
       '<table>'||CHR(10)||CHR(10)||
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       '<th>Owner</th>'||CHR(10)||
       '<th>Index Type</th>'||CHR(10)||
       '<th>Part</th>'||CHR(10)||
       '<th>DoP</th>'||CHR(10)||
       '<th>Temp</th>'||CHR(10)||
       '<th>Uniqueness</th>'||CHR(10)||
       '<th>Cols</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Distinct<br>Keys</th>'||CHR(10)||
       '<th>Blevel</th>'||CHR(10)||
       '<th>Leaf<br>Blocks</th>'||CHR(10)||
       '<th>Avg<br>Leaf<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Avg<br>Data<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Clustering<br>Factor</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '<th>Stat<br>Type<br>Locked</th>'||CHR(10)||
       '<th>Stale<br>Stats</th>'||CHR(10)||
   	'<th>Stats<br>Versions</th>'||CHR(10)||
   	'<th>Status</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT v.table_name,
       v.table_owner owner,
       2 line_type,
       ROWNUM row_num,
       CHR(10)||'<tr>'||CHR(10)||
       '<td class="r">'||ROWNUM||'</td>'||CHR(10)||
       '<td><a href="#ic_'||LOWER(v.index_name||'_'||v.owner)||'">'||v.index_name||'</a></td>'||CHR(10)||
       '<td>'||v.owner||'</td>'||CHR(10)||
       '<td>'||v.index_type||'</td>'||CHR(10)||
	   CASE WHEN v.partitioned = 'YES' 
	     THEN '<td class="c"><a href="#ip_'||LOWER(v.table_name||'_'||v.table_owner)||'">'||v.partitioned||'</a></td>'
		 ELSE '<td class="c">'||v.partitioned||'</td>'
	   END||CHR(10)||
       '<td class="c">'||v.degree||'</td>'||CHR(10)||
       '<td class="c">'||v.temporary||'</td>'||CHR(10)||
       '<td>'||v.uniqueness||'</td>'||CHR(10)||
       '<td class="c"><a href="#ic_'||LOWER(v.index_name||'_'||v.owner)||'">'||v.columns||'</a></td>'||CHR(10)||
       '<td class="r">'||v.num_rows||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size||'</td>'||CHR(10)||
       '<td class="r">'||v.sample_size_perc||'</td>'||CHR(10)||
       '<td nowrap>'||v.last_analyzed||'</td>'||CHR(10)||
       '<td class="r">'||v.distinct_keys||'</td>'||CHR(10)||
       '<td class="r">'||v.blevel||'</td>'||CHR(10)||
       '<td class="r">'||v.leaf_blocks||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_leaf_blocks_per_key||'</td>'||CHR(10)||
       '<td class="r">'||v.avg_data_blocks_per_key||'</td>'||CHR(10)||
       '<td class="r">'||v.clustering_factor||'</td>'||CHR(10)||
       '<td class="c">'||v.global_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.user_stats||'</td>'||CHR(10)||
       '<td class="c">'||v.stattype_locked||'</td>'||CHR(10)||
       '<td class="c">'||v.stale_stats||'</td>'||CHR(10)||
       '<td class="c"><a href="#i_stat_ver_'||LOWER(v.table_name||'_'||v.table_owner)||'">Versions</a></td>'||CHR(10)||
       '<td class="c">'||v.status||'</td>'||CHR(10)||
       '</tr>'||CHR(10) line_text
  FROM (
SELECT /*+ NO_MERGE LEADING(pt s i) */
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner,
       i.index_type,
       i.partitioned,
       i.degree,
       i.temporary,
       i.uniqueness,
       (SELECT COUNT(*)
          FROM dba_ind_columns c
         WHERE c.index_owner = s.owner
           AND c.index_name = s.index_name
           AND c.table_owner = s.table_owner
           AND c.table_name = s.table_name) columns,
       s.num_rows,
       s.sample_size,
       CASE WHEN s.num_rows > 0 THEN TO_CHAR(ROUND(s.sample_size * 100 / s.num_rows, 1), '99999990D0') END sample_size_perc,
       TO_CHAR(s.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       s.distinct_keys,
       s.blevel,
       s.leaf_blocks,
       s.avg_leaf_blocks_per_key,
       s.avg_data_blocks_per_key,
       s.clustering_factor,
       s.global_stats,
       s.user_stats,
       s.stattype_locked,
       s.stale_stats,
       i.status
FROM plan_table pt,
       dba_ind_statistics s,
       dba_indexes i
 WHERE pt.object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
   AND pt.object_owner = s.table_owner
   AND pt.object_name = s.table_name
   AND s.object_type = 'INDEX'
   AND s.owner = i.owner
   AND s.index_name = i.index_name
   AND s.table_owner = i.table_owner
   AND s.table_name = i.table_name
 ORDER BY
       s.table_name,
       s.table_owner,
       s.index_name,
       s.owner) v
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       3 line_type,
       1 row_num,
       '<tr>'||CHR(10)||
       '<th>#</th>'||CHR(10)||
       --'<th>Table Name</th>'||CHR(10)||
       --'<th>Owner</th>'||CHR(10)||
       '<th>Index Name</th>'||CHR(10)||
       '<th>Owner</th>'||CHR(10)||
       '<th>Index Type</th>'||CHR(10)||
       '<th>Part</th>'||CHR(10)||
       '<th>DoP</th>'||CHR(10)||
       '<th>Temp</th>'||CHR(10)||
       '<th>Uniqueness</th>'||CHR(10)||
       '<th>Cols</th>'||CHR(10)||
       '<th>Num<br>Rows</th>'||CHR(10)||
       '<th>Sample<br>Size</th>'||CHR(10)||
       '<th>Perc</th>'||CHR(10)||
       '<th>Last Analyzed</th>'||CHR(10)||
       '<th>Distinct<br>Keys</th>'||CHR(10)||
       '<th>Blevel</th>'||CHR(10)||
       '<th>Leaf<br>Blocks</th>'||CHR(10)||
       '<th>Avg<br>Leaf<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Avg<br>Data<br>Blocks<br>per Key</th>'||CHR(10)||
       '<th>Clustering<br>Factor</th>'||CHR(10)||
       '<th>Global<br>Stats</th>'||CHR(10)||
       '<th>User<br>Stats</th>'||CHR(10)||
       '<th>Stat<br>Type<br>Locked</th>'||CHR(10)||
       '<th>Stale<br>Stats</th>'||CHR(10)||
   	'<th>Stats<br>Versions</th>'||CHR(10)||
   	'<th>Status</th>'||CHR(10)||
       '</tr>'||CHR(10) line_text
FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id
 UNION ALL
SELECT object_name table_name,
       object_owner owner,
       4 line_type,
       1 row_num,
       CHR(10)||'</table></details><!-- Srini -->'||CHR(10)||CHR(10) line_text
  FROM plan_table
 WHERE object_type = 'TABLE'
   AND STATEMENT_ID = :sql_id) v2
 ORDER BY
       v2.table_name,
       v2.owner,
       v2.line_type,
       v2.row_num;	   
	   

-- Display command to partition index



PRO <details open><br/><summary id="summary3">Command to partition index</summary>

select * from (
  SELECT  REPLACE(REPLACE(REPLACE(REPLACE(DBMS_METADATA.GET_DDL('INDEX', i.index_name, i.owner), '<', CHR(38)||'lt;'), '>', CHR(38)||'gt;'), '''', CHR(38)||'#39;'), '"', CHR(38)||'quot;') || 'PARTITION BY HASH('  || c.column_name || ') PARTITIONS 64'
 FROM plan_table pt,
       dba_indexes i,
       dba_ind_columns c,
       gv$active_session_history ash
 WHERE pt.object_type = 'TABLE'
   AND pt.STATEMENT_ID = :sql_id
   AND pt.object_name = i.table_name
   AND ash.sql_id = :sql_id
   AND ash.event like '%buffer busy%'
   AND ash.sql_id = pt.statement_id
   AND i.index_name = c.index_name
   AND c.column_position = 1) where rownum=1;


select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');
/* -------------------------
 *
 * footer
 *
 * ------------------------- */
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <hr size="3">
PRO <font class="f">^^mos_doc. ^^method. ^^doc_ver. ^^time_stamp2.</font>
PRO </body>
PRO </html>

SPO OFF;

/**************************************************************************************************/

/**************************************************************************************************
 *
 * execution_plans report
 *
 **************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Execution Plans - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));

/* -------------------------
 *
 * heading
 *
 * ------------------------- */
SPO ^^files_prefix._3_execution_plans.html;

PRO <html>
PRO <!-- $Header: pdbcs/no_ship_src/service/scripts/ops/adb_sql/diagsql/sqlhc.sql /main/3 2022/03/07 01:33:04 scharala Exp $ -->
PRO <!-- Copyright (c) 2000-2012, Oracle Corporation. All rights reserved. -->
PRO <!-- Author: carlos.sierra@oracle.com -->
PRO
PRO <head>
PRO <title>^^files_prefix._3_execution_plans.html</title>
PRO

PRO <style type="text/css">
PRO body {font:10pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
PRO a {font-weight:bold; color:#663300;}
PRO pre {font:8pt Monaco,"Courier New",Courier,monospace;} /* for code */
PRO h1 {font-size:16pt; font-weight:bold; color:#336699;}
PRO h2 {font-size:14pt; font-weight:bold; color:#336699;}
PRO h3 {font-size:12pt; font-weight:bold; color:#336699;}
PRO li {font-size:10pt; font-weight:bold; color:#336699; padding:0.1em 0 0 0;}
PRO table {font-size:8pt; color:black; background:white;}
PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td {text-align:left; background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td.c {text-align:center;} /* center */
PRO td.l {text-align:left;} /* left (default) */
PRO td.r {text-align:right;} /* right */
PRO font.n {font-size:8pt; font-style:italic; color:#336699;} /* table footnote in blue */
PRO font.f {font-size:8pt; color:#999999;} /* footnote in gray */
PRO #summary1 {font-weight: bold; font-size: 16pt; color:#336699;}
PRO #summary2 {font-weight: bold; font-size: 14pt; color:#336699;}
PRO #summary3 {font-weight: bold; font-size: 12pt; color:#336699;}
PRO #summary4 {font-weight: bold; font-size: 10pt; color:#336699;}
PRO summary:hover {background-color: #FFFF99;}
PRO .button  {cursor: pointer;}
PRO .button1 {border-radius: 8px; background-color: #FFFF99; color: black;}
PRO .button1:hover {background-color: #4CAF50;color: white;}
PRO #mark_fmt {font:8pt Monaco,"Courier New",Courier,monospace; background-color:#ffcccc;} /* for highlighting plan issues */
PRO </style>
PRO

PRO </head>
PRO <body>
PRO <h1><a target="MOS" href="^^doc_link.^^mos_doc.">^^mos_doc.</a> ^^method.
PRO ^^doc_ver. Report: ^^files_prefix._3_execution_plans.html</h1>
PRO

PRO <pre>
PRO License    : ^^input_license.
PRO Input      : ^^input_parameter.
PRO SIGNATURE  : ^^signature.
PRO SIGNATUREF : ^^signaturef.
PRO RDBMS      : ^^rdbms_version.
PRO Platform   : ^^platform.
PRO Database   : ^^database_name_short.
PRO DBID       : ^^dbid.
PRO Host       : ^^host_name_short.
PRO Instance   : ^^instance_number.
PRO CPU_Count  : ^^sys_cpu.
PRO Num CPUs   : ^^num_cpus.
PRO Num Cores  : ^^num_cores.
PRO Num Sockets: ^^num_sockets.
PRO Block Size : ^^sys_db_block_size.
PRO OFE        : ^^sys_ofe.
PRO DYN_SAMP   : ^^sys_ds.
PRO EBS        : "^^is_ebs."
PRO SIEBEL     : "^^is_siebel."
PRO PSFT       : "^^is_psft."
PRO Date       : ^^time_stamp2.
PRO User       : ^^sessionuser.
PRO </pre>

PRO <ul>
PRO <li><a href="#text">SQL Text</a></li>
PRO <li><a href="#mem_plans_last">Current Execution Plans (last execution)</a></li>
PRO <li><a href="#mem_plans_all">Current Execution Plans (all executions)</a></li>
PRO <li><a href="#awr_plans">Historical Execution Plans</a></li>
PRO <li><a href="#baseline_plans">Baseline Execution Plans</a></li>
PRO </ul>

/* -------------------------
 *
 * sql_text
 *
 * ------------------------- */
PRO <script language="JavaScript" type="text/JavaScript">
PRO function openInNewWindow(url)
PRO {
PRO   window.open(url,"_blank");
PRO }
PRO </script>
PRO <a name="text"></a><details open><br/><summary id="summary2">SQL Text</summary>
PRO <FORM><BUTTON class="button button1" onclick="openInNewWindow(&quot;https://apex.oraclecorp.com/pls/apex/f?p=28906&quot;)">Analyze SQL Text via PSR Tool [use Upload SQL Button]</BUTTON></FORM> 
PRO
PRO <pre>

DECLARE
  l_sql_text CLOB := :sql_text;
  l_pos NUMBER;
BEGIN
  WHILE NVL(LENGTH(l_sql_text), 0) > 0
  LOOP
    l_pos := INSTR(l_sql_text, CHR(10));
    IF l_pos > 0 THEN
      DBMS_OUTPUT.PUT_LINE(SUBSTR(l_sql_text, 1, l_pos - 1));
      l_sql_text := SUBSTR(l_sql_text, l_pos + 1);
    ELSE
      DBMS_OUTPUT.PUT_LINE(l_sql_text);
      l_sql_text := NULL;
    END IF;
  END LOOP;
END;
/

PRO </pre>

select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
PRO </details><!--Pushkar-->
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * DBMS_XPLAN.DISPLAY_CURSOR OUTLINE ALLSTATS LAST
 *
 * ------------------------- */
COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;

PRO <a name="mem_plans_last"></a><details open><br/><summary id="summary2">Current Execution Plans (last execution)</summary>
PRO
PRO Captured while still in memory. Metrics below are for the last execution of each child cursor.<br>
PRO If STATISTICS_LEVEL was set to ALL at the time of the hard-parse then A-Rows column is populated.
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->

/* uday replaced with below SQL to get execution order
 *
SELECT RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, t.plan_table_output
  FROM gv$sql v,
       TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
 WHERE v.sql_id = :sql_id
   AND v.loaded_versions > 0;
*/

DECLARE
   pragma autonomous_transaction;
   l_exec_order number;

    PROCEDURE assign_execution_order (
      p_inst_id         IN NUMBER,
      p_plan_hash_value IN NUMBER,
      p_child_number    IN NUMBER,
      p_id              IN NUMBER )
    IS
    BEGIN
      FOR j IN (SELECT id
                  FROM plan_table
                 WHERE 1 = 1
                   AND partition_id = p_inst_id
                   AND plan_id      = p_plan_hash_value
                   AND STATEMENT_ID = p_child_number
                   AND parent_id    = p_id
                   AND object_name  = :sql_id
                 -- ORDER BY position
                 ORDER BY (case when parent_id = 0 then position else null end) desc, position  -- PSRv10 to fix scalar subquery ordering
                 )
      LOOP
        assign_execution_order (
          p_inst_id         => p_inst_id,
          p_plan_hash_value => p_plan_hash_value,
          p_child_number    => p_child_number,
          p_id              => j.id );
      END LOOP;

      l_exec_order := l_exec_order + 1;

      UPDATE plan_table
         SET cardinality = l_exec_order
       WHERE 1 = 1
         AND partition_id = p_inst_id
         AND plan_id      = p_plan_hash_value
         AND STATEMENT_ID = p_child_number
         AND object_name  = :sql_id
         AND id = p_id;
    END assign_execution_order;

begin

  DELETE plan_table where STATEMENT_ID = :sql_id;
  commit;

  begin
/* uday.psr.v6 replaced with below 
    insert into plan_table 
            (partition_id, object_name, plan_id,         statement_id, id, parent_id, position, cardinality)
      select inst_id,      sql_id,      plan_hash_value, child_number, id, parent_id, position, -1 as exec_order 
        from gv$sql_plan 
       where sql_id = :sql_id
    ;
*/
    insert into plan_table 
            (partition_id, object_name, plan_id, statement_id, id, parent_id, position, cardinality)
      with plans as
      (
       select --+ materialize  
              * 
         from (
               select inst_id, sql_id, child_number, plan_hash_value, 
                      -- executions, 
                      -- round((elapsed_time/decode(nvl(executions, 0), 0, 1, executions))/1000000, 2)  avg_elatime,
                      -- round((buffer_gets/decode(nvl(executions, 0), 0, 1, executions)), 2) avg_bg,
                      row_number() over(partition by sql_id, plan_hash_value order by (case when inst_id = SYS_CONTEXT ('USERENV', 'INSTANCE') then 0 else 1 end), child_number) rn
                 from gv$sql 
                where sql_id = :sql_id
              ) v
        where rn=1   -- getting one plan per phv
      )
      -- uday psrv10 select sp.inst_id, sp.sql_id, sp.plan_hash_value, sp.child_number, id, parent_id, position, -1 as exec_order
      select inst_id, sql_id, plan_hash_value, child_number, id, parent_id, position, exec_order
        from (
              select sp.inst_id, sp.sql_id, sp.plan_hash_value, sp.child_number, 
                     nvl(skp.display_id, id) id, nvl(skp.parent_id, sp.parent_id) parent_id, 
                     position, -1 as exec_order
                     , skp.skipped
                from gv$sql_plan sp, plans,
                     -- uday psrv10 - below query to extract in 12c DB
                     (select p.inst_id, p.sql_id, p.child_number, p.plan_hash_value, xt.*
                        from gv$sql_plan p,
                             XMLTABLE('/other_xml/display_map/row'
                               PASSING xmltype(p.other_xml)
                               COLUMNS
                                 oper_id     number PATH '@op',      -- operation_id
                                 display_id  number PATH '@dis',     -- display_id
                                 parent_id   number PATH '@par',     -- parent_id
                                 part_id     number PATH '@prt',     -- partitioning display id
                                 depth       number PATH '@dep',     -- display depth
                                 skipped     number PATH '@skp'      -- whether to skip this in display
                               ) xt
                       where p.sql_id = :sql_id
                         and other_xml is not null) skp
               where plans.sql_id = sp.sql_id
                 and plans.inst_id = sp.inst_id
                 and plans.plan_hash_value = sp.plan_hash_value
                 and plans.child_number = sp.child_number
                 and skp.sql_id(+) = sp.sql_id
                 and skp.inst_id(+) = sp.inst_id
                 and skp.plan_hash_value(+) = sp.plan_hash_value
                 and skp.child_number(+) = sp.child_number
                 and skp.oper_id(+) = sp.id   -- uday psrv10 for 12c
             ) 
             where skipped = 0 or skipped is null   -- uday psrv10 for 12c skip plan lines that are not executed
    ;

    -- dbms_output.put_line('row count: ' || sql%rowcount);

  exception when others then
    raise_application_error(-20000, 'Please create plan_table using script: $ORACLE_HOME/rdbms/admin/utlxplan.sql');
  end;

  for cn in (select distinct partition_id inst_id, STATEMENT_ID as child_number from plan_table where object_name = :sql_id order by STATEMENT_ID)
  loop
    FOR i IN (SELECT 
                     partition_id inst_id,
                     plan_id      plan_hash_value,
                     STATEMENT_ID child_number,
                     id
                FROM plan_table
               WHERE STATEMENT_ID = cn.child_number
                 and partition_id = cn.inst_id
                 AND object_name = :sql_id
                 AND parent_id IS NULL)
    LOOP
      l_exec_order := 0;

      assign_execution_order (
        p_inst_id         => i.inst_id,
        p_plan_hash_value => i.plan_hash_value,
        p_child_number    => i.child_number,
        p_id              => i.id );
    END LOOP;
  END LOOP;
  COMMIT;

end;
/

-- set termout on

--
--Uday.PSR.v6: Now getting unique plans, and getting from local instance whenever available (see order by clause of analytical function below)
--
With s as
(
 select rownum rn, 
        t.plan_table_output, 
        v.inst_id, v.child_number, v.plan_hash_value phv,
        RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child
   -- FROM gv$sql v,
   FROM 
        (
          select * 
            from (
                  select inst_id, sql_id, child_number, plan_hash_value, executions, 
                         round((elapsed_time/decode(nvl(executions, 0), 0, 1, executions))/1000000, 2)  avg_elatime,
                         round((buffer_gets/decode(nvl(executions, 0), 0, 1, executions)), 2) avg_bg,
                         row_number() over(partition by sql_id, plan_hash_value 
                                               order by (case when inst_id = SYS_CONTEXT ('USERENV', 'INSTANCE') then 0 else 1 end), child_number) rn
                    from gv$sql 
                   where sql_id = :sql_id
                     AND loaded_versions > 0
        ) v
        where rn=1
        ) v,
        TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
		WHERE t.plan_table_output NOT in ('-------------------------------------------------------------',
	                                      '-------------','--------------------------------------',
	                                      '---------------------------------------------------',
								          '-----------------------------------------------------------',
										  '-----', '---------------------')
		  AND NOT regexp_like (t.plan_table_output, '(<q|q>|CDATA)')
)
, p as
  (     -- pline_id: extracting plan id column from plan_table_output
       select rn, phv, to_number(case when regexp_like (plan_table_output,'^[|][*]? *([0-9]+) *[|].*[|]$') then
                 regexp_replace(plan_table_output,'^[|][*]? *([0-9]+) *[|].*[|]$','\1')
                 END) pline_ID
              , child_number child#
              , plan_table_output
              , inst_id
              , inst_child
         from s
  )
, po as
     (-- here we are printing child# on all lines
      select rn, phv, child# child_orig
             , pline_ID
             ,  max(pline_ID) over(partition by inst_id, phv, child#) max_pline_id
             ,  max(child#) over(partition by inst_id, phv, child#) child#
             , plan_table_output
             , inst_id
             , inst_child
        from p
     )
, ef as (select rn, inst_id, phv, child_orig, child#, rn-3 firstl from po where pline_id = 0 ) -- first line of the exec plan
, el as (select rn, inst_id, phv, child_orig, child#, pline_id, rn+1 lastl from po where (inst_id, pline_id, child_orig) in (select distinct inst_id, max_pline_id, child_orig from po )) -- last line of the exec plan
, pre_fmt as 
 (  
  select regexp_replace(
         substr(po.plan_table_output, 1, 7) ||
         case when ef.firstl = po.rn then   '--------'  -- first line
              when ef.firstl+1 = po.rn then ' exeOrd|'  -- 2nd line
              when ef.firstl+2 = po.rn then '--------'  -- 3rd line
              when po.rn between ef.firstl+3 and el.lastl-1 then ' ' || lpad(pt.cardinality, 5, ' ')||' |'  -- cardinality is execution order
              when el.lastl    = po.rn then   '--------' -- last line
         end ||
         substr(po.plan_table_output, 8)
         , '(Plan hash value: [[:digit:]]+)', chr(10)||chr(10)|| po.inst_child|| '\1' ) as plan_table_output
    from po, plan_table pt, ef, el
   where pt.id(+) = po.pline_id
     and pt.STATEMENT_ID(+) = po.child#
     and pt.partition_id(+) = po.inst_id
     and pt.object_name(+) = :sql_id
     and ef.child# = el.child#
     and ef.inst_id = el.inst_id
     and ef.child# = po.child#
     and ef.inst_id = po.inst_id
     and el.child# = po.child#
     and el.inst_id = po.inst_id
   order by po.rn
 )
 select 
     case 
		   when rownum = 1                                                then '<pre>'||t.plan_table_output
 			 when t.plan_table_output like '%Inst:%'                        then '</pre></details><details open><summary ID="summary3">'||t.plan_table_output||'</summary><pre>'        
			 when t.plan_table_output like 'Query Block Name%'              then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>' 
			 when t.plan_table_output like 'Outline Data%'                  then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
			 when t.plan_table_output like 'Peeked Binds%'                  then '</pre></details><details open><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
			 when t.plan_table_output like 'Predicate Information%'         then '</pre></details><details open><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'   
			 when t.plan_table_output like 'Column Projection Information%' then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
       when t.plan_table_output like 'Hint Report%'                   then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  		
       when t.plan_table_output like 'Query Block Registry%'          then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'        
       when t.plan_table_output like 'Note%'                          then '</pre></details><details open><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  			 
       when t.plan_table_output like '% FULL%'                        then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'         
       when t.plan_table_output like '% CARTESIAN%'                   then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'  
       when t.plan_table_output like '%SKIP%'                         then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'              
--       when t.plan_table_output like '%HASH%'                         then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'              
       when t.plan_table_output like '%COLLECTION%ITERATOR%'          then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'                  
	     else t.plan_table_output
		end || lead (NULL,1,chr(10)||'</pre>') over (ORDER BY rownum) as plan_table_output
 from pre_fmt t
;

PRO </details>
select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * DBMS_XPLAN.DISPLAY_CURSOR OUTLINE ALLSTATS
 *
 * ------------------------- */
PRO <a name="mem_plans_all"></a><details open><br/><summary id="summary2">Current Execution Plans (all executions)</summary>
PRO
PRO Captured while still in memory. Metrics below are an aggregate for all the execution of each child cursor.<br>
PRO If STATISTICS_LEVEL was set to ALL at the time of the hard-parse then A-Rows column is populated.
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->


/* uday: replaced with below sql to get execution order
 *
SELECT RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, t.plan_table_output
  FROM gv$sql v,
       TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS', 'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
 WHERE v.sql_id = :sql_id
   AND v.loaded_versions > 0
   AND v.executions > 1;
*/


With s as
(
 select rownum rn, 
        t.plan_table_output,
        v.inst_id, v.child_number, v.plan_hash_value phv,
        RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child
   FROM gv$sql v,
        TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS', 'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t
  WHERE v.sql_id = :sql_id
    AND t.plan_table_output NOT in ('-------------------------------------------------------------',
	                                '-------------','--------------------------------------',
	                                '---------------------------------------------------',
									'-----------------------------------------------------------',
									'-----', '---------------------')
		AND NOT regexp_like (t.plan_table_output, '(<q|q>|CDATA)')
    AND v.loaded_versions > 0
)
, p as
  (     -- pline_id: extracting plan id column from plan_table_output
       select rn, phv, to_number(case when regexp_like (plan_table_output,'^[|][*]? *([0-9]+) *[|].*[|]$') then
                 regexp_replace(plan_table_output,'^[|][*]? *([0-9]+) *[|].*[|]$','\1')
                 END) pline_ID
              , child_number child#
              , plan_table_output
              , inst_id
              , inst_child
         from s
  )
, po as
     (-- here we are printing child# on all lines
      select rn, phv, child# child_orig
             , pline_ID
             ,  max(pline_ID) over(partition by inst_id, phv, child#) max_pline_id
             ,  max(child#) over(partition by inst_id, phv, child#) child#
             , plan_table_output
             , inst_id
             , inst_child
        from p
     )
, ef as (select rn, inst_id, phv, child_orig, child#, rn-3 firstl from po where pline_id = 0 ) -- first line of the exec plan
, el as (select rn, inst_id, phv, child_orig, child#, pline_id, rn+1 lastl from po where (inst_id, pline_id, child_orig) in (select distinct inst_id, max_pline_id, child_orig from po )) -- last line of the exec plan
, pre_fmt as 
 (  
  select regexp_replace(
         substr(po.plan_table_output, 1, 7) ||
         case when ef.firstl = po.rn then   '--------'  -- first line
              when ef.firstl+1 = po.rn then ' exeOrd|'  -- 2nd line
              when ef.firstl+2 = po.rn then '--------'  -- 3rd line
              when po.rn between ef.firstl+3 and el.lastl-1 then ' ' || lpad(pt.cardinality, 5, ' ')||' |'  -- cardinality is execution order
              when el.lastl    = po.rn then   '--------' -- last line
         end ||
         substr(po.plan_table_output, 8)
         , '(Plan hash value: [[:digit:]]+)', chr(10)||chr(10)|| po.inst_child|| '\1' ) as plan_table_output
    from po, plan_table pt, ef, el
   where pt.id(+) = po.pline_id
     and pt.STATEMENT_ID(+) = po.child#
     and pt.partition_id(+) = po.inst_id
     AND object_name(+) = :sql_id
     and ef.child# = el.child#
     and ef.inst_id = el.inst_id
     and ef.child# = po.child#
     and ef.inst_id = po.inst_id
     and el.child# = po.child#
     and el.inst_id = po.inst_id
   order by po.rn
 )
 select 
     case 
		   when rownum = 1                                                then '<pre>'||t.plan_table_output
		   when regexp_count(t.plan_table_output,'^SQL_ID')> 0            then '</pre></details><details open><summary ID="summary3">'||'Next plan'||'</summary><pre>'||t.plan_table_output       
 			 when t.plan_table_output like '%Inst:%'                        then '</pre></details><details open><summary ID="summary3">'||t.plan_table_output||'</summary><pre>'        
			 when t.plan_table_output like 'Query Block Name%'              then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>' 
			 when t.plan_table_output like 'Outline Data%'                  then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
			 when t.plan_table_output like 'Peeked Binds%'                  then '</pre></details><details open><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
			 when t.plan_table_output like 'Predicate Information%'         then '</pre></details><details open><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'   
			 when t.plan_table_output like 'Column Projection Information%' then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
       when t.plan_table_output like 'Hint Report%'                   then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  		
       when t.plan_table_output like 'Query Block Registry%'          then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'        
       when t.plan_table_output like 'Note%'                          then '</pre></details open><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  			 
       when t.plan_table_output like '% FULL%'                        then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'         
       when t.plan_table_output like '% CARTESIAN%'                   then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'  
       when t.plan_table_output like '%SKIP%'                         then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'              
--       when t.plan_table_output like '%HASH%'                         then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'              
       when t.plan_table_output like '%COLLECTION%ITERATOR%'          then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'                  
	     else t.plan_table_output
		end || lead (NULL,1,chr(10)||'</pre>') over (ORDER BY rownum) as plan_table_output
 from pre_fmt t
;

PRO </details>
select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

/* -------------------------
 *
 * DBMS_XPLAN.DISPLAY_AWR OUTLINE
 *
 * ------------------------- */
PRO <a name="awr_plans"></a><details open><br/><summary id="summary2">Historical Execution Plans</summary>
PRO
PRO This section includes data captured by AWR. If this is a stand-by read-only database then the AWR information below is from the Primary database.
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->


/* uday: replaced with below plsql and sql to get execution plan 
SELECT t.plan_table_output
  FROM (SELECT DISTINCT sql_id, plan_hash_value, dbid
          FROM dba_hist_sql_plan WHERE :license IN ('T', 'D') AND dbid = ^^dbid. AND sql_id = :sql_id) v,
       TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED')) t;
*/

DECLARE
   pragma autonomous_transaction;
   l_exec_order number;

    PROCEDURE assign_execution_order (
      p_plan_hash_value IN NUMBER,
      p_id              IN NUMBER )
    IS
    BEGIN
      FOR j IN (SELECT id
                  FROM plan_table
                 WHERE 1 = 1
                   AND plan_id      = p_plan_hash_value
                   AND parent_id    = p_id
                   AND object_name  = :sql_id
                 -- ORDER BY position
                 ORDER BY (case when parent_id = 0 then position else null end) desc, position  -- PSRv10 to fix scalar subquery ordering
                 )
      LOOP
        assign_execution_order (
          p_plan_hash_value => p_plan_hash_value,
          p_id              => j.id );
      END LOOP;

      l_exec_order := l_exec_order + 1;


      UPDATE plan_table
         SET cardinality = l_exec_order
       WHERE 1 = 1
         AND object_name  = :sql_id
         AND plan_id      = p_plan_hash_value
         AND id = p_id;

      -- dbms_output.put_line('rows updated: ' || sql%rowcount || ' l_exec_order: ' || l_exec_order || ' plan/id: ' || p_plan_hash_value || '/'|| p_id);
    END assign_execution_order;

begin

  DELETE plan_table where object_name = :sql_id;
  commit;

  begin
    insert into plan_table 
            (object_name, plan_id, id, parent_id, position, cardinality)
      -- 
      -- uday psrv10 
      --   select sql_id, plan_hash_value,  id,               parent_id,                  position, -1 as exec_order 
      select sql_id, plan_hash_value, id, parent_id, position, exec_order
        from (
               select sp.sql_id, sp.plan_hash_value, 
                      nvl(skp.display_id, id) id, nvl(skp.parent_id, sp.parent_id) parent_id, 
                      position, -1 as exec_order
                      , skp.skipped
                 from dba_hist_sql_plan sp,
                      -- uday psrv10 - below query to extract in 12c DB
                      (select p.sql_id, p.plan_hash_value, xt.*
                         from dba_hist_sql_plan p,    
                              XMLTABLE('/other_xml/display_map/row'
                                PASSING xmltype(p.other_xml)
                                COLUMNS 
                                  oper_id     number PATH '@op',      -- operation_id
                                  display_id  number PATH '@dis',     -- display_id
                                  parent_id   number PATH '@par',     -- parent_id
                                  part_id     number PATH '@prt',     -- partitioning display id
                                  depth       number PATH '@dep',     -- display depth
                                  skipped     number PATH '@skp'      -- whether to skip this in display
                                ) xt
                        where :license IN ('T', 'D') 
                          and p.dbid = ^^dbid. 
                          and p.sql_id = :sql_id
                          and p.other_xml is not null
                      ) skp
                where :license IN ('T', 'D') 
                  and sp.dbid = ^^dbid. 
                  and sp.sql_id = :sql_id
                  and skp.sql_id(+) = sp.sql_id
                  and skp.plan_hash_value(+) = sp.plan_hash_value
                  and skp.oper_id(+) = sp.id   --uday psrv10 for 12c
             ) 
             where skipped = 0 or skipped is null   -- uday psrv10 for 12c skip plan lines that are not executed
    ;

  exception when others then
    raise_application_error(-20000, 'Please create plan_table using script: $ORACLE_HOME/rdbms/admin/utlxplan.sql');
  end;

  for cn in (select distinct plan_id plan_hash_value from plan_table where object_name = :sql_id order by plan_id)
  loop
    FOR i IN (SELECT 
                     plan_id      plan_hash_value,
                     id
                FROM plan_table
               WHERE plan_id = cn.plan_hash_value
                 AND object_name = :sql_id
                 AND parent_id IS NULL)
    LOOP
      l_exec_order := 0;

      assign_execution_order (
        p_plan_hash_value => i.plan_hash_value,
        p_id              => i.id );
    END LOOP;
  END LOOP;
  COMMIT;

end;
/

With s as
(
 select rownum rn, 
        t.plan_table_output,
        v.plan_hash_value phv
  FROM (SELECT DISTINCT sql_id, plan_hash_value, dbid
          FROM dba_hist_sql_plan 
         WHERE :license IN ('T', 'D') 
           AND dbid = ^^dbid. 
           AND sql_id = :sql_id
       ) v,
       TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED')) t
	   WHERE t.plan_table_output NOT in ('-------------------------------------------------------------',
	                                     '-------------','--------------------------------------',
	                                     '---------------------------------------------------',
									     '-----------------------------------------------------------',
										 '-----', '---------------------')
		   AND NOT regexp_like (t.plan_table_output, '(<q|q>|CDATA)')
)
, p as 
  (     -- pline_id: extracting plan id column from plan_table_output
        --
       select rn, to_number(case when regexp_like (plan_table_output,'^[|][*]? *([0-9]+) *[|].*[|]$') then
              regexp_replace(plan_table_output,'^[|][*]? *([0-9]+) *[|].*[|]$','\1')
                END) pline_ID
              , plan_table_output
              , phv
         from s
  )
, po as
     (
      select rn, pline_ID, plan_table_output, phv
       from p 
     )
, ef as (select phv, rn-3 firstl from po where pline_id = 0 ) -- first line of the exec plan
, el as (select phv, rn+1 lastl from po where (phv, pline_id) in (select phv, max(pline_id) from po group by phv)) -- last line of the exec plan
, pre_fmt as 
 (  
   select 
         substr(po.plan_table_output, 1, 7) ||
         case when ef.firstl = rn then   '--------'  -- first line
              when ef.firstl+1 = rn then ' exeOrd|'  -- 2nd line
              when ef.firstl+2 = rn then '--------'  -- 3rd line
              when rn between firstl+3 and lastl-1 then ' ' || lpad(pt.cardinality, 5, ' ')||' |'  -- cardinality is execution order
              when el.lastl    = rn then   '--------' -- last line
         end ||
         substr(po.plan_table_output, 8) as plan_table_output
    from po, plan_table pt, ef, el
   where pt.id(+) = po.pline_id
     and pt.plan_id(+) = po.phv
     and pt.object_name(+) = :sql_id
     and ef.phv = el.phv
     and ef.phv = po.phv
     and el.phv = po.phv
   order by po.rn
 )
 select 
     case 
		   when rownum = 1                                                then '<pre>'||t.plan_table_output
		   when regexp_count(t.plan_table_output,'^SQL_ID')> 0            then '</pre></details><details open><summary ID="summary3">'||'Next plan'||'</summary><pre>'||t.plan_table_output       
 			 when t.plan_table_output like '%Inst:%'                        then '</pre></details><details open><summary ID="summary3">'||t.plan_table_output||'</summary><pre>'        
			 when t.plan_table_output like 'Query Block Name%'              then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>' 
			 when t.plan_table_output like 'Outline Data%'                  then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
			 when t.plan_table_output like 'Peeked Binds%'                  then '</pre></details><details open><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
			 when t.plan_table_output like 'Predicate Information%'         then '</pre></details><details open><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'   
			 when t.plan_table_output like 'Column Projection Information%' then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  
       when t.plan_table_output like 'Hint Report%'                   then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  		
       when t.plan_table_output like 'Query Block Registry%'          then '</pre></details><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'        
       when t.plan_table_output like 'Note%'                          then '</pre></details open><details><summary ID="summary4">'||t.plan_table_output||'</summary><pre>'  			 
       when t.plan_table_output like '% FULL%'                        then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'         
       when t.plan_table_output like '% CARTESIAN%'                   then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'  
       when t.plan_table_output like '%SKIP%'                         then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'              
--       when t.plan_table_output like '%HASH%'                         then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'              
       when t.plan_table_output like '%COLLECTION%ITERATOR%'          then '<mark ID="mark_fmt">'||t.plan_table_output||'</mark>'                  
	     else t.plan_table_output
		end || lead (NULL,1,chr(10)||'</pre>') over (ORDER BY rownum) as plan_table_output
 from pre_fmt t
;

PRO </details>
select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

--KDRUPARE AH-3084 Beg
/* -------------------------
 *
 * DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE
 *
 * ------------------------- */
PRO <a name="baseline_plans"></a><details open><br/><summary id="summary2">Baseline Execution Plans</summary>
PRO
PRO
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- Please Wait -->
PRO

PRO <pre>
SELECT t.plan_table_output
  FROM (SELECT DISTINCT sql_handle
          FROM dba_sql_plan_baselines WHERE :license IN ('T', 'D') 
		  AND signature IN (SELECT exact_matching_signature FROM gv$sql WHERE sql_id = :sql_id)) v,
       TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE(v.sql_handle)) t;
PRO </pre>


PRO <br>
PRO </details>
select round((sysdate-to_date(:start_time,'dd-mon-rr hh24:mi:ss'))*86400) diff from dual;
PRO <table style="width:100%"><tr><td style="text-align:right; background-color:#ffffff">Time taken: ^^diff. seconds</td></tr></table>
exec :start_time := to_char(sysdate,'dd-mon-rr hh24:mi:ss');

--KDRUPARE AH-3084 End


/* -------------------------
 *
 * footer
 *
 * ------------------------- */
PRO
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <hr size="3">
PRO <font class="f">^^mos_doc. ^^method. ^^doc_ver. ^^time_stamp2.</font>
PRO </body>
PRO </html>

SPO OFF;

/**************************************************************************************************/

/**************************************************************************************************
 *
 * 11g sql detail report
 *
 **************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: SQL Detail Report - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO 11g SQL Detail Report
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait

VAR det CLOB;
EXEC :det := 'SQL Detail Report is available on 11.2 and higher';

set serveroutput on 
SPO ^^files_prefix._4_sql_detail.html;
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
PRO <!-- begin DBMS_SQLTUNE.REPORT_SQL_DETAIL
DECLARE
  l_start_time DATE := NULL;
  l_end_time DATE := NULL;
  l_duration NUMBER := NULL;
  l_det clob := 'SQL Detail Report is available on 11.2 and higher';
  l_sql_id varchar2(13) := :sql_id;
BEGIN
  DBMS_LOB.CREATETEMPORARY(:det, TRUE);
  -- IF :minsnap is not null and :maxsnap is not null  -- PSRv8
  IF :minsnap <> -1 and :maxsnap <> -1 
  THEN
    select least(min(mi.begin_interval_time), min(sample_time)) mint, 
           greatest(max(mx.end_interval_time), max(sample_time)) maxt,
           ((cast(greatest(max(mx.end_interval_time), max(sample_time)) as date) - cast(least(min(mi.begin_interval_time), min(sample_time)) as date))  * 24 * 3600) dura1 
      into l_start_time, l_end_time, l_duration
      from dba_hist_snapshot mi, dba_hist_snapshot mx, gv$active_session_history ash
     where mi.snap_id = :minsnap
       and mi.dbid = ^^dbid.
       and mx.snap_id = :maxsnap
       and mx.dbid = ^^dbid.
       and ash.sql_id = :sql_id
    ;
  ELSE
    select min(sample_time) mint, 
           max(sample_time) maxt, 
           ((cast(max(sample_time) as date) - cast(min(sample_time) as date)) * 24 * 3600) dura1 
      into l_start_time, l_end_time, l_duration
      from gv$active_session_history ash
     where ash.sql_id = :sql_id
    ;
  END IF;

  IF l_start_time is not null and DBMS_DB_VERSION.version < 12 THEN
    l_duration := GREATEST(NVL(l_duration, 0), 24 * 3600); -- at least 1 day

    :det := DBMS_SQLTUNE.REPORT_SQL_DETAIL(
       sql_id       => :sql_id,
       start_time   => l_start_time,
       duration     => l_duration,
       report_level => 'ALL',
       type         => 'ACTIVE' );

  END IF;

  IF DBMS_DB_VERSION.version > 11 and l_start_time is not null THEN

    $IF DBMS_DB_VERSION.version > 11
    $THEN
       begin
        l_det := DBMS_PERF.REPORT_SQL (
           sql_id       => l_sql_id,
           is_realtime  => 0,
           outer_start_time   => l_start_time,
           outer_end_time     => l_end_time,
           selected_start_time=> l_start_time,
           selected_end_time  => l_end_time,
           inst_id            => null,
           dbid               => ^^dbid.,
           monitor_list_detail=> 5,
           report_reference   => null,
           report_level => 'typical',
           type         => 'ACTIVE' );
       end;
    $END
    NULL;
    :det := l_det;
  END IF;
END;
/
rem PRO end -->
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
SELECT :det FROM DUAL;
SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
SPO OFF;

/**************************************************************************************************/

/**************************************************************************************************
 *
 * 11g sql monitor report
 *
 **************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: SQL Monitor Report - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO SQL Monitor Report
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait

SPO ^^files_prefix._5_sql_monitor.sql;
PRO -- SQL Monitor Report for ^^sql_id.

DECLARE
  l_count NUMBER := 0;
  TYPE mon_rt IS RECORD (
    sql_exec_start DATE,
    file_name varchar2(20),
    sql_exec_id NUMBER,
    sql_plan_hash_value NUMBER,
    inst_id NUMBER,
    elapsed_time number,
    rank_by_start number,
    rank_by_elapsed_desc number,
    rank_by_elapsed_asc number
   );
  mon_rec mon_rt;
  mon_cv SYS_REFCURSOR;

    --PSRv10
    PROCEDURE print_commands (
        mon_rec IN mon_rt
      , p_rpt_typ IN varchar2
    )
    IS
    BEGIN

      DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_start := '''||TO_CHAR(mon_rec.sql_exec_start, 'YYYYMMDDHH24MISS')||''';');
      DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_id := '||TO_CHAR(mon_rec.sql_exec_id)||';');
      DBMS_OUTPUT.PUT_LINE('EXEC :mon_sql_plan_hash_value := '||TO_CHAR(mon_rec.sql_plan_hash_value)||';');
      DBMS_OUTPUT.PUT_LINE('EXEC :mon_inst_id := '||TO_CHAR(mon_rec.inst_id)||';');
      DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||mon_rec.file_name||'_'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_sql_monitor'||case when p_rpt_typ = 'ACTIVE' then '.html;' when p_rpt_typ = 'TEXT' then '.txt;' end);
      -- DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
      -- DBMS_OUTPUT.PUT_LINE('PRO <!-- begin DBMS_SQLTUNE.REPORT_SQL_MONITOR');
      DBMS_OUTPUT.PUT_LINE('BEGIN');

      IF DBMS_DB_VERSION.version > 11 THEN -- PSRv7

        $IF DBMS_DB_VERSION.version > 11
        $THEN
          DBMS_OUTPUT.PUT_LINE('  :mon_report := DBMS_SQL_MONITOR.report_sql_monitor(');
        $END
        NULL; -- PSRv8
      ELSE
        DBMS_OUTPUT.PUT_LINE('  :mon_report := DBMS_SQLTUNE.REPORT_SQL_MONITOR (');
      END IF;
      DBMS_OUTPUT.PUT_LINE('    sql_id         => :mon_sql_id,');
      DBMS_OUTPUT.PUT_LINE('    sql_exec_start => TO_DATE(:mon_exec_start, ''YYYYMMDDHH24MISS''),');
      DBMS_OUTPUT.PUT_LINE('    sql_exec_id    => :mon_exec_id,');
      DBMS_OUTPUT.PUT_LINE('    report_level   => ''ALL'',');
      DBMS_OUTPUT.PUT_LINE('    type           => '''||p_rpt_typ||''' );');
      DBMS_OUTPUT.PUT_LINE('END;');
      DBMS_OUTPUT.PUT_LINE('/');
      --DBMS_OUTPUT.PUT_LINE('PRO end -->');
      DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');

      IF '^^rdbms_version.' LIKE '11.1%' THEN
        DBMS_OUTPUT.PUT_LINE('PRO <html>');
        DBMS_OUTPUT.PUT_LINE('PRO <head>');
        DBMS_OUTPUT.PUT_LINE('PRO  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>');
        DBMS_OUTPUT.PUT_LINE('PRO  <base href="http://download.oracle.com/otn_software/"/>');
        DBMS_OUTPUT.PUT_LINE('PRO  <script language="javascript" type="text/javascript" src="emviewers/scripts/flashver.js">');
        DBMS_OUTPUT.PUT_LINE('PRO   <!--Test flash version-->');
        DBMS_OUTPUT.PUT_LINE('PRO  </script>');
        DBMS_OUTPUT.PUT_LINE('PRO  <style>');
        DBMS_OUTPUT.PUT_LINE('PRO      body { margin: 0px; overflow:hidden }');
        DBMS_OUTPUT.PUT_LINE('PRO    </style>');
        DBMS_OUTPUT.PUT_LINE('PRO </head>');
        DBMS_OUTPUT.PUT_LINE('PRO <body scroll="no">');
        DBMS_OUTPUT.PUT_LINE('PRO  <script type="text/xml">');
        DBMS_OUTPUT.PUT_LINE('PRO   <!--FXTMODEL-->');
      END IF;

      DBMS_OUTPUT.PUT_LINE('SELECT :mon_report FROM DUAL;');

      IF '^^rdbms_version.' LIKE '11.1%' THEN
        DBMS_OUTPUT.PUT_LINE('PRO    <!--FXTMODEL-->');
        DBMS_OUTPUT.PUT_LINE('PRO   </script>');
        DBMS_OUTPUT.PUT_LINE('PRO   <script language="JavaScript" type="text/javascript" src="emviewers/scripts/loadswf.js">');
        DBMS_OUTPUT.PUT_LINE('PRO    <!--Load report viewer-->');
        DBMS_OUTPUT.PUT_LINE('PRO   </script>');
        DBMS_OUTPUT.PUT_LINE('PRO   <iframe name="_history" frameborder="0" scrolling="no" width="22" height="0">');
        DBMS_OUTPUT.PUT_LINE('PRO    <html>');
        DBMS_OUTPUT.PUT_LINE('PRO     <head>');
        DBMS_OUTPUT.PUT_LINE('PRO      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>');
        DBMS_OUTPUT.PUT_LINE('PRO      <script type="text/javascript" language="JavaScript1.2" charset="utf-8">');
        DBMS_OUTPUT.PUT_LINE('PRO                 var v = new top.Vars(top.getSearch(window)); <!-- ; -->');
        DBMS_OUTPUT.PUT_LINE('PRO                 var fv = v.toString("$_"); <!-- ; -->');
        DBMS_OUTPUT.PUT_LINE('PRO               </script>');
        DBMS_OUTPUT.PUT_LINE('PRO     </head>');
        DBMS_OUTPUT.PUT_LINE('PRO     <body>');
        DBMS_OUTPUT.PUT_LINE('PRO      <script type="text/javascript" language="JavaScript1.2" charset="utf-8" src="emviewers/scripts/document.js">');
        DBMS_OUTPUT.PUT_LINE('PRO       <!--Run document script-->');
        DBMS_OUTPUT.PUT_LINE('PRO      </script>');
        DBMS_OUTPUT.PUT_LINE('PRO     </body>');
        DBMS_OUTPUT.PUT_LINE('PRO    </html>');
        DBMS_OUTPUT.PUT_LINE('PRO   </iframe>');
        DBMS_OUTPUT.PUT_LINE('PRO  </body>');
        DBMS_OUTPUT.PUT_LINE('PRO </html>');
      END IF;

      DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
      DBMS_OUTPUT.PUT_LINE('SPO OFF;');
    END print_commands;
BEGIN
  IF :license = 'T' AND '^^rdbms_version.' >= '11' THEN
    DBMS_OUTPUT.PUT_LINE('VAR mon_exec_start VARCHAR2(14);');
    DBMS_OUTPUT.PUT_LINE('VAR mon_exec_id NUMBER;');
    DBMS_OUTPUT.PUT_LINE('VAR mon_sql_plan_hash_value NUMBER;');
    DBMS_OUTPUT.PUT_LINE('VAR mon_inst_id NUMBER;');
    DBMS_OUTPUT.PUT_LINE('VAR mon_report CLOB;');
    DBMS_OUTPUT.PUT_LINE('VAR mon_sql_id VARCHAR2(13);');
    DBMS_OUTPUT.PUT_LINE('EXEC :mon_sql_id := ''^^sql_id.'';');
    DBMS_OUTPUT.PUT_LINE('SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF;');

    -- cursor variable to avoid error on 10g since v$sql_monitor didn't exist then
--Uday.Replaced with below.v6    OPEN mon_cv FOR
--Uday.Replaced with below.v6      'SELECT DISTINCT '||
--Uday.Replaced with below.v6      '       sql_exec_start, '||
--Uday.Replaced with below.v6      '       sql_exec_id, '||
--Uday.Replaced with below.v6      '       sql_plan_hash_value, '||
--Uday.Replaced with below.v6      '       inst_id '||
--Uday.Replaced with below.v6      '  FROM gv$sql_monitor /* 11g */ '||
--Uday.Replaced with below.v6      ' WHERE process_name = ''ora'' '||
--Uday.Replaced with below.v6      '   AND sql_id = ''^^sql_id.'' '||
--Uday.Replaced with below.v6      ' ORDER BY '||
--Uday.Replaced with below.v6      '       1, '||
--Uday.Replaced with below.v6      '       2';
    OPEN mon_cv FOR
       q'[
       select * from (
       SELECT distinct
              sql_exec_start,
              to_char(sql_exec_start, 'ddmon_hh24mmss'),
              sql_exec_id,
              sql_plan_hash_value,
              inst_id
              , elapsed_time/1000000 elapsed_time
              , rank() over(partition by sql_plan_hash_value order by sql_exec_start desc) rank_by_start
              , rank() over(partition by sql_plan_hash_value order by elapsed_time desc) rank_by_elapsed_desc
              , rank() over(partition by sql_plan_hash_value order by elapsed_time) rank_by_elapsed_asc  -- PSRv10
         FROM gv$sql_monitor 
        WHERE process_name = 'ora'
          AND sql_id = :sql_id
       )
        -- where rank_by_start <= 2 or rank_by_elapsed = 1
        where rank_by_start <= 2 or rank_by_elapsed_desc <= 2 or rank_by_elapsed_asc <= 2 -- PSRv10
        -- ORDER BY 3, 1 desc, 2
        ORDER BY sql_plan_hash_value, sql_exec_start desc, sql_exec_id
      ]' using :sql_id;

    LOOP
      FETCH mon_cv INTO mon_rec;
      EXIT WHEN mon_cv%NOTFOUND;

      l_count := l_count + 1;
      IF l_count > ^^sql_monitor_reports. THEN
        EXIT; -- exits loop
      END IF;
      print_commands(mon_rec, 'ACTIVE'); -- PSRv10
      print_commands(mon_rec, 'TEXT');   -- PSRv10

    END LOOP;
    CLOSE mon_cv;
  ELSE
    DBMS_OUTPUT.PUT_LINE('-- SQL Monitor Reports are available on 11.1 and higher, and they are part of the Oracle Tuning pack.');
  END IF;
END;
/

SPO OFF;

PRO SQL Monitor Report from AWR
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait

SPO ^^files_prefix._5_sql_monitor.sql append;
PRO -- SQL Monitor Report for ^^sql_id.

DECLARE
  l_count NUMBER := 0;
  TYPE mon_rt IS RECORD (
    sql_exec_start DATE,
    file_name varchar2(20),
    report_id NUMBER,
    sql_exec_id NUMBER,
    sql_plan_hash_value NUMBER,
    inst_id NUMBER,
    elapsed_time number,
    rank_by_start number,
    rank_by_elapsed_desc number,
    rank_by_elapsed_asc number
   );
  mon_rec mon_rt;
  mon_cv SYS_REFCURSOR;
BEGIN
  IF :license = 'T' 
  THEN
    $IF DBMS_DB_VERSION.version > 11
    $THEN

      DBMS_OUTPUT.PUT_LINE('VAR mon_exec_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_plan_hash_value NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_inst_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report CLOB;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_id VARCHAR2(13);');
      DBMS_OUTPUT.PUT_LINE('SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF;');


      OPEN mon_cv FOR
         q'~
            with awr_sql_monitor as
            (
              SELECT report_id, instance_number, key1 sql_id, key2 sql_exec_id, to_date(key3, 'MM/DD/YYYY HH24:MI:SS')  sql_exec_start
                     , to_number(regexp_substr(report_summary, q'{<stat name="elapsed_time">([[:digit:]]+)</stat>}', 1, 1, null, 1)) elapsed_time
                     , regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1)  phv
                FROM dba_hist_reports
               WHERE component_name = 'sqlmonitor'
                 AND key1 = '^^sql_id'
                 --  and EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/plan_hash') not in
                 --  PSRv9.1
                 -- and regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1) in 
                 --     (
                 --      SELECT distinct sql_plan_hash_value
                 --        FROM gv$sql_monitor
                 --       WHERE process_name = 'ora'
                 --         AND sql_id = '^^sql_id'
                 --     )
            )
            , awr_sql_monitor2 as 
            (
            select distinct 
                          sql_exec_start,
                          to_char(sql_exec_start, 'ddmon_hh24mmss'),
                          report_id,
                          sql_exec_id,
                          phv,
                          instance_number
                          , elapsed_time/1000000 elapsed_time
                          , rank() over(partition by phv order by sql_exec_start desc) rank_by_start
                          , rank() over(partition by phv order by elapsed_time desc) rank_by_elapsed_desc
                          , rank() over(partition by phv order by elapsed_time) rank_by_elapsed_asc  -- PSRv9.1
              from awr_sql_monitor
            )
            select *
              from awr_sql_monitor2
             where rank_by_start <= 2 or rank_by_elapsed_desc <= 2 or rank_by_elapsed_asc <= 2 -- PSRv9.1
             ORDER BY phv, sql_exec_start desc, sql_exec_id
        ~';

      LOOP
        FETCH mon_cv INTO mon_rec;
        EXIT WHEN mon_cv%NOTFOUND;

        l_count := l_count + 1;
        IF l_count > ^^sql_monitor_reports. THEN
          EXIT; -- exits loop
        END IF;

        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_start := '''||TO_CHAR(mon_rec.sql_exec_start, 'YYYYMMDDHH24MISS')||''';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_report_id := '||TO_CHAR(mon_rec.report_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_id := '||TO_CHAR(mon_rec.sql_exec_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_sql_plan_hash_value := '||TO_CHAR(mon_rec.sql_plan_hash_value)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_inst_id := '||TO_CHAR(mon_rec.inst_id)||';');
        DBMS_OUTPUT.PUT_LINE('--============');
        -- DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||mon_rec.file_name||'_'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- begin DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL -->');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  :mon_report := DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(');
        DBMS_OUTPUT.PUT_LINE('    rid  => :mon_report_id,');
        DBMS_OUTPUT.PUT_LINE('    type => ''ACTIVE'' );');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- end -->');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');

        DBMS_OUTPUT.PUT_LINE('SELECT :mon_report FROM DUAL;');

        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        DBMS_OUTPUT.PUT_LINE('SPO OFF;');
        DBMS_OUTPUT.PUT_LINE('--============');
      END LOOP;
      CLOSE mon_cv;
    $END
    NULL;
  END IF;
END;
/
SPO OFF;

/* Bug 33709268: We need to collect more sql monitor reports based on
 * some more conditions. Here we are adding conditions based on
 * buffer_gets (asc and desc) and Physical Reads (asc and desc).
 * Adding it in its own loop, as do not want to disturbe what we are
 * already collecting above plus the ranking mechanism we are using has
 * possibility of collision
 */

DEF sql_monitor_reports = '2'; --Limiting to max 2 reports for every condition

SPO ^^files_prefix._5_sql_monitor.sql append;
PRO -- SQL Monitor Report for ^^sql_id. rank_by_buffer_gets_desc

DECLARE
  l_count NUMBER := 0;
  TYPE mon_rt IS RECORD (
    sql_exec_start DATE,
    file_name varchar2(20),
    report_id NUMBER,
    sql_exec_id NUMBER,
    sql_plan_hash_value NUMBER,
    inst_id NUMBER,
    buffer_gets number,
    rank_by_buffer_gets_desc number
   );
  mon_rec mon_rt;
  mon_cv SYS_REFCURSOR;
BEGIN
  IF :license = 'T' 
  THEN
    $IF DBMS_DB_VERSION.version > 11
    $THEN

      DBMS_OUTPUT.PUT_LINE('VAR mon_exec_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_plan_hash_value NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_inst_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report CLOB;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_id VARCHAR2(13);');
      DBMS_OUTPUT.PUT_LINE('SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF;');


      OPEN mon_cv FOR
         q'~
            with awr_sql_monitor as
            (
              SELECT report_id, instance_number, key1 sql_id, key2 sql_exec_id, to_date(key3, 'MM/DD/YYYY HH24:MI:SS')  sql_exec_start
                     , to_number(regexp_substr(report_summary, q'{<stat name="buffer_gets">([[:digit:]]+)</stat>}', 1, 1, null, 1)) buffer_gets
                     , regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1)  phv
                FROM dba_hist_reports
               WHERE component_name = 'sqlmonitor'
                 AND key1 = '^^sql_id'
                 --  and EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/plan_hash') not in
                 --  PSRv9.1
                 -- and regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1) in 
                 --     (
                 --      SELECT distinct sql_plan_hash_value
                 --        FROM gv$sql_monitor
                 --       WHERE process_name = 'ora'
                 --         AND sql_id = '^^sql_id'
                 --     )
            )
            , awr_sql_monitor2 as 
            (
            select distinct 
                          sql_exec_start,
                          to_char(sql_exec_start, 'ddmon_hh24mmss'),
                          report_id,
                          sql_exec_id,
                          phv,
                          instance_number
                          , buffer_gets
                          , rank() over(partition by phv order by buffer_gets desc) rank_by_buffer_gets_desc
              from awr_sql_monitor
            )
            select *
              from awr_sql_monitor2
             where rank_by_buffer_gets_desc <= 2
             ORDER BY buffer_gets desc
        ~';

      LOOP
        FETCH mon_cv INTO mon_rec;
        EXIT WHEN mon_cv%NOTFOUND;

        l_count := l_count + 1;
        IF l_count > ^^sql_monitor_reports. THEN
          EXIT; -- exits loop
        END IF;

        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_start := '''||TO_CHAR(mon_rec.sql_exec_start, 'YYYYMMDDHH24MISS')||''';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_report_id := '||TO_CHAR(mon_rec.report_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_id := '||TO_CHAR(mon_rec.sql_exec_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_sql_plan_hash_value := '||TO_CHAR(mon_rec.sql_plan_hash_value)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_inst_id := '||TO_CHAR(mon_rec.inst_id)||';');
        DBMS_OUTPUT.PUT_LINE('--============');
        -- DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||mon_rec.file_name||'_'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- begin DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL -->');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  :mon_report := DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(');
        DBMS_OUTPUT.PUT_LINE('    rid  => :mon_report_id,');
        DBMS_OUTPUT.PUT_LINE('    type => ''ACTIVE'' );');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- end -->');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');

        DBMS_OUTPUT.PUT_LINE('SELECT :mon_report FROM DUAL;');

        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        DBMS_OUTPUT.PUT_LINE('SPO OFF;');
        DBMS_OUTPUT.PUT_LINE('--============');
      END LOOP;
      CLOSE mon_cv;
    $END
    NULL;
  END IF;
END;
/
SPO OFF;

SPO ^^files_prefix._5_sql_monitor.sql append;
PRO -- SQL Monitor Report for ^^sql_id. rank_by_buffer_gets_asc

DECLARE
  l_count NUMBER := 0;
  TYPE mon_rt IS RECORD (
    sql_exec_start DATE,
    file_name varchar2(20),
    report_id NUMBER,
    sql_exec_id NUMBER,
    sql_plan_hash_value NUMBER,
    inst_id NUMBER,
    buffer_gets number,
    rank_by_buffer_gets_asc number
   );
  mon_rec mon_rt;
  mon_cv SYS_REFCURSOR;
BEGIN
  IF :license = 'T' 
  THEN
    $IF DBMS_DB_VERSION.version > 11
    $THEN

      DBMS_OUTPUT.PUT_LINE('VAR mon_exec_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_plan_hash_value NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_inst_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report CLOB;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_id VARCHAR2(13);');
      DBMS_OUTPUT.PUT_LINE('SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF;');


      OPEN mon_cv FOR
         q'~
            with awr_sql_monitor as
            (
              SELECT report_id, instance_number, key1 sql_id, key2 sql_exec_id, to_date(key3, 'MM/DD/YYYY HH24:MI:SS')  sql_exec_start
                     , to_number(regexp_substr(report_summary, q'{<stat name="buffer_gets">([[:digit:]]+)</stat>}', 1, 1, null, 1)) buffer_gets
                     , regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1)  phv
                FROM dba_hist_reports
               WHERE component_name = 'sqlmonitor'
                 AND key1 = '^^sql_id'
                 --  and EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/plan_hash') not in
                 --  PSRv9.1
                 -- and regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1) in 
                 --     (
                 --      SELECT distinct sql_plan_hash_value
                 --        FROM gv$sql_monitor
                 --       WHERE process_name = 'ora'
                 --         AND sql_id = '^^sql_id'
                 --     )
            )
            , awr_sql_monitor2 as 
            (
            select distinct 
                          sql_exec_start,
                          to_char(sql_exec_start, 'ddmon_hh24mmss'),
                          report_id,
                          sql_exec_id,
                          phv,
                          instance_number
                          , buffer_gets
                          , rank() over(partition by phv order by buffer_gets) rank_by_buffer_gets_asc
              from awr_sql_monitor
            )
            select *
              from awr_sql_monitor2
             where rank_by_buffer_gets_asc <= 2
             ORDER BY buffer_gets
        ~';

      LOOP
        FETCH mon_cv INTO mon_rec;
        EXIT WHEN mon_cv%NOTFOUND;

        l_count := l_count + 1;
        IF l_count > ^^sql_monitor_reports. THEN
          EXIT; -- exits loop
        END IF;

        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_start := '''||TO_CHAR(mon_rec.sql_exec_start, 'YYYYMMDDHH24MISS')||''';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_report_id := '||TO_CHAR(mon_rec.report_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_id := '||TO_CHAR(mon_rec.sql_exec_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_sql_plan_hash_value := '||TO_CHAR(mon_rec.sql_plan_hash_value)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_inst_id := '||TO_CHAR(mon_rec.inst_id)||';');
        DBMS_OUTPUT.PUT_LINE('--============');
        -- DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||mon_rec.file_name||'_'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- begin DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL -->');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  :mon_report := DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(');
        DBMS_OUTPUT.PUT_LINE('    rid  => :mon_report_id,');
        DBMS_OUTPUT.PUT_LINE('    type => ''ACTIVE'' );');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- end -->');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');

        DBMS_OUTPUT.PUT_LINE('SELECT :mon_report FROM DUAL;');

        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        DBMS_OUTPUT.PUT_LINE('SPO OFF;');
        DBMS_OUTPUT.PUT_LINE('--============');
      END LOOP;
      CLOSE mon_cv;
    $END
    NULL;
  END IF;
END;
/
SPO OFF;

SPO ^^files_prefix._5_sql_monitor.sql append;
PRO -- SQL Monitor Report for ^^sql_id. rank_by_read_bytes_desc

DECLARE
  l_count NUMBER := 0;
  TYPE mon_rt IS RECORD (
    sql_exec_start DATE,
    file_name varchar2(20),
    report_id NUMBER,
    sql_exec_id NUMBER,
    sql_plan_hash_value NUMBER,
    inst_id NUMBER,
    read_bytes number,
    rank_by_read_bytes_desc number
   );
  mon_rec mon_rt;
  mon_cv SYS_REFCURSOR;
BEGIN
  IF :license = 'T' 
  THEN
    $IF DBMS_DB_VERSION.version > 11
    $THEN

      DBMS_OUTPUT.PUT_LINE('VAR mon_exec_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_plan_hash_value NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_inst_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report CLOB;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_id VARCHAR2(13);');
      DBMS_OUTPUT.PUT_LINE('SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF;');


      OPEN mon_cv FOR
         q'~
            with awr_sql_monitor as
            (
              SELECT report_id, instance_number, key1 sql_id, key2 sql_exec_id, to_date(key3, 'MM/DD/YYYY HH24:MI:SS')  sql_exec_start
                     , to_number(regexp_substr(report_summary, q'{<stat name="read_bytes">([[:digit:]]+)</stat>}', 1, 1, null, 1))  read_bytes
                     , regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1)  phv
                FROM dba_hist_reports
               WHERE component_name = 'sqlmonitor'
                 AND key1 = '^^sql_id'
                 --  and EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/plan_hash') not in
                 --  PSRv9.1
                 -- and regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1) in 
                 --     (
                 --      SELECT distinct sql_plan_hash_value
                 --        FROM gv$sql_monitor
                 --       WHERE process_name = 'ora'
                 --         AND sql_id = '^^sql_id'
                 --     )
            )
            , awr_sql_monitor2 as 
            (
            select distinct 
                          sql_exec_start,
                          to_char(sql_exec_start, 'ddmon_hh24mmss'),
                          report_id,
                          sql_exec_id,
                          phv,
                          instance_number
                          , read_bytes
                          , rank() over(partition by phv order by read_bytes desc) rank_by_read_bytes_desc
              from awr_sql_monitor
            )
            select *
              from awr_sql_monitor2
             where rank_by_read_bytes_desc <= 2
             ORDER BY read_bytes desc
        ~';

      LOOP
        FETCH mon_cv INTO mon_rec;
        EXIT WHEN mon_cv%NOTFOUND;

        l_count := l_count + 1;
        IF l_count > ^^sql_monitor_reports. THEN
          EXIT; -- exits loop
        END IF;

        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_start := '''||TO_CHAR(mon_rec.sql_exec_start, 'YYYYMMDDHH24MISS')||''';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_report_id := '||TO_CHAR(mon_rec.report_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_id := '||TO_CHAR(mon_rec.sql_exec_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_sql_plan_hash_value := '||TO_CHAR(mon_rec.sql_plan_hash_value)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_inst_id := '||TO_CHAR(mon_rec.inst_id)||';');
        DBMS_OUTPUT.PUT_LINE('--============');
        -- DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||mon_rec.file_name||'_'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- begin DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL -->');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  :mon_report := DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(');
        DBMS_OUTPUT.PUT_LINE('    rid  => :mon_report_id,');
        DBMS_OUTPUT.PUT_LINE('    type => ''ACTIVE'' );');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- end -->');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');

        DBMS_OUTPUT.PUT_LINE('SELECT :mon_report FROM DUAL;');

        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        DBMS_OUTPUT.PUT_LINE('SPO OFF;');
        DBMS_OUTPUT.PUT_LINE('--============');
      END LOOP;
      CLOSE mon_cv;
    $END
    NULL;
  END IF;
END;
/
SPO OFF;

SPO ^^files_prefix._5_sql_monitor.sql append;
PRO -- SQL Monitor Report for ^^sql_id. rank_by_read_bytes_asc

DECLARE
  l_count NUMBER := 0;
  TYPE mon_rt IS RECORD (
    sql_exec_start DATE,
    file_name varchar2(20),
    report_id NUMBER,
    sql_exec_id NUMBER,
    sql_plan_hash_value NUMBER,
    inst_id NUMBER,
    read_bytes number,
    rank_by_read_bytes_asc number
   );
  mon_rec mon_rt;
  mon_cv SYS_REFCURSOR;
BEGIN
  IF :license = 'T' 
  THEN
    $IF DBMS_DB_VERSION.version > 11
    $THEN

      DBMS_OUTPUT.PUT_LINE('VAR mon_exec_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_plan_hash_value NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_inst_id NUMBER;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_report CLOB;');
      DBMS_OUTPUT.PUT_LINE('VAR mon_sql_id VARCHAR2(13);');
      DBMS_OUTPUT.PUT_LINE('SET ECHO OFF FEED OFF VER OFF SHOW OFF HEA OFF LIN 2000 NEWP NONE PAGES 0 LONG 2000000 LONGC 2000 SQLC MIX TAB ON TRIMS ON TI OFF TIMI OFF ARRAY 100 NUMF "" SQLP SQL> SUF sql BLO . RECSEP OFF APPI OFF AUTOT OFF;');


      OPEN mon_cv FOR
         q'~
            with awr_sql_monitor as
            (
              SELECT report_id, instance_number, key1 sql_id, key2 sql_exec_id, to_date(key3, 'MM/DD/YYYY HH24:MI:SS')  sql_exec_start
                     , to_number(regexp_substr(report_summary, q'{<stat name="read_bytes">([[:digit:]]+)</stat>}', 1, 1, null, 1))  read_bytes
                     , regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1)  phv
                FROM dba_hist_reports
               WHERE component_name = 'sqlmonitor'
                 AND key1 = '^^sql_id'
                 --  and EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/plan_hash') not in
                 --  PSRv9.1
                 -- and regexp_substr(report_summary, q'{<plan_hash>([[:digit:]]+)</plan_hash>}', 1, 1, null, 1) in 
                 --     (
                 --      SELECT distinct sql_plan_hash_value
                 --        FROM gv$sql_monitor
                 --       WHERE process_name = 'ora'
                 --         AND sql_id = '^^sql_id'
                 --     )
            )
            , awr_sql_monitor2 as 
            (
            select distinct 
                          sql_exec_start,
                          to_char(sql_exec_start, 'ddmon_hh24mmss'),
                          report_id,
                          sql_exec_id,
                          phv,
                          instance_number
                          , read_bytes
                          , rank() over(partition by phv order by read_bytes) rank_by_read_bytes_asc
              from awr_sql_monitor
            )
            select *
              from awr_sql_monitor2
             where rank_by_read_bytes_asc <= 2
             ORDER BY read_bytes
        ~';

      LOOP
        FETCH mon_cv INTO mon_rec;
        EXIT WHEN mon_cv%NOTFOUND;

        l_count := l_count + 1;
        IF l_count > ^^sql_monitor_reports. THEN
          EXIT; -- exits loop
        END IF;

        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_start := '''||TO_CHAR(mon_rec.sql_exec_start, 'YYYYMMDDHH24MISS')||''';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_report_id := '||TO_CHAR(mon_rec.report_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_exec_id := '||TO_CHAR(mon_rec.sql_exec_id)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_sql_plan_hash_value := '||TO_CHAR(mon_rec.sql_plan_hash_value)||';');
        DBMS_OUTPUT.PUT_LINE('EXEC :mon_inst_id := '||TO_CHAR(mon_rec.inst_id)||';');
        DBMS_OUTPUT.PUT_LINE('--============');
        -- DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SPO ^^files_prefix._'||mon_rec.file_name||'_'||TO_CHAR(mon_rec.sql_exec_id)||'_'||TO_CHAR(mon_rec.sql_plan_hash_value)||'_'||TO_CHAR(mon_rec.inst_id)||'_5_awr_sql_monitor.html;');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- begin DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL -->');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  :mon_report := DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(');
        DBMS_OUTPUT.PUT_LINE('    rid  => :mon_report_id,');
        DBMS_OUTPUT.PUT_LINE('    type => ''ACTIVE'' );');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        --DBMS_OUTPUT.PUT_LINE('PRO <!-- end -->');
        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');

        DBMS_OUTPUT.PUT_LINE('SELECT :mon_report FROM DUAL;');

        DBMS_OUTPUT.PUT_LINE('SELECT ''<!-- ''||TO_CHAR(SYSDATE, ''YYYY-MM-DD/HH24:MI:SS'')||'' -->'' FROM dual;');
        DBMS_OUTPUT.PUT_LINE('SPO OFF;');
        DBMS_OUTPUT.PUT_LINE('--============');
      END LOOP;
      CLOSE mon_cv;
    $END
    NULL;
  END IF;
END;
/
SPO OFF;

DEF sql_monitor_reports = '12'; --Resetting back to orininal value

-- 11g
@^^files_prefix._5_sql_monitor.sql

/**************************************************************************************************
 *
 * Uday.PSR.v6
 * - Monitored SQL Binds
 *
 **************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Monitored SQLs Binds ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO Fetching Monitored SQLs Binds and Bind Values
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait

SET heading on pages 1000
REM Pushkar - converted binds to html format
SPO ^^files_prefix._51_sqlmonitor_binds.html;

PRO <style type="text/css">
PRO body {font:10pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
PRO table {font-size:8pt; color:black; background:white;}
PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td {text-align:left; background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO </style>

set markup html on

PRO ------------------------------------;
PRO Monitored SQLs Binds and Bind Values
PRO ------------------------------------;

col name for a35 heading "Bind Variable Name"
col val for a40 heading "Bind Value"
col dty for a20 heading "Data Type"
col pos for 999 heading "Position"
col et heading "Elapsed|Time(s)"
col buffer_gets heading "Buffer|Gets"
col sql_plan_hash_value heading "PHV"
col sql_exec_start for a21 heading "SQL Exec|Start"

break on sql_exec_id on sql_exec_start on sql_plan_hash_value on et on buffer_gets skip 1

set timing on
with smon_binds as
(
SELECT c.sql_exec_id, c.sql_exec_start, c.sql_plan_hash_value, round(elapsed_time/1000000,2) et, buffer_gets,
       to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos')) pos,
       EXTRACTVALUE(VALUE(D), '/bind/@name') name, 
       EXTRACTVALUE(VALUE(D), '/bind') val,
       EXTRACTVALUE(VALUE(D), '/bind/@dtystr') dty
FROM
 gv$sql_monitor c
 , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.BINDS_XML ), '/binds/bind'))) D
where c.sql_id = :sql_id
  and c.binds_xml is not null
)
select sql_exec_id, sql_exec_start, sql_plan_hash_value, et, buffer_gets, pos, name
       , case when dty like 'TIMEST%' THEN
               rtrim(
                    to_char(100*(to_number(substr(val,1,2),'XX')-100)
                            + (to_number(substr(val,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(val,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(val,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(val,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(val,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(val,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(val,15,8),'XXXXXXXX')  
               )
              else val
         end val 
       , dty
  from smon_binds
order by sql_exec_start, sql_exec_id, pos
;
set timing off


PRO 
set markup html off
SPO OFF;

/**************************************************************************************************/

/**************************************************************************************************
 *
 * Uday (Fusion PSR):
 * - Hard parse pct at each FA user level 
 * - VPD policies at child cursor level
 *
 **************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Hard Parse percent ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO Hard Parse percent by user (client_id) from AWR and ASH
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait

col sql_plan_hash_value heading "PHV"
col client_id for a30 heading "User"
col cnt for 999999999 heading "Samples"
col execs for 999999999 heading "Executions"
col hp_cnt for 999999999 heading "Total|HardParse|Samples"
col hp_pct for 999999999 heading "HardParse|Pct"
col minst for a35 heading "MinSampleTime"
col maxst for a35 heading "MaxSampleTime"
col elap for a35 heading "Elapsed"
col ecid_cnt for 999999 heading "#of|ECIDs"
col min_ecid_hp_cnt for 9999 heading "~Min|Hard|Parse|Time"
col max_ecid_hp_cnt for 9999 heading "~Max|Hard|Parse|Time"

SET heading on pages 1000

--Uday.PSR.v6 : replaced with better one: added min/max hpt
--Uday.PSR.v6 select sql_id, client_id, count(*) cnt, count(distinct sql_exec_start) execs, count(distinct ecid) ecid_cnt
--Uday.PSR.v6        , sum(case when in_hard_parse = 'Y' then 1 else 0 end) hp_cnt
--Uday.PSR.v6        , round((sum(case when in_hard_parse = 'Y' then 1 else 0 end)/count(*))*100 ,2) hp_pct
--Uday.PSR.v6        -- , sum(case when in_hard_parse = 'N' then 1 else 0 end) exec_cnt
--Uday.PSR.v6        , min(sample_time) minst, max(sample_time) maxst, max(sample_time)-min(sample_time) elap
--Uday.PSR.v6   from gv$active_session_history ash
--Uday.PSR.v6  where sql_id = :sql_id
--Uday.PSR.v6  group by sql_id, client_id
--Uday.PSR.v6  order by  sql_id, hp_pct desc, cnt desc
--Uday.PSR.v6 ;
--Uday.PSR.v6 

SPO ^^files_prefix._10_hardParsePctByUser.txt;

PRO
PRO ---------------------------------------------------------;
PRO Hard Parse percent by user (client_id) from in-memory ASH:;
PRO ---------------------------------------------------------;
PRO
PRO
-- set timing on
with hp as
(
select sql_id, client_id, sql_exec_start, ecid, in_hard_parse, sample_time
       , sum(case when in_hard_parse = 'Y' then 1 else 0 end) over(partition by sql_id, client_id, ecid) ecid_hp_cnt 
  from gv$active_session_history ash
 where 1=1
   and sql_id = :sql_id
)
select sql_id, client_id, count(*) cnt, count(distinct sql_exec_start) execs, count(distinct ecid) ecid_cnt
       , min(ecid_hp_cnt) min_ecid_hp_cnt, max(ecid_hp_cnt) max_ecid_hp_cnt
       , sum(case when in_hard_parse = 'Y' then 1 else 0 end) hp_cnt
       , round((sum(case when in_hard_parse = 'Y' then 1 else 0 end)/count(*))*100 ,2) hp_pct
       -- , sum(case when in_hard_parse = 'N' then 1 else 0 end) exec_cnt
       , min(sample_time) minst, max(sample_time) maxst
       -- , max(sample_time)-min(sample_time) elap
  from hp
 where 1=1
 group by sql_id, client_id
 order by sql_id, hp_pct desc, cnt desc
;
-- set timing off

-- Uday.PSR.v6 replacing with better one
-- Uday.PSR.v6 with snaps as (select /*+ materialize */ sql_id, min(snap_id) minsnap, max(snap_id) maxsnap from dba_hist_sqlstat where sql_id = :sql_id group by sql_id)
-- Uday.PSR.v6 select /*+ leading(snaps ash) no_merge */ 
-- Uday.PSR.v6        ash.sql_id, sql_plan_hash_value, client_id, count(*) cnt, count(distinct sql_exec_start) execs
-- Uday.PSR.v6        , sum(case when in_hard_parse = 'Y' then 1 else 0 end) hp_cnt
-- Uday.PSR.v6        , round((sum(case when in_hard_parse = 'Y' then 1 else 0 end)/count(*))*100 ,2) hp_pct
-- Uday.PSR.v6        -- , sum(case when in_hard_parse = 'N' then 1 else 0 end) exec_cnt
-- Uday.PSR.v6        , min(sample_time) minst, max(sample_time) maxst, max(sample_time)-min(sample_time) elap
-- Uday.PSR.v6   from dba_hist_active_sess_history ash
-- Uday.PSR.v6        , snaps
-- Uday.PSR.v6  WHERE :license IN ('T', 'D')
-- Uday.PSR.v6    AND ash.dbid = ^^dbid.
-- Uday.PSR.v6    and ash.sql_id = snaps.sql_id
-- Uday.PSR.v6    and ash.snap_id between snaps.minsnap and snaps.maxsnap
-- Uday.PSR.v6  group by ash.sql_id, sql_plan_hash_value, client_id
-- Uday.PSR.v6  order by  ash.sql_id, hp_pct desc, cnt desc, sql_plan_hash_value
-- Uday.PSR.v6 ;

PRO
PRO Hard Parse percent by user (client_id) from on-disk AWR:
PRO -------------------------------------------------------;
PRO

-- set timing on
with hp as 
	(
	select ash.sql_id, client_id, sql_exec_start, ecid, in_hard_parse, sample_time
	       , sum(case when in_hard_parse = 'Y' then 1 else 0 end) over(partition by ash.sql_id, client_id, ecid) ecid_hp_cnt 
	  from dba_hist_active_sess_history ash
	 WHERE 1=1
	   and :license IN ('T', 'D')
	   and ash.dbid = ^^dbid.
	   and ash.sql_id = :sql_id
	   and ash.snap_id between :minsnap and :maxsnap
	   and ecid is not null
	-- order by sql_id, ecid  
	)
select /*+ leading(ash) no_merge */
       sql_id, client_id, count(*) cnt, count(distinct sql_exec_start) execs, count(distinct ecid) ecid_cnt
       , min(ecid_hp_cnt) min_ecid_hp_cnt, max(ecid_hp_cnt) max_ecid_hp_cnt
       , sum(case when in_hard_parse = 'Y' then 1 else 0 end) hp_cnt
       , round((sum(case when in_hard_parse = 'Y' then 1 else 0 end)/count(*))*100 ,2) hp_pct
       , min(sample_time) minst, max(sample_time) maxst
  from hp
 group by sql_id, client_id
 order by sql_id, hp_pct desc, cnt desc
;
-- set timing off

PRO
PRO ---------------------------------;
PRO Hard Parse By ECID - Last 7 Days
PRO ---------------------------------;
PRO

COL CNT FOR 999
COL ECID FOR A64
COL START_TIME FOR A26
COL END_TIME FOR A26
COL ELAPSED_TIME FOR A20

select inst_id,
       client_id,
       ecid,
       cnt,
       start_time,
       end_time,
       extract(hour from elapsed_time)||':'||extract(minute from elapsed_time)||':'||extract(second from elapsed_time) elapsed_time
from
(
  select inst_id,
         client_id,
         ecid,
         count(*) cnt,
         min(sample_time) start_time,
         max(sample_time) end_time,
         max(sample_time) - min(sample_time) elapsed_time
  from gv$active_session_history
  where sql_id = :sql_id
  and in_hard_parse = 'Y'
  and sample_time > sysdate - 7
  and ecid is not null
  group by inst_id, client_id, ecid
  having count(*) > 1
  union
  select instance_number inst_id,
         client_id,
         ecid,
         count(*) cnt,
         min(sample_time) start_time,
         max(sample_time) end_time,
         max(sample_time) - min(sample_time) elapsed_time
  from dba_hist_active_sess_history
  where sql_id = :sql_id
  and in_hard_parse = 'Y'
  and sample_time > sysdate - 7
  and ecid is not null
  group by instance_number, client_id, ecid
  having count(*) > 1
)
order by start_time;

PRO 
PRO 

SPO OFF;


EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: VPD policy ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO Getting VPD Policies for each child cursor
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait


col child_number for 999 heading "Ch#"
BREAK ON ROW SKIP 1
SPO ^^files_prefix._11_VPD_Policies.txt;

PRO
PRO
PRO VPD Policies for each child cursor from memory:
PRO ----------------------------------------------;
PRO

-- set timing on
select distinct p.sql_id, p.inst_id, p.child_number, p.object_name, p.policy, p.predicate
  from gv$vpd_policy p, gv$sql s
 where s.sql_id = :sql_id
   and s.inst_id = p.inst_id
   and s.sql_id  = p.sql_id
   and s.child_number = p.child_number
   -- and p.policy like '%PII%'
 order by p.sql_id, p.inst_id, p.child_number, p.policy
;
-- set timing off

PRO 
SPO OFF;
SET heading off pages 0
clear breaks

/**************************************************************************************************
 *
 * Uday (Fusion PSR): v6
 * - Histogram Actual Values
 *
 **************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Histogram Actual Values ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO Fetching Histogram Actual Values
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait

/* -------------------------
 *
 * Uday.PSR.v6
 * inserting tables used in the plans into PLAN_TABLE to improve performance 
 * - with clause is repeated in all the diagnostic SQLs.
 * - slow performance, especially 'table columns'
 *
 * ------------------------- */

DELETE plan_table where STATEMENT_ID = :sql_id;
commit;
insert into plan_table(STATEMENT_ID, object_owner, object_type, object_name, cardinality, cost, optimizer, object_alias, operation, options, io_cost, bytes)
  WITH  
    object AS (
       SELECT /*+ MATERIALIZE */
              object_owner owner, object_name name, object_type
         FROM gv$sql_plan
        WHERE inst_id IN (SELECT inst_id FROM gv$instance)
          AND sql_id = :sql_id
          AND object_owner IS NOT NULL
          AND object_name IS NOT NULL
          AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
        UNION
       SELECT object_owner owner, object_name name, object_type
         FROM dba_hist_sql_plan
        WHERE :license IN ('T', 'D')
          AND dbid = ^^dbid.
          AND sql_id = :sql_id
          AND object_owner IS NOT NULL
          AND object_name IS NOT NULL
          AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') --Uday.v6
    )
    , plan_tables AS (
         SELECT /*+ MATERIALIZE */
                'TABLE' object_type, o.owner object_owner, o.name object_name
           FROM object o
          WHERE o.object_type like 'TABLE%'
          UNION
         SELECT /*+ leading (o) */ 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
           FROM dba_indexes i,
                object o
          WHERE o.object_type like 'INDEX%'  --Uday.v6
            AND i.owner = o.owner
            AND i.index_name = o.name
          UNION
         SELECT /*+ leading (o) */ 'TABLE' object_type, t.owner object_owner, t.table_name object_name
           FROM dba_tables t,
                object o
          WHERE t.owner = o.owner
            AND t.table_name = o.name
            AND o.object_type IS NULL /* PUSHKAR 10.8: this helps in insert statement analysis */            
    )
         -- (object_owner, object type,    object_name,  cardinality, cost,         
  -- select t.owner,          pt.object_type, t.table_name, t.num_rows,  t.sample_size, 
  select distinct :sql_id, t.owner,          pt.object_type, t.table_name, t.num_rows,  t.sample_size, 
         -- OPTIMIZER
         TO_CHAR(t.last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed, 
         -- object_alias, operation,   options, io_cost,  bytes
         temporary,       partitioned, degree,  t.blocks, t.avg_row_len
    from plan_tables pt, dba_tables t
   where t.table_name = pt.object_name
     and t.owner = pt.object_owner
  ;
SET heading on pages 50000 trims on verify off feedback off

rem select STATEMENT_ID, object_type, object_owner, object_name from plan_table;
rem pause;

SPO ^^files_prefix._12_histogram_actual_values.html;

rem PRO <style type="text/css">
rem PRO body {font:10pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
rem PRO table {font-size:8pt; color:black; background:white;}
rem PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
rem PRO td {text-align:left; background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
rem PRO </style>

rem set markup html on
PRO <html>
PRO <head><title>^^files_prefix._12_histogram_actual_values.html</title></head>
PRO <body><pre>

PRO -----------------------;
PRO Histogram Actual Values
PRO -----------------------;
PRO .                     --- NOTE for HYBRID HISTOGRAM ---;
PRO .            Popularity - IF endpoint_repeat_count > avg SIZE OF the bucket is popular 
PRO .                         ELSE not popular (null)
PRO .
PRO .            Following situations are possible with predicates (assume equi condition)
PRO .            1) popular                   - nn_rows * selectivity
PRO .            2) non popular - WITH BUCKET - nn_rows * greatest (NewDensity, selectivity) 
PRO .            3) non popular - NO   BUCKET - nn_rows * NewDensity

PRO .            NewDensity = ((BktCnt-PopBktCnt)/BktCnt) /(NDV-PopValCnt)
PRO .                         [fraction of non-popularCnt]/[non-popular NDV]
PRO .            BktCnt   = SampleSize
PRO .            PopBktCnt= Sum of Popular endpoint_repeat_counts across popular buckets
PRO .            PopValCnt= How many buckets have popular values

col table_name for a30 heading "Table Name"
col column_name for a30 heading "Column Name"
col approx_value for a30 heading "Approx Value"
col rows_per_bucket for 99999999999 heading "Rows Per|Bucket"
col selectivity for 99.99999999 heading "Selectivity"
column num_rows for 99999999999 heading "Num Rows"
column nn_rows  for 99999999999 heading "Column|Not Null|Rows"
column histogram  for a14 heading "Histogram|Type"
column endpoint_number for 99999999999 heading "Endpoint|Number"
column ENDPOINT_REPEAT_COUNT for 999999999 heading "Endpoint|Repeat|Count"
column POPULAR_REPEAT_COUNT  for 999999999 heading "Popular|Repeat|Count"
column sample_size for 99999999999 heading "SampleSize|BktCnt"
column num_distinct for 99999999999 heading "NDV"
column popular for A7 head "popular|?"

break on table_name skip 2 on num_rows on column_name on nn_rows skip 1

COMPUTE SUM   label PopBktCnt OF popular_repeat_count rows_per_bucket on column_name
COMPUTE COUNT label PopValCnt OF popular on column_name
-- psrv9: added partition by h.column_name to get correct lag value

variable histval refcursor
-- set timing on
BEGIN
  IF '^^rdbms_version' like '11%'
  THEN
    OPEN :histval FOR 
     q'[
         with c as
         (
          select /*+ materialize leading(t) */ t.object_owner owner, t.object_name table_name, 
                 t.cardinality num_rows, c.column_name, c.histogram, 
                 c.sample_size, c.num_nulls, c.num_buckets, c.data_type
            from plan_table t, dba_tab_cols c
           where 1=1
             -- and t.owner = 'FUSION' and t.table_name = 'PER_ALL_ASSIGNMENTS_M' 
             -- and c.column_name in ('ACTION_CODE', 'BUSINESS_UNIT_ID', 'FREEZE_UNTIL_DATE')
             and t.object_owner = c.owner
             and t.object_name  = c.table_name
             AND STATEMENT_ID = '^^sql_id'
             and c.histogram <> 'NONE'
         )
         select /*+ no_merge */ h.table_name, c.num_rows, h.column_name, (c.num_rows-c.num_nulls) nn_rows, c.histogram, c.sample_size, h.endpoint_number
                ,
                 case when c.data_type like '%CHAR%' then
                                 nvl(ENDPOINT_ACTUAL_VALUE,UTL_RAW.CAST_TO_VARCHAR2(SUBSTR(LPAD(TO_CHAR(h.endpoint_value,'fmxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'),30,'0'),1,12))) ||''
                               when data_type = 'NUMBER' then
                                 to_char(h.endpoint_value) ||''
                               when data_type = 'DATE' or data_type like 'TIMESTAMP%' then
                                 to_char(to_date(to_char(trunc(h.endpoint_value)), 'J') + (h.endpoint_value - TRUNC(h.endpoint_value)),'SYYYY / MM / DD HH24:MI:SS') ||''
                 end approx_value
                ,
                 case when c.histogram IN ('TOP-FREQUENCY', 'FREQUENCY') then
                        round((h.endpoint_number - (lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number))) / c.sample_size * (c.num_rows-c.num_nulls)) 
                     when c.histogram = 'HEIGHT BALANCED' then
                        round((h.endpoint_number - (lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number)) ) / c.num_buckets * (c.num_rows-c.num_nulls)) 
                 end rows_per_bucket
                ,
                 case when c.histogram IN ('TOP-FREQUENCY', 'FREQUENCY') then
                        trunc((h.endpoint_number - lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number)) / c.sample_size,5) 
                     when c.histogram = 'HEIGHT BALANCED' then
                        trunc((h.endpoint_number - lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number)) / c.num_buckets,5)  
                 end selectivity
           from c, dba_tab_histograms h
          where c.owner = h.owner and c.table_name = h.table_name and c.column_name = h.column_name 
          order by h.table_name, h.column_name, h.endpoint_number
       ]';
  ELSIF '^^rdbms_version' like '12%' or '^^rdbms_version' like '19%'
  THEN
    OPEN :histval FOR 
     q'[
         with c as
         (
          select /*+ materialize leading(t) */ t.object_owner owner, t.object_name table_name, 
                 t.cardinality num_rows, c.column_name, c.histogram, 
                 c.sample_size, c.num_nulls, c.num_buckets, c.data_type, c.num_distinct
            from plan_table t, dba_tab_cols c
           where 1=1
             -- and t.owner = 'FUSION' and t.table_name = 'PER_ALL_ASSIGNMENTS_M' 
             -- and c.column_name in ('ACTION_CODE', 'BUSINESS_UNIT_ID', 'FREEZE_UNTIL_DATE')
             and t.object_owner = c.owner
             and t.object_name  = c.table_name
             AND STATEMENT_ID = '^^sql_id'
             and c.histogram <> 'NONE'
         )
        select /*+ ordered use_nl(h) push_pred(h) OPT_PARAM('_optimizer_adaptive_plans','false') no_merge */ 
                h.table_name, c.num_rows, h.column_name, (c.num_rows-c.num_nulls) nn_rows, c.num_distinct, c.histogram, c.sample_size, h.endpoint_number
                , case when c.histogram IN ('TOP-FREQUENCY', 'FREQUENCY') then
                        round((h.endpoint_number - (lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number)))) 
                     when c.histogram = 'HEIGHT BALANCED' then
                        round((h.endpoint_number - (lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number)) ) / c.num_buckets * (c.num_rows-c.num_nulls)) 
                     when c.histogram = 'HYBRID' then
                        round((h.endpoint_number - (lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number)))) 
                        --round(endpoint_repeat_count /c.sample_size * (c.num_rows-c.num_nulls)) 
                 end rows_per_bucket
                ,
                 case when c.data_type like '%CHAR%' then
                                 nvl(ENDPOINT_ACTUAL_VALUE, UTL_RAW.CAST_TO_VARCHAR2(SUBSTR(LPAD(TO_CHAR(h.endpoint_value,'fmxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'),30,'0'),1,12))) ||''
                               when data_type = 'NUMBER' then
                                 to_char(h.endpoint_value) ||''
                               when data_type = 'DATE' or data_type like 'TIMESTAMP%' then
                                 to_char(to_date(to_char(trunc(h.endpoint_value)), 'J') + (h.endpoint_value - TRUNC(h.endpoint_value)),'SYYYY / MM / DD HH24:MI:SS') ||''
                 end approx_value
                ,case when c.histogram = 'HYBRID' then
                    endpoint_repeat_count
                 end endpoint_repeat_count                 
                ,
                 case when c.histogram IN ('TOP-FREQUENCY', 'FREQUENCY') then
                        trunc((h.endpoint_number - lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number)) / c.sample_size,5) 
                     when c.histogram = 'HEIGHT BALANCED' then
                        trunc((h.endpoint_number - lag(h.endpoint_number,1,0) over (partition by h.table_name, h.column_name order by h.endpoint_number)) / c.num_buckets,5) 
                     when c.histogram = 'HYBRID' then
                        trunc(endpoint_repeat_count /c.sample_size,5) 
                 end selectivity
                ,
                 case 
                     when c.histogram = 'HYBRID' and endpoint_repeat_count > c.sample_size/c.num_buckets then endpoint_repeat_count
                 end popular_repeat_count 
                ,                 
                 case 
                     when c.histogram = 'HYBRID' and endpoint_repeat_count > c.sample_size/c.num_buckets then 'popular'
                 end popular
           from c, dba_tab_histograms h
          where c.owner = h.owner and c.table_name = h.table_name and c.column_name = h.column_name 
          order by h.table_name, h.column_name, h.endpoint_number
       ]';
  END IF;
END;
/

SET feedback on 
PRINT histval
SET feedback off
-- set timing off

PRO </pre></body></html>
rem set markup html off
SPO OFF;

CLEAR compute;

/**************************************************************************************************
 *
 * New Script by Vivek Jha v10.5
 * - Histogram Actual Values at Hard Parse time
 *
 **************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: Histogram Actual Values at Hard Parse ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO Fetching Histogram Actual Values at Hard Parse
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait


/*
delete plan_table where STATEMENT_ID = :sql_id;
commit;
insert into plan_table(STATEMENT_ID, object_owner, object_type, object_name, cardinality, cost, optimizer, object_alias, operation, options, io_cost, bytes)
  WITH  
    object AS (
       SELECT /*+ MATERIALIZE * /
              object_owner owner, object_name name, object_type
         FROM gv$sql_plan
        WHERE inst_id IN (SELECT inst_id FROM gv$instance)
          AND sql_id = :sql_id
          AND object_owner IS NOT NULL
          AND object_name IS NOT NULL
          AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') 
        UNION
       SELECT object_owner owner, object_name name, object_type
         FROM dba_hist_sql_plan
        WHERE :license IN ('T', 'D')
          AND dbid = ^^dbid.
          AND sql_id = :sql_id
          AND object_owner IS NOT NULL
          AND object_name IS NOT NULL
          AND not (object_type = 'TABLE (TEMP)' and object_name like 'SYS_TEMP%') 
    )
    , plan_tables AS (
         SELECT /*+ MATERIALIZE * /
                'TABLE' object_type, o.owner object_owner, o.name object_name
           FROM object o
          WHERE o.object_type like 'TABLE%'
          UNION
         SELECT 'TABLE' object_type, i.table_owner object_owner, i.table_name object_name
           FROM dba_indexes i,
                object o
          WHERE o.object_type like 'INDEX%'  
            AND i.owner = o.owner
            AND i.index_name = o.name
    )
  select distinct :sql_id, t.owner,          pt.object_type, t.table_name, t.num_rows,  t.sample_size, 
           TO_CHAR(t.last_analyzed, 'DD-MON-YY HH24:MI:SS') last_analyzed, 
         temporary,       partitioned, degree,  t.blocks, t.avg_row_len
    from plan_tables pt, dba_tables t
   where t.table_name = pt.object_name
     and t.owner = pt.object_owner
  ;
*/  
SET heading on pages 1000

var  l_last_load_time varchar2(50) ;
var  l_plan_hash_value number;

begin
select plan_hash_value into :l_plan_hash_value from gv$sql where sql_id = :sql_id order by last_load_time desc FETCH FIRST 1 ROW ONLY;
select last_load_time into :l_last_load_time from gv$sql where sql_id = :sql_id order by last_load_time desc FETCH FIRST 1 ROW ONLY;
end;
/


SPO ^^files_prefix._15_histogram_actual_values_atHardParse.html;

SET heading on pages 1000

rem PRO <style type="text/css">
rem PRO body {font:10pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
rem PRO table {font-size:8pt; color:black; background:white;}
rem PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
rem PRO td {text-align:left; background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
rem PRO </style>

rem set markup html on
PRO <html>
PRO <head><title>^^files_prefix._15_histogram_actual_values_atHardParse.html</title></head>
PRO <body><pre>


PRO # Histogram Actual Values at Hard Parse 
PRO
PRO This script outputs the Column Histograms for a give SQL ID and PLAN HASH VALUE based on the last HARD PARSE TIME
PRO (current histograms might be different from the time when the SQL was last hard parsed)
PRO Data is fetched from tables in memory. Depending on the Retention period for those tables, not all tables used in the execution plan might show up in the output

col "Plan Hash" format A100 
SELECT '         Plan Hash Value:' ||:l_plan_hash_value ||'        Hard Parse Time: ' || :l_last_load_time "Plan Hash" from dual;



/*
col table_name for a30 heading "Table Name"
col num_rows for 99999999999 heading "Table Rows"
col column_name for a30 heading "Column Name"
col SAVTIME for a40 heading "Stats Gather Time"
col Bucket for 99999999999 heading "Bucket"
column nn_rows  for 99999999999 heading "Column|Not Null|Rows"
column histogram  for a16 heading "Histogram|Type"
col approx_value for a100 heading "Approx Value"
col rows_per_bucket for 999999999 heading "Rows Per|Bucket"
col selectivity for 99.999999999 heading "Selectivity"

break on table_name on num_rows on column_name on nn_rows
*/

--set timing on

         with c as
         (
          select /*+ materialize leading(t) */ t.object_owner owner, t.object_name table_name, 
                 t.cardinality num_rows, c.column_name, c.histogram, 
                 c.sample_size, c.num_nulls, c.num_buckets, c.data_type
            from plan_table t, dba_tab_cols c
           where 1=1
             and t.object_owner = c.owner
             and t.object_name  = c.table_name
             AND STATEMENT_ID = '^^sql_id'
             and c.histogram <> 'NONE'
         ),
         maxst as
         (
           select c.owner , c.table_name, max(savtime) savtimemax
           from c, sys.obj$ o, sys.col$ col, sys.user$ u, sys.wri$_OPTSTAT_HISTGRM_HISTORY hh
	     where  c.owner = u.name and c.table_name = o.name and c.column_name = col.name 
	       and hh.obj# = o.obj#
	       and col.obj# = o.obj#
	       and hh.intcol# = col.col#
	       and o.owner# = u.user#
	       --and hh.savtime < (select to_date(max(last_load_time),'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id)
	       and hh.savtime  <  (select to_date(last_load_time,'yyyy-mm-dd hh24:mi:ss') from gv$sql where sql_id = :sql_id and plan_hash_value = :l_plan_hash_value order by last_load_time desc FETCH FIRST 1 ROW ONLY)
	       group by c.owner, c.table_name
              )
         select /*+ ordered use_nl(h) push_pred(h) OPT_PARAM('_optimizer_adaptive_plans','false') no_merge */ 
                c.table_name, c.num_rows, c.column_name,hh.savtime,hh.bucket, (c.num_rows-c.num_nulls) nn_rows, c.histogram, 
                 case when c.data_type like '%CHAR%' then utl_raw.cast_to_varchar2(hh.epvalue_raw) ||''
                      when c.data_type = 'NUMBER'    then utl_raw.cast_to_number(hh.epvalue_raw)  ||''
                      when c.data_type = 'DATE' or data_type like 'TIMESTAMP%' then
                                 to_char(to_date(to_char(trunc(hh.endpoint)), 'J') + (hh.endpoint - TRUNC(hh.endpoint)),'SYYYY / MM / DD HH24:MI:SS') ||''
                 end approx_value
                ,case when c.histogram = 'HYBRID' then
                    hh.ep_repeat_count
                 end endpoint_repeat_count                   
                ,
		case when c.histogram IN ('TOP-FREQUENCY', 'FREQUENCY') then 	
			round((hh.bucket - (lag(hh.bucket,1,0) over (partition by c.table_name, c.column_name order by hh.bucket)))) 
		when c.histogram = 'HEIGHT BALANCED' then			
			round((hh.bucket - (lag(hh.bucket,1,0) over (partition by c.table_name, c.column_name order by hh.bucket)) ) / c.num_buckets * (c.num_rows-c.num_nulls)) 
                when c.histogram = 'HYBRID' then
                        --round(hh.ep_repeat_count /c.sample_size * (c.num_rows-c.num_nulls)) 
                        round((hh.bucket - (lag(hh.bucket,1,0) over (partition by c.table_name, c.column_name order by hh.bucket)))) 
                 end rows_per_bucket
                ,
		case when c.histogram IN ('TOP-FREQUENCY', 'FREQUENCY') then 	
			trunc((hh.bucket - lag(hh.bucket,1,0) over (partition by c.table_name, c.column_name order by hh.bucket)) / c.sample_size,5) 
		when c.histogram = 'HEIGHT BALANCED' then			
			trunc((hh.bucket - lag(hh.bucket,1,0) over (partition by c.table_name, c.column_name order by hh.bucket)) / c.num_buckets,5)  
                when c.histogram = 'HYBRID' then
                        trunc(hh.ep_repeat_count /c.sample_size,5) 
                 end selectivity
                , 
                  case 
                     when c.histogram = 'HYBRID' and hh.ep_repeat_count >= c.sample_size/c.num_buckets then 'popular'
                  else ''
                 end popular                 
	   from c, sys.obj$ o, sys.col$ col, sys.user$ u, sys.wri$_OPTSTAT_HISTGRM_HISTORY hh, maxst
	     where  c.owner = u.name and c.table_name = o.name and c.column_name = col.name 
	       and hh.obj# = o.obj#
	       and col.obj# = o.obj#
	       and hh.intcol# = col.col#
	       and o.owner# = u.user#
	       and c.owner = maxst.owner
	       and c.table_name = maxst.table_name
	       and hh.savtime = maxst.savtimemax
             order by c.table_name, c.column_name, hh.bucket;


PRO
PRO **** ORA-942 ERROR on sys.wri$_OPTSTAT_%_HISTORY can be ignored ****
--set timing off

PRO </pre></body></html>
rem set markup html off
SPO OFF;



/*================================= SQL Profile - Vivek Jha =================================*/
/* this creates SQL profile scripts for Top3 PHV's */

SET HEAD OFF
EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: SQL Profile Report - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
PRO SQL Profile Scripts
PRO
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait



SET TERM OFF ECHO OFF FEED OFF VER OFF HEA ON LIN 2000 PAGES 100 LONG 8000000 LONGC 800000 TRIMS ON TI OFF TIMI OFF SERVEROUT ON SIZE 1000000 NUMF "" 


SPO ^^files_prefix._16_sql_profiles.sql;
PRO -- SQL Profile Scripts for ^^sql_id.

VAR sql_text CLOB;
VAR sql_text2 CLOB;
VAR other_xml CLOB;
EXEC :sql_text := NULL;
EXEC :sql_text2 := NULL;
EXEC :other_xml := NULL;

DECLARE 
   c_sql_id v$sql.sql_id%type; 
   c_plan_hash_value v$sql.plan_hash_value%type; 
   c_avg_et_secs v$sql.elapsed_time%type; 
   l_sql_text VARCHAR2(32767);
   l_clob_size NUMBER;
   l_offset NUMBER;

  l_pos NUMBER;
  --l_clob_size NUMBER;
  --l_offset NUMBER;
  --l_sql_text VARCHAR2(32767);
  l_len NUMBER;
  l_hint VARCHAR2(32767);

	CURSOR c_phv is 
	WITH
	p AS (
	SELECT sql_id, plan_hash_value
	  FROM gv$sql_plan
	 WHERE sql_id = TRIM(:sql_id)
	   AND other_xml IS NOT NULL
	 UNION
	SELECT sql_id, plan_hash_value
	  FROM dba_hist_sql_plan
	 WHERE sql_id = TRIM(:sql_id)
	   AND other_xml IS NOT NULL ),
	m AS (
	SELECT sql_id, plan_hash_value,
	       SUM(elapsed_time)/SUM(executions) avg_et_secs
	  FROM gv$sql
	 WHERE sql_id = TRIM(:sql_id)
	   AND executions > 0
	 GROUP BY
	       sql_id, plan_hash_value ),
	a AS (
	SELECT sql_id, plan_hash_value,
	       SUM(elapsed_time_total)/SUM(executions_total) avg_et_secs
	  FROM dba_hist_sqlstat
	 WHERE sql_id = TRIM(:sql_id)
	   AND executions_total > 0
	 GROUP BY
	       sql_id, plan_hash_value )
	select * from 
	(SELECT p.sql_id, p.plan_hash_value, NVL(m.avg_et_secs, a.avg_et_secs) avg_et_secs
	  FROM p, m, a
	  WHERE p.plan_hash_value = m.plan_hash_value(+)
	  AND p.plan_hash_value = a.plan_hash_value(+)
	  ORDER BY avg_et_secs )
	WHERE rownum < 4;

BEGIN
	DBMS_OUTPUT.PUT_LINE('REM');
	DBMS_OUTPUT.PUT_LINE('REM');
	DBMS_OUTPUT.PUT_LINE('REM');
	DBMS_OUTPUT.PUT_LINE('REM ################################################################################');
	DBMS_OUTPUT.PUT_LINE('REM       SQL PROFILE Script START      ');
	DBMS_OUTPUT.PUT_LINE('REM (if multiple plans available, you will see multiple scripts appended below  ');
	DBMS_OUTPUT.PUT_LINE('REM (Extract SQL profile for your plan hash value into a separate file to execute');
	DBMS_OUTPUT.PUT_LINE('REM ################################################################################');
	DBMS_OUTPUT.PUT_LINE('REM');
	DBMS_OUTPUT.PUT_LINE('REM');
	DBMS_OUTPUT.PUT_LINE('REM');
	DBMS_OUTPUT.PUT_LINE('REM');
	DBMS_OUTPUT.PUT_LINE('REM This file has SQL Profile Scripts for the following Plan Hash Values');

    OPEN c_phv;
    LOOP
        FETCH c_phv INTO c_sql_id, c_plan_hash_value, c_avg_et_secs ;
	   EXIT WHEN c_phv%notfound; 
        DBMS_OUTPUT.PUT_LINE('REM       Plan Hash Value : '||c_plan_hash_value||'          Avg Elapsed Time :'||round(c_avg_et_secs/1000,2)||'ms');
    END LOOP; 
    CLOSE c_phv; 


   OPEN c_phv; 
	DBMS_OUTPUT.PUT_LINE('REM');

   LOOP 
	   FETCH c_phv into c_sql_id, c_plan_hash_value, c_avg_et_secs ; 
	   EXIT WHEN c_phv%notfound; 

		--dbms_output.put_line('@coe_xfr_sql_profile '||c_sql_id || ' ' || c_plan_hash_value ); 

	   
	   -- get sql_text from memory ------------------------------------------------------------------

	   BEGIN 
	    --DBMS_OUTPUT.PUT_LINE('SQL ID: '||c_sql_id);
	  
		  FOR i IN (SELECT DISTINCT piece, sql_text
			      FROM gv$sqltext_with_newlines
			     WHERE sql_id = TRIM(c_sql_id)
			     ORDER BY 1, 2)
		  LOOP
	    --DBMS_OUTPUT.PUT_LINE('Inside SQL text Loop');
	    --DBMS_OUTPUT.PUT_LINE('SQL Text: '||:sql_text);
	    --DBMS_OUTPUT.PUT_LINE(' ');

		    IF :sql_text IS NULL THEN
		      DBMS_LOB.CREATETEMPORARY(:sql_text, TRUE);
		      DBMS_LOB.OPEN(:sql_text, DBMS_LOB.LOB_READWRITE);
		    END IF;
		    -- removes NULL characters
		    l_sql_text := REPLACE(i.sql_text, CHR(00), ' ');
		    -- adds a NULL character at the end of each line
		  END LOOP;
		  -- if found in memory then sql_text is not null
		  IF :sql_text IS NOT NULL THEN
		    DBMS_LOB.CLOSE(:sql_text);
		  END IF;
		EXCEPTION
		  WHEN OTHERS THEN
		    DBMS_OUTPUT.PUT_LINE('getting sql_text from memory: '||SQLERRM);
		    :sql_text := NULL;
	    END;
	


	--   SELECT :sql_text FROM DUAL;

	-- get sql_text from awr ------------------------------------------------------------------
	    BEGIN
		  IF :sql_text IS NULL OR NVL(DBMS_LOB.GETLENGTH(:sql_text), 0) = 0 THEN
		    SELECT sql_text
		      INTO :sql_text2
		      FROM dba_hist_sqltext
		     WHERE sql_id = TRIM(c_sql_id)
		       AND sql_text IS NOT NULL
		       AND ROWNUM = 1;
		  END IF;
		  -- if found in awr then sql_text2 is not null
		  IF :sql_text2 IS NOT NULL THEN
		    l_clob_size := NVL(DBMS_LOB.GETLENGTH(:sql_text2), 0);
		    l_offset := 1;
		    DBMS_LOB.CREATETEMPORARY(:sql_text, TRUE);
		    DBMS_LOB.OPEN(:sql_text, DBMS_LOB.LOB_READWRITE);
		    -- store in clob as 64 character pieces plus a NUL character at the end of each piece
		    WHILE l_offset < l_clob_size
		    LOOP
		      IF l_clob_size - l_offset > 64 THEN
			l_sql_text := REPLACE(DBMS_LOB.SUBSTR(:sql_text2, 64, l_offset), CHR(00), ' ');
		      ELSE -- last piece
			l_sql_text := REPLACE(DBMS_LOB.SUBSTR(:sql_text2, l_clob_size - l_offset + 1, l_offset), CHR(00), ' ');
		      END IF;
		      DBMS_LOB.WRITEAPPEND(:sql_text, LENGTH(l_sql_text) + 1, l_sql_text||CHR(00));
		      l_offset := l_offset + 64;
		    END LOOP;
		    DBMS_LOB.CLOSE(:sql_text);
		  END IF;
		EXCEPTION
		  WHEN OTHERS THEN
		    DBMS_OUTPUT.PUT_LINE('getting sql_text from awr: '||SQLERRM);
		    :sql_text := NULL;
	    END;

	--	SELECT :sql_text2 FROM DUAL;
	--	SELECT :sql_text FROM DUAL;

	-- validate sql_text
	--SET TERM ON;
	BEGIN
	  IF :sql_text IS NULL THEN
	    RAISE_APPLICATION_ERROR(-20100, 'SQL_TEXT for SQL_ID c_sql_id. was not found in memory (gv$sqltext_with_newlines) or AWR (dba_hist_sqltext).');
	  END IF;
	END;
	   


	-- get other_xml from memory ------------------------------------------------------------------
	BEGIN
	  FOR i IN (SELECT other_xml
		      FROM gv$sql_plan
		     WHERE sql_id = TRIM(c_sql_id )
		       AND plan_hash_value = TO_NUMBER(TRIM(c_plan_hash_value))
		       AND other_xml IS NOT NULL
		     ORDER BY
			   child_number, id)
	  LOOP
	    :other_xml := i.other_xml;
	    EXIT; -- 1st
	  END LOOP;
	EXCEPTION
	  WHEN OTHERS THEN
	    DBMS_OUTPUT.PUT_LINE('getting other_xml from memory: '||SQLERRM);
	    :other_xml := NULL;
	END;
	


	--------- get other_xml from awr ------------------------------------------------------------------
	BEGIN
	  IF :other_xml IS NULL OR NVL(DBMS_LOB.GETLENGTH(:other_xml), 0) = 0 THEN
	    FOR i IN (SELECT other_xml
			FROM dba_hist_sql_plan
		       WHERE sql_id = TRIM(c_sql_id)
			 AND plan_hash_value = TO_NUMBER(TRIM(c_plan_hash_value))
			 AND other_xml IS NOT NULL
		       ORDER BY
			     id)
	    LOOP
	      :other_xml := i.other_xml;
	      EXIT; -- 1st
	    END LOOP;
	  END IF;
	EXCEPTION
	  WHEN OTHERS THEN
	    DBMS_OUTPUT.PUT_LINE('getting other_xml from awr: '||SQLERRM);
	    :other_xml := NULL;
	END;



	-- get other_xml from memory from modified SQL ------------------------------------------------------------------
	BEGIN
	  IF :other_xml IS NULL OR NVL(DBMS_LOB.GETLENGTH(:other_xml), 0) = 0 THEN
	    FOR i IN (SELECT other_xml
			FROM gv$sql_plan
		       WHERE plan_hash_value = TO_NUMBER(TRIM(c_plan_hash_value))
			 AND other_xml IS NOT NULL
		       ORDER BY
			     child_number, id)
	    LOOP
	      :other_xml := i.other_xml;
	      EXIT; -- 1st
	    END LOOP;
	  END IF;
	EXCEPTION
	  WHEN OTHERS THEN
	    DBMS_OUTPUT.PUT_LINE('getting other_xml from memory: '||SQLERRM);
	    :other_xml := NULL;
	END;
	

	-- get other_xml from awr from modified SQL ------------------------------------------------------------------
	BEGIN
	  IF :other_xml IS NULL OR NVL(DBMS_LOB.GETLENGTH(:other_xml), 0) = 0 THEN
	    FOR i IN (SELECT other_xml
			FROM dba_hist_sql_plan
		       WHERE plan_hash_value = TO_NUMBER(TRIM(c_plan_hash_value))
			 AND other_xml IS NOT NULL
		       ORDER BY
			     id)
	    LOOP
	      :other_xml := i.other_xml;
	      EXIT; -- 1st
	    END LOOP;
	  END IF;
	EXCEPTION
	  WHEN OTHERS THEN
	    DBMS_OUTPUT.PUT_LINE('getting other_xml from awr: '||SQLERRM);
	    :other_xml := NULL;
	END;



	--SET TERM ON;
	BEGIN
	  IF :other_xml IS NULL THEN
	    RAISE_APPLICATION_ERROR(-20101, 'PLAN for SQL_ID c_sql_id. and PHV c_plan_hash_value. was not found in memory (gv$sql_plan) or AWR (dba_hist_sql_plan).');
	  END IF;
	END;


--==========================END MAIN SQL PROFILE CREATION SCRIPT =========================================

-- generates script that creates sql profile in target system:
	BEGIN

		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM **************************************************************************************************************');
		DBMS_OUTPUT.PUT_LINE('REM     SQL PROFILE Script for Plan Hash Value : '|| c_plan_hash_value||'        STARTS HERE');  
		DBMS_OUTPUT.PUT_LINE('REM     Script: coe_xfr_sql_profile_'||c_sql_id||'_'||c_plan_hash_value||'.sql');
		DBMS_OUTPUT.PUT_LINE('REM ');
		DBMS_OUTPUT.PUT_LINE('REM ');
		DBMS_OUTPUT.PUT_LINE('REM     Execute coe_xfr_sql_profile_'||c_sql_id||'_'||c_plan_hash_value||'.sql');
		DBMS_OUTPUT.PUT_LINE('REM     on TARGET system in order to create a custom SQL Profile with ');
		DBMS_OUTPUT.PUT_LINE('REM     plan '||c_plan_hash_value||' linked to adjusted sql_text.');
		DBMS_OUTPUT.PUT_LINE('REM ');
		DBMS_OUTPUT.PUT_LINE('REM   Copy text from here till it says ''SQL PROFILE Script for Plan Hash Value : '|| c_plan_hash_value||' ENDS HERE''');  
		DBMS_OUTPUT.PUT_LINE('REM **************************************************************************************************************');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');

		  DBMS_OUTPUT.PUT_LINE('SPO coe_xfr_sql_profile_'||c_sql_id||'_'||c_plan_hash_value||'.log;');
		  DBMS_OUTPUT.PUT_LINE('SET ECHO ON TERM ON LIN 2000 TRIMS ON SERVEROUT ON SIZE UNLIMITED NUMF 99999999999999999999;');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('REM $Header: pdbcs/no_ship_src/service/scripts/ops/adb_sql/diagsql/sqlhc.sql /main/3 2022/03/07 01:33:04 scharala Exp $');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('REM Copyright (c) 2000-2012, Oracle Corporation. All rights reserved.');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('REM AUTHOR');
		  DBMS_OUTPUT.PUT_LINE('REM   carlos.sierra@oracle.com');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('REM SCRIPT');
		  DBMS_OUTPUT.PUT_LINE('REM   coe_xfr_sql_profile_'||c_sql_id||'_'||c_plan_hash_value||'.sql');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('REM DESCRIPTION');
		  DBMS_OUTPUT.PUT_LINE('REM   This script is generated by coe_xfr_sql_profile.sql');
		  DBMS_OUTPUT.PUT_LINE('REM   It contains the SQL*Plus commands to create a custom');
		  DBMS_OUTPUT.PUT_LINE('REM   SQL Profile for SQL_ID '||c_sql_id||' based on plan hash');
		  DBMS_OUTPUT.PUT_LINE('REM   value '||c_plan_hash_value||'.');
		  DBMS_OUTPUT.PUT_LINE('REM   The custom SQL Profile to be created by this script');
		  DBMS_OUTPUT.PUT_LINE('REM   will affect plans for SQL commands with signature');
		  DBMS_OUTPUT.PUT_LINE('REM   matching the one for SQL Text below.');
		  DBMS_OUTPUT.PUT_LINE('REM   Review SQL Text and adjust accordingly.');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('REM PARAMETERS');
		  DBMS_OUTPUT.PUT_LINE('REM   None.');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('REM EXAMPLE');
		  DBMS_OUTPUT.PUT_LINE('REM   SQL> START coe_xfr_sql_profile_'||c_sql_id||'_'||c_plan_hash_value||'.sql;');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('REM NOTES');
		  DBMS_OUTPUT.PUT_LINE('REM   1. Should be run as SYSTEM or SYSDBA.');
		  DBMS_OUTPUT.PUT_LINE('REM   2. User must have CREATE ANY SQL PROFILE privilege.');
		  DBMS_OUTPUT.PUT_LINE('REM   3. SOURCE and TARGET systems can be the same or similar.');
		  DBMS_OUTPUT.PUT_LINE('REM   4. To drop this custom SQL Profile after it has been created:');
		  DBMS_OUTPUT.PUT_LINE('REM      EXEC DBMS_SQLTUNE.DROP_SQL_PROFILE(''coe_'||c_sql_id||'_'||c_plan_hash_value||''');');
		  DBMS_OUTPUT.PUT_LINE('REM   5. Be aware that using DBMS_SQLTUNE requires a license');
		  DBMS_OUTPUT.PUT_LINE('REM      for the Oracle Tuning Pack.');
		  DBMS_OUTPUT.PUT_LINE('REM   6. If you modified a SQL putting Hints in order to produce a desired');
		  DBMS_OUTPUT.PUT_LINE('REM      Plan, you can remove the artifical Hints from SQL Text pieces below.');
		  DBMS_OUTPUT.PUT_LINE('REM      By doing so you can create a custom SQL Profile for the original');
		  DBMS_OUTPUT.PUT_LINE('REM      SQL but with the Plan captured from the modified SQL (with Hints).');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('WHENEVER SQLERROR EXIT SQL.SQLCODE;');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('VAR signature NUMBER;');
		  DBMS_OUTPUT.PUT_LINE('VAR signaturef NUMBER;');
		  DBMS_OUTPUT.PUT_LINE('REM');
		  DBMS_OUTPUT.PUT_LINE('DECLARE');
		  DBMS_OUTPUT.PUT_LINE('sql_txt CLOB;');
		  DBMS_OUTPUT.PUT_LINE('h       SYS.SQLPROF_ATTR;');
		  DBMS_OUTPUT.PUT_LINE('db_sql_signature NUMBER;');
		  DBMS_OUTPUT.PUT_LINE('PROCEDURE wa (p_line IN VARCHAR2) IS');
		  DBMS_OUTPUT.PUT_LINE('BEGIN');
		  DBMS_OUTPUT.PUT_LINE('DBMS_LOB.WRITEAPPEND(sql_txt, LENGTH(p_line), p_line);');
		  DBMS_OUTPUT.PUT_LINE('END wa;');
		  DBMS_OUTPUT.PUT_LINE('BEGIN');
		  DBMS_OUTPUT.PUT_LINE('DBMS_LOB.CREATETEMPORARY(sql_txt, TRUE);');
		  DBMS_OUTPUT.PUT_LINE('DBMS_LOB.OPEN(sql_txt, DBMS_LOB.LOB_READWRITE);');
		  DBMS_OUTPUT.PUT_LINE('-- SQL Text pieces below do not have to be of same length.');
		  DBMS_OUTPUT.PUT_LINE('-- So if you edit SQL Text (i.e. removing temporary Hints),');
		  DBMS_OUTPUT.PUT_LINE('-- there is no need to edit or re-align unmodified pieces.');
		  l_clob_size := NVL(DBMS_LOB.GETLENGTH(:sql_text), 0);
		  l_offset := 1;
		  WHILE l_offset < l_clob_size
		  LOOP
		    l_pos := DBMS_LOB.INSTR(:sql_text, CHR(00), l_offset);
		    IF l_pos > 0 THEN
		      l_len := l_pos - l_offset;
		    ELSE -- last piece
		      l_len := l_clob_size - l_pos + 1;
		    END IF;
		    l_sql_text := DBMS_LOB.SUBSTR(:sql_text, l_len, l_offset);
		    /* cannot do such 3 replacement since a line could end with a comment using "--"
		    l_sql_text := REPLACE(l_sql_text, CHR(10), ' '); -- replace LF with SP
		    l_sql_text := REPLACE(l_sql_text, CHR(13), ' '); -- replace CR with SP
		    l_sql_text := REPLACE(l_sql_text, CHR(09), ' '); -- replace TAB with SP
		    */
		    l_offset := l_offset + l_len + 1;
		    IF l_len > 0 THEN
		      IF INSTR(l_sql_text, '''[') + INSTR(l_sql_text, ']''') = 0 THEN
			l_sql_text := '['||l_sql_text||']';
		      ELSIF INSTR(l_sql_text, '''{') + INSTR(l_sql_text, '}''') = 0 THEN
			l_sql_text := '{'||l_sql_text||'}';
		      ELSIF INSTR(l_sql_text, '''<') + INSTR(l_sql_text, '>''') = 0 THEN
			l_sql_text := '<'||l_sql_text||'>';
		      ELSIF INSTR(l_sql_text, '''(') + INSTR(l_sql_text, ')''') = 0 THEN
			l_sql_text := '('||l_sql_text||')';
		      ELSIF INSTR(l_sql_text, '''"') + INSTR(l_sql_text, '"''') = 0 THEN
			l_sql_text := '"'||l_sql_text||'"';
		      ELSIF INSTR(l_sql_text, '''|') + INSTR(l_sql_text, '|''') = 0 THEN
			l_sql_text := '|'||l_sql_text||'|';
		      ELSIF INSTR(l_sql_text, '''~') + INSTR(l_sql_text, '~''') = 0 THEN
			l_sql_text := '~'||l_sql_text||'~';
		      ELSIF INSTR(l_sql_text, '''^') + INSTR(l_sql_text, '^''') = 0 THEN
			l_sql_text := '^'||l_sql_text||'^';
		      ELSIF INSTR(l_sql_text, '''@') + INSTR(l_sql_text, '@''') = 0 THEN
			l_sql_text := '@'||l_sql_text||'@';
		      ELSIF INSTR(l_sql_text, '''#') + INSTR(l_sql_text, '#''') = 0 THEN
			l_sql_text := '#'||l_sql_text||'#';
		      ELSIF INSTR(l_sql_text, '''%') + INSTR(l_sql_text, '%''') = 0 THEN
			l_sql_text := '%'||l_sql_text||'%';
		      ELSIF INSTR(l_sql_text, '''$') + INSTR(l_sql_text, '$''') = 0 THEN
			l_sql_text := '$'||l_sql_text||'$';
		      ELSE
			l_sql_text := CHR(96)||l_sql_text||CHR(96);
		      END IF;
		      DBMS_OUTPUT.PUT_LINE('wa(q'''||l_sql_text||''');');
		    END IF;
		  END LOOP;
		  DBMS_OUTPUT.PUT_LINE('DBMS_LOB.CLOSE(sql_txt);');
		  DBMS_OUTPUT.PUT_LINE('h := SYS.SQLPROF_ATTR(');
		  DBMS_OUTPUT.PUT_LINE('q''[BEGIN_OUTLINE_DATA]'',');
		  FOR i IN (SELECT /*+ opt_param('parallel_execution_enabled', 'false') */
				   SUBSTR(EXTRACTVALUE(VALUE(d), '/hint'), 1, 4000) hint
			      FROM TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(:other_xml), '/*/outline_data/hint'))) d)
		  LOOP
		    l_hint := i.hint;
		    WHILE NVL(LENGTH(l_hint), 0) > 0
		    LOOP
		      IF LENGTH(l_hint) <= 500 THEN
			DBMS_OUTPUT.PUT_LINE('q''['||l_hint||']'',');
			l_hint := NULL;
		      ELSE
			l_pos := INSTR(SUBSTR(l_hint, 1, 500), ' ', -1);
			DBMS_OUTPUT.PUT_LINE('q''['||SUBSTR(l_hint, 1, l_pos)||']'',');
			l_hint := '   '||SUBSTR(l_hint, l_pos);
		      END IF;
		    END LOOP;
		  END LOOP;
		  DBMS_OUTPUT.PUT_LINE('q''[END_OUTLINE_DATA]'');');
		  DBMS_OUTPUT.PUT_LINE(':signature := DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(sql_txt);');
		  DBMS_OUTPUT.PUT_LINE(':signaturef := DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE(sql_txt, TRUE);');
		  DBMS_OUTPUT.PUT_LINE('begin');
		  DBMS_OUTPUT.PUT_LINE('  begin');
		  DBMS_OUTPUT.PUT_LINE('    select exact_matching_signature');
		  DBMS_OUTPUT.PUT_LINE('    into db_sql_signature');
		  DBMS_OUTPUT.PUT_LINE('    from gv$sql');
		  DBMS_OUTPUT.PUT_LINE('    where sql_id = '''||c_sql_id||'''');
		  DBMS_OUTPUT.PUT_LINE('    and rownum = 1;');
		  DBMS_OUTPUT.PUT_LINE('  if db_sql_signature = :signature');
		  DBMS_OUTPUT.PUT_LINE('  then');
		  DBMS_OUTPUT.PUT_LINE('    dbms_output.put_line(''SQL signature matches EXACT_MATCHING_SIGNATURE from GV$SQL.'');');
		  DBMS_OUTPUT.PUT_LINE('  else');
		  DBMS_OUTPUT.PUT_LINE('    dbms_output.put_line(''SQL signature '' || to_char(:signature) || '' does not match EXACT_MATCHING_SIGNATURE '' || to_char(db_sql_signature) ||  '' from GV$SQL'');');
		  DBMS_OUTPUT.PUT_LINE('    RAISE_APPLICATION_ERROR(-20100, ''SQL signature and GV$SQL exact matching signature do not match.'');');
		  DBMS_OUTPUT.PUT_LINE('  end if;');
		  DBMS_OUTPUT.PUT_LINE('  exception');
		  DBMS_OUTPUT.PUT_LINE('    when no_data_found then');
		  DBMS_OUTPUT.PUT_LINE('      db_sql_signature := -1;');
		  DBMS_OUTPUT.PUT_LINE('    when others then');
		  DBMS_OUTPUT.PUT_LINE('      raise;');
		  DBMS_OUTPUT.PUT_LINE('  end;');
		  DBMS_OUTPUT.PUT_LINE('  if db_sql_signature = -1');
		  DBMS_OUTPUT.PUT_LINE('  then');
		  DBMS_OUTPUT.PUT_LINE('    begin ');
		  DBMS_OUTPUT.PUT_LINE('      select force_matching_signature');
		  DBMS_OUTPUT.PUT_LINE('      into db_sql_signature');
		  DBMS_OUTPUT.PUT_LINE('      from dba_hist_sqlstat');
		  DBMS_OUTPUT.PUT_LINE('      where sql_id = '''||c_sql_id||'''');
		  DBMS_OUTPUT.PUT_LINE('      and force_matching_signature != 0');
		  DBMS_OUTPUT.PUT_LINE('      and rownum = 1;');
		  DBMS_OUTPUT.PUT_LINE('      if db_sql_signature = :signaturef');
		  DBMS_OUTPUT.PUT_LINE('      then');
		  DBMS_OUTPUT.PUT_LINE('        dbms_output.put_line(''SQL force signature matches FORCE_MATCHING_SIGNATURE from DBA_HIST_SQLSTAT.'');');
		  DBMS_OUTPUT.PUT_LINE('      else');
		  DBMS_OUTPUT.PUT_LINE('        dbms_output.put_line(''Force SQL signature '' || to_char(:signaturef) || '' does not match FORCE_MATCHING_SIGNATURE '' || to_char(db_sql_signature) || '' from DBA_HIST_SQLSTAT.'');');
		  DBMS_OUTPUT.PUT_LINE('        RAISE_APPLICATION_ERROR(-20100, ''Force SQL signature and DBA_HIST_SQLSTAT force matching signature do not match.'');');
		  DBMS_OUTPUT.PUT_LINE('      end if;');
		  DBMS_OUTPUT.PUT_LINE('    exception ');
		  DBMS_OUTPUT.PUT_LINE('      when no_data_found then');
		  DBMS_OUTPUT.PUT_LINE('        dbms_output.put_line(''Unable to validate SQL signature because SQL_ID was not found in GV$SQL or DBA_HIST_SQLSTAT.'');');
		  DBMS_OUTPUT.PUT_LINE('      when others then');
		  DBMS_OUTPUT.PUT_LINE('        raise;');
		  DBMS_OUTPUT.PUT_LINE('    end;');
		  DBMS_OUTPUT.PUT_LINE('  end if;');
		  DBMS_OUTPUT.PUT_LINE('end;');
		  DBMS_OUTPUT.PUT_LINE('DBMS_SQLTUNE.IMPORT_SQL_PROFILE (');
		  DBMS_OUTPUT.PUT_LINE('sql_text    => sql_txt,');
		  DBMS_OUTPUT.PUT_LINE('profile     => h,');
		  DBMS_OUTPUT.PUT_LINE('name        => ''coe_'||c_sql_id||'_'||c_plan_hash_value||''',');
		  DBMS_OUTPUT.PUT_LINE('description => ''coe '||c_sql_id||' '||c_plan_hash_value||' ''||:signature||'' ''||:signaturef||'''',');
		  DBMS_OUTPUT.PUT_LINE('category    => ''DEFAULT'',');
		  DBMS_OUTPUT.PUT_LINE('validate    => TRUE,');
		  DBMS_OUTPUT.PUT_LINE('replace     => TRUE,');
		  DBMS_OUTPUT.PUT_LINE('force_match => FALSE /* TRUE:FORCE (match even when different literals in SQL). FALSE:EXACT (similar to CURSOR_SHARING) */ );');
		  DBMS_OUTPUT.PUT_LINE('DBMS_LOB.FREETEMPORARY(sql_txt);');
		  DBMS_OUTPUT.PUT_LINE('END;');
		  DBMS_OUTPUT.PUT_LINE('/');
		  DBMS_OUTPUT.PUT_LINE('WHENEVER SQLERROR CONTINUE');
		  DBMS_OUTPUT.PUT_LINE('SET ECHO OFF;');
		  DBMS_OUTPUT.PUT_LINE('PRINT signature');
		  DBMS_OUTPUT.PUT_LINE('PRINT signaturef');
		  DBMS_OUTPUT.PUT_LINE('PRO');
		  DBMS_OUTPUT.PUT_LINE('PRO ... manual custom SQL Profile has been created');
		  DBMS_OUTPUT.PUT_LINE('PRO');
		  DBMS_OUTPUT.PUT_LINE('SET TERM ON ECHO OFF LIN 80 TRIMS OFF NUMF "";');
		  DBMS_OUTPUT.PUT_LINE('SPO OFF;');
		  DBMS_OUTPUT.PUT_LINE('PRO');
		  DBMS_OUTPUT.PUT_LINE('PRO COE_XFR_SQL_PROFILE_'||c_sql_id||'_'||c_plan_hash_value||' completed');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM **************************************************************************************************************');
		DBMS_OUTPUT.PUT_LINE('REM *******    SQL PROFILE Script for Plan Hash Value : '|| c_plan_hash_value||'         ENDS HERE');  
		DBMS_OUTPUT.PUT_LINE('REM **************************************************************************************************************');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');
		DBMS_OUTPUT.PUT_LINE('REM');

	END;


--==========================END MAIN SQL PROFILE CREATION SCRIPT =========================================


	-- Main Cursor check
	   EXIT WHEN c_phv%notfound; 
   END LOOP; 
   CLOSE c_phv; 
DBMS_OUTPUT.PUT_LINE('REM ');
DBMS_OUTPUT.PUT_LINE('REM ');
DBMS_OUTPUT.PUT_LINE('REM ');
DBMS_OUTPUT.PUT_LINE('REM ################################################################################');
DBMS_OUTPUT.PUT_LINE('REM               ALL SQL PROFILE Scripts END ');
DBMS_OUTPUT.PUT_LINE('REM ################################################################################');
DBMS_OUTPUT.PUT_LINE('REM');
DBMS_OUTPUT.PUT_LINE('REM');

END; 
/
SPO OFF;

--SET DEF ON TERM OFF ECHO OFF FEED OFF VER OFF HEA ON LIN 2000 PAGES 100 LONG 8000000 LONGC 800000 TRIMS ON TI OFF TIMI OFF SERVEROUT ON SIZE 1000000 NUMF "" SQLP SQL>;
--SET TERM ON ECHO OFF FEED ON VER ON HEA ON LIN 80 PAGES 14 LONG 80 LONGC 80 TRIMS OFF TI OFF TIMI OFF SERVEROUT OFF 
--SET DEF ON TERM ON ECHO OFF FEED OFF VER OFF HEA ON LIN 2000 SERVEROUT OFF

--SET TERM ON ECHO OFF FEED OFF VER OFF HEA OFF LIN 2000 PAGES 1000 LONG 2000000 LONGC 2000 TRIMS ON TI OFF TIMI OFF SERVEROUT ON SIZE 1000000 NUMF "" ;

rem PRO end -->
rem SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
rem SELECT :det FROM DUAL;
rem SELECT '<!-- '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS')||' -->' FROM dual;
--SPO OFF;



/*================================= SQL Profile - Vivek Jha END=================================*/



/**************************************************************************************************
 *
 * Uday.PSR.v6
 * - ALL binds
 *   - monitored 
 *   - peeked (mem, awr)
 *   - captured (mem, awr)
 *
 **************************************************************************************************/

EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: All Bind Values ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait

SET heading on pages 1000 lines 300 trimspool on

col plan_hash_value for 999999999999 heading "Plan Hash|Value"
col position for 999 heading "Position"
col name for a30 heading "Bind Variable Name"
col peeked_value for a30 heading "Peeked Value"
col captured_value for a31 heading "Captured Value"
col dup_pos for 999 heading "Dup|Pos"
col dtype for a15 heading "Data Type"
col datatype_string for a15 heading "Data Type"
col max_length for 9999 heading "Max|Len"
col ch# for 999 heading "Child|Num"
col plan_gen_ts for a21 heading "Plan Generated|On"
col LAST_CAPTURED for a21 heading "Captured|On"
col avg_et for 999999.999 heading "Avg|Elapsed|Time"
col avg_bg for 9999999999 heading "Avg|Buffer|Gets"
col sqlmon_et for 999999.999 heading "Elapsed|Time"
col sqlmon_bg for 9999999999 heading "Buffer|Gets"
col sqlmon_val for a31 heading "Monitored Bind|Value"
col sql_exec_start for a22 heading "SQL Exec Start"
col instance_number for 99 heading "Inst#"
col END_INTERVAL_TIME for a30 heading "Snapshot"

REM Pushkar - converted binds to html format
SPO ^^files_prefix._13_all_bind_values.html;

PRO <style type="text/css">
PRO body {font:10pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
PRO table {font-size:8pt; color:black; background:white;}
PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td {text-align:left; background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO </style>

set markup html on


PRO
PRO Sections:
PRO --------;
PRO  1. Peeked Vs Monitored Bind Values - In Memory
PRO  2. Peeked Vs Captured  Bind Values - In Memory
PRO  3. Peeked Vs Captured  Bind Values - In AWR
PRO
PRO -----------------------------------------------;
PRO Peeked Vs Monitored Bind Values - In Memory
PRO -----------------------------------------------;

break on inst_id on sql_exec_id on sql_exec_start on plan_gen_ts on plan_hash_value on ch# on sqlmon_et on sqlmon_bg skip 1

-- set timing on
with peeked as
(
  SELECT /*+ materialize */ inst_id, sql_id, plan_hash_value, address, child_address, child_number, timestamp,
         to_number(extractValue(value(d), '/bind/@pos')) position,
         extractValue(value(d), '/bind/@nam') name,
         max(extractValue(value(d), '/bind')) over(partition by inst_id, sql_id, plan_hash_value, address, child_address, child_number, extractValue(value(d), '/bind/@nam')) value,
         to_number(extractValue(value(d), '/bind/@ppo')) dup_pos,
         extractValue(value(d), '/bind/@dty') dtype,
         to_number(extractValue(value(d), '/bind/@mxl')) max_length
    FROM
         gv$sql_plan c
         , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.other_xml ), '/*/peeked_binds/bind'))) D
   where c.sql_id = :sql_id
     and c.other_xml is not null
   -- order by sql_id, to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos'))
)
,
peeked_val as
(
  select peeked.*,
         (case when dtype = 1 then 'VARCHAR2(' || max_length || ')'
               when dtype = 2 then 'NUMBER(' || max_length || ')'
               when dtype = 12 then 'Date(' || max_length || ')'
               when dtype in (180, 181) then 'TIMESTAMP(' || max_length || ')'
          end
         ) datatype_string,
         case
           when dtype = 1  -- VARCHAR2
             then to_char(utl_raw.cast_to_varchar2(value))
           when dtype = 2  -- NUMBER
             then to_char(utl_raw.cast_to_number(value))
           when dtype = 12 -- Date
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                           + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00'))
           when dtype in (180, 181)  -- Timestamp and Timestamp with tz
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                            + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(value,15,8),'XXXXXXXX')  )
           else
              value
         end cvalue
    from peeked
   -- order by position
)
,
captured_binds as
(
  select sm.key, sm.inst_id, sm.sql_id, sm.sql_exec_id, sm.sql_exec_start, sm.sql_plan_hash_value, sm.sql_child_address, 
         round(sm.elapsed_time/1000000,2) elapsed_time, buffer_gets,
         to_number(extractvalue(value(b), '/bind/@pos')) position,
         extractvalue(value(b), '/bind/@name') name, 
         extractvalue(value(b), '/bind') captured_value,
         extractvalue(value(b), '/bind/@dtystr') datatype_string
   from
         gv$sql_monitor sm
         , table(xmlsequence(extract(xmltype(sm.binds_xml ), '/binds/bind'))) b
   where sm.sql_id = :sql_id
     and sm.binds_xml is not null
   -- ORDER BY inst_id, child_number, position, dup_position
)
select cb.inst_id, cb.sql_exec_id, to_char(cb.sql_exec_start, 'dd-mon-yy hh24:mi:ss') sql_exec_start, cb.sql_plan_hash_value 
       , max(pv.child_number) over(partition by cb.key) ch# 
       , to_char(max(pv.timestamp) over(partition by cb.key), 'dd-mon-yy hh24:mi:ss') plan_gen_ts 
       , cb.elapsed_time sqlmon_et, cb.buffer_gets sqlmon_bg
       , cb.position, cb.name
       , cb.datatype_string
       , pv.cvalue peeked_value
       , case when cb.datatype_string like 'TIMEST%' THEN
               rtrim(
                    to_char(100*(to_number(substr(cb.captured_value,1,2),'XX')-100)
                            + (to_number(substr(cb.captured_value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(cb.captured_value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(cb.captured_value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(cb.captured_value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(cb.captured_value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(cb.captured_value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(cb.captured_value,15,8),'XXXXXXXX')  
               )
              else cb.captured_value 
         end sqlmon_val 
  from peeked_val pv, captured_binds cb
 where 1 = 1
   and cb.inst_id = pv.inst_id
   and cb.sql_id  = pv.sql_id
   and cb.sql_child_address = pv.child_address
   and cb.sql_plan_hash_value = pv.plan_hash_value
   and cb.position = pv.position
   and cb.name = pv.name
 order by cb.inst_id, cb.sql_exec_id, cb.sql_exec_start, cb.sql_plan_hash_value, ch#, plan_gen_ts, cb.elapsed_time, cb.buffer_gets, cb.position
;
-- set timing off

clear breaks

PRO
PRO
PRO Peeked Vs Captured Bind Values - In Memory 
PRO ------------------------------------------;
PRO

break on inst_id on plan_hash_value on ch# on plan_gen_ts on avg_et on avg_bg skip 1

-- set timing on
with peeked as
(
  SELECT /*+ materialize */ inst_id, sql_id, plan_hash_value, address, child_address, child_number, timestamp,
         to_number(extractValue(value(d), '/bind/@pos')) position,
         extractValue(value(d), '/bind/@nam') name,
         extractValue(value(d), '/bind') value,
         to_number(extractValue(value(d), '/bind/@ppo')) dup_pos,
         extractValue(value(d), '/bind/@dty') dtype,
         to_number(extractValue(value(d), '/bind/@mxl')) max_length
    FROM
         gv$sql_plan c
         , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.other_xml ), '/*/peeked_binds/bind'))) D
   where c.sql_id = :sql_id
    and c.other_xml is not null
  -- order by sql_id, to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos'))
)
,
peeked_val as
(
  select peeked.*,
         (case when dtype = 1 then 'VARCHAR2'
               when dtype = 2 then 'NUMBER'
               when dtype = 12 then 'Date'
               when dtype in (180, 181) then 'TIMESTAMP'
          end
         ) datatype_string,
         case
           when dtype = 1  -- VARCHAR2
             then to_char(utl_raw.cast_to_varchar2(value))
           when dtype = 2  -- NUMBER
             then to_char(utl_raw.cast_to_number(value))
           when dtype = 12 -- Date
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                           + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00'))
           when dtype in (180, 181)  -- Timestamp and Timestamp with tz
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                            + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(value,15,8),'XXXXXXXX')  )
           else
              value
         end cvalue
    from peeked
   -- order by position
)
,
captured_binds as
(
  SELECT s.inst_id, s.sql_id, s.plan_hash_value, s.CHILD_ADDRESS, s.CHILD_NUMBER, s.address
         , s.first_load_time, s.last_active_time, s.executions, s.buffer_gets
         , round(s.elapsed_time/1000000/decode(s.executions, 0, 1, s.executions), 3) avg_et
         , round(s.buffer_gets/decode(s.executions, 0, 1, s.executions)) avg_bg
         , b.position, b.name
         , case when b.datatype_string like 'TIMESTAM%' then
                  substr(anydata.accesstimestamp(b.value_anydata),1,50)
                else b.value_string
           end captured_value
         , b.datatype_string
         , b.LAST_CAPTURED
    FROM gv$sql s, gv$sql_bind_capture b
   WHERE s.sql_id = :sql_id
     and b.inst_id = s.inst_id
     and b.sql_id  = s.sql_id
     and b.address = s.address
     and b.child_address = s.child_address
     and b.child_number = s.child_number
   -- ORDER BY inst_id, child_number, position, dup_position
)
select pv.inst_id, pv.plan_hash_value, pv.child_number ch#, to_char(pv.timestamp, 'dd-mon-yy hh24:mi:ss') plan_gen_ts, cb.avg_et, cb.avg_bg
       , pv.position, pv.name 
       -- , pv.datatype_string
       , case when cb.datatype_string is not null then cb.datatype_string else pv.datatype_string end datatype_string
       , pv.cvalue peeked_value
       , cb.captured_value
       -- , cb.last_captured
       , to_char(cb.last_captured, 'dd-mon-yy hh24:mi:ss') last_captured
  from peeked_val pv, captured_binds cb
 where 1 = 1
   and cb.inst_id = pv.inst_id
   and cb.sql_id  = pv.sql_id
   and cb.address = pv.address
   and cb.child_address = pv.child_address
   and cb.child_number = pv.child_number
   and cb.position = pv.position
   and cb.name = pv.name
 order by pv.timestamp, pv.plan_hash_value, pv.child_number, to_number(pv.position)
;
-- set timing off

clear breaks

PRO ---------------------------------------;
PRO Peeked Vs Captured Bind Values - In AWR 
PRO ---------------------------------------;
PRO

break on instance_number on snap_id on end_interval_time on plan_hash_value on plan_gen_ts on avg_et on avg_bg skip 1

-- set timing on
with peeked as 
(
  SELECT /*+ materialize */ sql_id, plan_hash_value, timestamp,
         to_number(extractValue(value(d), '/bind/@pos')) position,
         extractValue(value(d), '/bind/@nam') name,
         extractValue(value(d), '/bind') value,
         to_number(extractValue(value(d), '/bind/@ppo')) dup_pos,
         extractValue(value(d), '/bind/@dty') dtype,
         to_number(extractValue(value(d), '/bind/@mxl')) max_length
    FROM
         dba_hist_sql_plan c
         , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(c.other_xml ), '/*/peeked_binds/bind'))) D
   where 1=1
     and :license IN ('T', 'D')
     and c.dbid = ^^dbid.
     and c.sql_id = :sql_id
    and c.other_xml is not null
  -- order by sql_id, to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos'))
)
,
peeked_binds as 
(
  select /*+ materialize */ peeked.*,
         (case when dtype = 1 then 'VARCHAR2'
               when dtype = 2 then 'NUMBER'
               when dtype = 12 then 'Date'
               when dtype in (180, 181) then 'TIMESTAMP'
          end
         ) datatype_string, 
         case 
           when dtype = 1  -- VARCHAR2
             then to_char(utl_raw.cast_to_varchar2(value))
           when dtype = 2  -- NUMBER
             then to_char(utl_raw.cast_to_number(value))
           when dtype = 12 -- Date
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                           + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00'))
           when dtype in (180, 181)  -- Timestamp and Timestamp with tz
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                            + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(value,15,8),'XXXXXXXX')  )
           else
              value
         end cvalue
    from peeked
   -- order by position
)
,
captured_binds as
(
  select /*+ materialize */ s.dbid, s.instance_number, s.snap_id, s.sql_id, s.plan_hash_value, s.executions_delta, s.buffer_gets_delta,
         round(s.elapsed_time_delta/1000000/decode(s.executions_delta, 0, 1, s.executions_delta), 3) avg_et,
         round(s.buffer_gets_delta/decode(s.executions_delta, 0, 1, s.executions_delta)) avg_bg
         , b.position
         -- , bm.name -- PSRv7 - moved to main select to improve performance
         , case when b.datatype_string like 'TIMESTAM%' then
                  substr(anydata.accesstimestamp(b.value_anydata),1,50) 
                else b.value_string
           end captured_value
         , b.datatype_string
         , b.LAST_CAPTURED
         , ss.END_INTERVAL_TIME
    from dba_hist_sqlstat s, table(dbms_sqltune.extract_binds(s.bind_data)) b
         -- , dba_hist_sql_bind_metadata bm  -- PSRv7 - using only to get name, which we are already getting from peeked binds
         , dba_hist_snapshot ss
   where 1 = 1
     and :license IN ('T', 'D')
     and s.dbid = ^^dbid.
     and s.sql_id = :sql_id
     and s.bind_data is not null
     and s.dbid = ss.dbid
     and s.instance_number = ss.instance_number
     and s.snap_id = ss.snap_id
     and s.dbid = ss.dbid
     -- and bm.sql_id = s.sql_id      -- PSRv7
     -- AND bm.position = b.position  -- PSRv7
)
select cb.instance_number, cb.snap_id, cb.end_interval_time, pv.plan_hash_value, to_char(pv.timestamp, 'dd-mon-yy hh24:mi:ss') plan_gen_ts, cb.avg_et, cb.avg_bg, pv.position, pv.name 
       , case when cb.datatype_string is not null then cb.datatype_string else pv.datatype_string end datatype_string
       , pv.cvalue peeked_value
       , cb.captured_value, to_char(cb.last_captured, 'dd-mon-yy hh24:mi:ss') last_captured -- PSRv7
  from peeked_binds pv, captured_binds cb
 where 1 = 1
   and pv.plan_hash_value = cb.plan_hash_value
   and cb.position = pv.position
 order by pv.plan_hash_value, cb.instance_number, cb.snap_id, pv.timestamp, to_number(pv.position)
;
-- set timing off

PRO 
set markup html off
SPO OFF;

/**************************************************************************************************
 *
 * Uday.PSR.v10
 * - generate executable script with peeked binds
 *
 **************************************************************************************************/

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
PRO Please Wait

SET heading on pages 1000 lines 300 trimspool on

SPO ^^files_prefix._14_executable_script.sql

prompt --;
prompt -- executable script with peeked binds
prompt --;
set pages 10000 head off 
prompt set serveroutput off pages 1000 lines 250 trimspool on
prompt --;
prompt ;
prompt ;
prompt -- WHENEVER SQLERROR EXIT SQL.SQLCODE;
prompt -- ;
prompt -- begin
prompt --  if user <> 'FUSION' then
prompt --      RAISE_APPLICATION_ERROR(-20002, 'please login as FUSION user');
prompt --  end if;
prompt -- end;
prompt -- /
prompt -- ;
prompt -- Prompt  ;
prompt -- Prompt Enter SYSTEM password. It is used to fetch execution plan later in the script. It is not printed anywhere. 
prompt -- prompt  ;
prompt -- ;
prompt -- accept system_password CHAR PROMPT 'SYSTEM Password (not printed anywhere):  ' HIDE
prompt -- ;
prompt -- set timing off serveroutput off trimspool on lines 250 pages 10000 verify off
prompt -- ;
prompt -- COL time_stamp NEW_V time_stamp FOR A15;
prompt -- SELECT TO_CHAR(SYSDATE, 'ddmonHH24MISS') time_stamp FROM DUAL;
prompt -- ;
prompt -- col spoolf new_value spoolf
prompt -- select 'bug20902533_17m3u5qn35d8c_&&time_stamp' spoolf from dual;
prompt -- spool &&spoolf..log
prompt ;
prompt ;
prompt ;
prompt alter session set current_schema=fusion;;
prompt alter session set statistics_level=all;;
prompt -- alter session set tracefile_identifier = 'psr_17m3u5qn35d8c_&&time_stamp';
prompt -- alter session set events 'sql_trace wait=true, bind=true, plan_stat=adaptive: trace[rdbms.SQL_Optimizer.*]:10730 trace name context forever, level 1';
prompt -- ALTER SESSION SET events '10730 trace name context forever, level 1';
prompt -- ALTER session SET events='10235 trace name context forever, level 2:27072 trace name errorstack level 3';
prompt -- alter session set events 'trace[rdbms.SQL_Optimizer.*]';

prompt --;
prompt ;
prompt -- prompt ;
prompt -- prompt -----------;
prompt -- prompt attaching to FND Session...
prompt -- prompt -----------;
prompt -- prompt
prompt -- declare
prompt --   p_user_guid varchar2(32);
prompt --   p_user_name varchar2(60) := '43417567';
prompt --   fnd_session_id varchar2(32);
prompt -- BEGIN
prompt --   select SESSION_ID
prompt --     into fnd_session_id
prompt --     from ( select * from FUSION.FND_SESSIONS 
prompt --             where USER_NAME=p_user_name
prompt --             order by LAST_CONNECT desc
prompt --   ) where rownum <= 1
prompt --   ;
prompt --   ;
prompt --   fnd_session_mgmt.attach_session(fnd_session_id);
prompt -- END;
prompt -- /

with peeked as
(
  SELECT /*+ materialize */ distinct '1gv$' source, inst_id, sql_id, plan_hash_value, address, child_address, child_number, timestamp,
         -1 position, null name, null value, null dup_pos, null dtype, null max_length
    FROM
         gv$sql_plan sp
   where sp.sql_id = :sql_id
union all
  SELECT /*+ materialize */ '1gv$' source, inst_id, sql_id, plan_hash_value, address, child_address, child_number, timestamp,
         to_number(extractValue(value(d), '/bind/@pos')) position,
         extractValue(value(d), '/bind/@nam') name,
         max(extractValue(value(d), '/bind')) over(partition by inst_id, sql_id, plan_hash_value, address, child_address, child_number, extractValue(value(d), '/bind/@nam')) value,
         to_number(extractValue(value(d), '/bind/@ppo')) dup_pos,
         extractValue(value(d), '/bind/@dty') dtype,
         to_number(extractValue(value(d), '/bind/@mxl')) max_length
    FROM
         gv$sql_plan sp
         , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(sp.other_xml ), '/*/peeked_binds/bind'))) D
   where sp.sql_id = :sql_id
     and sp.other_xml is not null
   -- order by sql_id, to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos'))
union all
  SELECT /*+ materialize */ distinct '2awr' source, 0 inst_id, sql_id, plan_hash_value, null address, null child_address, -1 child_number, timestamp,
         -1 position, null name, null value, null dup_pos, null dtype, null max_length
    FROM
         dba_hist_sql_plan sp
   where 1=1
     and :license IN ('T', 'D')
     and sp.dbid = ^^dbid.
     and sp.sql_id = :sql_id
union all
  SELECT /*+ materialize */ '2awr' source, 0 inst_id, sql_id, plan_hash_value, null address, null child_address, -1 child_number, timestamp,
         to_number(extractValue(value(d), '/bind/@pos')) position,
         extractValue(value(d), '/bind/@nam') name,
         extractValue(value(d), '/bind') value,
         to_number(extractValue(value(d), '/bind/@ppo')) dup_pos,
         extractValue(value(d), '/bind/@dty') dtype,
         to_number(extractValue(value(d), '/bind/@mxl')) max_length
    FROM
         dba_hist_sql_plan sp
         , TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(sp.other_xml ), '/*/peeked_binds/bind'))) D
   where 1=1
     and :license IN ('T', 'D')
     and sp.dbid = ^^dbid.
     and sp.sql_id = :sql_id
     and sp.other_xml is not null
   -- order by sql_id, to_number(EXTRACTVALUE(VALUE(D), '/bind/@pos'))
)
,
peeked_val as
(
  select peeked.*,
         case regexp_substr(replace(name,':',''),'[[:digit:]]') when replace(name,':','') then Replace(name, ':', ':PSR') end bind_name,
         (case when dtype = 1 then 'VARCHAR2(' || max_length || ')'
               when dtype = 2 then 'NUMBER(' || max_length || ')'
               when dtype in (180, 181, 12) then 'VARCHAR2(30)'
--               when dtype in (180, 181) then 'TIMESTAMP(' || max_length || ')'
          end
         ) datatype_string,
         case
           when dtype = 1  -- VARCHAR2
             then to_char(utl_raw.cast_to_varchar2(value))
           when dtype = 2  -- NUMBER
             then to_char(utl_raw.cast_to_number(value))
           when dtype = 12 -- Date
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                           + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00'))
           when dtype in (180, 181)  -- Timestamp and Timestamp with tz
             then rtrim(
                    to_char(100*(to_number(substr(value,1,2),'XX')-100)
                            + (to_number(substr(value,3,2),'XX')-100),'fm0000')||'-'||
                    to_char(to_number(substr(value,5,2),'XX'),'fm00')||'-'||
                    to_char(to_number(substr(value,7,2),'XX'),'fm00')||' '||
                    to_char(to_number(substr(value,9,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,11,2),'XX')-1,'fm00')||':'||
                    to_char(to_number(substr(value,13,2),'XX')-1,'fm00')
                    ||'.'||to_number(substr(value,15,8),'XXXXXXXX')  )
           else
              value
         end cvalue
    from peeked
)
,
formatted_val as 
( 
    select peeked_val.*, 
	   decode(cvalue, NULL, 'NULL', cvalue) as nvalue,
       case when dtype in (12)       then q'{to_date     ('}'|| decode(cvalue, '-- ::'  , NULL, cvalue) || q'{','YYYY-MM-DD HH24:MI:SS' )}'
	        when dtype in (180, 181) then q'{to_timestamp('}'|| decode(cvalue, '-- ::.' , NULL, cvalue) || q'{','YYYY-MM-DD HH24:MI:SS.')}'
	   end dtvalue
    from peeked_val
)
select --* 
--       inst_id, sql_id, plan_hash_value, address, child_address, child_number, timestamp, position,
--       bind_name, name,
       case when position = -1 and source = '1gv$'
            then '--**************************************************************' || chr(10) || 
                 '-- Source: GV$, inst/phv/ch#: ' || inst_id ||'/'|| plan_hash_value || '/' || child_number || chr(10) ||
                 '--**************************************************************' 
            when position = -1 and source = '2awr' 
            then '--**************************************************************' || chr(10) || 
                 '-- Source: AWR, phv: ' || plan_hash_value || chr(10) ||
                 '--**************************************************************' 
            else  'variable ' || REPLACE(NAME, ':', '') || ' ' || case when datatype_string like 'NUMBER%' then 'NUMBER' else datatype_string end || chr(10) || 
                  'exec ' || name || ' := ' || case when datatype_string like 'NUMBER%' then nvalue  || ';' 
				                                    when dtype in (12, 180, 181)        then dtvalue || ';'
				                                    else                             '''' || cvalue  || ''';' 
											   end
       end str
  from formatted_val
 order by source, sql_id, inst_id, child_number, plan_hash_value, position
;

prompt --;
prompt --;
prompt COL time_stamp NEW_V time_stamp FOR A15
prompt SELECT TO_CHAR(SYSDATE, 'ddmonHH24MISS') time_stamp FROM DUAL;;
prompt --;
prompt --;

set pagesize 0 echo off timing off linesize 1000 trimspool on trim on long 2000000 longchunksize 2000000 feedback off

with str(sql_text) as 
(SELECT sql_fulltext
          FROM gv$sql
         WHERE sql_id = :sql_id
           AND ROWNUM = 1
        UNION ALL
        SELECT sql_text
          FROM dba_hist_sqltext
         WHERE sql_id = :sql_id
           AND ROWNUM = 1
       ),
cnt as (select sql_text, 
               case when regexp_count(sql_text,'(select|insert|update|delete|merge)[[:space:]]+(--\+|\/\*\+)',1,'i') > 0 then 1
               else 0 
               end hinted 
        from str)
select case when hinted=1 then regexp_replace(sql_text,'(select|insert|update|delete|merge)[[:space:]]+(--\+|\/\*\+)(.*)?(\*\/|.+)','\1 \2 gather_plan_statistics psr_^^time_stamp._^^sql_id \3 \4',1,1,'i')
       else regexp_replace(sql_text,'(select|insert|update|delete|merge)','\1 /*+ gather_plan_statistics psr_^^time_stamp._^^sql_id */',1,1,'i') 
       end
from cnt
 WHERE ROWNUM = 1; 

prompt ;;
prompt --;
prompt select * from table(dbms_xplan.display_cursor(NULL,NULL,'ADVANCED ALLSTATS LAST -OUTLINE -PROJECTION -ALIAS +PEEKED_BINDS'));;

spool off

/**************************************************************************************************/
/**************************************************************************************************/

/**************************************************************************************************
 *
 * Uday (Fusion PSR):
 * - Export table stats
 * - todo: write datapump code to export table...use export_stats_table.sql from this folder
 * - todo: will implement later once 12c version is stable and performing well
 **************************************************************************************************/

--udayRemove EXEC DBMS_APPLICATION_INFO.SET_CLIENT_INFO('^^method.: exporting table stats ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS'));
--udayRemove PRO
--udayRemove SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
--udayRemove PRO Please Wait
--udayRemove 
--udayRemove set serveroutput ON
--udayRemove SPO ^^script..log APP
--udayRemove PRO
--udayRemove PRO exporting table stats
--udayRemove PRO
--udayRemove DECLARE
--udayRemove   l_stat_tab_owner VARCHAR2(12) := '^^sessionuser.';
--udayRemove   l_stat_table     VARCHAR2(30) := '^^script._^^sql_id.';
--udayRemove   l_stat_id        VARCHAR2(32) :=  '^^script._^^sql_id.';
--udayRemove 
--udayRemove BEGIN
--udayRemove 
--udayRemove   dbms_stats.Create_stat_table (ownname => l_stat_tab_owner, stattab => l_stat_table);
--udayRemove 
--udayRemove   for cur_tables in (select object_owner owner, object_name table_name from gv$sql_plan 
--udayRemove                       where sql_id = '^^sql_id.' 
--udayRemove                         and object_type = 'TABLE'
--udayRemove                      union
--udayRemove                      select object_owner owner, object_name table_name from dba_hist_sql_plan 
--udayRemove                       where sql_id = '^^sql_id.' 
--udayRemove                         and object_type = 'TABLE'
--udayRemove                     )
--udayRemove   LOOP
--udayRemove     dbms_output.put_line('exporting stats for table: ' || cur_tables.table_name);
--udayRemove     DBMS_STATS.EXPORT_TABLE_STATS
--udayRemove             (
--udayRemove               ownname  => cur_tables.owner,
--udayRemove               tabname  => cur_tables.table_name,
--udayRemove               stattab  => l_stat_table,
--udayRemove               statid   => l_stat_id,
--udayRemove               cascade  => TRUE,
--udayRemove               statown  => l_stat_tab_owner
--udayRemove              );
--udayRemove 
--udayRemove     dbms_output.put_line('exporting table preferences: ' || cur_tables.table_name);
--udayRemove     DBMS_STATS.EXPORT_TABLE_PREFS
--udayRemove             (
--udayRemove               ownname  => cur_tables.owner,
--udayRemove               tabname  => cur_tables.table_name,
--udayRemove               stattab  => l_stat_table,
--udayRemove               statid   => l_stat_id,
--udayRemove               statown  => l_stat_tab_owner
--udayRemove              );
--udayRemove   END LOOP;
--udayRemove 
--udayRemove   dbms_output.Put_line('exporting system stats: ');
--udayRemove   DBMS_STATS.EXPORT_SYSTEM_STATS
--udayRemove             (
--udayRemove               stattab  => l_stat_table,
--udayRemove               statid   => l_stat_id,
--udayRemove               statown  => l_stat_tab_owner
--udayRemove              );
--udayRemove 
--udayRemove   dbms_output.Put_line('Export the statistics table using the below command and upload to the bug:');
--udayRemove   dbms_output.Put_line('exp tables='||l_stat_tab_owner||'.'||l_stat_table||' file='||l_stat_table||'.dmp log=STAT.log');
--udayRemove END;
--udayRemove /
--udayRemove SPO off
--udayRemove set serveroutput OFF

-- HOS echo exp tables=^^sessionuser..^^script._^^sql_id file=^^script._^^sql_id..dmp log=STAT.log

/**************************************************************************************************/

/**************************************************************************************************/

/* -------------------------
 *
 * wrap up
 *
 * ------------------------- */

-- turing trace off
-- ALTER SESSION SET SQL_TRACE = FALSE;
--ALTER SESSION SET STATISTICS_LEVEL = 'TYPICAL';
spool sqlhc_tcb.log
define sqlhc_tcb_dir = 'SQL_TCB_DIR';
column sqlhc_tcb_dir new_value sqlhc_tcb_dir format a11;
variable sqlhc_tcb_dir varchar2(11);
exec :sqlhc_tcb_dir := '^^SQLHC_TCB_DIR.';
declare
  tc_out clob;
  sqlhc_tcb varchar2(3);
  sqlhc_tcb_dir varchar2(11);
begin
  if ( upper(:sqlhc_tcb) = 'TCB' ) then
    dbms_sqldiag.export_sql_testcase(directory=>:sqlhc_tcb_dir, sql_id=>'^^sql_id.',exportMetadata=>TRUE,exportData=>FALSE, testcase=>tc_out);
  end if;
end;
/
column cp_source_files new_value cp_source_files format a500;
select case ( select upper('^^sqlhc_tcb.') from dual)
when 'TCB' then 'cp -v '||directory_path||'/oratcb*^^sql_id.*.* .'
else          'touch ./oratcb_^^sql_id._NO_TCB_COLLECTED.txt'
end cp_source_files from dba_directories where directory_name='^^SQLHC_TCB_DIR.';

host ^^cp_source_files.
spool off
-- get udump directory path
COL udump_path NEW_V udump_path FOR A500;
-- SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') udump_path FROM v$parameter2 WHERE name = 'user_dump_dest'; -- PSRv7
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') udump_path FROM v$diag_info where name = 'Diag Trace';

-- tkprof for trace from execution of tool in case someone reports slow performance in tool
-- HOS tkprof ^^udump_path.*^^script._^^unique_id.*.trc ^^files_prefix._tkprof_nosort.txt
-- HOS tkprof ^^udump_path.*^^script._^^unique_id.*.trc ^^files_prefix._tkprof_sort.txt sort=prsela exeela fchela

-- windows workaround (copy below will error out on linux and unix)
-- HOS copy ^^udump_path.*^^script._^^unique_id.*.trc ^^udump_path.^^script._^^unique_id..trc
-- HOS tkprof ^^udump_path.^^script._^^unique_id..trc ^^files_prefix._tkprof_nosort.txt
-- HOS tkprof ^^udump_path.^^script._^^unique_id..trc ^^files_prefix._tkprof_sort.txt sort=prsela exeela fchela

SPO ^^script..log APP
set head off
SELECT 'START: ' || to_timestamp('^^sqlhcstart', 'DD-Mon-RR HH24:MI:SS.FF') from dual;
SELECT 'End:   ' || to_timestamp(to_char(systimestamp, 'DD-Mon-RR HH24:MI:SS.FF'), 'DD-Mon-RR HH24:MI:SS.FF') from dual;

-- SELECT 'END:   '||TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') FROM dual;
SELECT 'Time: ' || (to_timestamp(to_char(systimestamp, 'DD-Mon-RR HH24:MI:SS.FF'), 'DD-Mon-RR HH24:MI:SS.FF') - to_timestamp('^^sqlhcstart', 'DD-Mon-RR HH24:MI:SS.FF')) as sqlhc_runtime from dual;
set head on
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
host zip -m ^^files_prefix._9_log.zip sqlhc_tcb.log
HOS zip -m ^^files_prefix._9_log.zip ask_container.sql ask_container1.sql
HOS zip -m ^^files_prefix._9_log.zip sql_shared_cursor_sum_^^sql_id..sql
HOS zip -m ^^files_prefix._9_log.zip sql_shared_cursor_col_^^sql_id..sql
HOS zip -m ^^files_prefix._9_log.zip sql_shared_cursor_cur_^^sql_id..sql
-- HOS zip -m ^^files_prefix._9_log.zip ^^files_prefix._tkprof_*.txt
HOS zip -m ^^files_prefix._9_log.zip ^^files_prefix._5_sql_monitor.sql
HOS zip -m ^^files_prefix..zip ^^files_prefix._9_log.zip
HOS zip -m ^^files_prefix._5_sql_monitor.zip ^^files_prefix.*monitor*.*
HOS zip -m ^^files_prefix..zip ^^files_prefix._5_sql_monitor.zip
-- Uday.PSR.v5 added below files 
HOS zip -m ^^files_prefix..zip ^^files_prefix._10_hardParsePctByUser.txt
HOS zip -m ^^files_prefix..zip ^^files_prefix._11_VPD_Policies.txt
-- Uday.PSR.v6
HOS zip -m ^^files_prefix..zip ^^files_prefix._12_histogram_actual_values.html
HOS zip -m ^^files_prefix..zip ^^files_prefix._13_all_bind_values.html
HOS zip -m ^^files_prefix..zip ^^files_prefix._14_executable_script.sql
HOS zip -m ^^files_prefix..zip ^^files_prefix._15_histogram_actual_values_atHardParse.html
HOS zip -m ^^files_prefix..zip ^^files_prefix._16_sql_profiles.sql
host zip -m ^^files_prefix._17_tcb.zip ./oratcb*^^sql_id.*.*
host zip -m ^^files_prefix..zip ^^files_prefix._17_tcb.zip

/* Reenable PX */
ALTER SESSION ENABLE PARALLEL QUERY;

