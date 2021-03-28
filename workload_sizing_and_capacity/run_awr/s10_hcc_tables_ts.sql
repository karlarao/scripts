
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
spool storage_10_hcc_tables_ts-&_instname-&_conname-&_conid..html


-- hcc tables
select owner, table_name, tablespace_name, num_rows, blocks, logging, partitioned, compression, compress_for
from dba_tables
where compression = 'ENABLED';


-- hcc tablespaces 
set lines 200
set pages 80
col tablespace_name format a22 head 'Tablespace'
col compress_for format a20 head 'CompressType'
col def_tab_compression format a20 head 'CompSetting'
select tablespace_name,
       def_tab_compression,
       nvl(compress_for,'NONE') compress_for,
       block_size, force_logging, bigfile, encrypted, extent_management, allocation_type, segment_space_management
from dba_tablespaces;


spool off 
set markup html off
