-- copy paste the output and modify to create the csv sql 

set timing off
set feedback off
set heading off
set echo off

select 'column '||column_name||' format a'||(DATA_LENGTH+2) from dba_tab_columns where table_name='&&TABLE_NAME';
select column_name||','from dba_tab_columns where table_name='&&TABLE_NAME' order by column_id asc;

-- GV$ACTIVE_SESSION_HISTORY
-- DBA_HIST_ACTIVE_SESS_HISTORY
-- CDB_HIST_ACTIVE_SESS_HISTORY
