
-- set context 
alter session set container = ORCL;
show con_name
show pdbs



--###############################################################################
-- LIST RANGE AUTOMATIC partition (pruning doesn't work because the date column is varchar)


-- varchar
drop table PartitionedTable purge;
CREATE TABLE PartitionedTable
( 
  id              number,
  PartitionKey    VARCHAR2(128 BYTE), -- using varchar
  created         date,
  trunc_created   VARCHAR2(200) generated always AS (TO_CHAR(created,'DD-MON-YYYY')) virtual
) 
PARTITION BY LIST (PartitionKey, trunc_created) AUTOMATIC
(  
  PARTITION PSTART VALUES ('start', '01-JAN-1970')
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


-- prune ap6wrv77hnj2a
select /* 22xqv11u52m5wa */ * from PartitionedTable where PartitionKey ='200';



-- no prune 9c1c8xbgkjzvz
select /* 22xqv11u52m5wb */ * from PartitionedTable 
    where  created >= to_date('19920101','yyyymmdd') ;
    
    
-- no prune dkt0wyty1u620
select /* 22xqv11u52m5wc */ * from PartitionedTable 
    where  created <= to_date('19980101','yyyymmdd') ;
        

-- prune bcs2wabau1b7m    
select /* 22xqv11u52m5wd */ * from PartitionedTable 
where PartitionKey ='9'
and created >= to_date('20180101','yyyymmdd');    


--######## only works when PartitionKey is number 

drop table PartitionedTable purge;
CREATE TABLE PartitionedTable
( 
  id              number,
  PartitionKey    number, -- using number
  created         date,
  trunc_created date generated always as (trunc(created)) virtual
) 
PARTITION BY LIST (PartitionKey, trunc_created) AUTOMATIC
(  
  PARTITION PDEFAULT VALUES (1, to_date('01.01.2000', 'DD.MM.YYYY'))
);
insert into PartitionedTable (id, partitionkey, created) VALUES (1,100,to_date('01/02/1990','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created) VALUES (1,200,to_date('01/02/1990','DD/MM/YYYY')); 
insert into PartitionedTable (id, partitionkey, created)select OBJECT_ID,OBJECT_ID, max(created) from all_objects where rownum <2 group by OBJECT_ID;
select * from PartitionedTable;
commit;
exec dbms_stats.gather_table_stats(ownname => 'SYSTEM',tabname => 'PARTITIONEDTABLE', granularity => 'ALL');


select * from PartitionedTable;

-- prune 2yvjb8zarqhca
select /* v partitionedtable2 */ * from PartitionedTable where PartitionKey ='100';


-- prune 1tsa224myvh6r
select /* v partitionedtable4 */ * from PartitionedTable 
    where  created >= to_date('20161031','yyyymmdd') ;
    

-- prune 0k92sxjxr5m0p    
select /* v partitionedtable5 */ * from PartitionedTable 
where PartitionKey ='100'
and created >= to_date('20161031','yyyymmdd');    




--## THIS DEMONSTRATE NO PRUNING when flipping the column position of LIST, make sure to use (trunc(created)) virtual and not (TO_CHAR(created,'DD-MON-YYYY')) virtual on the DATE virtual column
--######## you can use DATE when you put it as first column of LIST then <varchar> next


-- varchar
drop table PartitionedTable purge;
CREATE TABLE PartitionedTable
( 
  id              number,
  PartitionKey    VARCHAR2(128 BYTE), -- using varchar
  created         date,
  trunc_created   date generated always AS (TO_CHAR(created,'DD-MON-YYYY')) virtual
) 
PARTITION BY LIST (trunc_created, PartitionKey) AUTOMATIC
(  
  PARTITION PSTART VALUES ('01-JAN-1970', 'start')
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


-- prune 1k6y0jaj8s3mr
select /* 22xqv11u52m5wa2a3 */ * from PartitionedTable where PartitionKey ='200';



-- no prune cmw0xdjz2sv6n
select /* 22xqv11u52m5wb2b3 */ * from PartitionedTable 
    where  created >= to_date('19920101','yyyymmdd') ;
    
    
-- no prune cjmbxd4rd0qwz
select /* 22xqv11u52m5wc2c3 */ * from PartitionedTable 
    where  created <= to_date('19980101','yyyymmdd') ;
        

-- prune 0kbp67ujg7y56    
select /* 22xqv11u52m5wd2d3 */ * from PartitionedTable 
where PartitionKey ='9'
and created >= to_date('20180101','yyyymmdd');    

   


--######## Andy Klock! THIS PRUNES! use DATE as first column of LIST then <varchar> next
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
  PARTITION PSTART VALUES (to_date('01/01/2000', 'DD/MM/YYYY'), 'start')
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