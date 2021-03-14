
-- set context 
alter session set container = ORCL;
show con_name
show pdbs


--###############################################################################
-- LIST RANGE MANUAL SPLIT FUTURE DATES (simple testcase)

drop table PartitionedTable purge;
create table PartitionedTable (  
  id              number,
  PartitionKey    VARCHAR2(128 BYTE),
  created         date  
)
partition by list (id, PartitionKey)
subpartition by range (created)
subpartition template
(
  subpartition SP1 values less than (to_date ('2020-01-01','YYYY-MM-DD')),
  subpartition SP2 values less than (to_date ('2020-02-01','YYYY-MM-DD')),
  subpartition SP3 values less than (to_date ('2020-03-01','YYYY-MM-DD')),
  subpartition SPFUTURE VALUES LESS THAN(MAXVALUE)
)
(
  partition P1 values (1,'100'),
  partition P2 values (2,'200'),
  partition PDEFAULT values (default)
);


insert into PartitionedTable (id, partitionkey, created) VALUES (1,100,to_date('01/02/1990','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created) VALUES (2,200,to_date('01/02/1990','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created) VALUES (1,200,to_date('01/02/1990','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created) VALUES (1,500,to_date('01/02/2025','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created) VALUES (1,600,to_date('01/02/2026','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created)select OBJECT_ID,OBJECT_ID, max(created) from all_objects where rownum <2 group by OBJECT_ID;
select * from PartitionedTable;
commit;
exec dbms_stats.gather_table_stats(ownname => 'SYSTEM',tabname => 'PARTITIONEDTABLE', granularity => 'ALL');

-- split commands
-- https://oracle-base.com/articles/12c/online-split-partition-and-subpartition-12cr2
-- https://stackoverflow.com/questions/60500419/split-maxvalue-partition-in-oracle-with-new-subpartition-template
--
--select * from SYSTEM.PARTITIONEDTABLE partition(P3);
--select * from SYSTEM.PARTITIONEDTABLE subpartition(P3_SPFUTURE);
--
---- this works
--ALTER TABLE PARTITIONEDTABLE SPLIT PARTITION PDEFAULT VALUES (1,'500')
--INTO (PARTITION P3, PARTITION PDEFAULT);  
--
---- this works 
--ALTER TABLE PARTITIONEDTABLE SPLIT SUBPARTITION P3_SPFUTURE AT (TO_DATE('01/03/2025','MM/DD/YYYY')) 
--  INTO (
--    SUBPARTITION P3_SP4,
--    SUBPARTITION P3_SPFUTURE
--  ); 
--ALTER TABLE PARTITIONEDTABLE SPLIT SUBPARTITION P3_SPFUTURE AT (TO_DATE('02/02/2025','MM/DD/YYYY')) 
--  INTO (
--    SUBPARTITION P3_SP5,
--    SUBPARTITION P3_SPFUTURE
--  );   



select * from PartitionedTable;

select TO_CHAR(created,'YYYYMMDD') from all_objects where rownum < 5;

desc PartitionedTable



-- no prune 1z4j43094qqns
select /* ap6wrv77hnj2aa0a */ * from PartitionedTable;

-- no prune 304r073p9x6zx
select /* ap6wrv77hnj2aa0 */ count(*) from PartitionedTable;

-- prune 925812hajs3vp
select /* ap6wrv77hnj2aa */ * from PartitionedTable where PartitionKey ='200';


-- no prune 7rpncyd681wc0
select /* ap6wrv77hnj2ab */ * from PartitionedTable 
    where  created >= to_date('19920101','yyyymmdd') ;

-- no prune 7fzt2nc8yg71x
select /* ap6wrv77hnj2abz */ * from PartitionedTable 
    where  created >= to_date('20200101','yyyymmdd') ;    
    
-- prune dsqad34f15xmj
select /* ap6wrv77hnj2ac */ * from PartitionedTable 
    where  created <= to_date('19980101','yyyymmdd') ;
        

-- prune 5svfcu6w17103    
select /* ap6wrv77hnj2ad */ * from PartitionedTable 
where PartitionKey ='9'
and created >= to_date('20180101','yyyymmdd');    


--###############################################################################
-- LIST RANGE MANUAL SPLIT FUTURE DATES

drop table SYSTEM.TEST_LIST_RANGE purge;
create table SYSTEM.TEST_LIST_RANGE (  
    OWNER VARCHAR2(128 BYTE)  NOT NULL ENABLE, 
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
	END_DATE DATE 
)
partition by list (owner, object_type)
subpartition by range (begin_date)
subpartition template
(
  subpartition SP1 values less than (to_date ('2020-01-01','YYYY-MM-DD')),
  subpartition SP2 values less than (to_date ('2020-02-01','YYYY-MM-DD')),
  subpartition SP3 values less than (to_date ('2020-03-01','YYYY-MM-DD')),
  subpartition SPFUTURE VALUES LESS THAN(MAXVALUE)
)
(
  partition P1 values ('SYS','TABLE'),
  partition P2 values ('SYS','INDEX'),
  partition PDEFAULT values (default)
);



-- non partitioned temp table (for faster select on all_objects)
create table t_orig
   as
   select a.* , created-1 as begin_date,
                created+1 as end_date
   from all_objects a;
   

insert into SYSTEM.TEST_LIST_RANGE 
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


exec dbms_stats.gather_table_stats(ownname => 'SYSTEM',tabname => 'TEST_LIST_RANGE', granularity => 'ALL');  
   
   
   
-- check partitions and rows   
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.tablespace_name, num_rows
  FROM all_tab_partitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_LIST_RANGE',table_name)
  ORDER BY 1, partition_position ASC
/

-- check subpartitions and rows   
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.subpartition_name,a.tablespace_name, num_rows
  FROM all_tab_subpartitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_LIST_RANGE',table_name)
  ORDER BY 1, partition_position ASC
/

select * from SYSTEM.TEST_LIST_RANGE;
select * from SYSTEM.TEST_LIST_RANGE partition(SYS_P723);
select * from SYSTEM.TEST_LIST_RANGE subpartition(SYS_SUBP722);
   

-- no prune 3xvztacz2wy0b
select /* TEST_LIST_RANGEa0 */ * from TEST_LIST_RANGE;

-- no prune 3g2t2nc3sxu84
select /* TEST_LIST_RANGEb */ count(*) from TEST_LIST_RANGE;

-- prune 71u61vswacvdy
select /* TEST_LIST_RANGEc */ * from TEST_LIST_RANGE where owner ='SYS';


-- prune 1fxr8xjpn0ypy
select /* TEST_LIST_RANGEd */ * from TEST_LIST_RANGE where owner ='SYS' and object_type = 'TABLE';


-- no prune 195qpn7zyfcuz
select /* TEST_LIST_RANGEe */ * from TEST_LIST_RANGE 
    where  begin_date >= to_date('20190501','yyyymmdd') ;

-- no prune 58thv8jzvc8k4    
select /* TEST_LIST_RANGEe0a */ * from TEST_LIST_RANGE 
    where  Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd') ;        
    
-- prune 3rsvx4a117774
select /* TEST_LIST_RANGEf */ * from TEST_LIST_RANGE 
    where  begin_date <= to_date('20190501','yyyymmdd') ;


-- no prune 7wy9zmrsug1z3
select /* TEST_LIST_RANGEf0a */ * from TEST_LIST_RANGE 
    where  Trunc(Cast(begin_date AS DATE)) <= to_date('20190501','yyyymmdd') ;
        
-- prune 6bknhhg7mxdxw    
select /* TEST_LIST_RANGEg */ * from TEST_LIST_RANGE 
where owner ='SYS' and object_type = 'TABLE'
and begin_date >= to_date('20190501','yyyymmdd');    

   
-- no prune 1zjzp0vfrdkm3   
select /* TEST_LIST_RANGEh */ * from TEST_LIST_RANGE 
where ( (end_date >= to_date('20210131','yyyymmdd') )
and  ( begin_date >= to_date('20190401','yyyymmdd') ) 
and  ( begin_date <= to_date('20210401','yyyymmdd') ) );   


   