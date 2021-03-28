-- run_awr_topsql_bigobj_topn_v3_by_elap.sql
-- top sqls for top segments 
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com

set feedback off term off head on und off trimspool on echo off lines 4000 colsep ',' arraysize 5000 verify off newpage none

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

spool awr_topsql_bigobj_by_elap-&_instname-&_conname-&_conid..csv

set lines 500
col obj_name format a32
col sql_text format a20
col pschema format a20
col module format a50
col db format a20
col sqldetail format a50
col fms format 99999999999999999999999999

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
                                   DENSE_RANK() OVER (PARTITION BY spacesql.object_name, stt.sql_text ORDER BY sum(s.elapsed_time_delta) DESC) time_rank
                                    FROM   dba_hist_sqlstat s, 
                                           st_temp stt,
                                           (SELECT sql_id, object_name 
                                                                           FROM   dba_hist_sql_plan 
                                                                           WHERE  object_name in (
                                                                                          select table_name from 
                                                                                          (
                                                                                          /* Largest 200 Objects (DBA_SEGMENTS) - MODIFIED TO FILTER OBJECTS */
                                                                                          WITH schema_object AS (
                                                                                          SELECT /*+  MATERIALIZE NO_MERGE  */ /* 2b.207 */
                                                                                                segment_type,
                                                                                                owner,
                                                                                                segment_name,
                                                                                                tablespace_name,
                                                                                                COUNT(*) segments,
                                                                                                SUM(extents) extents,
                                                                                                SUM(blocks) blocks,
                                                                                                SUM(bytes) bytes
                                                                                          FROM dba_segments
                                                                                          WHERE 'Y' = 'Y'
                                                                                          GROUP BY
                                                                                                segment_type,
                                                                                                owner,
                                                                                                segment_name,
                                                                                                tablespace_name
                                                                                          ), totals AS (
                                                                                          SELECT /*+  MATERIALIZE NO_MERGE  */ /* 2b.207 */
                                                                                                SUM(segments) segments,
                                                                                                SUM(extents) extents,
                                                                                                SUM(blocks) blocks,
                                                                                                SUM(bytes) bytes
                                                                                          FROM schema_object
                                                                                          ), top_200_pre AS (
                                                                                          SELECT /*+  MATERIALIZE NO_MERGE  */ /* 2b.207 */
                                                                                                ROWNUM rank, v1.*
                                                                                                FROM (
                                                                                          SELECT so.segment_type,
                                                                                                so.owner,
                                                                                                so.segment_name,
                                                                                                so.tablespace_name,
                                                                                                so.segments,
                                                                                                so.extents,
                                                                                                so.blocks,
                                                                                                so.bytes,
                                                                                                ROUND((so.segments / t.segments) * 100, 3) segments_perc,
                                                                                                ROUND((so.extents / t.extents) * 100, 3) extents_perc,
                                                                                                ROUND((so.blocks / t.blocks) * 100, 3) blocks_perc,
                                                                                                ROUND((so.bytes / t.bytes) * 100, 3) bytes_perc
                                                                                          FROM schema_object so,
                                                                                                totals t
                                                                                          ORDER BY
                                                                                                bytes_perc DESC NULLS LAST
                                                                                          ) v1
                                                                                          WHERE ROWNUM < 41
                                                                                          ), top_200 AS (
                                                                                          SELECT p.*,
                                                                                                (SELECT object_id
                                                                                                FROM dba_objects o
                                                                                                WHERE o.object_type = p.segment_type
                                                                                                AND o.owner = p.owner
                                                                                                AND o.object_name = p.segment_name
                                                                                                AND o.object_type NOT LIKE '%PARTITION%') object_id,
                                                                                                (SELECT data_object_id
                                                                                                FROM dba_objects o
                                                                                                WHERE o.object_type = p.segment_type
                                                                                                AND o.owner = p.owner
                                                                                                AND o.object_name = p.segment_name
                                                                                                AND o.object_type NOT LIKE '%PARTITION%') data_object_id,
                                                                                                (SELECT SUM(p2.bytes_perc) FROM top_200_pre p2 WHERE p2.rank <= p.rank) bytes_perc_cum
                                                                                          FROM top_200_pre p
                                                                                          ), top_200_totals AS (
                                                                                          SELECT /*+  MATERIALIZE NO_MERGE  */ /* 2b.207 */
                                                                                                SUM(segments) segments,
                                                                                                SUM(extents) extents,
                                                                                                SUM(blocks) blocks,
                                                                                                SUM(bytes) bytes,
                                                                                                SUM(segments_perc) segments_perc,
                                                                                                SUM(extents_perc) extents_perc,
                                                                                                SUM(blocks_perc) blocks_perc,
                                                                                                SUM(bytes_perc) bytes_perc
                                                                                          FROM top_200
                                                                                          )
                                                                                          SELECT v.rank,
                                                                                                v.segment_type,
                                                                                                v.owner,
                                                                                                v.segment_name,
                                                                                                v.object_id,
                                                                                                v.data_object_id,
                                                                                                v.tablespace_name,
                                                                                                CASE
                                                                                                WHEN v.segment_type LIKE 'INDEX%' THEN
                                                                                                (SELECT i.table_name
                                                                                                      FROM dba_indexes i
                                                                                                WHERE i.owner = v.owner AND i.index_name = v.segment_name)
                                                                                                WHEN v.segment_type LIKE 'LOB%' THEN
                                                                                                (SELECT l.table_name
                                                                                                      FROM dba_lobs l
                                                                                                WHERE l.owner = v.owner AND l.segment_name = v.segment_name)
                                                                                                ELSE v.segment_name
                                                                                                END table_name,
                                                                                                v.segments,
                                                                                                v.extents,
                                                                                                v.blocks,
                                                                                                v.bytes,
                                                                                                ROUND(v.bytes / POWER(10,9), 3) gb,
                                                                                                LPAD(TO_CHAR(v.segments_perc, '990.000'), 7) segments_perc,
                                                                                                LPAD(TO_CHAR(v.extents_perc, '990.000'), 7) extents_perc,
                                                                                                LPAD(TO_CHAR(v.blocks_perc, '990.000'), 7) blocks_perc,
                                                                                                LPAD(TO_CHAR(v.bytes_perc, '990.000'), 7) bytes_perc,
                                                                                                LPAD(TO_CHAR(v.bytes_perc_cum, '990.000'), 7) perc_cum
                                                                                          FROM (
                                                                                          SELECT d.rank,
                                                                                                d.segment_type,
                                                                                                d.owner,
                                                                                                d.segment_name,
                                                                                                d.object_id,
                                                                                                d.data_object_id,
                                                                                                d.tablespace_name,
                                                                                                d.segments,
                                                                                                d.extents,
                                                                                                d.blocks,
                                                                                                d.bytes,
                                                                                                d.segments_perc,
                                                                                                d.extents_perc,
                                                                                                d.blocks_perc,
                                                                                                d.bytes_perc,
                                                                                                d.bytes_perc_cum
                                                                                          FROM top_200 d) v)
                                                                            )  ) spacesql
                                    WHERE s.sql_id = spacesql.sql_id
                                    AND s.sql_id = stt.sql_id
                                    GROUP BY s.parsing_schema_name, s.module, spacesql.object_name, s.sql_id, s.plan_hash_value, s.force_matching_signature, stt.sql_text
                                          ) a,
                                    (select sql_id, sql_text, sqldetail 
                                    	from st_temp) st
            where st.sql_id(+) = a.sql_id 
            and a.time_rank <= 15
            order by obj_name, st.sql_text, time_rank
/
spool off
