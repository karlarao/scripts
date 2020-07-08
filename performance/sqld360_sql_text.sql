def edb360_secs2go = 3600
def psqlid = &1
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '&psqlid', '111007', NULL);

@sqld360main_sqltextonly.sql

! mkdir dir_&psqlid
! mv sqld360_*&psqlid* dir_&psqlid
! mv planx_*&psqlid* dir_&psqlid
! mv sqlmon_*&psqlid* dir_&psqlid
! mv sqlmon_invalid* dir_&psqlid

exit

