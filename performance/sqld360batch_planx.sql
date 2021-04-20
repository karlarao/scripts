

-- input variables
def edb360_secs2go = 3600
def psqlid = "sqld360batch"


-- define the list of SQL_IDs here 
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', 'gx4t0v15w4tt5', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', 'f9urrbyx457xc', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '2b780kryr8y0f', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '4fvp7jw3zd9ku', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '7dbv3dpt4myj1', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', 'gjmmn0uwp26r1', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', 'gbkcj8ctqfh1z', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '1nhgrtxz5fjx5', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '18qdxm4pkyguk', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '2zwjx22tun8mc', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', 'gbkcj8ctqfh1z', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '7dbv3dpt4myj1', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '7g87jyqny6tqp', '111007', NULL);
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '3df7rn31xkfds', '111007', NULL);	
INSERT INTO plan_table (id, statement_id, operation, options, object_node) values (dbms_random.value(1,10000), 'SQLD360_SQLID', '6hg0ap0nr5b3b', '111007', NULL);


-- execute collection, planx only 
@sqld360main_planx.sql


exit



