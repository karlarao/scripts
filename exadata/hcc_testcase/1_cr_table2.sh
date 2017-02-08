sqlplus /nolog<<EOF
connect / as sysdba
drop user hccuser cascade;
drop tablespace ts_hcctest including contents and datafiles;
drop tablespace ts_scratch including contents and datafiles;

create bigfile tablespace ts_hcctest;
create bigfile tablespace ts_scratch;

create user hccuser identified by hccuser;
grant dba to hccuser;
grant select any dictionary to hccuser;
grant unlimited tablespace to hccuser;
alter user hccuser default tablespace ts_hcctest;
alter user hccuser temporary tablespace temp;

connect hccuser/hccuser
create table hcctable tablespace ts_hcctest parallel nologging as select * from sys.dba_objects where rownum <= 10000;
commit;
exit
EOF
