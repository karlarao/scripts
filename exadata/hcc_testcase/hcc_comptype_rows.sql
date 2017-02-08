-- lst16-06-comptype.sql, from john clarke
set lines 200
col owner format a15 head "Owner"
col tabname format a35 head "Table"
col myrowid format a20 head "RowId" 
col comptype format a20 head "CompType"
set echo on

select '&&owner' owner, '&&table_name' tabname, rowid myrowid,
decode(dbms_compression.get_compression_type('&&owner','&&table_name',rowid),
	1,'No Compression',
	2,'Basic/OLTP',
	4,'HCC Query High',
	8,'HCC Query Low',
	16,'HCC Archive High',
	32,'HCC Archive Low',
        64,'Block') comptype
from "&&owner"."&&table_name"
where &&predicate
/


