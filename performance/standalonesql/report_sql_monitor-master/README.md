
# report_sql_monitor

Modified README by Karl Arao

# There are two modes to run this 
1) Run with 1 SQL_ID 
2) Batch Run with multiple SQL_IDs


## To run with 1 SQL_ID just do the following: 
	sqlplus "/ as sysdba" 
	@sqld360 <SQL_ID> 


## To run in batch of SQL_IDs do the following: 
You can do a batch run of report generation by inserting the SQL_ID to the plan_table. You can do this by doing manual INSERT or INSERT..SELECT on a filtered list of SQL_IDs. Example below: 
	def edb360_secs2go = 3600
	INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '0p1f7w41jj1tq', '111007', NULL);
	INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '3ddvj44c10qqx', '111007', NULL);
	INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '3m8smr0v7v1m6', '111007', NULL);
	INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '3nnj1js6gy2yb', '111007', NULL);
	INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '3sqgkcng6vx8r', '111007', NULL);
	@sqld360main.sql 


# Utility SHELL scripts and use
1) archive.sh - moves any output folders/files to archive folder
2) changeconfig.sh - allows to change the sqld360 main config file to use the fast version (only metadata,sqlmon) or original config (all sections)





