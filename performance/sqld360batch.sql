
-- input variables
def edb360_secs2go = 3600
def psqlid = "sqld360batch"


-- define the list of SQL_IDs here 
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '31a10gjhav20j', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '5940pkcca9ajg', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '552cz27tmq3u7', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '31a10gjhav20j', '111007', NULL);


-- execute collection 
@sqld360main.sql


exit

