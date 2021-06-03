set feedback off term off head on und off trimspool on echo off lines 4000 colsep ',' arraysize 5000 verify off newpage none

COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;

COLUMN dbname NEW_VALUE _dbname NOPRINT
select lower(db_unique_name) dbname from v$database;

COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;

COLUMN name NEW_VALUE _hostname NOPRINT
select lower(host_name) name from v$instance;

COLUMN conname NEW_VALUE _conname NOPRINT
select case 
            when a.conname = 'CDB$ROOT'   then 'ROOT'
            when a.conname = 'PDB$SEED'   then 'SEED'
            else a.conname
            end as conname
from (select SYS_CONTEXT('USERENV', 'CON_NAME') conname from dual) a;

COLUMN conid NEW_VALUE _conid NOPRINT
select SYS_CONTEXT('USERENV', 'CON_ID') conid from dual;


VARIABLE  g_retention  NUMBER
DEFINE    p_default = 8
DEFINE    p_max = 300
SET VERIFY OFF
DECLARE
  v_default  NUMBER(3) := &p_default;
  v_max      NUMBER(3) := &p_max;
BEGIN
  select
    ((TRUNC(SYSDATE) + RETENTION - TRUNC(SYSDATE)) * 86400)/60/60/24 AS RETENTION_DAYS
    into :g_retention
  from dba_hist_wr_control
  where dbid in (select dbid from v$database);

  if :g_retention > v_default then
    :g_retention := v_max;
  else
    :g_retention := v_default;
  end if;
END;
/


set lines 500
col obj_name format a32
col sql_text format a20
col pschema format a20
col module format a50
col db format a20
col sqldetail format a50
col fms format 99999999999999999999999999

spool awr_topsql_segstat_topn_by_exec-&_instname-&_conname-&_conid..csv

with st_temp as (select a.sql_id, a.dbid, a.sql_text, a.sqldetail
	             from (select /*+  MATERIALIZE NO_MERGE  */ 
	                sql_id, 
	                dbid, 
	                nvl(b.name, a.command_type) sql_text, 
	                REPLACE(REPLACE( dbms_lob.substr(sql_text,50,1), CHR(10) ), CHR(13) ) sqldetail 
                 from dba_hist_sqltext a, audit_actions b 
                 where a.command_type =  b.action(+)) a
                 where a.sqldetail not like '%SQL Analyze%'
                 and a.sqldetail not like '%sys.ora%'
                 )
select trim('&_dbname') db , a.*, st.sqldetail sqldetail from
                          (
                            SELECT s.parsing_schema_name pschema,
                                   s.module module,
                                   spacesql.object_name obj_name, 
                                   s.sql_id, 
                                   s.plan_hash_value, 
                                   s.force_matching_signature fms,
                                   stt.sql_text,
                                   decode((sum(s.executions_delta)), 0, to_number(null), ((sum(s.elapsed_time_delta)) / (sum(s.executions_delta)) / 1000000)) elapexec,
                                   sum(s.executions_delta)                                  execs, 
                                   sum(s.elapsed_time_delta) / 1000000                      etime, 
                                   sum(s.cpu_time_delta)/1000000                            cputime,
                                   sum(s.iowait_delta)/1000000                              iotime,
                                   sum(s.disk_reads_delta)                                  pio, 
                                   sum(s.buffer_gets_delta)                                 lio,
                                   DENSE_RANK() OVER (PARTITION BY spacesql.object_name, stt.sql_text ORDER BY sum(s.executions_delta) DESC) time_rank
                                    FROM   dba_hist_sqlstat s, 
                                           st_temp stt,
                                           (SELECT sql_id, object_name 
                                                                           FROM   dba_hist_sql_plan 
                                                                           WHERE  object_name in (
                                                                                        select object_name from (
                                                                                        SELECT
                                                                                          object_name, seg_rank
                                                                                        FROM
                                                                                            (
                                                                                                SELECT
                                                                                                  r.snap_id,
                                                                                                  TO_CHAR(r.tm,'MM/DD/YY HH24:MI:SS') tm,
                                                                                                  r.inst,
                                                                                                  n.owner,
                                                                                                  n.tablespace_name,
                                                                                                  n.dataobj#,
                                                                                                  n.object_name,
                                                                                                  CASE
                                                                                                    WHEN LENGTH(n.subobject_name) < 11
                                                                                                    THEN n.subobject_name
                                                                                                    ELSE SUBSTR(n.subobject_name,LENGTH(n.subobject_name)-9)
                                                                                                  END subobject_name,
                                                                                                  n.object_type,
                                                                                                  (r.PHYSICAL_READS_DELTA + r.LOGICAL_READS_DELTA) as physical_rlio,
                                                                                                  r.LOGICAL_READS_DELTA,
                                                                                                  r.PHYSICAL_READS_DELTA,
                                                                                                  DENSE_RANK() OVER (PARTITION BY r.snap_id ORDER BY r.PHYSICAL_READS_DELTA + r.LOGICAL_READS_DELTA DESC) seg_rank
                                                                                                FROM
                                                                                                      dba_hist_seg_stat_obj n,
                                                                                                      (
                                                                                                        SELECT
                                                                                                          s0.snap_id snap_id,
                                                                                                          s0.END_INTERVAL_TIME tm,
                                                                                                          s0.instance_number inst,
                                                                                                          b.dataobj#,
                                                                                                          b.obj#,
                                                                                                          b.dbid,
                                                                                                          sum(b.LOGICAL_READS_DELTA) LOGICAL_READS_DELTA,
                                                                                                          sum(b.PHYSICAL_READS_DELTA) PHYSICAL_READS_DELTA
                                                                                                        FROM
                                                                                                            dba_hist_snapshot s0,
                                                                                                            dba_hist_snapshot s1,
                                                                                                            dba_hist_seg_stat b
                                                                                                        WHERE
                                                                                                            s0.dbid                  = &_dbid
                                                                                                            AND s1.dbid              = s0.dbid
                                                                                                            AND b.dbid               = s0.dbid
                                                                                                            AND s1.instance_number   = s0.instance_number
                                                                                                            AND b.instance_number    = s0.instance_number
                                                                                                            AND s1.snap_id           = s0.snap_id + 1
                                                                                                            AND b.snap_id            = s0.snap_id + 1
                                                                                                            AND s0.END_INTERVAL_TIME > sysdate - :g_retention
                                                                                                        GROUP BY
                                                                                                          s0.snap_id, s0.END_INTERVAL_TIME, s0.instance_number, b.dataobj#, b.obj#, b.dbid
                                                                                                      ) r
                                                                                                WHERE n.dataobj#     = r.dataobj#
                                                                                                AND n.obj#           = r.obj#
                                                                                                AND n.dbid           = r.dbid
                                                                                                AND r.PHYSICAL_READS_DELTA + r.LOGICAL_READS_DELTA > 0
                                                                                                ORDER BY physical_rlio DESC,
                                                                                                  object_name,
                                                                                                  owner,
                                                                                                  subobject_name
                                                                                            )
                                                                                        WHERE
                                                                                        seg_rank <=15)
                                                                            )  ) spacesql
                                    WHERE s.sql_id = spacesql.sql_id
                                    AND s.sql_id = stt.sql_id
                                    AND s.PARSING_SCHEMA_NAME NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN','AUDSYS','MDSYS','ORDSYS','XDB','APEX_PUBLIC_USER','ORACLE_OCM','APEX_050100','GSMADMIN_INTERNAL','ORDS_METADATA')
                                    GROUP BY s.parsing_schema_name, s.module, spacesql.object_name, s.sql_id, s.plan_hash_value, s.force_matching_signature, stt.sql_text
                                          ) a,
                                    (select sql_id, sql_text, sqldetail 
                                    	from st_temp) st
            where st.sql_id(+) = a.sql_id 
            and a.time_rank <= 15
            order by obj_name, st.sql_text, time_rank
/
spool off 