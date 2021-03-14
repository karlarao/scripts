
-- set context 
alter session set container = ORCL;
show con_name
show pdbs

--###############################################################################
-- RANGE interval LIST partition (simple testcase)


drop table t_daterange_submulti purge;
CREATE TABLE t_daterange_submulti -- this works
  (
   begin_date timestamp,
   owner varchar2(20),
   object_type varchar2(20)
  )
  PARTITION BY RANGE (begin_date)
   INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH') )
   SUBPARTITION BY LIST (owner, object_type)
   SUBPARTITION TEMPLATE (
      SUBPARTITION recur_0y VALUES ('SYS','TABLE'),
      SUBPARTITION recur_1y VALUES ('SYS','INDEX'),
      SUBPARTITION recur_def VALUES (DEFAULT) )
   (
   PARTITION pstart VALUES LESS THAN (TO_DATE ('1970-01-01','yyyy-mm-dd')) );   


insert into t_daterange_submulti (begin_date, owner, object_type) VALUES (to_date('01/02/1990','DD/MM/YYYY'),'SYS','TABLE');    
insert into t_daterange_submulti (begin_date, owner, object_type) VALUES (to_date('03/07/2021','DD/MM/YYYY'),'SYS','TABLE');    
insert into t_daterange_submulti (begin_date, owner, object_type) VALUES (to_date('03/07/2021','DD/MM/YYYY'),'KARL','TABLE');    
insert into t_daterange_submulti (begin_date, owner, object_type) VALUES (to_date('01/02/2020','DD/MM/YYYY'),'SYS','TABLE');    
commit;   


-- no prune 4wkdznqsmy065
select /* t_daterange_submultide */ count(*) from t_daterange_submulti;

-- prune f5qhanzkazczp
select /* t_daterange_submultia */ * from t_daterange_submulti where owner ='KARL';


-- prune c62svwn2qf149
select /* v t_daterange_submultib */ * from t_daterange_submulti 
    where  begin_date >= to_date('20210101','yyyymmdd') ;
    
    
-- prune 1zdy354usq288
select /* t_daterange_submultic */ * from t_daterange_submulti 
    where  begin_date <= to_date('19980101','yyyymmdd') ;
        

-- prune 6801xxuuk5g1r    
select /* t_daterange_submultid */ * from t_daterange_submulti 
where owner ='KARL'
and begin_date >= to_date('20210101','yyyymmdd');    


--###############################################################################
-- RANGE interval LIST partition
   
drop table SYSTEM.TEST_RANGE_LIST purge;
 CREATE TABLE SYSTEM.TEST_RANGE_LIST 
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
	END_DATE DATE)
  PARTITION BY RANGE (begin_date)
   INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH') )
   SUBPARTITION BY LIST (owner, object_type)
   SUBPARTITION TEMPLATE (
      SUBPARTITION SP1 VALUES ('SYS','TABLE'),   
      SUBPARTITION SPDEFAULT VALUES (DEFAULT) )
   (
   PARTITION PSTART VALUES LESS THAN (TO_DATE ('1970-01-01','yyyy-mm-dd')) ); 
   
   

-- non partitioned temp table (for faster select on all_objects)
create table t_orig
   as
   select a.* , created-1 as begin_date,
                created+1 as end_date
   from all_objects a;
   

insert into SYSTEM.TEST_RANGE_LIST 
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


exec dbms_stats.gather_table_stats(ownname => 'SYSTEM',tabname => 'TEST_RANGE_LIST', granularity => 'ALL');  
   
   
   
-- check partitions and rows   
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.tablespace_name, num_rows
  FROM all_tab_partitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_RANGE_LIST',table_name)
  ORDER BY 1, partition_position ASC
/

-- check subpartitions and rows   
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.subpartition_name,a.tablespace_name, num_rows
  FROM all_tab_subpartitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_RANGE_LIST',table_name)
  ORDER BY 1, partition_position ASC
/

select * from SYSTEM.TEST_RANGE_LIST;
select * from SYSTEM.TEST_RANGE_LIST partition(SYS_P723);
select * from SYSTEM.TEST_RANGE_LIST subpartition(SYS_SUBP722);
   
   

-- no prune avq68gfq7ndxr
select /* TEST_RANGE_LISTa0 */ * from TEST_RANGE_LIST;

-- no prune 1w1ag2dqgxn2r
select /* TEST_RANGE_LISTa */ count(*) from TEST_RANGE_LIST;

-- prune 72v16h9189yau
select /* TEST_RANGE_LISTb */ * from TEST_RANGE_LIST where owner ='SYS';


-- prune 98famt7usu84g
select /* TEST_RANGE_LISTb0 */ * from TEST_RANGE_LIST where owner ='SYS' and object_type = 'TABLE';


-- prune 31u8y6dhwdxd3
select /* v TEST_RANGE_LISTc */ * from TEST_RANGE_LIST 
    where  begin_date >= to_date('20190501','yyyymmdd') ;

-- no prune f4qpp333yumnh
select /* TEST_RANGE_LISTc0a */ * from TEST_RANGE_LIST 
    where  Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd') ;      
    
-- prune d3b40q3mb3g87
select /* TEST_RANGE_LISTd */ * from TEST_RANGE_LIST 
    where  begin_date <= to_date('20190501','yyyymmdd') ;

-- no prune 0145srmxucy79
select /* TEST_RANGE_LISTd0a */ * from TEST_RANGE_LIST 
    where  Trunc(Cast(begin_date AS DATE)) <= to_date('20190501','yyyymmdd') ;    
        

-- prune 6gj7zwc9rzbq5    
select /* TEST_RANGE_LISTe */ * from TEST_RANGE_LIST 
where owner ='SYS' and object_type = 'TABLE'
and begin_date >= to_date('20190501','yyyymmdd');    

   
-- prune ccjajbdwq80uf   
select /* TEST_RANGE_LISTf */ * from TEST_RANGE_LIST 
where ( (end_date >= to_date('20210131','yyyymmdd') )
and  ( begin_date >= to_date('20190401','yyyymmdd') ) 
and  ( begin_date <= to_date('20210401','yyyymmdd') ) );   


   