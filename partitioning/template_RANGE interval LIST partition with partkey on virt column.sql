
-- set context 
alter session set container = ORCL;
show con_name
show pdbs

--###############################################################################
-- RANGE interval LIST partition (simple testcase)


drop table t_daterange_submulti purge;
CREATE TABLE t_daterange_submulti 
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
-- RANGE interval LIST partition with partkey on virtual column
   
drop table SYSTEM.TEST_RANGE_LIST_VIRT purge;
 CREATE TABLE SYSTEM.TEST_RANGE_LIST_VIRT 
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
    begin_date_virtual invisible generated always as (Trunc(Cast(begin_date AS DATE)))
    )
  PARTITION BY RANGE (begin_date_virtual)
   INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH') )
   SUBPARTITION BY LIST (owner, object_type)
   SUBPARTITION TEMPLATE (
      SUBPARTITION SP1 VALUES ('SYS','TABLE'),   
      SUBPARTITION SPDEFAULT VALUES (DEFAULT) )
   (
   PARTITION PSTART VALUES LESS THAN (TO_DATE ('1970-01-01','yyyy-mm-dd')) ); 
   
   
-- to address date filter where Trunc(Cast is not used
drop index TEST_RANGE_LIST_VIRT_IDX;
create index TEST_RANGE_LIST_VIRT_IDX on TEST_RANGE_LIST_VIRT(BEGIN_DATE,END_DATE) global
     partition by hash(BEGIN_DATE,END_DATE) partitions 32;   


-- non partitioned temp table (for faster select on all_objects)
create table t_orig
   as
   select a.* , created-1 as begin_date,
                created+1 as end_date
   from all_objects a;


insert into SYSTEM.TEST_RANGE_LIST_VIRT 
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


exec dbms_stats.gather_table_stats(ownname => 'SYSTEM',tabname => 'TEST_RANGE_LIST_VIRT', granularity => 'ALL');  
   
   
   
-- check partitions and rows (4 partitions)  
--select count(*) from (
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.tablespace_name, num_rows
  FROM all_tab_partitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_RANGE_LIST_VIRT',table_name)
--  );
  ORDER BY 1, partition_position ASC
/

-- check subpartitions and rows (8 subpartitions)  
--select count(*) from (
  SELECT table_name,high_value,a.partition_position,a.partition_name,a.subpartition_name,a.tablespace_name, num_rows
  FROM all_tab_subpartitions  a
  where table_owner like nvl('SYSTEM',table_owner)
  and table_name like nvl('TEST_RANGE_LIST_VIRT',table_name)
--  );
  ORDER BY 1, partition_position ASC
/

-- check INDEX partitions and rows   
  SELECT index_name,composite,high_value,a.partition_position,a.partition_name,a.tablespace_name, num_rows
  FROM all_ind_partitions  a
  where index_owner like nvl('SYSTEM',index_owner)
  and index_name like nvl('TEST_RANGE_LIST_VIRT_IDX',index_name)
  ORDER BY 1, partition_position ASC
/

select * from SYSTEM.TEST_RANGE_LIST;
select * from SYSTEM.TEST_RANGE_LIST partition(SYS_P723);
select * from SYSTEM.TEST_RANGE_LIST subpartition(SYS_SUBP722);
   
   

-- no prune 6k2nrgrunpjum
select /* TEST_RANGE_LIST_VIRT0 */ * from TEST_RANGE_LIST_VIRT;

-- no prune d1ckcg1qxvt6r
select /* TEST_RANGE_LIST_VIRTa */ count(*) from TEST_RANGE_LIST_VIRT;

-- prune 105uprtj519fd
select /* TEST_RANGE_LIST_VIRTb */ * from TEST_RANGE_LIST_VIRT where owner ='SYS';


-- prune fb7a068c39cqu
select /* TEST_RANGE_LIST_VIRTc */ * from TEST_RANGE_LIST_VIRT where owner ='SYS' and object_type = 'TABLE';


-- no prune gf62h1qvbm7mm - when Trunc(Cast is not used there's no pruning
select /* TEST_RANGE_LIST_VIRTd */ * from TEST_RANGE_LIST_VIRT 
    where  begin_date >= to_date('20190501','yyyymmdd') ;

-- create index no prune 8am79xbyh23fm
select /* TEST_RANGE_LIST_VIRTd0ab */ * from TEST_RANGE_LIST_VIRT 
    where  begin_date >= to_date('20190501','yyyymmdd') ;

-- create index prune 8am79xbyh23fm - after stats gathering
select /* TEST_RANGE_LIST_VIRTd0abc */ * from TEST_RANGE_LIST_VIRT 
    where  begin_date >= to_date('20190501','yyyymmdd') ;

-- prune fvhvnbdvdkdr7         
select /* TEST_RANGE_LIST_VIRTd0 */ * from TEST_RANGE_LIST_VIRT 
    where  Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd') ;    
    
    
-- no prune 944hu3ycv6uju - when Trunc(Cast is not used there's no pruning
select /* TEST_RANGE_LIST_VIRTe */ * from TEST_RANGE_LIST_VIRT 
    where  begin_date <= to_date('20190501','yyyymmdd') ;

-- create index prune 69xfz9zf5q8b0
select /* TEST_RANGE_LIST_VIRTe0ab */ * from TEST_RANGE_LIST_VIRT 
    where  begin_date <= to_date('20190501','yyyymmdd') ;

-- prune 778anq9s6dct7
select /* TEST_RANGE_LIST_VIRTe0 */ * from TEST_RANGE_LIST_VIRT 
    where  Trunc(Cast(begin_date AS DATE)) <= to_date('20190501','yyyymmdd') ;
        

-- prune 89hx9jv4bhy0u    
select /* TEST_RANGE_LIST_VIRTf0a */ * from TEST_RANGE_LIST_VIRT 
where owner ='SYS' and object_type = 'TABLE'
and begin_date >= to_date('20190501','yyyymmdd');    


-- prune gq8gt71bpn67n
select /* TEST_RANGE_LIST_VIRTf0 */ * from TEST_RANGE_LIST_VIRT
WHERE  ( ( Trunc(Cast(end_date AS DATE)) >= To_date('2021-01-31', 'YYYY-MM-DD') )
         AND ( Trunc(Cast(begin_date AS DATE)) >= To_date('2019-04-01', 'YYYY-MM-DD') )
         AND ( Trunc(Cast(begin_date AS DATE)) <= To_date('2021-04-01', 'YYYY-MM-DD') ) ) ;
   



   