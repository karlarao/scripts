

define SQL_TOP_N = 2

set head off verify off feed off

COL name NEW_V _instname NOPRINT
select lower(instance_name) name from v$instance;
COL ecr_dbid NEW_V ecr_dbid;
SELECT 'get_dbid', TO_CHAR(dbid) ecr_dbid FROM v$database;
COL current_time NEW_V current_time FOR A15;
SELECT 'current_time: ' x, TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') current_time FROM DUAL;

spool awr_planx-&_instname-&current_time..sql.reference.sql
select distinct '@planx Y ' || sql_id || ',' || sqldetail || ',' || parsing_schema_name
from 
(
 select force_matching_signature, max(sql_id) keep (dense_rank first order by elap_rank asc) sql_id , sqldetail, parsing_schema_name
 from 
(
SELECT * FROM(
SELECT s.sql_id, s.force_matching_signature, t.sqldetail ,s.PARSING_SCHEMA_NAME ,
DENSE_RANK() OVER
      (ORDER BY sum(EXECUTIONS_DELTA) DESC ) exec_rank,
DENSE_RANK() OVER
      (ORDER BY sum(ELAPSED_TIME_DELTA) DESC ) elap_rank,
DENSE_RANK() OVER
      (ORDER BY sum(BUFFER_GETS_DELTA) DESC ) log_reads_rank,
DENSE_RANK() OVER
      (ORDER BY sum(disk_reads_delta) DESC ) phys_reads_rank
 FROM dba_hist_sqlstat s,(select sql_id, dbid , sqldetail 
                            from
                            (select
                            sql_id, dbid,  
                            REPLACE(REPLACE( dbms_lob.substr(sql_text,50,1), CHR(10) ), CHR(13) ) sqldetail 
                            from dba_hist_sqltext a) a
                            where a.sqldetail not like '%SQL Analyze%'
                            and a.sqldetail not like '%sys.ora%') t
 WHERE s.dbid = &&ecr_dbid.  
  AND s.dbid = t.dbid
  AND s.sql_id = t.sql_id
  AND s.PARSING_SCHEMA_NAME NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','AUDSYS','MDSYS','ORDSYS','XDB','APEX_PUBLIC_USER','ORACLE_OCM','APEX_050100','GSMADMIN_INTERNAL','ORDS_METADATA')
  AND s.force_matching_signature != 0
  GROUP BY s.sql_id,s.force_matching_signature , t.sqldetail, s.PARSING_SCHEMA_NAME
  )
WHERE elap_rank <= &SQL_TOP_N
 OR phys_reads_rank <= &SQL_TOP_N
 or log_reads_rank <= &SQL_TOP_N
 or exec_rank <= &SQL_TOP_N
 )
  group by force_matching_signature , sqldetail, parsing_schema_name
  )
union all
select distinct '@planx Y ' || sql_id || ',' || sqldetail || ',' || parsing_schema_name
from 
(
SELECT * FROM(
SELECT s.sql_id, s.force_matching_signature, t.sqldetail ,s.PARSING_SCHEMA_NAME ,
DENSE_RANK() OVER
      (ORDER BY sum(EXECUTIONS_DELTA) DESC ) exec_rank,
DENSE_RANK() OVER
      (ORDER BY sum(ELAPSED_TIME_DELTA) DESC ) elap_rank,
DENSE_RANK() OVER
      (ORDER BY sum(BUFFER_GETS_DELTA) DESC ) log_reads_rank,
DENSE_RANK() OVER
      (ORDER BY sum(disk_reads_delta) DESC ) phys_reads_rank
 FROM dba_hist_sqlstat s,(select sql_id, dbid , sqldetail
                            from
                            (select
                            sql_id, dbid,  
                            REPLACE(REPLACE( dbms_lob.substr(sql_text,50,1), CHR(10) ), CHR(13) ) sqldetail 
                            from dba_hist_sqltext a) a
                            where a.sqldetail not like '%SQL Analyze%'
                            and a.sqldetail not like '%sys.ora%') t
 WHERE s.dbid = &&ecr_dbid.  
   AND s.dbid = t.dbid
  AND s.sql_id = t.sql_id
  AND s.PARSING_SCHEMA_NAME NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','AUDSYS','MDSYS','ORDSYS','XDB','APEX_PUBLIC_USER','ORACLE_OCM','APEX_050100','GSMADMIN_INTERNAL','ORDS_METADATA')
  AND force_matching_signature = 0
  GROUP BY s.sql_id,s.force_matching_signature , t.sqldetail, s.PARSING_SCHEMA_NAME
  )
WHERE elap_rank <= &SQL_TOP_N
 OR phys_reads_rank <= &SQL_TOP_N
 or log_reads_rank <= &SQL_TOP_N
 or exec_rank <= &SQL_TOP_N
 );

spool off 

spool awr_planx-&_instname-&current_time..sql
select distinct '@planx Y ' || sql_id --|| ',' || sqldetail || ',' || parsing_schema_name
from 
(
 select force_matching_signature, max(sql_id) keep (dense_rank first order by elap_rank asc) sql_id --, sqldetail, parsing_schema_name
 from 
(
SELECT * FROM(
SELECT s.sql_id, s.force_matching_signature, --t.sqldetail ,s.PARSING_SCHEMA_NAME ,
DENSE_RANK() OVER
      (ORDER BY sum(EXECUTIONS_DELTA) DESC ) exec_rank,
DENSE_RANK() OVER
      (ORDER BY sum(ELAPSED_TIME_DELTA) DESC ) elap_rank,
DENSE_RANK() OVER
      (ORDER BY sum(BUFFER_GETS_DELTA) DESC ) log_reads_rank,
DENSE_RANK() OVER
      (ORDER BY sum(disk_reads_delta) DESC ) phys_reads_rank
 FROM dba_hist_sqlstat s,(select sql_id, dbid --, sqldetail 
                            from
                            (select
                            sql_id, dbid,  
                            REPLACE(REPLACE( dbms_lob.substr(sql_text,50,1), CHR(10) ), CHR(13) ) sqldetail 
                            from dba_hist_sqltext a) a
                            where a.sqldetail not like '%SQL Analyze%'
                            and a.sqldetail not like '%sys.ora%') t
 WHERE s.dbid = &&ecr_dbid.  
  AND s.dbid = t.dbid
  AND s.sql_id = t.sql_id
  AND s.PARSING_SCHEMA_NAME NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','AUDSYS','MDSYS','ORDSYS','XDB','APEX_PUBLIC_USER','ORACLE_OCM','APEX_050100','GSMADMIN_INTERNAL','ORDS_METADATA')
  AND s.force_matching_signature != 0
  GROUP BY s.sql_id,s.force_matching_signature --, t.sqldetail, s.PARSING_SCHEMA_NAME
  )
WHERE elap_rank <= &SQL_TOP_N
 OR phys_reads_rank <= &SQL_TOP_N
 or log_reads_rank <= &SQL_TOP_N
 or exec_rank <= &SQL_TOP_N
 )
  group by force_matching_signature --, sqldetail, parsing_schema_name
  )
union all
select distinct '@planx Y ' || sql_id --|| ',' || sqldetail || ',' || parsing_schema_name
from 
(
SELECT * FROM(
SELECT s.sql_id, s.force_matching_signature, --t.sqldetail ,s.PARSING_SCHEMA_NAME ,
DENSE_RANK() OVER
      (ORDER BY sum(EXECUTIONS_DELTA) DESC ) exec_rank,
DENSE_RANK() OVER
      (ORDER BY sum(ELAPSED_TIME_DELTA) DESC ) elap_rank,
DENSE_RANK() OVER
      (ORDER BY sum(BUFFER_GETS_DELTA) DESC ) log_reads_rank,
DENSE_RANK() OVER
      (ORDER BY sum(disk_reads_delta) DESC ) phys_reads_rank
 FROM dba_hist_sqlstat s,(select sql_id, dbid --, sqldetail
                            from
                            (select
                            sql_id, dbid,  
                            REPLACE(REPLACE( dbms_lob.substr(sql_text,50,1), CHR(10) ), CHR(13) ) sqldetail 
                            from dba_hist_sqltext a) a
                            where a.sqldetail not like '%SQL Analyze%'
                            and a.sqldetail not like '%sys.ora%') t
 WHERE s.dbid = &&ecr_dbid.  
   AND s.dbid = t.dbid
  AND s.sql_id = t.sql_id
  AND s.PARSING_SCHEMA_NAME NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','AUDSYS','MDSYS','ORDSYS','XDB','APEX_PUBLIC_USER','ORACLE_OCM','APEX_050100','GSMADMIN_INTERNAL','ORDS_METADATA')
  AND force_matching_signature = 0
  GROUP BY s.sql_id,s.force_matching_signature --, t.sqldetail, s.PARSING_SCHEMA_NAME
  )
WHERE elap_rank <= &SQL_TOP_N
 OR phys_reads_rank <= &SQL_TOP_N
 or log_reads_rank <= &SQL_TOP_N
 or exec_rank <= &SQL_TOP_N
 );

spool off 

PRO Running planx 
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@awr_planx-&_instname-&current_time..sql

! mkdir awr_planx-&_instname
! mv planx*&_instname*.txt awr_planx-&_instname
! mv awr_planx-&_instname-*.sql awr_planx-&_instname

