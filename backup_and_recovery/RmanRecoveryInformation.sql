-- RmanRecoveryInformation.sql
-- Get full details of the state of the database in a restore/recovery scenario
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--
-- NOTE: this script spools a file called recovery_info.txt which is your starting point on a B&R scenario

spool recovery_info.txt
set pagesize 20000
set linesize 300
set pause off
set serveroutput on
set feedback on
set echo on
set numformat 999999999999999
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';

select name, CREATED, controlfile_type, open_mode, checkpoint_change#, ARCHIVE_CHANGE#, FLASHBACK_ON, FORCE_LOGGING from  v$database;

-- for 10g up
select incarnation#,resetlogs_change#,resetlogs_time,prior_resetlogs_change#,prior_resetlogs_time,status from v$database_incarnation;

-- for 9i below
select resetlogs_change#,resetlogs_time,prior_resetlogs_change#,prior_resetlogs_time from v$database_incarnation;

select substr(name, 1, 50), status from v$datafile;

select substr(name,1,40), recover, fuzzy, checkpoint_change# from v$datafile_header;

select GROUP#,THREAD#,SEQUENCE#,MEMBERS,ARCHIVED,STATUS,FIRST_CHANGE# from  v$log;

select GROUP#,substr(member,1,60) from v$logfile;

select * from v$log_history;

select * from v$recover_file;

select * from V$BACKUP_CORRUPTION;

select * from V$COPY_CORRUPTION;

select * from V$DATABASE_BLOCK_CORRUPTION;

SELECT * FROM v$recovery_log;

SELECT f.name,b.status,b.change#,b.time FROM v$backup b,v$datafile f WHERE b.file# = f.file# AND b.status='ACTIVE';

SELECT hxfil file_num,substr(hxfnm,1,40) file_name,fhtyp type,hxerr validity, fhscn chk_ch#, fhtnm tablespace_name,fhsta status,fhrba_seq sequence FROM x$kcvfh;

select 'controlfile' "SCN location",'SYSTEM checkpoint' name,checkpoint_change#
from v$database
union
select 'file in controlfile',to_char(count(*)),checkpoint_change#
from v$datafile
group by checkpoint_change#
union
select 'file header',to_char(count(*)),checkpoint_change#
from v$datafile_header
group by checkpoint_change#;

col name format a50
select 'controlfile' "SCN location",'SYSTEM checkpoint' name,checkpoint_change#
from v$database
union
select 'file in controlfile',name,checkpoint_change#
from v$datafile 
union
select 'file header',name,checkpoint_change#
from v$datafile_header;


-- The query below checks if all of the online datafiles are synchronized in terms of their SCN (system change number), you can normally open your database your database if the SCNs are synced and redo from redo logs are applied

      select status, checkpoint_change#,
	      to_char(checkpoint_time, 'DD-MON-YYYY HH24:MI:SS') as checkpoint_time,
	      count(*)
	from v$datafile_header
	group by status, checkpoint_change#, checkpoint_time
	order by status, checkpoint_change#, checkpoint_time;

-- The query below checks for offline datafiles

      select file#, name from v$datafile
      where file# in (select file# from v$datafile_header
		      where status='OFFLINE');  

-- The query below checks if the required redo log sequence# is still available in the online redo logs and the corresponding redo log member is still physically existing on the disk

      set echo on feedback on pagesize 100 numwidth 16 
      alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS'; 
      select LF.member, L.group#, L.thread#, L.sequence#, L.status, 
	    L.first_change#, L.first_time, DF.min_checkpoint_change# 
      from v$log L, v$logfile LF, 
	  (select min(checkpoint_change#) min_checkpoint_change# 
	    from v$datafile_header 
	    where status='ONLINE') DF 
      where LF.group# = L.group# 
      and L.first_change# >= DF.min_checkpoint_change#;

-- Once the redo log member is identified, execute the recover command and apply the redo log member to fully recover the database



----------------------------------------------------------------------------------------------------------------------------------------------------------




SET PAGESIZE 20000
SET LINESIZE 1000
SET TRIMSPOOL ON
SET PAUSE OFF
SET SERVEROUTPUT ON
SET FEEDBACK ON
SET ECHO ON
SET NUMFORMAT 999999999999999
COL TABLESPACE_NAME FORMAT A50
COL FILE_NAME FORMAT A50
COL NAME FORMAT A50
COL MEMBER FORMAT A50
col DFILE_CHKP_CHANGE format a40
col DFILE_HED_CHKP_CHANGE format a40
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';


ARCHIVE LOG LIST;

SELECT *
FROM v$instance;


SELECT dbid,
name,
TO_CHAR(created, 'DD-MM-YYYY HH24:MI:SS') created,
open_mode,
log_mode,
TO_CHAR(checkpoint_change#, '999999999999999') as checkpoint_change#,
controlfile_type,
TO_CHAR(controlfile_change#, '999999999999999') as controlfile_change#,
TO_CHAR(controlfile_time, 'DD-MM-YYYY HH24:MI:SS') controlfile_time,
TO_CHAR(resetlogs_change#, '999999999999999') as resetlogs_change#,
TO_CHAR(resetlogs_time, 'DD-MM-YYYY HH24:MI:SS') resetlogs_time
FROM v$database;

SELECT *
FROM v$recover_file;

SELECT *
FROM v$recovery_log;

SELECT f.name, b.status, b.change#, b.time
FROM v$backup b,
v$datafile f
WHERE b.file# = f.file#
AND b.status = 'ACTIVE';

SELECT name,
file#,
status,
enabled,
creation_change#,
TO_CHAR(creation_time, 'DD-MM-YYYY HH24:MI:SS') as creation_time,
TO_CHAR(checkpoint_change#, '999999999999999') as checkpoint_change#,
TO_CHAR(checkpoint_time, 'DD-MM-YYYY HH24:MI:SS') as checkpoint_time,
TO_CHAR(offline_change#, '999999999999999') as offline_change#,
TO_CHAR(online_change#, '999999999999999') as online_change#,
TO_CHAR(online_time, 'DD-MM-YYYY HH24:MI:SS') as online_time,
TO_CHAR(bytes, '9,999,999,999,990') as bytes
FROM v$datafile
ORDER BY checkpoint_change#;

SELECT name,
file#,
status,
error,
creation_change#,
TO_CHAR(creation_time, 'DD-MM-YYYY HH24:MI:SS') as creation_time,
TO_CHAR(checkpoint_change#, '999999999999999') as checkpoint_change#,
TO_CHAR(checkpoint_time, 'DD-MM-YYYY HH24:MI:SS') as checkpoint_time,
TO_CHAR(resetlogs_change#, '999999999999999') as resetlogs_change#,
TO_CHAR(resetlogs_time, 'DD-MM-YYYY HH24:MI:SS') as resetlogs_time,
TO_CHAR(bytes, '9,999,999,999,990') as bytes
FROM v$datafile_header
ORDER BY checkpoint_change#;

SELECT status,
checkpoint_change#,
TO_CHAR(checkpoint_time, 'DD-MM-YYYY HH24:MI:SS') as checkpoint_time,
count(*)
FROM v$datafile_header
GROUP BY status, checkpoint_change#, checkpoint_time
ORDER BY status, checkpoint_change#, checkpoint_time;

SELECT dd.FILE#,
dd.NAME,
dd.STATUS,
to_char(dd.checkpoint_change#,'999999999999999') dfile_chkp_change,
to_char(dh.checkpoint_change#,'999999999999999') dfile_hed_chkp_change,
dh.recover,
dh.fuzzy
FROM v$datafile dd,
v$datafile_header dh
WHERE dd.FILE#=dh.FILE#;

select * from v$database_incarnation;


SELECT hxfil file_num,
hxfnm file_name,
fhtyp type,
hxerr validity,
fhscn scn,
fhtnm tablespace_name,
fhsta status ,
fhthr thread,
fhrba_seq sequence
FROM x$kcvfh
order by scn;


SELECT fhthr thread,
fhrba_seq sequence,
fhscn scn,
fhsta status,
count(*)
FROM x$kcvfh
group by fhthr,fhrba_seq,fhscn,fhsta;


SELECT hxfil file_num,
fhscn scn,
fhsta status ,
fhthr thread,
fhrba_seq sequence
FROM x$kcvfh
order by scn;




SELECT group#,
thread#,
sequence#,
members,
archived,
status,
TO_CHAR(first_change#, '999999999999999') as first_change#
FROM v$log;

SELECT group#,
member
FROM v$logfile;

SELECT a.recid,
a.thread#,
a.sequence#,
a.name,
tO_CHAR(a.first_change#, '999999999999999') as first_change#,
to_char(a.NEXT_CHANGE#, '999999999999999') as next_change# ,
a.archived,
a.deleted,
TO_DATE(a.completion_time, 'DD-MM-YYYY HH24:MI:SS') as completed
FROM v$archived_log a, v$log l
WHERE a.thread# = l.thread#
AND a.sequence# = l.sequence#;


SELECT a.recid,
a.thread#,
a.sequence#,
a.name,
tO_CHAR(a.first_change#, '999999999999999') as first_change#,
to_char(a.NEXT_CHANGE#, '999999999999999') as next_change# ,
a.archived,
a.deleted,
TO_DATE(a.completion_time, 'DD-MM-YYYY HH24:MI:SS') as completed
FROM v$archived_log a, v$recovery_log l
WHERE a.thread# = l.thread#
AND a.sequence# = l.sequence#;


SELECT recid,
thread#,
sequence#,
name,
tO_CHAR(first_change#, '999999999999999') as first_change#,
to_char(NEXT_CHANGE#, '999999999999999') as next_change# ,
archived,
deleted,
TO_DATE(completion_time, 'DD-MM-YYYY HH24:MI:SS') as completed,
blocks,
block_size
FROM v$archived_log;


spool off
exit

