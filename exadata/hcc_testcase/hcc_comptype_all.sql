-- lst16-11-allcomptypes.sql, from john clarke 
set lines 200
col comptype format a20 head "CompType"
col cnt format 999,999,999 head "#Rows"
col pct format 999.90 head "%ofTotal"
set echo on

select comptype,count(*) cnt,100*(count(*)/rowcount) pct
from (
 select '&&owner' owner, '&&table_name' tabname, rowid myrowid,
 decode(dbms_compression.get_compression_type('&&owner','&&table_name',rowid),
	1,'No Compression', 2,'Basic/OLTP', 4,'HCC Query High',
	8,'HCC Query Low', 16,'HCC Archive High', 32,'HCC Archive Low',
        64,'Block') comptype,
 (count(*) over ()) rowcount
from "&&owner"."&&table_name"
) group by comptype,rowcount
/

