rem
rem Header:     security_healthcheck.sql    
rem
rem NAME
rem   security_healthcheck.sql - DATABASE SECURITY HEALTHCHECK SCRIPT
rem
rem DESCRIPTON
rem   
rem NOTES
rem   Be sure to run this script as 'SYS as SYSDBA'
rem
rem CONSIDERATIONS
rem
rem CREATED (MM/DD/YY)
rem
rem MODIFIED   (MM/DD/YY)
rem karao       05/21/08    - added the following on script #7:
rem                                 'audit_sys_operations', 'remote_os_roles', 'os_roles', 'sql92_security', 'o7_dictionary_accessibility'
rem                         below are the security related parameters which are initialized when you install data vault:
rem                                 REMOTE_LOGIN_PASSWORDFILE = default, EXCLUSIVE
rem                                 AUDIT_SYS_OPERATIONS = TRUE
rem                                 REMOTE_OS_AUTHENT = FALSE
rem                                 REMOTE_OS_ROLES = FALSE
rem                                 OS_ROLES = FALSE
rem                                 OS_AUTHENT_PREFIX = '' 
rem                                 SQL92_SECURITY = TRUE
rem                                 O7_DICTIONARY_ACCESSIBILITY = FALSE
rem karao       06/01/08    - modified # 10:
rem                             !grep `grep ^dba: /etc/group | cut -d: -f3` /etc/passwd 
rem                         replaced with:
rem                             ! grep dba: /etc/group
rem karao       08/13/08        added with:
rem                             ! grep dba: /etc/group; grep oper: /etc/group
rem                             

---------------------------------------------------------------------------------------------------------------------------
-- for filename header 

define FileName=SecHealthCheck

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDD') spool_time FROM dual;

spool &FileName._&_dbname._&_spool_time..txt
---------------------------------------------------------------------------------------------------------------------------


set lines 400
set pages 66
col host for a40
set trims on



prompt
prompt DBA_TABLES 
prompt =======================
select owner, table_name, tablespace_name from dba_tables 
where owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by owner, table_name asc;


prompt
prompt DBA TAB COLS 
prompt =======================
select owner, table_name, column_name 
from dba_tab_columns
where owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by 1,2,3 asc;

prompt
prompt DBA_INDEXES 
prompt =======================
select owner, index_name, tablespace_name from dba_indexes
where owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by owner, index_name asc;


prompt
prompt DBA IND COLS 
prompt =======================
col index_owner format a20
col index_namne format a20
col column_name format a30
col table_owner format a20
col table_name format a20
select index_owner, index_name, column_position, column_name , table_owner, table_name 
from dba_ind_columns
where index_owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by 1,2,3,4,5,6 asc;


prompt
prompt DBA VIEWS 
prompt =======================
select owner, view_name 
from dba_views
where owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by owner, view_name asc;


prompt
prompt DBA PACKAGE BODY 
prompt =======================
select owner, object_name 
from dba_objects 
where object_type = 'PACKAGE BODY'
and owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by owner, object_name asc;


prompt
prompt DBA PROCEDURES 
prompt =======================
select owner, object_name, procedure_name
from dba_procedures
where owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by owner, object_name, procedure_name asc;


prompt
prompt DBA FUNCTIONS 
prompt =======================
select owner, object_name 
from dba_objects 
where object_type = 'FUNCTION'
and owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by owner, object_name asc;


prompt
prompt DBA TRIGGERS 
prompt =======================
select owner, trigger_name
from dba_triggers
where owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by owner, trigger_name asc;


prompt
prompt DBA SEQUENCES 
prompt =======================
select sequence_owner, sequence_name, min_value, max_value, increment_by, cache_size
from dba_sequences
where sequence_owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
order by sequence_owner, sequence_name asc;


prompt
prompt DBA SYNONYMS 
prompt =======================

select owner, synonym_name, table_owner, table_name, db_link
from dba_synonyms
where table_owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT')
order by owner, synonym_name, table_owner, table_name, db_link asc;


prompt
prompt DBA DB LINKS 
prompt =======================

select owner, db_link, username 
from dba_db_links
order by owner, db_link, username asc;


prompt
prompt DBA DIRECTORIES
prompt =======================

select * from dba_directories
order by 1,2,3;




Prompt Check for users with DBA privs
prompt ===========================================
select * from dba_role_privs
where grantee not in ('SYS','SYSTEM', 'ORACLE', 'OPS$ORACLE')
and granted_role='DBA'
order by 1,2 asc
/

Prompt Check user with Drop User or Alter User
prompt ===========================================
select * from dba_sys_privs
where (privilege like '%DROP%USER'
      or privilege like '%ALTER%USER%')
and grantee not in ('IMP_FULL_DATABASE', 'DBA')
order by 1,2 asc
/

Prompt Check for users with Alter Session
prompt ===========================================
select * from dba_sys_privs
where privilege = 'ALTER SESSION'
and grantee <> 'DBA'
order by 1,2 asc
/

Prompt Database users with deadly system privilages assigned to them.
prompt ===============================================================
select grantee, privilege, admin_option
from   sys.dba_sys_privs
where  (privilege like '% ANY %'
  or   privilege in ('BECOME USER', 'UNLIMITED TABLESPACE')
  or   admin_option = 'YES')
 and   grantee not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA')
order by 1,2 asc                       
/

col GRANTEE format a60
col GRANTED_ROLE format a30
Prompt Check for users with EXPORT/IMPORT FULL DATABASE
prompt ==========================================================
select * from dba_role_privs
where grantee not in ('SYS','SYSTEM', 'ORACLE', 'OPS$ORACLE')
and granted_role in ('EXP_FULL_DATABASE', 'IMP_FULL_DATABASE')
and grantee <> 'DBA'
order by 1,2 asc
/

col GRANTEE format a60
col GRANTED_ROLE format a30
Prompt Database users with deadly roles assigned to them.
Prompt ======================================================================
select grantee, granted_role, admin_option
from   sys.dba_role_privs
where  granted_role in ('DBA', 'AQ_ADMINISTRATOR_ROLE',
                       'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR')
  and  grantee not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA')
order by 1,2 asc                       
/

Prompt Security related initialization parameters
Prompt ==========================================
select name || '=' || value "PARAMETER"
from   sys.v_$parameter
where  lower(name) in ('remote_login_passwordfile', 'remote_os_authent',
                'os_authent_prefix', 'dblink_encrypt_login',
                'audit_trail', 'transaction_auditing', 'audit_sys_operations', 
                'remote_os_roles', 'os_roles', 'sql92_security', 'o7_dictionary_accessibility')
order by 1 asc                
/

Prompt Password file users
Prompt ====================
select * from sys.v_$pwfile_users
order by 1 asc
/

Prompt List security related profile information
Prompt ======================================================================

col profile format a20
col limit   format a20

select profile, resource_name, limit
from   dba_profiles
where  resource_name like '%PASSWORD%'
   or  resource_name like '%LOGIN%'
order by 1,2
/

Prompt Users that can startup, shutdown and admin Oracle Databases
Prompt ============================================================
! grep dba: /etc/group; grep oper: /etc/group

prompt
prompt ROLE-level Privileges for LS_READ and LS_WRITE
prompt ================================================
select * from dba_role_privs where grantee in ('LS_READ', 'LS_WRITE')
order by 1,2 asc
/

prompt
prompt Check on Security holes in database links
prompt ================================================
col host for a55
col name for a20
col userid for a15
col password for a20
select name, userid, password, host from sys.link$
order by 1,2 asc
/


Prompt Minimal password security check
Prompt ===============================
select username "User(s) with Default Password!"
 from dba_users
 where password in
('E066D214D5421CCC',  -- dbsnmp
 '24ABAB8B06281B4C',  -- ctxsys
 '72979A94BAD2AF80',  -- mdsys
 'C252E8FA117AF049',  -- odm
 'A7A32CD03D3CE8D5',  -- odm_mtr
 '88A2B2C183431F00',  -- ordplugins
 '7EFA02EC7EA6B86F',  -- ordsys
 '4A3BA55E08595C81',  -- outln
 'F894844C34402B67',  -- scott
 '3F9FBD883D787341',  -- wk_proxy
 '79DF7A1BD138CF11',  -- wk_sys
 '7C9BA362F8314299',  -- wmsys
 '88D8364765FCE6AF',  -- xdb
 'F9DA8977092B7B81',  -- tracesvr
 '9300C0977D7DC75E',  -- oas_public
 'A97282CE3D94E29E',  -- websys
 'AC9700FD3F1410EB',  -- lbacsys
 'E7B5D92911C831E1',  -- rman
 'AC98877DE1297365',  -- perfstat
 'D4C5016086B2DC6A',  -- sys
 'D4DF7931AB130E37')  -- system
order by 1 asc
/

prompt SYSTEM, ROLE and OBJECT Privileges -- to show all users, comment out the WHERE CLAUSE
Prompt ===============================
set verif off
set lines 300
set pages 66
set trims on
col owner for a10
col table_name for a30
col privilege for a30
col grantor for a10
col grantee for a25
col grantable for a4

prompt
prompt SYSTEM-level End User Privileges
prompt =======================
select * from dba_sys_privs
                where grantee in 
            ( 
                -- show roles
--              SELECT DISTINCT usr.NAME granted_role 
--              FROM (SELECT * 
--                    FROM SYS.sysauth$ 
--                    CONNECT BY PRIOR privilege# = grantee# 
--                    START WITH grantee# in 
--                          (SELECT user# 
--                            FROM SYS.user$ 
--                            -- WHERE NAME in ('SEC_MGR','SQLTXPLAIN','SEC_DBA','SCOTT')
--                          ) 
--                          OR grantee# = 1
--                    ) sauth,
--                    SYS.user$ usr 
--              WHERE usr.user# = sauth.privilege# 
                select role from dba_roles
              UNION ALL 
                -- show users
                select username from dba_users -- where username in ('SEC_MGR','SQLTXPLAIN','SEC_DBA','SCOTT')
              UNION ALL 
                SELECT 'PUBLIC' FROM DUAL
            ) 
 order by 1,2 asc; 

prompt
prompt ROLE-level End User Privileges
prompt =====================
select *
FROM (select * from dba_role_privs
                where grantee in 
            ( 
                -- show roles
--              SELECT DISTINCT usr.NAME granted_role 
--              FROM (SELECT * 
--                    FROM SYS.sysauth$ 
--                    CONNECT BY PRIOR privilege# = grantee# 
--                    START WITH grantee# in 
--                          (SELECT user# 
--                            FROM SYS.user$ 
--                            -- WHERE NAME in ('SEC_MGR','SQLTXPLAIN','SEC_DBA','SCOTT')
--                          ) 
--                          OR grantee# = 1
--                    ) sauth,
--                    SYS.user$ usr 
--              WHERE usr.user# = sauth.privilege# 
                select role from dba_roles
              UNION ALL 
                -- show users
                select username from dba_users -- where username in ('SEC_MGR','SQLTXPLAIN','SEC_DBA','SCOTT')
              UNION ALL 
                SELECT 'PUBLIC' FROM DUAL
            )
    ) 
 order by 1,2 asc; 

prompt
prompt OBJECT-level End User Privileges (end user grants), look for the 3rd column order by grantee
prompt =======================
-- create table ShcDistinctSchemaGrantee as select distinct grantee from dba_tab_privs;
select owner, grantor, grantee, table_name, grantable "GO",
       max(decode(privilege,'SELECT','X')) "SELECT",
       max(decode(privilege,'INSERT','X')) "INSERT",
       max(decode(privilege,'UPDATE','X')) "UPDATE",
       max(decode(privilege,'DELETE','X')) "DELETE",
       max(decode(privilege,'ALTER','X')) "ALTER",
       max(decode(privilege,'REFERENCES','X')) "REFERENCES",
       max(decode(privilege,'INDEX','X')) "INDEX",
       max(decode(privilege,'EXECUTE','X')) "EXECUTE"
from dba_tab_privs
-- where grantee in ('SEC_MGR','SQLTXPLAIN','SEC_DBA','SCOTT')
-- where grantee in (select grantee from ShcDistinctSchemaGrantee)
where owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
group by owner, grantor, grantee, table_name, grantable
order by grantee, table_name asc;
-- drop table ShcDistinctSchemaGrantee;

prompt
prompt OBJECT-level Application Schema Privileges (granted by APP schema), look for the 1st column order by owner
prompt =======================
-- create table ShcDistinctSchemaOwner as select distinct owner from dba_tab_privs;
select owner, grantor, grantee, table_name, grantable "GO",
       max(decode(privilege,'SELECT','X')) "SELECT",
       max(decode(privilege,'INSERT','X')) "INSERT",
       max(decode(privilege,'UPDATE','X')) "UPDATE",
       max(decode(privilege,'DELETE','X')) "DELETE",
       max(decode(privilege,'ALTER','X')) "ALTER",
       max(decode(privilege,'REFERENCES','X')) "REFERENCES",
       max(decode(privilege,'INDEX','X')) "INDEX",
       max(decode(privilege,'EXECUTE','X')) "EXECUTE"
from dba_tab_privs
-- where owner in ('SEC_MGR','SQLTXPLAIN','SEC_DBA','SCOTT')
-- where owner in (select owner from ShcDistinctSchemaOwner)
where owner not in ('SYS', 'SYSTEM', 'OUTLN', 'AQ_ADMINISTRATOR_ROLE',
                       'DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE',
                       'OEM_MONITOR', 'CTXSYS', 'DBSNMP', 'IFSSYS',
                       'IFSSYS$CM', 'MDSYS', 'ORDPLUGINS', 'ORDSYS',
                       'TIMESERIES_DBA', 'APEX_040200', 'DVF', 'OLAPSYS', 'FLOWS_FILES', 'DVSYS', 
                       'GSMADMIN_INTERNAL', 'TOAD', 'XDB', 'ORDDATA', 'APPQOSSYS', 'WMSYS', 'LBACSYS', 'PERFSTAT') 
group by owner, grantor, grantee, table_name, grantable
order by owner, table_name asc;
-- drop table ShcDistinctSchemaOwner;

set verif on
set lines 90

/* the following list the privileges for various objects
    -- UPDATE, REFERENCES, and INSERT can be restricted by specifying a subset of updateable columns
    -- a privilege granted on a synonym is converted to a privilege on the base table referenced by the synonym

Object_Privilege    Table   View    Sequence    Procedure
-----------------------------------------------------------------
ALTER           x   x   x
DELETE          x   x 
EXECUTE                         x 
INDEX           x   x
INSERT          x   x 
REFERENCES      x
SELECT          x   x   x 
UPDATE          x   x 

Sample Output:
OWNER      GRANTOR    GRANTEE           TABLE_NAME             GO  S I U D A R I E
---------- ---------- ------------------------- ------------------------------ --- - - - - - - - -
SEC_MGR    SEC_MGR    PUBLIC            ALL_USER_PRIV_PATH         NO  X
SEC_MGR    SEC_MGR    PUBLIC            USER_OBJECT_PRIVS          NO  X
SEC_MGR    SEC_MGR    PUBLIC            USER_SYSTEM_PRIVS          NO  X
*/

spool off
exit

