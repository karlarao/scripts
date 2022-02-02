
select inst_id, sid from gv$mystat where rownum < 2;

select /* usercheck */ s.sid sid, s.serial# serial#, lpad(p.spid,7) unix_pid 
from gv$process p, gv$session s
where p.addr=s.paddr
and   s.username is not null
and (s.inst_id, s.sid) in (select inst_id, sid from gv$mystat where rownum < 2);


select sys_context('userenv', 'con_name') PDB from dual;


select name DBNAME from v$database;


select instance_name INSTNAME from v$instance;


set lines 300
col name format a30
select con_id, dbid, con_uid, name, open_mode, open_time from v$pdbs;
