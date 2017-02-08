set lines 200
set pages 80
set echo on
col tablespace_name format a22 head 'Tablespace'
col compress_for format a20 head 'CompressType'
col def_tab_compression format a20 head 'CompSetting'
select tablespace_name,
       def_tab_compression,
       nvl(compress_for,'NONE') compress_for
from dba_tablespaces;


