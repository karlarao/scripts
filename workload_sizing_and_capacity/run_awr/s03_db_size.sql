COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;

COLUMN conname NEW_VALUE _conname NOPRINT
select case 
            when a.conname = 'CDB$ROOT'   then 'ROOT'
            when a.conname = 'PDB$SEED'   then 'SEED'
            else a.conname
            end as conname
from (select SYS_CONTEXT('USERENV', 'CON_NAME') conname from dual) a;

COLUMN conid NEW_VALUE _conid NOPRINT
select SYS_CONTEXT('USERENV', 'CON_ID') conid from dual;

set termout off
set heading on
set markup html on
spool storage_03_db_size-&_instname-&_conname-&_conid..html


col bytes format 999,999,999,999,999,999

WITH
sizes AS (
SELECT /*+  MATERIALIZE NO_MERGE  */ /* 1e.77 */
       'Data' file_type,
       SUM(bytes) bytes
  FROM v$datafile
 UNION ALL
SELECT 'Temp' file_type,
       SUM(bytes) bytes
  FROM v$tempfile
 UNION ALL
SELECT 'Log' file_type,
       SUM(bytes) * MAX(members) bytes
  FROM v$log
 UNION ALL
SELECT 'Control' file_type,
       SUM(block_size * file_size_blks) bytes
  FROM v$controlfile
),
dbsize AS (
SELECT /*+  MATERIALIZE NO_MERGE  */ /* 1e.77 */
       'Total' file_type,
       SUM(bytes) bytes
  FROM sizes
)
SELECT d.dbid,
       d.name db_name,
       s.file_type,
       s.bytes,
       ROUND(s.bytes/POWER(10,9),3) gb,
       CASE
       WHEN s.bytes > POWER(10,15) THEN ROUND(s.bytes/POWER(10,15),3)||' P'
       WHEN s.bytes > POWER(10,12) THEN ROUND(s.bytes/POWER(10,12),3)||' T'
       WHEN s.bytes > POWER(10,9) THEN ROUND(s.bytes/POWER(10,9),3)||' G'
       WHEN s.bytes > POWER(10,6) THEN ROUND(s.bytes/POWER(10,6),3)||' M'
       WHEN s.bytes > POWER(10,3) THEN ROUND(s.bytes/POWER(10,3),3)||' K'
       WHEN s.bytes > 0 THEN s.bytes||' B' END display
  FROM v$database d,
       sizes s
 UNION ALL
SELECT d.dbid,
       d.name db_name,
       s.file_type,
       s.bytes,
       ROUND(s.bytes/POWER(10,9),3) gb,
       CASE
       WHEN s.bytes > POWER(10,15) THEN ROUND(s.bytes/POWER(10,15),3)||' P'
       WHEN s.bytes > POWER(10,12) THEN ROUND(s.bytes/POWER(10,12),3)||' T'
       WHEN s.bytes > POWER(10,9) THEN ROUND(s.bytes/POWER(10,9),3)||' G'
       WHEN s.bytes > POWER(10,6) THEN ROUND(s.bytes/POWER(10,6),3)||' M'
       WHEN s.bytes > POWER(10,3) THEN ROUND(s.bytes/POWER(10,3),3)||' K'
       WHEN s.bytes > 0 THEN s.bytes||' B' END display
  FROM v$database d,
       dbsize s;


spool off 
set markup html off

