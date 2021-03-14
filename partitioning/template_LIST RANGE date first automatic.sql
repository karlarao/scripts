
-- set context 
alter session set container = ORCL;
show con_name
show pdbs



--######## (simple testcase) THIS PRUNES, use DATE as first column of LIST then <varchar> next
--## this uses the proper function matching date to date data type - (trunc(created)) virtual

-- varchar
drop table PartitionedTable purge;
CREATE TABLE PartitionedTable
( 
  id              number,
  PartitionKey    VARCHAR2(128 BYTE), -- using varchar
  created         date,
  trunc_created   date generated always AS (trunc(created)) virtual
) 
PARTITION BY LIST (trunc_created, PartitionKey) AUTOMATIC
(  
  PARTITION PSTART VALUES (to_date('01/01/1970', 'DD/MM/YYYY'), 'start')
);

insert into PartitionedTable (id, partitionkey, created) VALUES (1,100,to_date('01/02/1990','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created) VALUES (1,200,to_date('01/02/1990','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created)select OBJECT_ID,OBJECT_ID, max(created) from all_objects where rownum <2 group by OBJECT_ID;
select * from PartitionedTable;
commit;
exec dbms_stats.gather_table_stats(ownname => 'SYSTEM',tabname => 'PARTITIONEDTABLE', granularity => 'ALL');


select * from PartitionedTable;

select TO_CHAR(created,'YYYYMMDD') from all_objects where rownum < 5;

desc PartitionedTable


-- prune 35nrrd3pyrsuj
select /* 22xqv11u52m5wa2a1 */ * from PartitionedTable where PartitionKey ='200';

-- prune 5m59m5nxnwz7h
select /* 22xqv11u52m5wb2b1 */ * from PartitionedTable 
    where  created >= to_date('19920101','yyyymmdd') ;
        
-- prune cfyhddy58n920
select /* 22xqv11u52m5wc2c1 */ * from PartitionedTable 
    where  created <= to_date('19980101','yyyymmdd') ;
        
-- prune 4xxuycaygzqbs    
select /* 22xqv11u52m5wd2d1 */ * from PartitionedTable 
where PartitionKey ='9'
and created >= to_date('20180101','yyyymmdd'); 



--###############################################################################
-- automatic LIST partition on virtual column with format <date>,<key1>,<key2>
   
drop table SYSTEM.TEST_LIST_RANGE_AUTO_VIRT purge;
 CREATE TABLE SYSTEM.TEST_LIST_RANGE_AUTO_VIRT 
   (	OWNER VARCHAR2(128 BYTE)  NOT NULL ENABLE, 
	OBJECT_NAME VARCHAR2(128 BYTE)  NOT NULL ENABLE, 
	SUBOBJECT_NAME VARCHAR2(128 BYTE) , 
	OBJECT_ID NUMBER NOT NULL ENABLE, 
	DATA_OBJECT_ID NUMBER, 
	OBJECT_TYPE VARCHAR2(23 BYTE) , 
	CREATED DATE NOT NULL ENABLE, 
	LAST_DDL_TIME DATE NOT NULL ENABLE, 
	TIMESTAMP VARCHAR2(19 BYTE) , 
	STATUS VARCHAR2(7 BYTE) , 
	TEMPORARY VARCHAR2(1 BYTE) , 
	GENERATED VARCHAR2(1 BYTE) , 
	SECONDARY VARCHAR2(1 BYTE) , 
	NAMESPACE NUMBER NOT NULL ENABLE, 
	EDITION_NAME VARCHAR2(128 BYTE) , 
	SHARING VARCHAR2(18 BYTE) , 
	EDITIONABLE VARCHAR2(1 BYTE) , 
	ORACLE_MAINTAINED VARCHAR2(1 BYTE) , 
	APPLICATION VARCHAR2(1 BYTE) , 
	DEFAULT_COLLATION VARCHAR2(100 BYTE) , 
	DUPLICATED VARCHAR2(1 BYTE) , 
	SHARDED VARCHAR2(1 BYTE) , 
	CREATED_APPID NUMBER, 
	CREATED_VSNID NUMBER, 
	MODIFIED_APPID NUMBER, 
	MODIFIED_VSNID NUMBER, 
	BEGIN_DATE DATE, 
	END_DATE DATE,
    begin_date_virtual   date generated always AS (Trunc(Cast(begin_date AS DATE))) virtual
    )
  PARTITION BY LIST (begin_date_virtual, owner, object_type ) AUTOMATIC
    (  
      PARTITION PSTART VALUES (to_date('01/01/1970', 'DD/MM/YYYY'), 'START','START')
    );
 
   
   
-- to address date filter where Trunc(Cast is not used
drop index TEST_LIST_RANGE_AUTO_VIRT_IDX;
create index TEST_LIST_RANGE_AUTO_VIRT_IDX on TEST_LIST_RANGE_AUTO_VIRT(BEGIN_DATE,END_DATE) global
     partition by hash(BEGIN_DATE,END_DATE) partitions 32;   


-- non partitioned temp table (for faster select on all_objects)
create table t_orig
   as
   select a.* , created-1 as begin_date,
                created+1 as end_date
   from all_objects a;


insert into SYSTEM.TEST_LIST_RANGE_AUTO_VIRT 
(
OWNER,
OBJECT_NAME,
SUBOBJECT_NAME,
OBJECT_ID,
DATA_OBJECT_ID,
OBJECT_TYPE,
CREATED,
LAST_DDL_TIME,
TIMESTAMP,
STATUS,
TEMPORARY,
GENERATED,
SECONDARY,
NAMESPACE,
EDITION_NAME,
SHARING,
EDITIONABLE,
ORACLE_MAINTAINED,
APPLICATION,
DEFAULT_COLLATION,
DUPLICATED,
SHARDED,
CREATED_APPID,
CREATED_VSNID,
MODIFIED_APPID,
MODIFIED_VSNID  ,
begin_date,
end_date
) select 
OWNER,
OBJECT_NAME,
SUBOBJECT_NAME,
OBJECT_ID,
DATA_OBJECT_ID,
OBJECT_TYPE,
CREATED,
LAST_DDL_TIME,
TIMESTAMP,
STATUS,
TEMPORARY,
GENERATED,
SECONDARY,
NAMESPACE,
EDITION_NAME,
SHARING,
EDITIONABLE,
ORACLE_MAINTAINED,
APPLICATION,
DEFAULT_COLLATION,
DUPLICATED,
SHARDED,
CREATED_APPID,
CREATED_VSNID,
MODIFIED_APPID,
MODIFIED_VSNID  ,
 begin_date,
 end_date
   from t_orig a;   

commit;   


exec dbms_stats.gather_table_stats(ownname => 'SYSTEM',tabname => 'TEST_LIST_RANGE_AUTO_VIRT', granularity => 'ALL');  
   
   
   
-- check partitions and rows 
-- partition by day resulted to 323 partitions
--select count(*) from (
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.tablespace_name, num_rows
  FROM all_tab_partitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_LIST_RANGE_AUTO_VIRT',table_name)
--  );
  ORDER BY 1, partition_position ASC
/

-- check subpartitions and rows   
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.subpartition_name,a.tablespace_name, num_rows
  FROM all_tab_subpartitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_LIST_RANGE_AUTO_VIRT',table_name)
  ORDER BY 1, partition_position ASC
/

-- check INDEX partitions and rows   
  SELECT index_name,composite,high_value,a.partition_position,a.partition_name,a.tablespace_name, num_rows
  FROM all_ind_partitions  a
  where index_owner like nvl('SYSTEM',index_owner)
  and index_name like nvl('TEST_LIST_RANGE_AUTO_VIRT',index_name)
  ORDER BY 1, partition_position ASC
/

select * from SYSTEM.TEST_LIST_RANGE_AUTO_VIRT;

--( TO_DATE(' 2019-04-16 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'), 'SYS', 'TABLE' )
select * from SYSTEM.TEST_LIST_RANGE_AUTO_VIRT partition(SYS_P845);

   
   


DONE-- prune a65p8s82svc75  (this query is slow 200secs vs 34secs RANGE LIST virt col TEST_RANGE_LIST_VIRT      
select /* TEST_LIST_RANGE_AUTO_VIRTd */ * from TEST_LIST_RANGE_AUTO_VIRT 
    where  Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd') ;    
--
--SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
--------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
--a65p8s82svc75	   0 2702690513 	   1	    209.038185		290 select /* TEST_LIST_RANGE_AUTO_VIRTd */ * from TEST_LIST_RANGE_AUTO_VIRT
--Plan hash value: 2702690513
--
------------------------------------------------------------------------------------------------------------------------
--| Id  | Operation		| Name			    | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT	|			    |	     |	     |	  65 (100)|	     |	     |	     |
--|   1 |  PARTITION LIST ITERATOR|			    |  72434 |	  10M|	  65   (2)| 00:00:01 |	 KEY |	 KEY |
--|*  2 |   TABLE ACCESS FULL	| TEST_LIST_RANGE_AUTO_VIRT |  72434 |	  10M|	  65   (2)| 00:00:01 |	 KEY |	 KEY |
------------------------------------------------------------------------------------------------------------------------
--SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
--------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
--fvhvnbdvdkdr7	   0 2428588542 	   1	     33.628897		988 select /* TEST_RANGE_LIST_VIRTd0 */ * from TEST_RANGE_LIST_VIRT
--Plan hash value: 2428588542
--
--------------------------------------------------------------------------------------------------------------------
--| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT	 |			|	 |	 |    35 (100)| 	 |	 |	 |
--|   1 |  PARTITION RANGE ITERATOR|			|   5626 |   857K|    35   (0)| 00:00:01 |   594 |1048575|
--|   2 |   PARTITION LIST ALL	 |			|   5626 |   857K|    35   (0)| 00:00:01 |     1 |     2 |
--|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST_VIRT |   5626 |   857K|    35   (0)| 00:00:01 |  1187 |1048575|
--------------------------------------------------------------------------------------------------------------------
--


    
    
   


select Trunc(Cast(sysdate AS DATE)) from dual;
select Trunc(Cast(sysdate AS DATE),'MONTH') from dual;



 CREATE TABLE SYSTEM.TEST_LIST_RANGE_AUTO_VIRT_MONTH 
   (	OWNER VARCHAR2(128 BYTE)  NOT NULL ENABLE, 
	OBJECT_NAME VARCHAR2(128 BYTE)  NOT NULL ENABLE, 
	SUBOBJECT_NAME VARCHAR2(128 BYTE) , 
	OBJECT_ID NUMBER NOT NULL ENABLE, 
	DATA_OBJECT_ID NUMBER, 
	OBJECT_TYPE VARCHAR2(23 BYTE) , 
	CREATED DATE NOT NULL ENABLE, 
	LAST_DDL_TIME DATE NOT NULL ENABLE, 
	TIMESTAMP VARCHAR2(19 BYTE) , 
	STATUS VARCHAR2(7 BYTE) , 
	TEMPORARY VARCHAR2(1 BYTE) , 
	GENERATED VARCHAR2(1 BYTE) , 
	SECONDARY VARCHAR2(1 BYTE) , 
	NAMESPACE NUMBER NOT NULL ENABLE, 
	EDITION_NAME VARCHAR2(128 BYTE) , 
	SHARING VARCHAR2(18 BYTE) , 
	EDITIONABLE VARCHAR2(1 BYTE) , 
	ORACLE_MAINTAINED VARCHAR2(1 BYTE) , 
	APPLICATION VARCHAR2(1 BYTE) , 
	DEFAULT_COLLATION VARCHAR2(100 BYTE) , 
	DUPLICATED VARCHAR2(1 BYTE) , 
	SHARDED VARCHAR2(1 BYTE) , 
	CREATED_APPID NUMBER, 
	CREATED_VSNID NUMBER, 
	MODIFIED_APPID NUMBER, 
	MODIFIED_VSNID NUMBER, 
	BEGIN_DATE DATE, 
	END_DATE DATE,
    begin_date_virtual   date generated always AS (Trunc(Cast(begin_date AS DATE),'MONTH')) virtual
    )
  PARTITION BY LIST (begin_date_virtual, owner, object_type ) AUTOMATIC
    (  
      PARTITION PSTART VALUES (to_date('01/01/1970', 'DD/MM/YYYY'), 'START','START')
    );


insert into SYSTEM.TEST_LIST_RANGE_AUTO_VIRT_MONTH 
(
OWNER,
OBJECT_NAME,
SUBOBJECT_NAME,
OBJECT_ID,
DATA_OBJECT_ID,
OBJECT_TYPE,
CREATED,
LAST_DDL_TIME,
TIMESTAMP,
STATUS,
TEMPORARY,
GENERATED,
SECONDARY,
NAMESPACE,
EDITION_NAME,
SHARING,
EDITIONABLE,
ORACLE_MAINTAINED,
APPLICATION,
DEFAULT_COLLATION,
DUPLICATED,
SHARDED,
CREATED_APPID,
CREATED_VSNID,
MODIFIED_APPID,
MODIFIED_VSNID  ,
begin_date,
end_date
) select 
OWNER,
OBJECT_NAME,
SUBOBJECT_NAME,
OBJECT_ID,
DATA_OBJECT_ID,
OBJECT_TYPE,
CREATED,
LAST_DDL_TIME,
TIMESTAMP,
STATUS,
TEMPORARY,
GENERATED,
SECONDARY,
NAMESPACE,
EDITION_NAME,
SHARING,
EDITIONABLE,
ORACLE_MAINTAINED,
APPLICATION,
DEFAULT_COLLATION,
DUPLICATED,
SHARDED,
CREATED_APPID,
CREATED_VSNID,
MODIFIED_APPID,
MODIFIED_VSNID  ,
 begin_date,
 end_date
   from t_orig a;   

commit;   



DONE-- no prune 9hxx8w03195nc  
select /* TEST_LIST_RANGE_AUTO_VIRT_MONTHd1b */ * from TEST_LIST_RANGE_AUTO_VIRT_MONTH 
    where  Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd') ;    
    

select Trunc(Cast(SYSDATE AS DATE),'MONTH') from dual;


DONE-- no prune 88yz26rygfxfc
select /* TEST_LIST_RANGE_AUTO_VIRT_MONTHd3b1a */ * from TEST_LIST_RANGE_AUTO_VIRT_MONTH 
    where  Trunc(Cast(SYSDATE AS DATE),'MONTH') >= to_date('20190501','yyyymmdd') ;        



exec dbms_stats.gather_table_stats(ownname => 'SYSTEM',tabname => 'TEST_LIST_RANGE_AUTO_VIRT_MONTH', granularity => 'ALL');  
   
   
   
-- check partitions and rows 
-- partition by day resulted to 323 partitions
-- partition by month also resulted to 323 partitions
--select count(*) from (
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.tablespace_name, num_rows
  FROM all_tab_partitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_LIST_RANGE_AUTO_VIRT_MONTH',table_name)
--  );
  ORDER BY 1, partition_position ASC
/




--( TO_DATE(' 2019-04-16 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'), 'SYS', 'TABLE' ) -- trunc only
--( TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss', 'nls_calendar=gregorian'), 'SYS', 'TABLE' ) -- by month
select * from SYSTEM.TEST_LIST_RANGE_AUTO_VIRT_MONTH partition(SYS_P1169);

   
       
