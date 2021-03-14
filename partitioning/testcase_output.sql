


-- 64p3sd85z6u4g (prune)
select /* testcase partition */ * from t 
where end_date >= to_date('20210131','yyyymmdd') 
and  begin_date >= to_date('20190401','yyyymmdd')  
and  begin_date <= to_date('20210401','yyyymmdd') ;

00:16:15 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %testcase partition%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
64p3sd85z6u4g	   0 1571388083 	   1	       .139593	      1,621 select /* testcase partition */ * from t
									    where end_date >= to_date('20210131','


00:16:27 SYS@ORCL>  
00:16:38 SYS@ORCL> @dplan
Enter value for sql_id: 64p3sd85z6u4g

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	64p3sd85z6u4g, child number 0
-------------------------------------
select /* testcase partition */ * from t  where end_date >=
to_date('20210131','yyyymmdd')	and  begin_date >=
to_date('20190401','yyyymmdd')	 and  begin_date <=
to_date('20210401','yyyymmdd')

Plan hash value: 1571388083

--------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name | E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |	|	 |	 |   441 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|	|   3544 |   512K|   441   (1)| 00:00:01 |    10 |    12 |
|*  2 |   TABLE ACCESS FULL	 | T	|   3544 |   512K|   441   (1)| 00:00:01 |    10 |    12 |
--------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23], "T"."CREATED"[DATE,7],
       "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19], "T"."STATUS"[VARCHAR2,7],
       "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1], "T"."SECONDARY"[VARCHAR2,1],
       "T"."NAMESPACE"[NUMBER,22], "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1], "T"."CREATED_APPID"[NUMBER,22],
       "T"."CREATED_VSNID"[NUMBER,22], "T"."MODIFIED_APPID"[NUMBER,22],
       "T"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=137) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23], "T"."CREATED"[DATE,7],
       "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19], "T"."STATUS"[VARCHAR2,7],
       "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1], "T"."SECONDARY"[VARCHAR2,1],
       "T"."NAMESPACE"[NUMBER,22], "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1], "T"."CREATED_APPID"[NUMBER,22],
       "T"."CREATED_VSNID"[NUMBER,22], "T"."MODIFIED_APPID"[NUMBER,22],
       "T"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



83 rows selected.

--####################################################################################################################


-- 75n6q6rc75azn (no pruning)
select /* testcase non-partition */ * from t_orig 
where end_date >= to_date('20210131','yyyymmdd') 
and  begin_date >= to_date('20190401','yyyymmdd')  
and  begin_date <= to_date('20210401','yyyymmdd') ;

00:21:18 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %testcase non-partition%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
75n6q6rc75azn	   0 3935568924 	   1	       .362698	      2,058 select /* testcase non-partition */ * from t_orig
									    where end_date >= to_date('20


00:21:25 SYS@ORCL> 
00:21:27 SYS@ORCL> @dplan
Enter value for sql_id: 75n6q6rc75azn

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	75n6q6rc75azn, child number 0
-------------------------------------
select /* testcase non-partition */ * from t_orig  where end_date >=
to_date('20210131','yyyymmdd')	and  begin_date >=
to_date('20190401','yyyymmdd')	 and  begin_date <=
to_date('20210401','yyyymmdd')

Plan hash value: 3935568924

-----------------------------------------------------------------------------
| Id  | Operation	  | Name   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |	   |	    |	    |	441 (100)|	    |
|*  1 |  TABLE ACCESS FULL| T_ORIG |	  9 |  4491 |	441   (1)| 00:00:01 |
-----------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1 / T_ORIG@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_ORIG"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss') AND "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss') AND "BEGIN_DATE"<=TO_DATE(' 2021-04-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "T_ORIG"."OWNER"[VARCHAR2,128],
       "T_ORIG"."OBJECT_NAME"[VARCHAR2,128],
       "T_ORIG"."SUBOBJECT_NAME"[VARCHAR2,128],
       "T_ORIG"."OBJECT_ID"[NUMBER,22], "T_ORIG"."DATA_OBJECT_ID"[NUMBER,22],
       "T_ORIG"."OBJECT_TYPE"[VARCHAR2,23], "T_ORIG"."CREATED"[DATE,7],
       "T_ORIG"."LAST_DDL_TIME"[DATE,7], "T_ORIG"."TIMESTAMP"[VARCHAR2,19],
       "T_ORIG"."STATUS"[VARCHAR2,7], "T_ORIG"."TEMPORARY"[VARCHAR2,1],
       "T_ORIG"."GENERATED"[VARCHAR2,1], "T_ORIG"."SECONDARY"[VARCHAR2,1],
       "T_ORIG"."NAMESPACE"[NUMBER,22], "T_ORIG"."EDITION_NAME"[VARCHAR2,128],
       "T_ORIG"."SHARING"[VARCHAR2,18], "T_ORIG"."EDITIONABLE"[VARCHAR2,1],
       "T_ORIG"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_ORIG"."APPLICATION"[VARCHAR2,1],
       "T_ORIG"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_ORIG"."DUPLICATED"[VARCHAR2,1], "T_ORIG"."SHARDED"[VARCHAR2,1],
       "T_ORIG"."CREATED_APPID"[NUMBER,22],
       "T_ORIG"."CREATED_VSNID"[NUMBER,22],
       "T_ORIG"."MODIFIED_APPID"[NUMBER,22],
       "T_ORIG"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "END_DATE"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_ORIG]]></t><s
	><![CDATA[SEL$1]]></s></h></f></q>



80 rows selected.



--####################################################################################################################



-- 9yg660dpa79df (no pruning)
select /* testcase tableau */ * from t
WHERE  ( ( Trunc(Cast(t.end_date AS DATE)) >= To_date('2021-01-31', 'YYYY-MM-DD') )
         AND ( Trunc(Cast(t.begin_date AS DATE)) >= To_date('2019-04-01', 'YYYY-MM-DD') )
         AND ( Trunc(Cast(t.begin_date AS DATE)) <= To_date('2021-04-01', 'YYYY-MM-DD') ) ) ;



00:27:14 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %testcase tableau%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
9yg660dpa79df	   0 3557914527 	   1	       .304210	      1,717 select /* testcase tableau */ * from t
									    WHERE  ( ( Trunc(Cast(t.end_date AS DATE)


00:27:22 SYS@ORCL> 
00:27:34 SYS@ORCL> @dplan
Enter value for sql_id: 9yg660dpa79df

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	9yg660dpa79df, child number 0
-------------------------------------
select /* testcase tableau */ * from t WHERE  ( ( Trunc(Cast(t.end_date
AS DATE)) >= To_date('2021-01-31', 'YYYY-MM-DD') )	    AND (
Trunc(Cast(t.begin_date AS DATE)) >= To_date('2019-04-01',
'YYYY-MM-DD') ) 	 AND ( Trunc(Cast(t.begin_date AS DATE)) <=
To_date('2021-04-01', 'YYYY-MM-DD') ) )

Plan hash value: 3557914527

---------------------------------------------------------------------------------------------
| Id  | Operation	    | Name | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |	   |	    |	    |	445 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ALL|	   |	  9 |  1332 |	445   (2)| 00:00:01 |	  1 |	 12 |
|*  2 |   TABLE ACCESS FULL | T    |	  9 |  1332 |	445   (2)| 00:00:01 |	  1 |	 12 |
---------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter((TRUNC(CAST(INTERNAL_FUNCTION("T"."END_DATE") AS DATE))>=TO_DATE('
	      2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      TRUNC(CAST(INTERNAL_FUNCTION("T"."BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-04-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND TRUNC(CAST(INTERNAL_FUNCTION("T"."BEGIN_DATE
	      ") AS DATE))<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23],
       "T"."CREATED"[DATE,7], "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19],
       "T"."STATUS"[VARCHAR2,7], "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1],
       "T"."SECONDARY"[VARCHAR2,1], "T"."NAMESPACE"[NUMBER,22],
       "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1],
       "T"."CREATED_APPID"[NUMBER,22], "T"."CREATED_VSNID"[NUMBER,22],
       "T"."MODIFIED_APPID"[NUMBER,22], "T"."MODIFIED_VSNID"[NUMBER,22],
       "T"."BEGIN_DATE"[DATE,7], "T"."END_DATE"[DATE,7]
   2 - (rowset=137) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23],
       "T"."CREATED"[DATE,7], "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19],
       "T"."STATUS"[VARCHAR2,7], "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1],
       "T"."SECONDARY"[VARCHAR2,1], "T"."NAMESPACE"[NUMBER,22],
       "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1],
       "T"."CREATED_APPID"[NUMBER,22], "T"."CREATED_VSNID"[NUMBER,22],
       "T"."MODIFIED_APPID"[NUMBER,22], "T"."MODIFIED_VSNID"[NUMBER,22],
       "T"."BEGIN_DATE"[DATE,7], "T"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T]]></t><s><![CDATA[SEL$1]]>
	</s></h></f></q>



90 rows selected.



--####################################################################################################################


-- d1ju5q62dqcbg (prune)
select /* testcase tableau2 */ * from t 
where ( (end_date >= to_date('20210131','yyyymmdd') )
and  ( begin_date >= to_date('20190401','yyyymmdd') ) 
and  ( begin_date <= to_date('20210401','yyyymmdd') ) );


00:29:24 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %testcase tableau2%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
d1ju5q62dqcbg	   0 1571388083 	   1	       .097854	      1,621 select /* testcase tableau2 */ * from t
									    where ( (end_date >= to_date('20210131'


00:29:30 SYS@ORCL> @dplan
Enter value for sql_id: d1ju5q62dqcbg

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	d1ju5q62dqcbg, child number 0
-------------------------------------
select /* testcase tableau2 */ * from t  where ( (end_date >=
to_date('20210131','yyyymmdd') ) and  ( begin_date >=
to_date('20190401','yyyymmdd') )  and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 1571388083

--------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name | E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |	|	 |	 |   441 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|	|   3544 |   512K|   441   (1)| 00:00:01 |    10 |    12 |
|*  2 |   TABLE ACCESS FULL	 | T	|   3544 |   512K|   441   (1)| 00:00:01 |    10 |    12 |
--------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23], "T"."CREATED"[DATE,7],
       "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19], "T"."STATUS"[VARCHAR2,7],
       "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1], "T"."SECONDARY"[VARCHAR2,1],
       "T"."NAMESPACE"[NUMBER,22], "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1], "T"."CREATED_APPID"[NUMBER,22],
       "T"."CREATED_VSNID"[NUMBER,22], "T"."MODIFIED_APPID"[NUMBER,22],
       "T"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=137) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23], "T"."CREATED"[DATE,7],
       "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19], "T"."STATUS"[VARCHAR2,7],
       "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1], "T"."SECONDARY"[VARCHAR2,1],
       "T"."NAMESPACE"[NUMBER,22], "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1], "T"."CREATED_APPID"[NUMBER,22],
       "T"."CREATED_VSNID"[NUMBER,22], "T"."MODIFIED_APPID"[NUMBER,22],
       "T"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



83 rows selected.


--####################################################################################################################


-- JONATHAN LEWIS 

01:10:04 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %jonathan lewis%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
5228shjnyk9h0	   0 2739120976 	   1	       .004617		  2 select /* jonathan lewis */ * from transactions where transaction_date = sysdate

01:10:13 SYS@ORCL> @dplan
Enter value for sql_id: 5228shjnyk9h0

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	5228shjnyk9h0, child number 0
-------------------------------------
select /* jonathan lewis */ * from transactions where transaction_date
= sysdate

Plan hash value: 2739120976

--------------------------------------------------------------------------------------------------------
| Id  | Operation	       | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |	      |        |       |     2 (100)|	       |       |       |
|   1 |  PARTITION RANGE SINGLE|	      |      1 |   130 |     2	 (0)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL    | TRANSACTIONS |      1 |   130 |     2	 (0)| 00:00:01 |   KEY |   KEY |
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / TRANSACTIONS@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TRANSACTIONS"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("TRANSACTION_DATE"=SYSDATE@!)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "TRANSACTION_DATE"[DATE,7], "TRANSACTIONS"."JOB_ID"[VARCHAR2,10],
       "TRANSACTIONS"."ACCOUNT_ID"[NUMBER,22], "TRANSACTIONS"."TRANSACTION_TYPE"[VARCHAR2,2],
       "TRANSACTIONS"."TRANSACTION_ID"[VARCHAR2,10], "TRANSACTIONS"."AMOUNT"[NUMBER,22],
       "TRANSACTIONS"."PADDING"[VARCHAR2,100]
   2 - (rowset=256) "TRANSACTION_DATE"[DATE,7], "TRANSACTIONS"."JOB_ID"[VARCHAR2,10],
       "TRANSACTIONS"."ACCOUNT_ID"[NUMBER,22], "TRANSACTIONS"."TRANSACTION_TYPE"[VARCHAR2,2],
       "TRANSACTIONS"."TRANSACTION_ID"[VARCHAR2,10], "TRANSACTIONS"."AMOUNT"[NUMBER,22],
       "TRANSACTIONS"."PADDING"[VARCHAR2,100]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TRANSACTIONS]]></t><s><![CDATA[SEL$1]]>
	</s></h></f></q>



65 rows selected.


--####################################################################################################################


-- 4tkjsknaqu8cn (prune)
select /* testcase tableau3b */ * from t_virtual t
WHERE  ( ( Trunc(Cast(t.end_date AS DATE)) >= To_date('2021-01-31', 'YYYY-MM-DD') )
         AND ( Trunc(Cast(t.begin_date AS DATE)) >= To_date('2019-04-01', 'YYYY-MM-DD') )
         AND ( Trunc(Cast(t.begin_date AS DATE)) <= To_date('2021-04-01', 'YYYY-MM-DD') ) ) ;





01:38:03 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %testcase tableau3b%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
4tkjsknaqu8cn	   0 2546680718 	   1	       .409738	      1,903 select /* testcase tableau3b */ * from t_virtual t
									    WHERE  ( ( Trunc(Cast(t.end_d


01:38:09 SYS@ORCL> @dplan
Enter value for sql_id: 4tkjsknaqu8cn

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	4tkjsknaqu8cn, child number 0
-------------------------------------
select /* testcase tableau3b */ * from t_virtual t WHERE  ( (
Trunc(Cast(t.end_date AS DATE)) >= To_date('2021-01-31', 'YYYY-MM-DD')
)	   AND ( Trunc(Cast(t.begin_date AS DATE)) >=
To_date('2019-04-01', 'YYYY-MM-DD') )	       AND (
Trunc(Cast(t.begin_date AS DATE)) <= To_date('2021-04-01',
'YYYY-MM-DD') ) )

Plan hash value: 2546680718

-------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |	     |	      |       |   444 (100)|	      |       |       |
|   1 |  PARTITION RANGE ITERATOR|	     |	 3623 |   551K|   444	(2)| 00:00:01 |    10 |    12 |
|*  2 |   TABLE ACCESS FULL	 | T_VIRTUAL |	 3623 |   551K|   444	(2)| 00:00:01 |    10 |    12 |
-------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter((TRUNC(CAST(INTERNAL_FUNCTION("T"."END_DATE") AS DATE))>=TO_DATE(' 2021-01-31
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS
	      DATE))>=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))<=TO_DATE(' 2021-04-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss')))


Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=136) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23], "T"."CREATED"[DATE,7],
       "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19], "T"."STATUS"[VARCHAR2,7],
       "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1], "T"."SECONDARY"[VARCHAR2,1],
       "T"."NAMESPACE"[NUMBER,22], "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1], "T"."CREATED_APPID"[NUMBER,22],
       "T"."CREATED_VSNID"[NUMBER,22], "T"."MODIFIED_APPID"[NUMBER,22],
       "T"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "T"."END_DATE"[DATE,7]
   2 - (rowset=136) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23], "T"."CREATED"[DATE,7],
       "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19], "T"."STATUS"[VARCHAR2,7],
       "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1], "T"."SECONDARY"[VARCHAR2,1],
       "T"."NAMESPACE"[NUMBER,22], "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1], "T"."CREATED_APPID"[NUMBER,22],
       "T"."CREATED_VSNID"[NUMBER,22], "T"."MODIFIED_APPID"[NUMBER,22],
       "T"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "T"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T]]></t><s><![CDATA[SEL$1]]></s></h></
	f></q>



87 rows selected.

01:38:17 SYS@ORCL> 
01:39:35 SYS@ORCL> 
01:39:35 SYS@ORCL> 
01:39:36 SYS@ORCL> 
01:39:36 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %testcase tableau3b%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
4tkjsknaqu8cn	   0 2546680718 	   1	       .409738	      1,903 select /* testcase tableau3b */ * from t_virtual t
									    WHERE  ( ( Trunc(Cast(t.end_d

4tkjsknaqu8cn	   1 2546680718 	   1	       .199980	      1,619 select /* testcase tableau3b */ * from t_virtual t
									    WHERE  ( ( Trunc(Cast(t.end_d




--####################################################################################################################



-- virtual column NOT NULL and use index range scan 
-- add two virtual colums and index on it


-- 5jbnks81apdpf (no prune)
select /* t_two_colsc */ * from t_two_cols t
WHERE  ( ( Trunc(Cast(t.end_date AS DATE)) >= To_date('2021-01-31', 'YYYY-MM-DD') )
         AND ( Trunc(Cast(t.begin_date AS DATE)) >= To_date('2019-04-01', 'YYYY-MM-DD') )
         AND ( Trunc(Cast(t.begin_date AS DATE)) <= To_date('2021-04-01', 'YYYY-MM-DD') ) ) ;
         

13:32:38 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_two_colsc%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
5jbnks81apdpf	   0 2743874595 	   1	       .499634	      1,656 select /* t_two_colsc */ * from t_two_cols t
									    WHERE  ( ( Trunc(Cast(t.end_date AS


13:32:45 SYS@ORCL> 
13:32:46 SYS@ORCL> @dplan
Enter value for sql_id: 5jbnks81apdpf

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	5jbnks81apdpf, child number 0
-------------------------------------
select /* t_two_colsc */ * from t_two_cols t WHERE  ( (
Trunc(Cast(t.end_date AS DATE)) >= To_date('2021-01-31', 'YYYY-MM-DD')
)	   AND ( Trunc(Cast(t.begin_date AS DATE)) >=
To_date('2019-04-01', 'YYYY-MM-DD') )	       AND (
Trunc(Cast(t.begin_date AS DATE)) <= To_date('2021-04-01',
'YYYY-MM-DD') ) )

Plan hash value: 2743874595

---------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name	 | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |		 |	  |	  |   445 (100)|	  |	  |	  |
|   1 |  PARTITION RANGE ALL|		 |	9 |  1332 |   445   (2)| 00:00:01 |	1 |    12 |
|*  2 |   TABLE ACCESS FULL | T_TWO_COLS |	9 |  1332 |   445   (2)| 00:00:01 |	1 |    12 |
---------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter((TRUNC(CAST(INTERNAL_FUNCTION("T"."END_DATE") AS DATE))>=TO_DATE('
	      2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      TRUNC(CAST(INTERNAL_FUNCTION("T"."BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-04-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss') AND TRUNC(CAST(INTERNAL_FUNCTION("T"."BEGIN_DATE") AS
	      DATE))<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23], "T"."CREATED"[DATE,7],
       "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19], "T"."STATUS"[VARCHAR2,7],
       "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1], "T"."SECONDARY"[VARCHAR2,1],
       "T"."NAMESPACE"[NUMBER,22], "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1], "T"."CREATED_APPID"[NUMBER,22],
       "T"."CREATED_VSNID"[NUMBER,22], "T"."MODIFIED_APPID"[NUMBER,22],
       "T"."MODIFIED_VSNID"[NUMBER,22], "T"."BEGIN_DATE"[DATE,7], "T"."END_DATE"[DATE,7]
   2 - (rowset=137) "T"."OWNER"[VARCHAR2,128], "T"."OBJECT_NAME"[VARCHAR2,128],
       "T"."SUBOBJECT_NAME"[VARCHAR2,128], "T"."OBJECT_ID"[NUMBER,22],
       "T"."DATA_OBJECT_ID"[NUMBER,22], "T"."OBJECT_TYPE"[VARCHAR2,23], "T"."CREATED"[DATE,7],
       "T"."LAST_DDL_TIME"[DATE,7], "T"."TIMESTAMP"[VARCHAR2,19], "T"."STATUS"[VARCHAR2,7],
       "T"."TEMPORARY"[VARCHAR2,1], "T"."GENERATED"[VARCHAR2,1], "T"."SECONDARY"[VARCHAR2,1],
       "T"."NAMESPACE"[NUMBER,22], "T"."EDITION_NAME"[VARCHAR2,128], "T"."SHARING"[VARCHAR2,18],
       "T"."EDITIONABLE"[VARCHAR2,1], "T"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T"."APPLICATION"[VARCHAR2,1], "T"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T"."DUPLICATED"[VARCHAR2,1], "T"."SHARDED"[VARCHAR2,1], "T"."CREATED_APPID"[NUMBER,22],
       "T"."CREATED_VSNID"[NUMBER,22], "T"."MODIFIED_APPID"[NUMBER,22],
       "T"."MODIFIED_VSNID"[NUMBER,22], "T"."BEGIN_DATE"[DATE,7], "T"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T]]></t><s><![CDATA[SEL$1]]></s></
	h></f></q>



87 rows selected.


--####################################################################################################################



-- 0hc2t25zfztga (used index)
select /* t_two_colse */ * from t_two_cols 
where ( (end_date >= to_date('20210131','yyyymmdd') )
and  ( begin_date >= to_date('20190401','yyyymmdd') ) 
and  ( begin_date <= to_date('20210401','yyyymmdd') ) );
         
13:34:51 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_two_colse%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
0hc2t25zfztga	   0 2664057784 	   1	       .059739		 20 select /* t_two_colse */ * from t_two_cols
									    where ( (end_date >= to_date('202101


13:34:58 SYS@ORCL> @dplan
Enter value for sql_id: 0hc2t25zfztga

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	0hc2t25zfztga, child number 0
-------------------------------------
select /* t_two_colse */ * from t_two_cols  where ( (end_date >=
to_date('20210131','yyyymmdd') ) and  ( begin_date >=
to_date('20190401','yyyymmdd') )  and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 2664057784

--------------------------------------------------------------------------------------------------------------------------
| Id  | Operation				   | Name	| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT			   |		|	 |	 |     6 (100)| 	 |	 |	 |
|*  1 |  TABLE ACCESS BY GLOBAL INDEX ROWID BATCHED| T_TWO_COLS |   3545 |   512K|     6   (0)| 00:00:01 | ROWID | ROWID |
|*  2 |   INDEX RANGE SCAN			   | T_IDX	|      6 |	 |     5   (0)| 00:00:01 |	 |	 |
--------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1 / T_TWO_COLS@SEL$1
   2 - SEL$1 / T_TWO_COLS@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      INDEX_RS_ASC(@"SEL$1" "T_TWO_COLS"@"SEL$1" "T_IDX")
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$1" "T_TWO_COLS"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND "BEGIN_DATE">=TO_DATE('
	      2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND "BEGIN_DATE"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss')))
   2 - access("MAX_SEARCH_DATE_COLUMN">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "MIN_SEARCH_DATE_COLUMN"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))
       filter("MIN_SEARCH_DATE_COLUMN"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "T_TWO_COLS"."OWNER"[VARCHAR2,128], "T_TWO_COLS"."OBJECT_NAME"[VARCHAR2,128],
       "T_TWO_COLS"."SUBOBJECT_NAME"[VARCHAR2,128], "T_TWO_COLS"."OBJECT_ID"[NUMBER,22],
       "T_TWO_COLS"."DATA_OBJECT_ID"[NUMBER,22], "T_TWO_COLS"."OBJECT_TYPE"[VARCHAR2,23],
       "T_TWO_COLS"."CREATED"[DATE,7], "T_TWO_COLS"."LAST_DDL_TIME"[DATE,7], "T_TWO_COLS"."TIMESTAMP"[VARCHAR2,19],
       "T_TWO_COLS"."STATUS"[VARCHAR2,7], "T_TWO_COLS"."TEMPORARY"[VARCHAR2,1], "T_TWO_COLS"."GENERATED"[VARCHAR2,1],
       "T_TWO_COLS"."SECONDARY"[VARCHAR2,1], "T_TWO_COLS"."NAMESPACE"[NUMBER,22],
       "T_TWO_COLS"."EDITION_NAME"[VARCHAR2,128], "T_TWO_COLS"."SHARING"[VARCHAR2,18],
       "T_TWO_COLS"."EDITIONABLE"[VARCHAR2,1], "T_TWO_COLS"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_TWO_COLS"."APPLICATION"[VARCHAR2,1], "T_TWO_COLS"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_TWO_COLS"."DUPLICATED"[VARCHAR2,1], "T_TWO_COLS"."SHARDED"[VARCHAR2,1],
       "T_TWO_COLS"."CREATED_APPID"[NUMBER,22], "T_TWO_COLS"."CREATED_VSNID"[NUMBER,22],
       "T_TWO_COLS"."MODIFIED_APPID"[NUMBER,22], "T_TWO_COLS"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "END_DATE"[DATE,7]
   2 - "T_TWO_COLS".ROWID[ROWID,10], "T_TWO_COLS"."MAX_SEARCH_DATE_COLUMN"[DATE,7],
       "T_TWO_COLS"."MIN_SEARCH_DATE_COLUMN"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_TWO_COLS]]></t><s><![CDATA[SEL$1]]></s></h></f></q>



79 rows selected.


12:32:39 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_multi - owner, object_type%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
2n3vz1kbtzvbb	   0  550445590 	   1	       .084351		 11 select /* t_multi - owner, object_type */ * from t_multi
									    where owner = 'SYS'
									    an


12:32:50 SYS@ORCL> 
12:32:51 SYS@ORCL> 
12:32:51 SYS@ORCL> @dplan
Enter value for sql_id: 2n3vz1kbtzvbb

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	2n3vz1kbtzvbb, child number 0
-------------------------------------
select /* t_multi - owner, object_type */ * from t_multi  where owner =
'SYS' and object_type = 'TABLE'

Plan hash value: 550445590

--------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name	| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 	|	 |	 |    11 (100)| 	 |	 |	 |
|   1 |  PARTITION LIST SINGLE| 	|   1547 |   209K|    11   (0)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL   | T_MULTI |   1547 |   209K|    11   (0)| 00:00:01 |     1 |     1 |
--------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T_MULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_MULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("OWNER"='SYS' AND "OBJECT_TYPE"='TABLE'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "T_MULTI"."CREATED"[DATE,7], "T_MULTI"."LAST_DDL_TIME"[DATE,7],
       "T_MULTI"."TIMESTAMP"[VARCHAR2,19], "T_MULTI"."STATUS"[VARCHAR2,7],
       "T_MULTI"."TEMPORARY"[VARCHAR2,1], "T_MULTI"."GENERATED"[VARCHAR2,1],
       "T_MULTI"."SECONDARY"[VARCHAR2,1], "T_MULTI"."NAMESPACE"[NUMBER,22],
       "T_MULTI"."EDITION_NAME"[VARCHAR2,128], "T_MULTI"."SHARING"[VARCHAR2,18],
       "T_MULTI"."EDITIONABLE"[VARCHAR2,1], "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_MULTI"."APPLICATION"[VARCHAR2,1], "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_MULTI"."DUPLICATED"[VARCHAR2,1], "T_MULTI"."SHARDED"[VARCHAR2,1],
       "T_MULTI"."CREATED_APPID"[NUMBER,22], "T_MULTI"."CREATED_VSNID"[NUMBER,22],
       "T_MULTI"."MODIFIED_APPID"[NUMBER,22], "T_MULTI"."MODIFIED_VSNID"[NUMBER,22],
       "T_MULTI"."BEGIN_DATE"[DATE,7], "T_MULTI"."END_DATE"[DATE,7]
   2 - (rowset=138) "OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "T_MULTI"."CREATED"[DATE,7], "T_MULTI"."LAST_DDL_TIME"[DATE,7],
       "T_MULTI"."TIMESTAMP"[VARCHAR2,19], "T_MULTI"."STATUS"[VARCHAR2,7],
       "T_MULTI"."TEMPORARY"[VARCHAR2,1], "T_MULTI"."GENERATED"[VARCHAR2,1],
       "T_MULTI"."SECONDARY"[VARCHAR2,1], "T_MULTI"."NAMESPACE"[NUMBER,22],
       "T_MULTI"."EDITION_NAME"[VARCHAR2,128], "T_MULTI"."SHARING"[VARCHAR2,18],
       "T_MULTI"."EDITIONABLE"[VARCHAR2,1], "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_MULTI"."APPLICATION"[VARCHAR2,1], "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_MULTI"."DUPLICATED"[VARCHAR2,1], "T_MULTI"."SHARDED"[VARCHAR2,1],
       "T_MULTI"."CREATED_APPID"[NUMBER,22], "T_MULTI"."CREATED_VSNID"[NUMBER,22],
       "T_MULTI"."MODIFIED_APPID"[NUMBER,22], "T_MULTI"."MODIFIED_VSNID"[NUMBER,22],
       "T_MULTI"."BEGIN_DATE"[DATE,7], "T_MULTI"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_MULTI]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



85 rows selected.


12:34:13 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_multi - keys and dates%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
6k2dm9531xjxg	   0  550445590 	   1	       .015566		 30 select /* t_multi - keys and dates */ * from t_multi
									    where owner = 'SYS'
									    and ob



12:34:17 SYS@ORCL> @dplan
Enter value for sql_id: 6k2dm9531xjxg

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	6k2dm9531xjxg, child number 0
-------------------------------------
select /* t_multi - keys and dates */ * from t_multi  where owner =
'SYS' and object_type = 'INDEX' and ( (end_date >=
to_date('20210131','yyyymmdd') ) and  ( begin_date >=
to_date('20190401','yyyymmdd') )  and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 550445590

--------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name	| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 	|	 |	 |     9 (100)| 	 |	 |	 |
|   1 |  PARTITION LIST SINGLE| 	|      1 |   117 |     9   (0)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL   | T_MULTI |      1 |   117 |     9   (0)| 00:00:01 |     2 |     2 |
--------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T_MULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_MULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "OWNER"='SYS' AND "OBJECT_TYPE"='INDEX' AND "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss') AND "BEGIN_DATE"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=136) "OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "T_MULTI"."CREATED"[DATE,7], "T_MULTI"."LAST_DDL_TIME"[DATE,7],
       "T_MULTI"."TIMESTAMP"[VARCHAR2,19], "T_MULTI"."STATUS"[VARCHAR2,7],
       "T_MULTI"."TEMPORARY"[VARCHAR2,1], "T_MULTI"."GENERATED"[VARCHAR2,1],
       "T_MULTI"."SECONDARY"[VARCHAR2,1], "T_MULTI"."NAMESPACE"[NUMBER,22],
       "T_MULTI"."EDITION_NAME"[VARCHAR2,128], "T_MULTI"."SHARING"[VARCHAR2,18],
       "T_MULTI"."EDITIONABLE"[VARCHAR2,1], "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_MULTI"."APPLICATION"[VARCHAR2,1], "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_MULTI"."DUPLICATED"[VARCHAR2,1], "T_MULTI"."SHARDED"[VARCHAR2,1],
       "T_MULTI"."CREATED_APPID"[NUMBER,22], "T_MULTI"."CREATED_VSNID"[NUMBER,22],
       "T_MULTI"."MODIFIED_APPID"[NUMBER,22], "T_MULTI"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=136) "OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "T_MULTI"."CREATED"[DATE,7], "T_MULTI"."LAST_DDL_TIME"[DATE,7],
       "T_MULTI"."TIMESTAMP"[VARCHAR2,19], "T_MULTI"."STATUS"[VARCHAR2,7],
       "T_MULTI"."TEMPORARY"[VARCHAR2,1], "T_MULTI"."GENERATED"[VARCHAR2,1],
       "T_MULTI"."SECONDARY"[VARCHAR2,1], "T_MULTI"."NAMESPACE"[NUMBER,22],
       "T_MULTI"."EDITION_NAME"[VARCHAR2,128], "T_MULTI"."SHARING"[VARCHAR2,18],
       "T_MULTI"."EDITIONABLE"[VARCHAR2,1], "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_MULTI"."APPLICATION"[VARCHAR2,1], "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_MULTI"."DUPLICATED"[VARCHAR2,1], "T_MULTI"."SHARDED"[VARCHAR2,1],
       "T_MULTI"."CREATED_APPID"[NUMBER,22], "T_MULTI"."CREATED_VSNID"[NUMBER,22],
       "T_MULTI"."MODIFIED_APPID"[NUMBER,22], "T_MULTI"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_MULTI]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



91 rows selected.




12:36:43 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_multi - one key and dates%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
dptfs7xakask2	   0 2128917303 	   1	       .160560		  3 select /* t_multi - one key and dates */ * from t_multi
									    where owner = 'SYS'


12:36:54 SYS@ORCL> @dplan
Enter value for sql_id: dptfs7xakask2

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	dptfs7xakask2, child number 0
-------------------------------------
select /* t_multi - one key and dates */ * from t_multi  where owner =
'SYS'

Plan hash value: 2128917303

----------------------------------------------------------------------------------------------------
| Id  | Operation		| Name	  | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|	  |	   |	   |   303 (100)|	   |	   |	   |
|   1 |  PARTITION LIST ITERATOR|	  |   1767 |   255K|   303   (1)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL	| T_MULTI |   1767 |   255K|   303   (1)| 00:00:01 |   KEY |   KEY |
----------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T_MULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_MULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("OWNER"='SYS')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "T_MULTI"."OBJECT_TYPE"[VARCHAR2,23],
       "T_MULTI"."CREATED"[DATE,7], "T_MULTI"."LAST_DDL_TIME"[DATE,7],
       "T_MULTI"."TIMESTAMP"[VARCHAR2,19], "T_MULTI"."STATUS"[VARCHAR2,7],
       "T_MULTI"."TEMPORARY"[VARCHAR2,1], "T_MULTI"."GENERATED"[VARCHAR2,1],
       "T_MULTI"."SECONDARY"[VARCHAR2,1], "T_MULTI"."NAMESPACE"[NUMBER,22],
       "T_MULTI"."EDITION_NAME"[VARCHAR2,128], "T_MULTI"."SHARING"[VARCHAR2,18],
       "T_MULTI"."EDITIONABLE"[VARCHAR2,1], "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_MULTI"."APPLICATION"[VARCHAR2,1], "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_MULTI"."DUPLICATED"[VARCHAR2,1], "T_MULTI"."SHARDED"[VARCHAR2,1],
       "T_MULTI"."CREATED_APPID"[NUMBER,22], "T_MULTI"."CREATED_VSNID"[NUMBER,22],
       "T_MULTI"."MODIFIED_APPID"[NUMBER,22], "T_MULTI"."MODIFIED_VSNID"[NUMBER,22],
       "T_MULTI"."BEGIN_DATE"[DATE,7], "T_MULTI"."END_DATE"[DATE,7]
   2 - (rowset=138) "OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "T_MULTI"."OBJECT_TYPE"[VARCHAR2,23],
       "T_MULTI"."CREATED"[DATE,7], "T_MULTI"."LAST_DDL_TIME"[DATE,7],
       "T_MULTI"."TIMESTAMP"[VARCHAR2,19], "T_MULTI"."STATUS"[VARCHAR2,7],
       "T_MULTI"."TEMPORARY"[VARCHAR2,1], "T_MULTI"."GENERATED"[VARCHAR2,1],
       "T_MULTI"."SECONDARY"[VARCHAR2,1], "T_MULTI"."NAMESPACE"[NUMBER,22],
       "T_MULTI"."EDITION_NAME"[VARCHAR2,128], "T_MULTI"."SHARING"[VARCHAR2,18],
       "T_MULTI"."EDITIONABLE"[VARCHAR2,1], "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_MULTI"."APPLICATION"[VARCHAR2,1], "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_MULTI"."DUPLICATED"[VARCHAR2,1], "T_MULTI"."SHARDED"[VARCHAR2,1],
       "T_MULTI"."CREATED_APPID"[NUMBER,22], "T_MULTI"."CREATED_VSNID"[NUMBER,22],
       "T_MULTI"."MODIFIED_APPID"[NUMBER,22], "T_MULTI"."MODIFIED_VSNID"[NUMBER,22],
       "T_MULTI"."BEGIN_DATE"[DATE,7], "T_MULTI"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_MULTI]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



85 rows selected.



12:37:53 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_multi - one key and dates2%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
d38920ruvk6h9	   0 2128917303 	   1	       .679417	      1,141 select /* t_multi - one key and dates2 */ * from t_multi
									    where owner = 'SYS'
									    an


12:37:59 SYS@ORCL> @dplan
Enter value for sql_id: d38920ruvk6h9

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	d38920ruvk6h9, child number 0
-------------------------------------
select /* t_multi - one key and dates2 */ * from t_multi  where owner =
'SYS' and ( (end_date >= to_date('20210131','yyyymmdd') ) and  (
begin_date >= to_date('20190401','yyyymmdd') )	and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 2128917303

----------------------------------------------------------------------------------------------------
| Id  | Operation		| Name	  | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|	  |	   |	   |   303 (100)|	   |	   |	   |
|   1 |  PARTITION LIST ITERATOR|	  |	86 | 12728 |   303   (1)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL	| T_MULTI |	86 | 12728 |   303   (1)| 00:00:01 |   KEY |   KEY |
----------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T_MULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_MULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("OWNER"='SYS' AND "END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss') AND "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')
	      AND "BEGIN_DATE"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "T_MULTI"."OBJECT_TYPE"[VARCHAR2,23],
       "T_MULTI"."CREATED"[DATE,7], "T_MULTI"."LAST_DDL_TIME"[DATE,7],
       "T_MULTI"."TIMESTAMP"[VARCHAR2,19], "T_MULTI"."STATUS"[VARCHAR2,7],
       "T_MULTI"."TEMPORARY"[VARCHAR2,1], "T_MULTI"."GENERATED"[VARCHAR2,1],
       "T_MULTI"."SECONDARY"[VARCHAR2,1], "T_MULTI"."NAMESPACE"[NUMBER,22],
       "T_MULTI"."EDITION_NAME"[VARCHAR2,128], "T_MULTI"."SHARING"[VARCHAR2,18],
       "T_MULTI"."EDITIONABLE"[VARCHAR2,1], "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_MULTI"."APPLICATION"[VARCHAR2,1], "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_MULTI"."DUPLICATED"[VARCHAR2,1], "T_MULTI"."SHARDED"[VARCHAR2,1],
       "T_MULTI"."CREATED_APPID"[NUMBER,22], "T_MULTI"."CREATED_VSNID"[NUMBER,22],
       "T_MULTI"."MODIFIED_APPID"[NUMBER,22], "T_MULTI"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=137) "OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "T_MULTI"."OBJECT_TYPE"[VARCHAR2,23],
       "T_MULTI"."CREATED"[DATE,7], "T_MULTI"."LAST_DDL_TIME"[DATE,7],
       "T_MULTI"."TIMESTAMP"[VARCHAR2,19], "T_MULTI"."STATUS"[VARCHAR2,7],
       "T_MULTI"."TEMPORARY"[VARCHAR2,1], "T_MULTI"."GENERATED"[VARCHAR2,1],
       "T_MULTI"."SECONDARY"[VARCHAR2,1], "T_MULTI"."NAMESPACE"[NUMBER,22],
       "T_MULTI"."EDITION_NAME"[VARCHAR2,128], "T_MULTI"."SHARING"[VARCHAR2,18],
       "T_MULTI"."EDITIONABLE"[VARCHAR2,1], "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "T_MULTI"."APPLICATION"[VARCHAR2,1], "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100],
       "T_MULTI"."DUPLICATED"[VARCHAR2,1], "T_MULTI"."SHARDED"[VARCHAR2,1],
       "T_MULTI"."CREATED_APPID"[NUMBER,22], "T_MULTI"."CREATED_VSNID"[NUMBER,22],
       "T_MULTI"."MODIFIED_APPID"[NUMBER,22], "T_MULTI"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_MULTI]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



89 rows selected.



12:39:26 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_multi - one key object_type%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
1576xf1cxq3ug	   0  174168832 	   1	       .023468		  3 select /* t_multi - one key object_type */ * from t_multi
									    where object_type = '


12:39:34 SYS@ORCL> @dplan
Enter value for sql_id: 1576xf1cxq3ug

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1576xf1cxq3ug, child number 0
-------------------------------------
select /* t_multi - one key object_type */ * from t_multi  where
object_type = 'INDEX'

Plan hash value: 174168832

--------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name    | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |	      |        |       |    27 (100)|	       |       |       |
|   1 |  PARTITION LIST MULTI-COLUMN|	      |   1958 |   282K|    27	 (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|*  2 |   TABLE ACCESS FULL	    | T_MULTI |   1958 |   282K|    27	 (0)| 00:00:01 |KEY(MC)|KEY(MC)|
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T_MULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_MULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("OBJECT_TYPE"='INDEX')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "T_MULTI"."OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23], "T_MULTI"."CREATED"[DATE,7],
       "T_MULTI"."LAST_DDL_TIME"[DATE,7], "T_MULTI"."TIMESTAMP"[VARCHAR2,19],
       "T_MULTI"."STATUS"[VARCHAR2,7], "T_MULTI"."TEMPORARY"[VARCHAR2,1],
       "T_MULTI"."GENERATED"[VARCHAR2,1], "T_MULTI"."SECONDARY"[VARCHAR2,1],
       "T_MULTI"."NAMESPACE"[NUMBER,22], "T_MULTI"."EDITION_NAME"[VARCHAR2,128],
       "T_MULTI"."SHARING"[VARCHAR2,18], "T_MULTI"."EDITIONABLE"[VARCHAR2,1],
       "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1], "T_MULTI"."APPLICATION"[VARCHAR2,1],
       "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100], "T_MULTI"."DUPLICATED"[VARCHAR2,1],
       "T_MULTI"."SHARDED"[VARCHAR2,1], "T_MULTI"."CREATED_APPID"[NUMBER,22],
       "T_MULTI"."CREATED_VSNID"[NUMBER,22], "T_MULTI"."MODIFIED_APPID"[NUMBER,22],
       "T_MULTI"."MODIFIED_VSNID"[NUMBER,22], "T_MULTI"."BEGIN_DATE"[DATE,7],
       "T_MULTI"."END_DATE"[DATE,7]
   2 - (rowset=138) "T_MULTI"."OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23], "T_MULTI"."CREATED"[DATE,7],
       "T_MULTI"."LAST_DDL_TIME"[DATE,7], "T_MULTI"."TIMESTAMP"[VARCHAR2,19],
       "T_MULTI"."STATUS"[VARCHAR2,7], "T_MULTI"."TEMPORARY"[VARCHAR2,1],
       "T_MULTI"."GENERATED"[VARCHAR2,1], "T_MULTI"."SECONDARY"[VARCHAR2,1],
       "T_MULTI"."NAMESPACE"[NUMBER,22], "T_MULTI"."EDITION_NAME"[VARCHAR2,128],
       "T_MULTI"."SHARING"[VARCHAR2,18], "T_MULTI"."EDITIONABLE"[VARCHAR2,1],
       "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1], "T_MULTI"."APPLICATION"[VARCHAR2,1],
       "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100], "T_MULTI"."DUPLICATED"[VARCHAR2,1],
       "T_MULTI"."SHARDED"[VARCHAR2,1], "T_MULTI"."CREATED_APPID"[NUMBER,22],
       "T_MULTI"."CREATED_VSNID"[NUMBER,22], "T_MULTI"."MODIFIED_APPID"[NUMBER,22],
       "T_MULTI"."MODIFIED_VSNID"[NUMBER,22], "T_MULTI"."BEGIN_DATE"[DATE,7],
       "T_MULTI"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_MULTI]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



85 rows selected.



12:40:38 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_multi - one key object_type with dates%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
g7gqpfn23q7dz	   0  174168832 	   1	       .026093		128 select /* t_multi - one key object_type with dates */ * from t_multi
									    where obje


12:40:43 SYS@ORCL> @dplan
Enter value for sql_id: g7gqpfn23q7dz

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	g7gqpfn23q7dz, child number 0
-------------------------------------
select /* t_multi - one key object_type with dates */ * from t_multi
where object_type = 'INDEX' and ( (end_date >=
to_date('20210131','yyyymmdd') ) and  ( begin_date >=
to_date('20190401','yyyymmdd') )  and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 174168832

--------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name    | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |	      |        |       |    27 (100)|	       |       |       |
|   1 |  PARTITION LIST MULTI-COLUMN|	      |     96 | 14208 |    27	 (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|*  2 |   TABLE ACCESS FULL	    | T_MULTI |     96 | 14208 |    27	 (0)| 00:00:01 |KEY(MC)|KEY(MC)|
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T_MULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_MULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("OBJECT_TYPE"='INDEX' AND "END_DATE">=TO_DATE(' 2021-01-31 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss') AND "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss') AND "BEGIN_DATE"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "T_MULTI"."OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23], "T_MULTI"."CREATED"[DATE,7],
       "T_MULTI"."LAST_DDL_TIME"[DATE,7], "T_MULTI"."TIMESTAMP"[VARCHAR2,19],
       "T_MULTI"."STATUS"[VARCHAR2,7], "T_MULTI"."TEMPORARY"[VARCHAR2,1],
       "T_MULTI"."GENERATED"[VARCHAR2,1], "T_MULTI"."SECONDARY"[VARCHAR2,1],
       "T_MULTI"."NAMESPACE"[NUMBER,22], "T_MULTI"."EDITION_NAME"[VARCHAR2,128],
       "T_MULTI"."SHARING"[VARCHAR2,18], "T_MULTI"."EDITIONABLE"[VARCHAR2,1],
       "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1], "T_MULTI"."APPLICATION"[VARCHAR2,1],
       "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100], "T_MULTI"."DUPLICATED"[VARCHAR2,1],
       "T_MULTI"."SHARDED"[VARCHAR2,1], "T_MULTI"."CREATED_APPID"[NUMBER,22],
       "T_MULTI"."CREATED_VSNID"[NUMBER,22], "T_MULTI"."MODIFIED_APPID"[NUMBER,22],
       "T_MULTI"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=137) "T_MULTI"."OWNER"[VARCHAR2,128], "T_MULTI"."OBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128], "T_MULTI"."OBJECT_ID"[NUMBER,22],
       "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23], "T_MULTI"."CREATED"[DATE,7],
       "T_MULTI"."LAST_DDL_TIME"[DATE,7], "T_MULTI"."TIMESTAMP"[VARCHAR2,19],
       "T_MULTI"."STATUS"[VARCHAR2,7], "T_MULTI"."TEMPORARY"[VARCHAR2,1],
       "T_MULTI"."GENERATED"[VARCHAR2,1], "T_MULTI"."SECONDARY"[VARCHAR2,1],
       "T_MULTI"."NAMESPACE"[NUMBER,22], "T_MULTI"."EDITION_NAME"[VARCHAR2,128],
       "T_MULTI"."SHARING"[VARCHAR2,18], "T_MULTI"."EDITIONABLE"[VARCHAR2,1],
       "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1], "T_MULTI"."APPLICATION"[VARCHAR2,1],
       "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100], "T_MULTI"."DUPLICATED"[VARCHAR2,1],
       "T_MULTI"."SHARDED"[VARCHAR2,1], "T_MULTI"."CREATED_APPID"[NUMBER,22],
       "T_MULTI"."CREATED_VSNID"[NUMBER,22], "T_MULTI"."MODIFIED_APPID"[NUMBER,22],
       "T_MULTI"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_MULTI]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



88 rows selected.



12:43:07 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_multi - dates only%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
4fbxp937qgfm0	   0 1373923938 	   1	      1.007480	      2,138 select /* t_multi - dates only */ * from t_multi
									    where  ( (end_date >= to_date(


12:43:18 SYS@ORCL> @dplan
Enter value for sql_id: 4fbxp937qgfm0

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	4fbxp937qgfm0, child number 0
-------------------------------------
select /* t_multi - dates only */ * from t_multi  where  ( (end_date >=
to_date('20210131','yyyymmdd') ) and  ( begin_date >=
to_date('20190401','yyyymmdd') )  and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 1373923938

-----------------------------------------------------------------------------------------------
| Id  | Operation	   | Name    | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |	     |	      |       |   500 (100)|	      |       |       |
|   1 |  PARTITION LIST ALL|	     |	 3545 |   512K|   500	(1)| 00:00:01 |     1 |   293 |
|*  2 |   TABLE ACCESS FULL| T_MULTI |	 3545 |   512K|   500	(1)| 00:00:01 |     1 |   293 |
-----------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / T_MULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_MULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss')
	      AND "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "T_MULTI"."OWNER"[VARCHAR2,128],
       "T_MULTI"."OBJECT_NAME"[VARCHAR2,128], "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."OBJECT_ID"[NUMBER,22], "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22],
       "T_MULTI"."OBJECT_TYPE"[VARCHAR2,23], "T_MULTI"."CREATED"[DATE,7],
       "T_MULTI"."LAST_DDL_TIME"[DATE,7], "T_MULTI"."TIMESTAMP"[VARCHAR2,19],
       "T_MULTI"."STATUS"[VARCHAR2,7], "T_MULTI"."TEMPORARY"[VARCHAR2,1],
       "T_MULTI"."GENERATED"[VARCHAR2,1], "T_MULTI"."SECONDARY"[VARCHAR2,1],
       "T_MULTI"."NAMESPACE"[NUMBER,22], "T_MULTI"."EDITION_NAME"[VARCHAR2,128],
       "T_MULTI"."SHARING"[VARCHAR2,18], "T_MULTI"."EDITIONABLE"[VARCHAR2,1],
       "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1], "T_MULTI"."APPLICATION"[VARCHAR2,1],
       "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100], "T_MULTI"."DUPLICATED"[VARCHAR2,1],
       "T_MULTI"."SHARDED"[VARCHAR2,1], "T_MULTI"."CREATED_APPID"[NUMBER,22],
       "T_MULTI"."CREATED_VSNID"[NUMBER,22], "T_MULTI"."MODIFIED_APPID"[NUMBER,22],
       "T_MULTI"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=137) "T_MULTI"."OWNER"[VARCHAR2,128],
       "T_MULTI"."OBJECT_NAME"[VARCHAR2,128], "T_MULTI"."SUBOBJECT_NAME"[VARCHAR2,128],
       "T_MULTI"."OBJECT_ID"[NUMBER,22], "T_MULTI"."DATA_OBJECT_ID"[NUMBER,22],
       "T_MULTI"."OBJECT_TYPE"[VARCHAR2,23], "T_MULTI"."CREATED"[DATE,7],
       "T_MULTI"."LAST_DDL_TIME"[DATE,7], "T_MULTI"."TIMESTAMP"[VARCHAR2,19],
       "T_MULTI"."STATUS"[VARCHAR2,7], "T_MULTI"."TEMPORARY"[VARCHAR2,1],
       "T_MULTI"."GENERATED"[VARCHAR2,1], "T_MULTI"."SECONDARY"[VARCHAR2,1],
       "T_MULTI"."NAMESPACE"[NUMBER,22], "T_MULTI"."EDITION_NAME"[VARCHAR2,128],
       "T_MULTI"."SHARING"[VARCHAR2,18], "T_MULTI"."EDITIONABLE"[VARCHAR2,1],
       "T_MULTI"."ORACLE_MAINTAINED"[VARCHAR2,1], "T_MULTI"."APPLICATION"[VARCHAR2,1],
       "T_MULTI"."DEFAULT_COLLATION"[VARCHAR2,100], "T_MULTI"."DUPLICATED"[VARCHAR2,1],
       "T_MULTI"."SHARDED"[VARCHAR2,1], "T_MULTI"."CREATED_APPID"[NUMBER,22],
       "T_MULTI"."CREATED_VSNID"[NUMBER,22], "T_MULTI"."MODIFIED_APPID"[NUMBER,22],
       "T_MULTI"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_MULTI]]></t><s><![CDATA[SEL$
	1]]></s></h></f></q>



89 rows selected.


CREATE TABLE part_test
  (
   order_date_time timestamp,
   modulo_store_id NUMBER,
   recurring_flag CHAR (1)
  )
  PARTITION BY RANGE (order_date_time)
   INTERVAL ( NUMTOYMINTERVAL (1, 'MONTH') )
   SUBPARTITION BY LIST (modulo_store_id, recurring_flag)
   SUBPARTITION TEMPLATE (
      SUBPARTITION recur_0y VALUES ((0,'Y'),(0,'y')),
      SUBPARTITION recur_0n VALUES ((0,'N'),(0,'n')),
      SUBPARTITION recur_1y VALUES ((1,'Y'),(1,'y')),
      SUBPARTITION recur_1n VALUES ((1,'N'),(1,'n')),
      SUBPARTITION recur_2y VALUES ((2,'Y'),(2,'y')),
      SUBPARTITION recur_2n VALUES ((2,'N'),(2,'n')),
      SUBPARTITION recur_3y VALUES ((3,'Y'),(3,'y')),
      SUBPARTITION recur_3n VALUES ((3,'N'),(3,'n')),
      SUBPARTITION recur_def VALUES (DEFAULT) )
   (
   PARTITION pstart VALUES LESS THAN (TO_DATE ('2017-08-01','yyyy-mm-dd')) );


Select EXTRACT(DAY FROM TRUNC(timestamp)) from TABLE_NAME;


select TRUNC(CAST(created AS DATE), 'DAY') from all_objects where rownum < 10;
select TRUNC(CAST(created AS DATE), 'DAY') from all_objects where rownum < 10;

select EXTRACT(DAY FROM TRUNC(created)) from all_objects where rownum < 10;



14:59:03 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %v partitionedtable2%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
2yvjb8zarqhca	   0  594590928 	   1	       .042076		  2 select /* v partitionedtable2 */ * from PartitionedTable where PartitionKey ='10

14:59:08 SYS@ORCL> @dplan
Enter value for sql_id: 2yvjb8zarqhca

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	2yvjb8zarqhca, child number 0
-------------------------------------
select /* v partitionedtable2 */ * from PartitionedTable where
PartitionKey ='100'

Plan hash value: 594590928

-----------------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		 | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		 |	  |	  |	2 (100)|	  |	  |	  |
|   1 |  PARTITION LIST SINGLE| 		 |	1 |    22 |	2   (0)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL   | PARTITIONEDTABLE |	1 |    22 |	2   (0)| 00:00:01 |	2 |	2 |
-----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("PARTITIONKEY"=100)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[NUMBER,22],
       "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[NUMBER,22],
       "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



61 rows selected.



15:02:25 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %v partitionedtable4%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
1tsa224myvh6r	   0  367917378 	   1	       .006372		  2 select /* v partitionedtable4 */ * from PartitionedTable
										where  created >=


15:02:32 SYS@ORCL> @dplan
Enter value for sql_id: 1tsa224myvh6r

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1tsa224myvh6r, child number 0
-------------------------------------
select /* v partitionedtable4 */ * from PartitionedTable      where
created >= to_date('20161031','yyyymmdd')

Plan hash value: 367917378

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		       |	|	|     3 (100)|		|	|	|
|   1 |  PARTITION LIST MULTI-COLUMN|		       |      2 |    44 |     3   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|*  2 |   TABLE ACCESS FULL	    | PARTITIONEDTABLE |      2 |    44 |     3   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
-----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CREATED">=TO_DATE(' 2016-10-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONEDTABLE"."PARTITIONKEY"[NUMBER,22],
       "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONEDTABLE"."PARTITIONKEY"[NUMBER,22],
       "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



61 rows selected.


15:03:33 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %v partitionedtable5%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
0k92sxjxr5m0p	   0  939649965 	   1	       .005718		  0 select /* v partitionedtable5 */ * from PartitionedTable
									    where PartitionKey ='1


15:03:39 SYS@ORCL> @dplan
Enter value for sql_id: 0k92sxjxr5m0p

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	0k92sxjxr5m0p, child number 0
-------------------------------------
select /* v partitionedtable5 */ * from PartitionedTable  where
PartitionKey ='100' and created >= to_date('20161031','yyyymmdd')

Plan hash value: 939649965

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		| Name		   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|		   |	    |	    |	  3 (100)|	    |	    |	    |
|   1 |  PARTITION LIST ITERATOR|		   |	  1 |	 22 |	  3   (0)| 00:00:01 |	KEY |	KEY |
|*  2 |   TABLE ACCESS FULL	| PARTITIONEDTABLE |	  1 |	 22 |	  3   (0)| 00:00:01 |	KEY |	KEY |
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("PARTITIONKEY"=100 AND "CREATED">=TO_DATE(' 2016-10-31 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[NUMBER,22], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[NUMBER,22], "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



60 rows selected.



19:35:18 SYS@ORCL> 
19:35:18 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %multivvarchar2aa%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
22xqv11u52m5w	   0  594590928 	   1	       .006996		  2 select /* multivvarchar2aa */ * from PartitionedTable where PartitionKey ='theke

19:35:23 SYS@ORCL> @dplan
Enter value for sql_id: 22xqv11u52m5w

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	22xqv11u52m5w, child number 0
-------------------------------------
select /* multivvarchar2aa */ * from PartitionedTable where
PartitionKey ='thekey'

Plan hash value: 594590928

-----------------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		 | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		 |	  |	  |	2 (100)|	  |	  |	  |
|   1 |  PARTITION LIST SINGLE| 		 |	1 |    27 |	2   (0)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL   | PARTITIONEDTABLE |	1 |    27 |	2   (0)| 00:00:01 |	4 |	4 |
-----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("PARTITIONKEY"='thekey')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



61 rows selected.


19:38:12 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %v multivvarchar2ab%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
aa6q064tyvctn	   0 1130779953 	   1	       .008505		  9 select /* v multivvarchar2ab */ * from PartitionedTable
										where  created >= t


19:38:17 SYS@ORCL> @dplan
Enter value for sql_id: aa6q064tyvctn

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	aa6q064tyvctn, child number 0
-------------------------------------
select /* v multivvarchar2ab */ * from PartitionedTable      where
created >= to_date('20210101','yyyymmdd')

Plan hash value: 1130779953

--------------------------------------------------------------------------------------------------------
| Id  | Operation	   | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |		      |        |       |     3 (100)|	       |       |       |
|   1 |  PARTITION LIST ALL|		      |      1 |    29 |     3	 (0)| 00:00:01 |     1 |     5 |
|*  2 |   TABLE ACCESS FULL| PARTITIONEDTABLE |      1 |    29 |     3	 (0)| 00:00:01 |     1 |     5 |
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CREATED">=TO_DATE(' 2021-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$
	1]]></s></h></f></q>



61 rows selected.

19:38:24 SYS@ORCL> 
19:39:38 SYS@ORCL> 
19:39:39 SYS@ORCL> 
19:39:39 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %v multivvarchar2ac%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
gxsq2ttqucyp7	   0  594590928 	   1	       .003231		  2 select /* v multivvarchar2ac */ * from PartitionedTable
									    where PartitionKey ='th


19:39:44 SYS@ORCL> @dplan
Enter value for sql_id: gxsq2ttqucyp7

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	gxsq2ttqucyp7, child number 0
-------------------------------------
select /* v multivvarchar2ac */ * from PartitionedTable  where
PartitionKey ='thekey' and created >= to_date('20210101','yyyymmdd')

Plan hash value: 594590928

-----------------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		 | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		 |	  |	  |	2 (100)|	  |	  |	  |
|   1 |  PARTITION LIST SINGLE| 		 |	1 |    27 |	2   (0)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL   | PARTITIONEDTABLE |	1 |    27 |	2   (0)| 00:00:01 |	4 |	4 |
-----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("PARTITIONKEY"='thekey' AND "CREATED">=TO_DATE(' 2021-01-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



62 rows selected.


19:41:30 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %v multivvarchar2aba%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
1mhrpjtgswy83	   0 1130779953 	   1	       .007869		  9 select /* v multivvarchar2aba */ * from PartitionedTable
										where  created <=


19:41:36 SYS@ORCL> @dplan
Enter value for sql_id: 1mhrpjtgswy83

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1mhrpjtgswy83, child number 0
-------------------------------------
select /* v multivvarchar2aba */ * from PartitionedTable      where
created <= to_date('19980101','yyyymmdd')

Plan hash value: 1130779953

--------------------------------------------------------------------------------------------------------
| Id  | Operation	   | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |		      |        |       |     3 (100)|	       |       |       |
|   1 |  PARTITION LIST ALL|		      |      2 |    58 |     3	 (0)| 00:00:01 |     1 |     5 |
|*  2 |   TABLE ACCESS FULL| PARTITIONEDTABLE |      2 |    58 |     3	 (0)| 00:00:01 |     1 |     5 |
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CREATED"<=TO_DATE(' 1998-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$
	1]]></s></h></f></q>



61 rows selected.




19:49:18 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_daterange_submultia%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
f5qhanzkazczp	   0 3261219875 	   1	       .007509		  5 select /* t_daterange_submultia */ * from t_daterange_submulti where owner ='KAR

19:49:23 SYS@ORCL> 
19:49:25 SYS@ORCL> @dplan
Enter value for sql_id: f5qhanzkazczp

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	f5qhanzkazczp, child number 0
-------------------------------------
select /* t_daterange_submultia */ * from t_daterange_submulti where
owner ='KARL'

Plan hash value: 3261219875

----------------------------------------------------------------------------------------------------------------
| Id  | Operation	       | Name		      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |		      |        |       |     3 (100)|	       |       |       |
|   1 |  PARTITION RANGE ALL   |		      |      2 |    42 |     3	 (0)| 00:00:01 |     1 |1048575|
|   2 |   PARTITION LIST SINGLE|		      |      2 |    42 |     3	 (0)| 00:00:01 |   KEY |   KEY |
|*  3 |    TABLE ACCESS FULL   | T_DATERANGE_SUBMULTI |      2 |    42 |     3	 (0)| 00:00:01 |   KEY |   KEY |
----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / T_DATERANGE_SUBMULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_DATERANGE_SUBMULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("OWNER"='KARL')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "T_DATERANGE_SUBMULTI"."BEGIN_DATE"[TIMESTAMP,11], "OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]
   2 - (rowset=256) "T_DATERANGE_SUBMULTI"."BEGIN_DATE"[TIMESTAMP,11], "OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]
   3 - (rowset=256) "T_DATERANGE_SUBMULTI"."BEGIN_DATE"[TIMESTAMP,11], "OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_DATERANGE_SUBMULTI]]></t><s><![CDATA[SEL$1]]>
	</s></h></f></q>



64 rows selected.


19:51:16 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %v t_daterange_submultib%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
c62svwn2qf149	   0 2145833903 	   1	       .002787		  4 select /* v t_daterange_submultib */ * from t_daterange_submulti
										where  beg


19:51:22 SYS@ORCL> @dplan
Enter value for sql_id: c62svwn2qf149

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	c62svwn2qf149, child number 0
-------------------------------------
select /* v t_daterange_submultib */ * from t_daterange_submulti
where  begin_date >= to_date('20210101','yyyymmdd')

Plan hash value: 2145833903

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |     2 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|      1 |    21 |     2   (0)| 00:00:01 |   614 |1048575|
|   2 |   PARTITION LIST ALL	 |			|      1 |    21 |     2   (0)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL	 | T_DATERANGE_SUBMULTI |      1 |    21 |     2   (0)| 00:00:01 |  1227 |1048575|
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / T_DATERANGE_SUBMULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_DATERANGE_SUBMULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE">=TIMESTAMP' 2021-01-01 00:00:00')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "T_DATERANGE_SUBMULTI"."OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]
   2 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "T_DATERANGE_SUBMULTI"."OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]
   3 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "T_DATERANGE_SUBMULTI"."OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_DATERANGE_SUBMULTI]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



64 rows selected.


19:53:36 SYS@ORCL> @dplan
Enter value for sql_id: 1zdy354usq288

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1zdy354usq288, child number 0
-------------------------------------
select /* t_daterange_submultic */ * from t_daterange_submulti
where  begin_date <= to_date('19980101','yyyymmdd')

Plan hash value: 2145833903

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |     2 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|      2 |    42 |     2   (0)| 00:00:01 |     1 |   338 |
|   2 |   PARTITION LIST ALL	 |			|      2 |    42 |     2   (0)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL	 | T_DATERANGE_SUBMULTI |      2 |    42 |     2   (0)| 00:00:01 |     1 |   676 |
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / T_DATERANGE_SUBMULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_DATERANGE_SUBMULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE"<=TIMESTAMP' 1998-01-01 00:00:00')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "T_DATERANGE_SUBMULTI"."OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]
   2 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "T_DATERANGE_SUBMULTI"."OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]
   3 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "T_DATERANGE_SUBMULTI"."OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_DATERANGE_SUBMULTI]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



64 rows selected.



19:56:27 SYS@ORCL> @dplan
Enter value for sql_id: 6801xxuuk5g1r

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	6801xxuuk5g1r, child number 0
-------------------------------------
select /* t_daterange_submultid */ * from t_daterange_submulti	where
owner ='KARL' and begin_date >= to_date('20210101','yyyymmdd')

Plan hash value: 2170868542

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |     2 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|      1 |    21 |     2   (0)| 00:00:01 |   614 |1048575|
|   2 |   PARTITION LIST SINGLE  |			|      1 |    21 |     2   (0)| 00:00:01 |   KEY |   KEY |
|*  3 |    TABLE ACCESS FULL	 | T_DATERANGE_SUBMULTI |      1 |    21 |     2   (0)| 00:00:01 |   KEY |   KEY |
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / T_DATERANGE_SUBMULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_DATERANGE_SUBMULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("BEGIN_DATE">=TIMESTAMP' 2021-01-01 00:00:00' AND "OWNER"='KARL'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]
   2 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]
   3 - (rowset=256) "BEGIN_DATE"[TIMESTAMP,11], "OWNER"[VARCHAR2,20],
       "T_DATERANGE_SUBMULTI"."OBJECT_TYPE"[VARCHAR2,20]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_DATERANGE_SUBMULTI]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



64 rows selected.

19:57:54 SYS@ORCL> 
19:57:55 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %t_daterange_submultide%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
4wkdznqsmy065	   0 3577933703 	   1	       .008401		 12 select /* t_daterange_submultide */ count(*) from t_daterange_submulti

19:57:59 SYS@ORCL> @dplan
Enter value for sql_id: 4wkdznqsmy065

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	4wkdznqsmy065, child number 0
-------------------------------------
select /* t_daterange_submultide */ count(*) from t_daterange_submulti

Plan hash value: 3577933703

------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name		    | E-Rows | Cost (%CPU)| E-Time   | Pstart| Pstop |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |			    |	     |	   3 (100)|	     |	     |	     |
|   1 |  SORT AGGREGATE      |			    |	   1 |		  |	     |	     |	     |
|   2 |   PARTITION RANGE ALL|			    |	   4 |	   3   (0)| 00:00:01 |	   1 |1048575|
|   3 |    PARTITION LIST ALL|			    |	   4 |	   3   (0)| 00:00:01 |	   1 |	   2 |
|   4 |     TABLE ACCESS FULL| T_DATERANGE_SUBMULTI |	   4 |	   3   (0)| 00:00:01 |	   1 |1048575|
------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   4 - SEL$1 / T_DATERANGE_SUBMULTI@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "T_DATERANGE_SUBMULTI"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) COUNT(*)[22]
   2 - (rowset=1019)
   3 - (rowset=1019)
   4 - (rowset=1019)

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[T_DATERANGE_SUBMULTI]]></t><s><![CDAT
	A[SEL$1]]></s></h></f></q>



57 rows selected.


20:53:31 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wa%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
ap6wrv77hnj2a	   0  594590928 	   1	       .059836		  2 select /* 22xqv11u52m5wa */ * from PartitionedTable where PartitionKey ='200'

20:53:38 SYS@ORCL> @dplan
Enter value for sql_id: ap6wrv77hnj2a

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	ap6wrv77hnj2a, child number 0
-------------------------------------
select /* 22xqv11u52m5wa */ * from PartitionedTable where PartitionKey
='200'

Plan hash value: 594590928

-----------------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		 | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		 |	  |	  |	2 (100)|	  |	  |	  |
|   1 |  PARTITION LIST SINGLE| 		 |	1 |    27 |	2   (0)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL   | PARTITIONEDTABLE |	1 |    27 |	2   (0)| 00:00:01 |	3 |	3 |
-----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("PARTITIONKEY"='200')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



61 rows selected.


20:58:38 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wc%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
dkt0wyty1u620	   0 1130779953 	   1	       .149607		  7 select /* 22xqv11u52m5wc */ * from PartitionedTable
										where  created <= to_da


20:58:44 SYS@ORCL> @dplan
Enter value for sql_id: dkt0wyty1u620

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	dkt0wyty1u620, child number 0
-------------------------------------
select /* 22xqv11u52m5wc */ * from PartitionedTable	 where	created
<= to_date('19980101','yyyymmdd')

Plan hash value: 1130779953

--------------------------------------------------------------------------------------------------------
| Id  | Operation	   | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |		      |        |       |     3 (100)|	       |       |       |
|   1 |  PARTITION LIST ALL|		      |      2 |    52 |     3	 (0)| 00:00:01 |     1 |     4 |
|*  2 |   TABLE ACCESS FULL| PARTITIONEDTABLE |      2 |    52 |     3	 (0)| 00:00:01 |     1 |     4 |
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CREATED"<=TO_DATE(' 1998-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$
	1]]></s></h></f></q>



61 rows selected.


21:00:04 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wd%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
bcs2wabau1b7m	   0  594590928 	   1	       .005134		  2 select /* 22xqv11u52m5wd */ * from PartitionedTable
									    where PartitionKey ='9'
									    and


21:00:10 SYS@ORCL> @dplan
Enter value for sql_id: bcs2wabau1b7m

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	bcs2wabau1b7m, child number 0
-------------------------------------
select /* 22xqv11u52m5wd */ * from PartitionedTable  where PartitionKey
='9' and created >= to_date('20180101','yyyymmdd')

Plan hash value: 594590928

-----------------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		 | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		 |	  |	  |	2 (100)|	  |	  |	  |
|   1 |  PARTITION LIST SINGLE| 		 |	1 |    25 |	2   (0)| 00:00:01 |   KEY |   KEY |
|*  2 |   TABLE ACCESS FULL   | PARTITIONEDTABLE |	1 |    25 |	2   (0)| 00:00:01 |	4 |	4 |
-----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("PARTITIONKEY"='9' AND "CREATED">=TO_DATE(' 2018-01-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



62 rows selected.


21:38:57 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %ap6wrv77hnj2aa%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
925812hajs3vp	   0 4254536428 	   1	       .055223		  8 select /* ap6wrv77hnj2aa */ * from PartitionedTable where PartitionKey ='200'

21:39:03 SYS@ORCL> @dplan
Enter value for sql_id: 925812hajs3vp

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	925812hajs3vp, child number 0
-------------------------------------
select /* ap6wrv77hnj2aa */ * from PartitionedTable where PartitionKey
='200'

Plan hash value: 4254536428

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		       |	|	|     2 (100)|		|	|	|
|   1 |  PARTITION LIST MULTI-COLUMN|		       |      1 |    15 |     2   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|   2 |   PARTITION RANGE ALL	    |		       |      1 |    15 |     2   (0)| 00:00:01 |     1 |     3 |
|*  3 |    TABLE ACCESS FULL	    | PARTITIONEDTABLE |      1 |    15 |     2   (0)| 00:00:01 |   KEY |   KEY |
-----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("PARTITIONKEY"='200')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "PARTITIONEDTABLE"."CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "PARTITIONEDTABLE"."CREATED"[DATE,7]
   3 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128],
       "PARTITIONEDTABLE"."CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



64 rows selected.

21:40:16 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %ap6wrv77hnj2ab%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
7rpncyd681wc0	   0 1200101474 	   1	       .010919		 12 select /* ap6wrv77hnj2ab */ * from PartitionedTable
										where  created >= to_da


21:40:21 SYS@ORCL> @dplan
Enter value for sql_id: 7rpncyd681wc0

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	7rpncyd681wc0, child number 0
-------------------------------------
select /* ap6wrv77hnj2ab */ * from PartitionedTable	 where	created
>= to_date('19920101','yyyymmdd')

Plan hash value: 1200101474

----------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |			|	 |	 |     3 (100)| 	 |	 |	 |
|   1 |  PARTITION LIST ALL  |			|      4 |    60 |     3   (0)| 00:00:01 |     1 |     3 |
|   2 |   PARTITION RANGE ALL|			|      4 |    60 |     3   (0)| 00:00:01 |     1 |     3 |
|*  3 |    TABLE ACCESS FULL | PARTITIONEDTABLE |      4 |    60 |     3   (0)| 00:00:01 |     1 |     9 |
----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("CREATED">=TO_DATE(' 1992-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   3 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]
	]></s></h></f></q>



64 rows selected.
21:40:28 SYS@ORCL> 
21:42:01 SYS@ORCL> 
21:42:01 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %ap6wrv77hnj2aa0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
304r073p9x6zx	   0 3936040530 	   1	       .008060		 12 select /* ap6wrv77hnj2aa0 */ count(*) from PartitionedTable

21:42:07 SYS@ORCL> @dplan
Enter value for sql_id: 304r073p9x6zx

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	304r073p9x6zx, child number 0
-------------------------------------
select /* ap6wrv77hnj2aa0 */ count(*) from PartitionedTable

Plan hash value: 3936040530

---------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		 | E-Rows | Cost (%CPU)| E-Time   | Pstart| Pstop |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		 |	  |	3 (100)|	  |	  |	  |
|   1 |  SORT AGGREGATE       | 		 |	1 |	       |	  |	  |	  |
|   2 |   PARTITION LIST ALL  | 		 |	4 |	3   (0)| 00:00:01 |	1 |	3 |
|   3 |    PARTITION RANGE ALL| 		 |	4 |	3   (0)| 00:00:01 |	1 |	3 |
|   4 |     TABLE ACCESS FULL | PARTITIONEDTABLE |	4 |	3   (0)| 00:00:01 |	1 |	9 |
---------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   4 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) COUNT(*)[22]
   2 - (rowset=1019)
   3 - (rowset=1019)
   4 - (rowset=1019)

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA
	[SEL$1]]></s></h></f></q>



57 rows selected.

21:43:47 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %ap6wrv77hnj2ac%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
dsqad34f15xmj	   0 1327941231 	   1	       .044904		  6 select /* ap6wrv77hnj2ac */ * from PartitionedTable
										where  created <= to_da


21:44:26 SYS@ORCL> @dplan
Enter value for sql_id: dsqad34f15xmj

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	dsqad34f15xmj, child number 0
-------------------------------------
select /* ap6wrv77hnj2ac */ * from PartitionedTable	 where	created
<= to_date('19980101','yyyymmdd')

Plan hash value: 1327941231

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		| Name		   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|		   |	    |	    |	  3 (100)|	    |	    |	    |
|   1 |  PARTITION LIST ALL	|		   |	  3 |	 45 |	  3   (0)| 00:00:01 |	  1 |	  3 |
|   2 |   PARTITION RANGE SINGLE|		   |	  3 |	 45 |	  3   (0)| 00:00:01 |	  1 |	  1 |
|*  3 |    TABLE ACCESS FULL	| PARTITIONEDTABLE |	  3 |	 45 |	  3   (0)| 00:00:01 |	    |	    |
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("CREATED"<=TO_DATE(' 1998-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   3 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



64 rows selected.


21:45:39 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %ap6wrv77hnj2ad%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
5svfcu6w17103	   0 4254536428 	   1	       .013167		  4 select /* ap6wrv77hnj2ad */ * from PartitionedTable
									    where PartitionKey ='9'
									    and


21:45:50 SYS@ORCL> @dplan
Enter value for sql_id: 5svfcu6w17103

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	5svfcu6w17103, child number 0
-------------------------------------
select /* ap6wrv77hnj2ad */ * from PartitionedTable  where PartitionKey
='9' and created >= to_date('20180101','yyyymmdd')

Plan hash value: 4254536428

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		       |	|	|     2 (100)|		|	|	|
|   1 |  PARTITION LIST MULTI-COLUMN|		       |      1 |    15 |     2   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|   2 |   PARTITION RANGE ALL	    |		       |      1 |    15 |     2   (0)| 00:00:01 |     1 |     3 |
|*  3 |    TABLE ACCESS FULL	    | PARTITIONEDTABLE |      1 |    15 |     2   (0)| 00:00:01 |   KEY |   KEY |
-----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("PARTITIONKEY"='9' AND "CREATED">=TO_DATE(' 2018-01-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   3 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



62 rows selected.


21:48:47 SYS@ORCL> 
21:48:47 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %ap6wrv77hnj2aa0a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
1z4j43094qqns	   0 1200101474 	   1	       .011171		 12 select /* ap6wrv77hnj2aa0a */ * from PartitionedTable

21:48:57 SYS@ORCL> @dplan
Enter value for sql_id: 1z4j43094qqns

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1z4j43094qqns, child number 0
-------------------------------------
select /* ap6wrv77hnj2aa0a */ * from PartitionedTable

Plan hash value: 1200101474

----------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |			|	 |	 |     3 (100)| 	 |	 |	 |
|   1 |  PARTITION LIST ALL  |			|      4 |    60 |     3   (0)| 00:00:01 |     1 |     3 |
|   2 |   PARTITION RANGE ALL|			|      4 |    60 |     3   (0)| 00:00:01 |     1 |     3 |
|   3 |    TABLE ACCESS FULL | PARTITIONEDTABLE |      4 |    60 |     3   (0)| 00:00:01 |     1 |     9 |
----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "PARTITIONEDTABLE"."CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "PARTITIONEDTABLE"."CREATED"[DATE,7]
   3 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "PARTITIONEDTABLE"."CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]
	]></s></h></f></q>



58 rows selected.

21:53:10 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %ap6wrv77hnj2abz%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
7fzt2nc8yg71x	   0 1200101474 	   1	       .010518		 16 select /* ap6wrv77hnj2abz */ * from PartitionedTable
										where  created >= to_d


21:53:16 SYS@ORCL> @dplan
Enter value for sql_id: 7fzt2nc8yg71x

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	7fzt2nc8yg71x, child number 0
-------------------------------------
select /* ap6wrv77hnj2abz */ * from PartitionedTable	  where
created >= to_date('20200101','yyyymmdd')

Plan hash value: 1200101474

----------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |			|	 |	 |     3 (100)| 	 |	 |	 |
|   1 |  PARTITION LIST ALL  |			|      3 |    45 |     3   (0)| 00:00:01 |     1 |     3 |
|   2 |   PARTITION RANGE ALL|			|      3 |    45 |     3   (0)| 00:00:01 |     1 |     4 |
|*  3 |    TABLE ACCESS FULL | PARTITIONEDTABLE |      3 |    45 |     3   (0)| 00:00:01 |     1 |    12 |
----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("CREATED">=TO_DATE(' 2020-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   3 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]
	]></s></h></f></q>



64 rows selected.


00:27:19 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTa%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
1w1ag2dqgxn2r	   0 2382408120 	   1	       .162864	      1,632 select /* TEST_RANGE_LISTa */ count(*) from TEST_RANGE_LIST

00:27:26 SYS@ORCL> @dplan
Enter value for sql_id: 1w1ag2dqgxn2r

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1w1ag2dqgxn2r, child number 0
-------------------------------------
select /* TEST_RANGE_LISTa */ count(*) from TEST_RANGE_LIST

Plan hash value: 2382408120

-------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name	       | E-Rows | Cost (%CPU)| E-Time	| Pstart| Pstop |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |		       |	|   441 (100)|		|	|	|
|   1 |  SORT AGGREGATE      |		       |      1 |	     |		|	|	|
|   2 |   PARTITION RANGE ALL|		       |  72434 |   441   (1)| 00:00:01 |     1 |1048575|
|   3 |    PARTITION LIST ALL|		       |  72434 |   441   (1)| 00:00:01 |     1 |     2 |
|   4 |     TABLE ACCESS FULL| TEST_RANGE_LIST |  72434 |   441   (1)| 00:00:01 |     1 |1048575|
-------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   4 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) COUNT(*)[22]
   2 - (rowset=1019)
   3 - (rowset=1019)
   4 - (rowset=1019)

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDAT
	A[SEL$1]]></s></h></f></q>



57 rows selected.
00:28:22 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTa0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
avq68gfq7ndxr	   0 1209238144 	   1	       .037515		  5 select /* TEST_RANGE_LISTa0 */ * from TEST_RANGE_LIST

00:28:27 SYS@ORCL> @dplan
Enter value for sql_id: avq68gfq7ndxr

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	avq68gfq7ndxr, child number 0
-------------------------------------
select /* TEST_RANGE_LISTa0 */ * from TEST_RANGE_LIST

Plan hash value: 1209238144

--------------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |		      |        |       |   442 (100)|	       |       |       |
|   1 |  PARTITION RANGE ALL|		      |  72434 |    10M|   442	 (1)| 00:00:01 |     1 |1048575|
|   2 |   PARTITION LIST ALL|		      |  72434 |    10M|   442	 (1)| 00:00:01 |     1 |     2 |
|   3 |    TABLE ACCESS FULL| TEST_RANGE_LIST |  72434 |    10M|   442	 (1)| 00:00:01 |     1 |1048575|
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=139) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   2 - (rowset=139) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   3 - (rowset=139) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1
	]]></s></h></f></q>



97 rows selected.

00:29:43 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTb%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
72v16h9189yau	   0 2851181621 	   1	       .159470		  5 select /* TEST_RANGE_LISTb */ * from TEST_RANGE_LIST where owner ='SYS'

00:29:48 SYS@ORCL> @dplan
Enter value for sql_id: 72v16h9189yau

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	72v16h9189yau, child number 0
-------------------------------------
select /* TEST_RANGE_LISTb */ * from TEST_RANGE_LIST where owner ='SYS'

Plan hash value: 2851181621

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 	   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |		   |	    |	    |	442 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ALL	 |		   |   1767 |	255K|	442   (1)| 00:00:01 |	  1 |1048575|
|   2 |   PARTITION LIST ITERATOR|		   |   1767 |	255K|	442   (1)| 00:00:01 |	KEY |	KEY |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST |   1767 |	255K|	442   (1)| 00:00:01 |	  1 |1048575|
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("OWNER"='SYS')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   2 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   3 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



99 rows selected.

00:30:58 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTb0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
98famt7usu84g	   0  960007140 	   1	       .070461		 12 select /* TEST_RANGE_LISTb0 */ * from TEST_RANGE_LIST where owner ='SYS' and obj

00:31:03 SYS@ORCL> @dplan
Enter value for sql_id: 98famt7usu84g

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	98famt7usu84g, child number 0
-------------------------------------
select /* TEST_RANGE_LISTb0 */ * from TEST_RANGE_LIST where owner
='SYS' and object_type = 'TABLE'

Plan hash value: 960007140

-----------------------------------------------------------------------------------------------------------
| Id  | Operation	       | Name		 | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |		 |	  |	  |    12 (100)|	  |	  |	  |
|   1 |  PARTITION RANGE ALL   |		 |     48 |  7104 |    12   (0)| 00:00:01 |	1 |1048575|
|   2 |   PARTITION LIST SINGLE|		 |     48 |  7104 |    12   (0)| 00:00:01 |   KEY |   KEY |
|*  3 |    TABLE ACCESS FULL   | TEST_RANGE_LIST |     48 |  7104 |    12   (0)| 00:00:01 |   KEY |   KEY |
-----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("OWNER"='SYS' AND "OBJECT_TYPE"='TABLE'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   2 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   3 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1]]>
	</s></h></f></q>



100 rows selected.

00:33:19 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTc%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
31u8y6dhwdxd3	   0 1205817235 	   1	       .004357		  5 select /* v TEST_RANGE_LISTc */ * from TEST_RANGE_LIST
										where  begin_date >=


00:33:26 SYS@ORCL> @dplan
Enter value for sql_id: 31u8y6dhwdxd3

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	31u8y6dhwdxd3, child number 0
-------------------------------------
select /* v TEST_RANGE_LISTc */ * from TEST_RANGE_LIST	    where
begin_date >= to_date('20190501','yyyymmdd')

Plan hash value: 1205817235

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 	   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |		   |	    |	    |	 35 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ITERATOR|		   |  70922 |	 10M|	 35   (0)| 00:00:01 |	594 |1048575|
|   2 |   PARTITION LIST ALL	 |		   |  70922 |	 10M|	 35   (0)| 00:00:01 |	  1 |	  2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST |  70922 |	 10M|	 35   (0)| 00:00:01 |  1187 |1048575|
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE">=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



103 rows selected.


00:34:40 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTd%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
d3b40q3mb3g87	   0 1205817235 	   1	       .054072		  5 select /* TEST_RANGE_LISTd */ * from TEST_RANGE_LIST
										where  begin_date <= t


00:34:46 SYS@ORCL> @dplan
Enter value for sql_id: d3b40q3mb3g87

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	d3b40q3mb3g87, child number 0
-------------------------------------
select /* TEST_RANGE_LISTd */ * from TEST_RANGE_LIST	  where
begin_date <= to_date('20190501','yyyymmdd')

Plan hash value: 1205817235

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 	   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |		   |	    |	    |	442 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ITERATOR|		   |   1643 |	237K|	442   (1)| 00:00:01 |	  1 |	594 |
|   2 |   PARTITION LIST ALL	 |		   |   1643 |	237K|	442   (1)| 00:00:01 |	  1 |	  2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST |   1643 |	237K|	442   (1)| 00:00:01 |	  1 |  1188 |
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE"<=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



103 rows selected.

Enter value for sql_fulltext: %TEST_RANGE_LISTe%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
6gj7zwc9rzbq5	   0 2339577135 	   1	       .059929		  5 select /* TEST_RANGE_LISTe */ * from TEST_RANGE_LIST
									    where owner ='SYS' and obj


00:36:00 SYS@ORCL> 
00:36:01 SYS@ORCL> @dplan
Enter value for sql_id: 6gj7zwc9rzbq5

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	6gj7zwc9rzbq5, child number 0
-------------------------------------
select /* TEST_RANGE_LISTe */ * from TEST_RANGE_LIST  where owner
='SYS' and object_type = 'TABLE' and begin_date >=
to_date('20190501','yyyymmdd')

Plan hash value: 2339577135

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 	   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |		   |	    |	    |	  2 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ITERATOR|		   |	 47 |  6956 |	  2   (0)| 00:00:01 |	594 |1048575|
|   2 |   PARTITION LIST SINGLE  |		   |	 47 |  6956 |	  2   (0)| 00:00:01 |	KEY |	KEY |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST |	 47 |  6956 |	  2   (0)| 00:00:01 |	KEY |	KEY |
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("OWNER"='SYS' AND "OBJECT_TYPE"='TABLE' AND "BEGIN_DATE">=TO_DATE(' 2019-05-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   2 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   3 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST"."CREATED"[DATE,7], "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



102 rows selected.


00:51:11 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTf%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
ccjajbdwq80uf	   0 1205817235 	   1	       .061120	      3,240 select /* TEST_RANGE_LISTf */ * from TEST_RANGE_LIST
									    where ( (end_date >= to_da

ccjajbdwq80uf	   1 1205817235 	   1	       .104080	      3,240 select /* TEST_RANGE_LISTf */ * from TEST_RANGE_LIST
									    where ( (end_date >= to_da


00:54:07 SYS@ORCL> set serveroutput on
00:54:13 SYS@ORCL> @mismatch
Enter value for sql_id: ccjajbdwq80uf
old  14:	   and q.sql_id like ''&sql_id''',
new  14:	   and q.sql_id like ''ccjajbdwq80uf''',
SQL_ID			       = ccjajbdwq80uf
CHILD_NUMBER		       = 0
USE_FEEDBACK_STATS	       = Y
--------------------------------------------------
SQL_ID			       = ccjajbdwq80uf
CHILD_NUMBER		       = 1
--------------------------------------------------

PL/SQL procedure successfully completed.



00:51:18 SYS@ORCL> 
00:51:18 SYS@ORCL> 
00:51:18 SYS@ORCL> @dplan
Enter value for sql_id: ccjajbdwq80uf

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	ccjajbdwq80uf, child number 0
-------------------------------------
select /* TEST_RANGE_LISTf */ * from TEST_RANGE_LIST  where ( (end_date
>= to_date('20210131','yyyymmdd') ) and  ( begin_date >=
to_date('20190401','yyyymmdd') )  and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 1205817235

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 	   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |		   |	    |	    |	442 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ITERATOR|		   |   3545 |	512K|	442   (1)| 00:00:01 |	593 |	617 |
|   2 |   PARTITION LIST ALL	 |		   |   3545 |	512K|	442   (1)| 00:00:01 |	  1 |	  2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST |   3545 |	512K|	442   (1)| 00:00:01 |  1185 |  1234 |
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND "BEGIN_DATE"<=TO_DATE('
	      2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=137) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   3 - (rowset=137) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>


SQL_ID	ccjajbdwq80uf, child number 1
-------------------------------------
select /* TEST_RANGE_LISTf */ * from TEST_RANGE_LIST  where ( (end_date
>= to_date('20210131','yyyymmdd') ) and  ( begin_date >=
to_date('20190401','yyyymmdd') )  and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 1205817235

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 	   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |		   |	    |	    |	442 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ITERATOR|		   |	 40 |  5920 |	442   (1)| 00:00:01 |	593 |	617 |
|   2 |   PARTITION LIST ALL	 |		   |	 40 |  5920 |	442   (1)| 00:00:01 |	  1 |	  2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST |	 40 |  5920 |	442   (1)| 00:00:01 |  1185 |  1234 |
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND "BEGIN_DATE"<=TO_DATE('
	      2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=137) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   3 - (rowset=137) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - statistics feedback used for this statement
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



209 rows selected.



00:57:27 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %%TEST_RANGE_LIST_VIRTf0%%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
gq8gt71bpn67n	   0 2428588542 	   1	       .754152	      1,847 select /* TEST_RANGE_LIST_VIRTf0 */ * from TEST_RANGE_LIST_VIRT
									    WHERE  ( ( Trunc

gq8gt71bpn67n	   1 2428588542 	   2	       .274974	      1,632 select /* TEST_RANGE_LIST_VIRTf0 */ * from TEST_RANGE_LIST_VIRT
									    WHERE  ( ( Trunc



00:58:54 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTf0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
gq8gt71bpn67n	   0 2428588542 	   1	       .754152	      1,847 select /* TEST_RANGE_LIST_VIRTf0 */ * from TEST_RANGE_LIST_VIRT
									    WHERE  ( ( Trunc

gq8gt71bpn67n	   1 2428588542 	   4	       .310312	      1,632 select /* TEST_RANGE_LIST_VIRTf0 */ * from TEST_RANGE_LIST_VIRT
									    WHERE  ( ( Trunc




00:58:00 SYS@ORCL> @mismatch
Enter value for sql_id: gq8gt71bpn67n
SQL_ID			       = gq8gt71bpn67n
CHILD_NUMBER		       = 0
USE_FEEDBACK_STATS	       = Y
--------------------------------------------------
SQL_ID			       = gq8gt71bpn67n
CHILD_NUMBER		       = 1
--------------------------------------------------

PL/SQL procedure successfully completed.


00:58:51 SYS@ORCL> @dplan
Enter value for sql_id: gq8gt71bpn67n

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	gq8gt71bpn67n, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTf0 */ * from TEST_RANGE_LIST_VIRT WHERE
( ( Trunc(Cast(end_date AS DATE)) >= To_date('2021-01-31',
'YYYY-MM-DD') ) 	 AND ( Trunc(Cast(begin_date AS DATE)) >=
To_date('2019-04-01', 'YYYY-MM-DD') )	       AND (
Trunc(Cast(begin_date AS DATE)) <= To_date('2021-04-01', 'YYYY-MM-DD')
) )

Plan hash value: 2428588542

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |   446 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|   3622 |   551K|   446   (2)| 00:00:01 |   593 |   617 |
|   2 |   PARTITION LIST ALL	 |			|   3622 |   551K|   446   (2)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST_VIRT |   3622 |   551K|   446   (2)| 00:00:01 |  1185 |  1234 |
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter((TRUNC(CAST(INTERNAL_FUNCTION("END_DATE") AS DATE))>=TO_DATE(' 2021-01-31 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss') AND TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-04-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))<=TO_DATE('
	      2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=136) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=136) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   3 - (rowset=136) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>


SQL_ID	gq8gt71bpn67n, child number 1
-------------------------------------
select /* TEST_RANGE_LIST_VIRTf0 */ * from TEST_RANGE_LIST_VIRT WHERE
( ( Trunc(Cast(end_date AS DATE)) >= To_date('2021-01-31',
'YYYY-MM-DD') ) 	 AND ( Trunc(Cast(begin_date AS DATE)) >=
To_date('2019-04-01', 'YYYY-MM-DD') )	       AND (
Trunc(Cast(begin_date AS DATE)) <= To_date('2021-04-01', 'YYYY-MM-DD')
) )

Plan hash value: 2428588542

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |   446 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|     20 |  3120 |   446   (2)| 00:00:01 |   593 |   617 |
|   2 |   PARTITION LIST ALL	 |			|     20 |  3120 |   446   (2)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST_VIRT |     20 |  3120 |   446   (2)| 00:00:01 |  1185 |  1234 |
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter((TRUNC(CAST(INTERNAL_FUNCTION("END_DATE") AS DATE))>=TO_DATE(' 2021-01-31 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss') AND TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-04-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))<=TO_DATE('
	      2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=136) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=136) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   3 - (rowset=136) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - statistics feedback used for this statement
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



221 rows selected.



01:01:44 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRT0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
6k2nrgrunpjum	   0 2367113788 	   1	       .346562		  7 select /* TEST_RANGE_LIST_VIRT0 */ * from TEST_RANGE_LIST_VIRT

01:01:52 SYS@ORCL> 
01:01:57 SYS@ORCL> @dplan
Enter value for sql_id: 6k2nrgrunpjum

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	6k2nrgrunpjum, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRT0 */ * from TEST_RANGE_LIST_VIRT

Plan hash value: 2367113788

-------------------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name		   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |			   |	    |	    |	442 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ALL|			   |  72434 |	 10M|	442   (1)| 00:00:01 |	  1 |1048575|
|   2 |   PARTITION LIST ALL|			   |  72434 |	 10M|	442   (1)| 00:00:01 |	  1 |	  2 |
|   3 |    TABLE ACCESS FULL| TEST_RANGE_LIST_VIRT |  72434 |	 10M|	442   (1)| 00:00:01 |	  1 |1048575|
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=139) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=139) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=139) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1
	]]></s></h></f></q>



106 rows selected.


01:02:41 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTa%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
d1ckcg1qxvt6r	   0 2815752438 	   1	      1.103873	      1,635 select /* TEST_RANGE_LIST_VIRTa */ count(*) from TEST_RANGE_LIST_VIRT

01:02:49 SYS@ORCL> @dplan
Enter value for sql_id: d1ckcg1qxvt6r

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	d1ckcg1qxvt6r, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTa */ count(*) from TEST_RANGE_LIST_VIRT

Plan hash value: 2815752438

------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name		    | E-Rows | Cost (%CPU)| E-Time   | Pstart| Pstop |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |			    |	     |	 442 (100)|	     |	     |	     |
|   1 |  SORT AGGREGATE      |			    |	   1 |		  |	     |	     |	     |
|   2 |   PARTITION RANGE ALL|			    |  72434 |	 442   (1)| 00:00:01 |	   1 |1048575|
|   3 |    PARTITION LIST ALL|			    |  72434 |	 442   (1)| 00:00:01 |	   1 |	   2 |
|   4 |     TABLE ACCESS FULL| TEST_RANGE_LIST_VIRT |  72434 |	 442   (1)| 00:00:01 |	   1 |1048575|
------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   4 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) COUNT(*)[22]
   2 - (rowset=1019)
   3 - (rowset=1019)
   4 - (rowset=1019)

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDAT
	A[SEL$1]]></s></h></f></q>



57 rows selected.


01:03:38 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTb%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
105uprtj519fd	   0  947721019 	   1	       .011006		  7 select /* TEST_RANGE_LIST_VIRTb */ * from TEST_RANGE_LIST_VIRT where owner ='SYS

01:03:45 SYS@ORCL> @dplan
Enter value for sql_id: 105uprtj519fd

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	105uprtj519fd, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTb */ * from TEST_RANGE_LIST_VIRT where
owner ='SYS'

Plan hash value: 947721019

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |   442 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ALL	 |			|   1767 |   269K|   442   (1)| 00:00:01 |     1 |1048575|
|   2 |   PARTITION LIST ITERATOR|			|   1767 |   269K|   442   (1)| 00:00:01 |   KEY |   KEY |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST_VIRT |   1767 |   269K|   442   (1)| 00:00:01 |     1 |1048575|
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("OWNER"='SYS')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100]
       , "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100]
       , "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100]
       , "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



100 rows selected.


01:04:37 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTc%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
fb7a068c39cqu	   0  729917378 	   1	       .059470		 24 select /* TEST_RANGE_LIST_VIRTc */ * from TEST_RANGE_LIST_VIRT where owner ='SYS

01:04:42 SYS@ORCL> @dplan
Enter value for sql_id: fb7a068c39cqu

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	fb7a068c39cqu, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTc */ * from TEST_RANGE_LIST_VIRT where
owner ='SYS' and object_type = 'TABLE'

Plan hash value: 729917378

----------------------------------------------------------------------------------------------------------------
| Id  | Operation	       | Name		      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |		      |        |       |    12 (100)|	       |       |       |
|   1 |  PARTITION RANGE ALL   |		      |     48 |  7488 |    12	 (0)| 00:00:01 |     1 |1048575|
|   2 |   PARTITION LIST SINGLE|		      |     48 |  7488 |    12	 (0)| 00:00:01 |   KEY |   KEY |
|*  3 |    TABLE ACCESS FULL   | TEST_RANGE_LIST_VIRT |     48 |  7488 |    12	 (0)| 00:00:01 |   KEY |   KEY |
----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("OWNER"='SYS' AND "OBJECT_TYPE"='TABLE'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1]
       , "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1]
       , "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1]
       , "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]>
	</s></h></f></q>



103 rows selected.

01:05:31 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTd%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
gf62h1qvbm7mm	   0 2367113788 	   1	       .953163	      1,513 select /* TEST_RANGE_LIST_VIRTd */ * from TEST_RANGE_LIST_VIRT
										where  begin


01:05:40 SYS@ORCL> @dplan
Enter value for sql_id: gf62h1qvbm7mm

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	gf62h1qvbm7mm, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTd */ * from TEST_RANGE_LIST_VIRT
where  begin_date >= to_date('20190501','yyyymmdd')

Plan hash value: 2367113788

-------------------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name		   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |			   |	    |	    |	442 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ALL|			   |  70922 |	 10M|	442   (1)| 00:00:01 |	  1 |1048575|
|   2 |   PARTITION LIST ALL|			   |  70922 |	 10M|	442   (1)| 00:00:01 |	  1 |	  2 |
|*  3 |    TABLE ACCESS FULL| TEST_RANGE_LIST_VIRT |  70922 |	 10M|	442   (1)| 00:00:01 |	  1 |1048575|
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE">=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1
	]]></s></h></f></q>



112 rows selected.


01:07:32 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTd0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
fvhvnbdvdkdr7	   0 2428588542 	   1	       .876827		 10 select /* TEST_RANGE_LIST_VIRTd0 */ * from TEST_RANGE_LIST_VIRT
										where  Trun


01:07:40 SYS@ORCL> 
01:07:40 SYS@ORCL> @dplan
Enter value for sql_id: fvhvnbdvdkdr7

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	fvhvnbdvdkdr7, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTd0 */ * from TEST_RANGE_LIST_VIRT
where  Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd')

Plan hash value: 2428588542

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |    35 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|  72434 |    10M|    35   (0)| 00:00:01 |   594 |1048575|
|   2 |   PARTITION LIST ALL	 |			|  72434 |    10M|    35   (0)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST_VIRT |  72434 |    10M|    35   (0)| 00:00:01 |  1187 |1048575|
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



104 rows selected.
01:10:26 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTe%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
944hu3ycv6uju	   0 2367113788 	   1	       .313592		  7 select /* TEST_RANGE_LIST_VIRTe */ * from TEST_RANGE_LIST_VIRT
										where  begin


01:10:35 SYS@ORCL> @dplan
Enter value for sql_id: 944hu3ycv6uju

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	944hu3ycv6uju, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTe */ * from TEST_RANGE_LIST_VIRT
where  begin_date <= to_date('20190501','yyyymmdd')

Plan hash value: 2367113788

-------------------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name		   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |			   |	    |	    |	442 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ALL|			   |   1643 |	250K|	442   (1)| 00:00:01 |	  1 |1048575|
|   2 |   PARTITION LIST ALL|			   |   1643 |	250K|	442   (1)| 00:00:01 |	  1 |	  2 |
|*  3 |    TABLE ACCESS FULL| TEST_RANGE_LIST_VIRT |   1643 |	250K|	442   (1)| 00:00:01 |	  1 |1048575|
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE"<=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1
	]]></s></h></f></q>



112 rows selected.

01:11:51 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTe0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
778anq9s6dct7	   0 2428588542 	   1	       .145115		  7 select /* TEST_RANGE_LIST_VIRTe0 */ * from TEST_RANGE_LIST_VIRT
										where  Trun


01:11:59 SYS@ORCL> @dplan
Enter value for sql_id: 778anq9s6dct7

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	778anq9s6dct7, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTe0 */ * from TEST_RANGE_LIST_VIRT
where  Trunc(Cast(begin_date AS DATE)) <= to_date('20190501','yyyymmdd')

Plan hash value: 2428588542

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |   446 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|  66808 |     9M|   446   (2)| 00:00:01 |     1 |   594 |
|   2 |   PARTITION LIST ALL	 |			|  66808 |     9M|   446   (2)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST_VIRT |  66808 |     9M|   446   (2)| 00:00:01 |     1 |  1188 |
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))<=TO_DATE(' 2019-05-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



104 rows selected.



01:13:43 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTf0a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
89hx9jv4bhy0u	   0  729917378 	   1	       .054812		 46 select /* TEST_RANGE_LIST_VIRTf0a */ * from TEST_RANGE_LIST_VIRT
									    where owner ='


01:14:06 SYS@ORCL> @dplan
Enter value for sql_id: 89hx9jv4bhy0u

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	89hx9jv4bhy0u, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTf0a */ * from TEST_RANGE_LIST_VIRT  where
owner ='SYS' and object_type = 'TABLE' and begin_date >=
to_date('20190501','yyyymmdd')

Plan hash value: 729917378

----------------------------------------------------------------------------------------------------------------
| Id  | Operation	       | Name		      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |		      |        |       |    12 (100)|	       |       |       |
|   1 |  PARTITION RANGE ALL   |		      |     47 |  7332 |    12	 (0)| 00:00:01 |     1 |1048575|
|   2 |   PARTITION LIST SINGLE|		      |     47 |  7332 |    12	 (0)| 00:00:01 |   KEY |   KEY |
|*  3 |    TABLE ACCESS FULL   | TEST_RANGE_LIST_VIRT |     47 |  7332 |    12	 (0)| 00:00:01 |   KEY |   KEY |
----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("OWNER"='SYS' AND "OBJECT_TYPE"='TABLE' AND "BEGIN_DATE">=TO_DATE(' 2019-05-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1]
       , "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1]
       , "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1]
       , "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]>
	</s></h></f></q>



105 rows selected.


01:28:36 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEg%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
6bknhhg7mxdxw	   0 2193080926 	   1	       .711468		 65 select /* TEST_LIST_RANGEg */ * from TEST_LIST_RANGE
									    where owner ='SYS' and obj


01:28:43 SYS@ORCL> 
01:28:47 SYS@ORCL> @dplan
Enter value for sql_id: 6bknhhg7mxdxw

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	6bknhhg7mxdxw, child number 0
-------------------------------------
select /* TEST_LIST_RANGEg */ * from TEST_LIST_RANGE  where owner
='SYS' and object_type = 'TABLE' and begin_date >=
to_date('20190501','yyyymmdd')

Plan hash value: 2193080926

----------------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		|	 |	 |    12 (100)| 	 |	 |	 |
|   1 |  PARTITION LIST SINGLE| 		|   1039 |   141K|    12   (0)| 00:00:01 |   KEY |   KEY |
|   2 |   PARTITION RANGE ALL | 		|   1039 |   141K|    12   (0)| 00:00:01 |     1 |     4 |
|*  3 |    TABLE ACCESS FULL  | TEST_LIST_RANGE |   1039 |   141K|    12   (0)| 00:00:01 |	 |	 |
----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("BEGIN_DATE">=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "OWNER"='SYS' AND "OBJECT_TYPE"='TABLE'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   2 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   3 - (rowset=137) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



102 rows selected.

01:30:37 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEh%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
1zjzp0vfrdkm3	   0  916674461 	   1	       .126466	      1,632 select /* TEST_LIST_RANGEh */ * from TEST_LIST_RANGE
									    where ( (end_date >= to_da


01:30:43 SYS@ORCL> @dplan
Enter value for sql_id: 1zjzp0vfrdkm3

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1zjzp0vfrdkm3, child number 0
-------------------------------------
select /* TEST_LIST_RANGEh */ * from TEST_LIST_RANGE  where ( (end_date
>= to_date('20210131','yyyymmdd') ) and  ( begin_date >=
to_date('20190401','yyyymmdd') )  and  ( begin_date <=
to_date('20210401','yyyymmdd') ) )

Plan hash value: 916674461

---------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |		       |	|	|   441 (100)|		|	|	|
|   1 |  PARTITION LIST ALL  |		       |   3545 |   512K|   441   (1)| 00:00:01 |     1 |     3 |
|   2 |   PARTITION RANGE ALL|		       |   3545 |   512K|   441   (1)| 00:00:01 |     1 |     4 |
|*  3 |    TABLE ACCESS FULL | TEST_LIST_RANGE |   3545 |   512K|   441   (1)| 00:00:01 |     1 |    12 |
---------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("END_DATE">=TO_DATE(' 2021-01-31 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE">=TO_DATE(' 2019-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
	      "BEGIN_DATE"<=TO_DATE(' 2021-04-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=137) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   2 - (rowset=137) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]
   3 - (rowset=137) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7], "END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]
	]></s></h></f></q>



104 rows selected.


01:31:36 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEa0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
3xvztacz2wy0b	   0  916674461 	   1	       .013120		  3 select /* TEST_LIST_RANGEa0 */ * from TEST_LIST_RANGE

01:31:41 SYS@ORCL> @dplan
Enter value for sql_id: 3xvztacz2wy0b

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	3xvztacz2wy0b, child number 0
-------------------------------------
select /* TEST_LIST_RANGEa0 */ * from TEST_LIST_RANGE

Plan hash value: 916674461

---------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |		       |	|	|   441 (100)|		|	|	|
|   1 |  PARTITION LIST ALL  |		       |  72434 |    10M|   441   (1)| 00:00:01 |     1 |     3 |
|   2 |   PARTITION RANGE ALL|		       |  72434 |    10M|   441   (1)| 00:00:01 |     1 |     4 |
|   3 |    TABLE ACCESS FULL | TEST_LIST_RANGE |  72434 |    10M|   441   (1)| 00:00:01 |     1 |    12 |
---------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=139) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   2 - (rowset=139) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   3 - (rowset=139) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]
	]></s></h></f></q>



97 rows selected.


01:35:16 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEb%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
3g2t2nc3sxu84	   0 1100521887 	   1	       .014608	      1,632 select /* TEST_LIST_RANGEb */ count(*) from TEST_LIST_RANGE

01:35:22 SYS@ORCL> @dplan
Enter value for sql_id: 3g2t2nc3sxu84

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	3g2t2nc3sxu84, child number 0
-------------------------------------
select /* TEST_LIST_RANGEb */ count(*) from TEST_LIST_RANGE

Plan hash value: 1100521887

--------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		| E-Rows | Cost (%CPU)| E-Time	 | Pstart| Pstop |
--------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		|	 |   440 (100)| 	 |	 |	 |
|   1 |  SORT AGGREGATE       | 		|      1 |	      | 	 |	 |	 |
|   2 |   PARTITION LIST ALL  | 		|  72434 |   440   (1)| 00:00:01 |     1 |     3 |
|   3 |    PARTITION RANGE ALL| 		|  72434 |   440   (1)| 00:00:01 |     1 |     4 |
|   4 |     TABLE ACCESS FULL | TEST_LIST_RANGE |  72434 |   440   (1)| 00:00:01 |     1 |    12 |
--------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   4 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (#keys=0) COUNT(*)[22]
   2 - (rowset=1019)
   3 - (rowset=1019)
   4 - (rowset=1019)

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA
	[SEL$1]]></s></h></f></q>



57 rows selected.

01:35:28 SYS@ORCL> 


01:49:56 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEc%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
71u61vswacvdy	   0  107170416 	   1	       .003531		  3 select /* TEST_LIST_RANGEc */ * from TEST_LIST_RANGE where owner ='SYS'

01:50:00 SYS@ORCL> @dplan
Enter value for sql_id: 71u61vswacvdy

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	71u61vswacvdy, child number 0
-------------------------------------
select /* TEST_LIST_RANGEc */ * from TEST_LIST_RANGE where owner ='SYS'

Plan hash value: 107170416

------------------------------------------------------------------------------------------------------------
| Id  | Operation		| Name		  | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|		  |	   |	   |   440 (100)|	   |	   |	   |
|   1 |  PARTITION LIST ITERATOR|		  |   1767 |   255K|   440   (1)| 00:00:01 |   KEY |   KEY |
|   2 |   PARTITION RANGE ALL	|		  |   1767 |   255K|   440   (1)| 00:00:01 |	 1 |	 4 |
|*  3 |    TABLE ACCESS FULL	| TEST_LIST_RANGE |   1767 |   255K|   440   (1)| 00:00:01 |	   |	   |
------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("OWNER"='SYS')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   2 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   3 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



99 rows selected.


01:50:54 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEd%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
1fxr8xjpn0ypy	   0 2193080926 	   1	       .050432		  5 select /* TEST_LIST_RANGEd */ * from TEST_LIST_RANGE where owner ='SYS' and obje

01:51:04 SYS@ORCL> @dplan
Enter value for sql_id: 1fxr8xjpn0ypy

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1fxr8xjpn0ypy, child number 0
-------------------------------------
select /* TEST_LIST_RANGEd */ * from TEST_LIST_RANGE where owner ='SYS'
and object_type = 'TABLE'

Plan hash value: 2193080926

----------------------------------------------------------------------------------------------------------
| Id  | Operation	      | Name		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      | 		|	 |	 |    12 (100)| 	 |	 |	 |
|   1 |  PARTITION LIST SINGLE| 		|   1547 |   209K|    12   (0)| 00:00:01 |   KEY |   KEY |
|   2 |   PARTITION RANGE ALL | 		|   1547 |   209K|    12   (0)| 00:00:01 |     1 |     4 |
|*  3 |    TABLE ACCESS FULL  | TEST_LIST_RANGE |   1547 |   209K|    12   (0)| 00:00:01 |	 |	 |
----------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(("OWNER"='SYS' AND "OBJECT_TYPE"='TABLE'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   2 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   3 - (rowset=138) "OWNER"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22], "OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE"."CREATED"[DATE,7], "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19], "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1], "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1], "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1], "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1], "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE"."BEGIN_DATE"[DATE,7], "TEST_LIST_RANGE"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]]
	></s></h></f></q>



100 rows selected.

01:52:20 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEe%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
195qpn7zyfcuz	   0  916674461 	   1	       .546802	      1,327 select /* TEST_LIST_RANGEe */ * from TEST_LIST_RANGE
										where  begin_date >= t


01:52:25 SYS@ORCL> @dplan
Enter value for sql_id: 195qpn7zyfcuz

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	195qpn7zyfcuz, child number 0
-------------------------------------
select /* TEST_LIST_RANGEe */ * from TEST_LIST_RANGE	  where
begin_date >= to_date('20190501','yyyymmdd')

Plan hash value: 916674461

---------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |		       |	|	|   441 (100)|		|	|	|
|   1 |  PARTITION LIST ALL  |		       |  70922 |    10M|   441   (1)| 00:00:01 |     1 |     3 |
|   2 |   PARTITION RANGE ALL|		       |  70922 |    10M|   441   (1)| 00:00:01 |     1 |     4 |
|*  3 |    TABLE ACCESS FULL | TEST_LIST_RANGE |  70922 |    10M|   441   (1)| 00:00:01 |     1 |    12 |
---------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE">=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]
	]></s></h></f></q>



103 rows selected.
01:52:31 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEf%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
3rsvx4a117774	   0 3016304839 	   1	       .003319		  3 select /* TEST_LIST_RANGEf */ * from TEST_LIST_RANGE
										where  begin_date <= t


01:53:55 SYS@ORCL> @dplan
Enter value for sql_id: 3rsvx4a117774

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	3rsvx4a117774, child number 0
-------------------------------------
select /* TEST_LIST_RANGEf */ * from TEST_LIST_RANGE	  where
begin_date <= to_date('20190501','yyyymmdd')

Plan hash value: 3016304839

------------------------------------------------------------------------------------------------------------
| Id  | Operation		| Name		  | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|		  |	   |	   |   441 (100)|	   |	   |	   |
|   1 |  PARTITION LIST ALL	|		  |   1643 |   237K|   441   (1)| 00:00:01 |	 1 |	 3 |
|   2 |   PARTITION RANGE SINGLE|		  |   1643 |   237K|   441   (1)| 00:00:01 |	 1 |	 1 |
|*  3 |    TABLE ACCESS FULL	| TEST_LIST_RANGE |   1643 |   237K|   441   (1)| 00:00:01 |	   |	   |
------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE"<=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



103 rows selected.
01:56:32 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEf0a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
7wy9zmrsug1z3	   0  916674461 	   1	       .054941		 11 select /* TEST_LIST_RANGEf0a */ * from TEST_LIST_RANGE
										where  Trunc(Cast(be


01:56:39 SYS@ORCL> @dplan
Enter value for sql_id: 7wy9zmrsug1z3

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	7wy9zmrsug1z3, child number 0
-------------------------------------
select /* TEST_LIST_RANGEf0a */ * from TEST_LIST_RANGE	    where
Trunc(Cast(begin_date AS DATE)) <= to_date('20190501','yyyymmdd')

Plan hash value: 916674461

---------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |		       |	|	|   445 (100)|		|	|	|
|   1 |  PARTITION LIST ALL  |		       |   3622 |   523K|   445   (2)| 00:00:01 |     1 |     3 |
|   2 |   PARTITION RANGE ALL|		       |   3622 |   523K|   445   (2)| 00:00:01 |     1 |     4 |
|*  3 |    TABLE ACCESS FULL | TEST_LIST_RANGE |   3622 |   523K|   445   (2)| 00:00:01 |     1 |    12 |
---------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))<=TO_DATE(' 2019-05-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]
	]></s></h></f></q>



104 rows selected.

01:58:34 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGEe0a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
58thv8jzvc8k4	   0  916674461 	   1	      1.045142	      1,327 select /* TEST_LIST_RANGEe0a */ * from TEST_LIST_RANGE
										where  Trunc(Cast(be


01:58:41 SYS@ORCL> 
01:58:42 SYS@ORCL> 
01:58:42 SYS@ORCL> @dplan
Enter value for sql_id: 58thv8jzvc8k4

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	58thv8jzvc8k4, child number 0
-------------------------------------
select /* TEST_LIST_RANGEe0a */ * from TEST_LIST_RANGE	    where
Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd')

Plan hash value: 916674461

---------------------------------------------------------------------------------------------------------
| Id  | Operation	     | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |		       |	|	|   445 (100)|		|	|	|
|   1 |  PARTITION LIST ALL  |		       |   3622 |   523K|   445   (2)| 00:00:01 |     1 |     3 |
|   2 |   PARTITION RANGE ALL|		       |   3622 |   523K|   445   (2)| 00:00:01 |     1 |     4 |
|*  3 |    TABLE ACCESS FULL | TEST_LIST_RANGE |   3622 |   523K|   445   (2)| 00:00:01 |     1 |    12 |
---------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_LIST_RANGE"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_NAME"[VARCHAR2,128], "TEST_LIST_RANGE"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE"."CREATED"[DATE,7],
       "TEST_LIST_RANGE"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_LIST_RANGE"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE"."DEFAULT_COLLATION"[VARCHAR2,100], "TEST_LIST_RANGE"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE"."SHARDED"[VARCHAR2,1], "TEST_LIST_RANGE"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."CREATED_VSNID"[NUMBER,22], "TEST_LIST_RANGE"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE]]></t><s><![CDATA[SEL$1]
	]></s></h></f></q>



104 rows selected.


02:02:05 SYS@ORCL> 02:02:05 SYS@ORCL> 02:02:05 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTd0a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
0145srmxucy79	   0 1209238144 	   1	      3.558019		467 select /* TEST_RANGE_LISTd0a */ * from TEST_RANGE_LIST
										where  Trunc(Cast(be


02:02:13 SYS@ORCL> 
02:02:14 SYS@ORCL> @dplan
Enter value for sql_id: 0145srmxucy79

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	0145srmxucy79, child number 0
-------------------------------------
select /* TEST_RANGE_LISTd0a */ * from TEST_RANGE_LIST	    where
Trunc(Cast(begin_date AS DATE)) <= to_date('20190501','yyyymmdd')

Plan hash value: 1209238144

--------------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |		      |        |       |   888 (100)|	       |       |       |
|   1 |  PARTITION RANGE ALL|		      |   7243 |  1046K|   888	 (2)| 00:00:01 |     1 |1048575|
|   2 |   PARTITION LIST ALL|		      |   7243 |  1046K|   888	 (2)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL| TEST_RANGE_LIST |   7243 |  1046K|   888	 (2)| 00:00:01 |     1 |1048575|
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))<=TO_DATE(' 2019-05-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1
	]]></s></h></f></q>



104 rows selected.


02:04:51 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LISTc0a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
f4qpp333yumnh	   0 1209238144 	   1	       .744127	      2,999 select /* TEST_RANGE_LISTc0a */ * from TEST_RANGE_LIST
										where  Trunc(Cast(be


02:04:57 SYS@ORCL> @dplan
Enter value for sql_id: f4qpp333yumnh

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	f4qpp333yumnh, child number 0
-------------------------------------
select /* TEST_RANGE_LISTc0a */ * from TEST_RANGE_LIST	    where
Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd')

Plan hash value: 1209238144

--------------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |		      |        |       |   888 (100)|	       |       |       |
|   1 |  PARTITION RANGE ALL|		      |   7243 |  1046K|   888	 (2)| 00:00:01 |     1 |1048575|
|   2 |   PARTITION LIST ALL|		      |   7243 |  1046K|   888	 (2)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL| TEST_RANGE_LIST |   7243 |  1046K|   888	 (2)| 00:00:01 |     1 |1048575|
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01
	      00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST"."CREATED"[DATE,7],
       "TEST_RANGE_LIST"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST]]></t><s><![CDATA[SEL$1
	]]></s></h></f></q>



104 rows selected.

02:15:23 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTd0ab%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
8am79xbyh23fm	   0 2367113788 	   1	       .510863	      1,675 select /* TEST_RANGE_LIST_VIRTd0ab */ * from TEST_RANGE_LIST_VIRT
										where  be


02:15:28 SYS@ORCL> @dplan
Enter value for sql_id: 8am79xbyh23fm

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	8am79xbyh23fm, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTd0ab */ * from TEST_RANGE_LIST_VIRT
where  begin_date >= to_date('20190501','yyyymmdd')

Plan hash value: 2367113788

-------------------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name		   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |			   |	    |	    |	442 (100)|	    |	    |	    |
|   1 |  PARTITION RANGE ALL|			   |  70922 |	 10M|	442   (1)| 00:00:01 |	  1 |1048575|
|   2 |   PARTITION LIST ALL|			   |  70922 |	 10M|	442   (1)| 00:00:01 |	  1 |	  2 |
|*  3 |    TABLE ACCESS FULL| TEST_RANGE_LIST_VIRT |  70922 |	 10M|	442   (1)| 00:00:01 |	  1 |1048575|
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("BEGIN_DATE">=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2
       ,100], "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1
	]]></s></h></f></q>



112 rows selected.


02:21:50 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTe0ab%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
69xfz9zf5q8b0	   0 1433469910 	   1	       .120260		 10 select /* TEST_RANGE_LIST_VIRTe0ab */ * from TEST_RANGE_LIST_VIRT
										where  be


02:21:56 SYS@ORCL> @dplan
Enter value for sql_id: 69xfz9zf5q8b0

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	69xfz9zf5q8b0, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTe0ab */ * from TEST_RANGE_LIST_VIRT
where  begin_date <= to_date('20190501','yyyymmdd')

Plan hash value: 1433469910

-----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation				    | Name		       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT			    |			       |	|	|    52 (100)|		|	|	|
|   1 |  PARTITION HASH ALL			    |			       |   1643 |   250K|    52   (0)| 00:00:01 |     1 |    32 |
|   2 |   TABLE ACCESS BY GLOBAL INDEX ROWID BATCHED| TEST_RANGE_LIST_VIRT     |   1643 |   250K|    52   (0)| 00:00:01 | ROWID | ROWID |
|*  3 |    INDEX RANGE SCAN			    | TEST_RANGE_LIST_VIRT_IDX |   1643 |	|     7   (0)| 00:00:01 |     1 |    32 |
-----------------------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      INDEX_RS_ASC(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1" ("TEST_RANGE_LIST_VIRT"."BEGIN_DATE"))
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("BEGIN_DATE"<=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - "TEST_RANGE_LIST_VIRT".ROWID[ROWID,10], "BEGIN_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></s></h></f></q>



88 rows selected.

02:44:46 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTd0abc%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
2ctkg9ca4hb44	   0 1433469910 	   1	       .041827		  8 select /* TEST_RANGE_LIST_VIRTd0abc */ * from TEST_RANGE_LIST_VIRT
										where  b


02:44:55 SYS@ORCL> @dplan
Enter value for sql_id: 2ctkg9ca4hb44

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	2ctkg9ca4hb44, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTd0abc */ * from TEST_RANGE_LIST_VIRT
where  begin_date >= to_date('20190501','yyyymmdd')

Plan hash value: 1433469910

-----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation				    | Name		       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT			    |			       |	|	|   245 (100)|		|	|	|
|   1 |  PARTITION HASH ALL			    |			       |   5717 |   870K|   245   (0)| 00:00:01 |     1 |    32 |
|   2 |   TABLE ACCESS BY GLOBAL INDEX ROWID BATCHED| TEST_RANGE_LIST_VIRT     |   5717 |   870K|   245   (0)| 00:00:01 | ROWID | ROWID |
|*  3 |    INDEX RANGE SCAN			    | TEST_RANGE_LIST_VIRT_IDX |   5717 |	|    27   (0)| 00:00:01 |     1 |    32 |
-----------------------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      INDEX_RS_ASC(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1" ("TEST_RANGE_LIST_VIRT"."BEGIN_DATE" "TEST_RANGE_LIST_VIRT"."END_DATE"))
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("BEGIN_DATE">=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND "BEGIN_DATE" IS NOT NULL)

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7], "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19], "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7],
       "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18],
       "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - "TEST_RANGE_LIST_VIRT".ROWID[ROWID,10], "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></s></h></f></q>



88 rows selected.


12:53:44 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wa2a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
1k6y0jaj8s3mr	   0  367917378 	   1	      1.695543		  9 select /* 22xqv11u52m5wa2a */ * from PartitionedTable where PartitionKey ='200'

12:54:03 SYS@ORCL> @dplan
Enter value for sql_id: 1k6y0jaj8s3mr

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	1k6y0jaj8s3mr, child number 0
-------------------------------------
select /* 22xqv11u52m5wa2a */ * from PartitionedTable where
PartitionKey ='200'

Plan hash value: 367917378

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		       |	|	|     2 (100)|		|	|	|
|   1 |  PARTITION LIST MULTI-COLUMN|		       |      1 |    97 |     2   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|*  2 |   TABLE ACCESS FULL	    | PARTITIONEDTABLE |      1 |    97 |     2   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
-----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("PARTITIONKEY"='200')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



60 rows selected.


12:57:57 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wb2b%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
cmw0xdjz2sv6n	   0 1130779953 	   1	       .004199		 28 select /* 22xqv11u52m5wb2b */ * from PartitionedTable
										where  created >= to_d


12:58:05 SYS@ORCL> @dplan
Enter value for sql_id: cmw0xdjz2sv6n

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	cmw0xdjz2sv6n, child number 0
-------------------------------------
select /* 22xqv11u52m5wb2b */ * from PartitionedTable	  where
created >= to_date('19920101','yyyymmdd')

Plan hash value: 1130779953

--------------------------------------------------------------------------------------------------------
| Id  | Operation	   | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |		      |        |       |     3 (100)|	       |       |       |
|   1 |  PARTITION LIST ALL|		      |      1 |    97 |     3	 (0)| 00:00:01 |     1 |     4 |
|*  2 |   TABLE ACCESS FULL| PARTITIONEDTABLE |      1 |    97 |     3	 (0)| 00:00:01 |     1 |     4 |
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CREATED">=TO_DATE(' 1992-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$
	1]]></s></h></f></q>



62 rows selected.





12:59:00 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wc2c%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
cjmbxd4rd0qwz	   0 1130779953 	   1	       .042971		 28 select /* 22xqv11u52m5wc2c */ * from PartitionedTable
										where  created <= to_d


12:59:05 SYS@ORCL> @dplan
Enter value for sql_id: cjmbxd4rd0qwz

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	cjmbxd4rd0qwz, child number 0
-------------------------------------
select /* 22xqv11u52m5wc2c */ * from PartitionedTable	  where
created <= to_date('19980101','yyyymmdd')

Plan hash value: 1130779953

--------------------------------------------------------------------------------------------------------
| Id  | Operation	   | Name	      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |		      |        |       |     3 (100)|	       |       |       |
|   1 |  PARTITION LIST ALL|		      |      2 |   194 |     3	 (0)| 00:00:01 |     1 |     4 |
|*  2 |   TABLE ACCESS FULL| PARTITIONEDTABLE |      2 |   194 |     3	 (0)| 00:00:01 |     1 |     4 |
--------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CREATED"<=TO_DATE(' 1998-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$
	1]]></s></h></f></q>



62 rows selected.


12:59:38 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wd2d%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
0kbp67ujg7y56	   0  367917378 	   1	       .054184		  7 select /* 22xqv11u52m5wd2d */ * from PartitionedTable
									    where PartitionKey ='9'
									    an


12:59:46 SYS@ORCL> @dplan
Enter value for sql_id: 0kbp67ujg7y56

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	0kbp67ujg7y56, child number 0
-------------------------------------
select /* 22xqv11u52m5wd2d */ * from PartitionedTable where
PartitionKey ='9' and created >= to_date('20180101','yyyymmdd')

Plan hash value: 367917378

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		       |	|	|     2 (100)|		|	|	|
|   1 |  PARTITION LIST MULTI-COLUMN|		       |      1 |    97 |     2   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|*  2 |   TABLE ACCESS FULL	    | PARTITIONEDTABLE |      1 |    97 |     2   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
-----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("PARTITIONKEY"='9' AND "CREATED">=TO_DATE(' 2018-01-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



61 rows selected.


13:12:33 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wa2a1%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
35nrrd3pyrsuj	   0  367917378 	   1	       .058392		  9 select /* 22xqv11u52m5wa2a1 */ * from PartitionedTable where PartitionKey ='200'

13:12:43 SYS@ORCL> @dplan
Enter value for sql_id: 35nrrd3pyrsuj

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	35nrrd3pyrsuj, child number 0
-------------------------------------
select /* 22xqv11u52m5wa2a1 */ * from PartitionedTable where
PartitionKey ='200'

Plan hash value: 367917378

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		       |	|	|     2 (100)|		|	|	|
|   1 |  PARTITION LIST MULTI-COLUMN|		       |      1 |    97 |     2   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|*  2 |   TABLE ACCESS FULL	    | PARTITIONEDTABLE |      1 |    97 |     2   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
-----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("PARTITIONKEY"='200')

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



60 rows selected.

13:14:24 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wb2b1%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
5m59m5nxnwz7h	   0  939649965 	   1	       .013240		 24 select /* 22xqv11u52m5wb2b1 */ * from PartitionedTable
										where  created >= to_


13:14:33 SYS@ORCL> @dplan
Enter value for sql_id: 5m59m5nxnwz7h

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	5m59m5nxnwz7h, child number 0
-------------------------------------
select /* 22xqv11u52m5wb2b1 */ * from PartitionedTable	   where
created >= to_date('19920101','yyyymmdd')

Plan hash value: 939649965

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		| Name		   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|		   |	    |	    |	  3 (100)|	    |	    |	    |
|   1 |  PARTITION LIST ITERATOR|		   |	  1 |	 97 |	  3   (0)| 00:00:01 |	KEY |	KEY |
|*  2 |   TABLE ACCESS FULL	| PARTITIONEDTABLE |	  1 |	 97 |	  3   (0)| 00:00:01 |	KEY |	KEY |
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CREATED">=TO_DATE(' 1992-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



62 rows selected.


13:15:36 SYS@ORCL> 
13:15:37 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wc2c1%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
cfyhddy58n920	   0  939649965 	   1	       .056462		 22 select /* 22xqv11u52m5wc2c1 */ * from PartitionedTable
										where  created <= to_


13:15:44 SYS@ORCL> @dplan
Enter value for sql_id: cfyhddy58n920

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	cfyhddy58n920, child number 0
-------------------------------------
select /* 22xqv11u52m5wc2c1 */ * from PartitionedTable	   where
created <= to_date('19980101','yyyymmdd')

Plan hash value: 939649965

-------------------------------------------------------------------------------------------------------------
| Id  | Operation		| Name		   | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|		   |	    |	    |	  3 (100)|	    |	    |	    |
|   1 |  PARTITION LIST ITERATOR|		   |	  2 |	194 |	  3   (0)| 00:00:01 |	KEY |	KEY |
|*  2 |   TABLE ACCESS FULL	| PARTITIONEDTABLE |	  2 |	194 |	  3   (0)| 00:00:01 |	KEY |	KEY |
-------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("CREATED"<=TO_DATE(' 1998-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22],
       "PARTITIONEDTABLE"."PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



62 rows selected.


13:16:31 SYS@ORCL> 
13:16:31 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %22xqv11u52m5wd2d1%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
4xxuycaygzqbs	   0  367917378 	   1	       .011227		 19 select /* 22xqv11u52m5wd2d1 */ * from PartitionedTable
									    where PartitionKey ='9'
									    a


13:16:38 SYS@ORCL> 
13:16:39 SYS@ORCL> @dplan
Enter value for sql_id: 4xxuycaygzqbs

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	4xxuycaygzqbs, child number 0
-------------------------------------
select /* 22xqv11u52m5wd2d1 */ * from PartitionedTable where
PartitionKey ='9' and created >= to_date('20180101','yyyymmdd')

Plan hash value: 367917378

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation		    | Name	       | E-Rows |E-Bytes| Cost (%CPU)| E-Time	| Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	    |		       |	|	|     3 (100)|		|	|	|
|   1 |  PARTITION LIST MULTI-COLUMN|		       |      1 |    97 |     3   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
|*  2 |   TABLE ACCESS FULL	    | PARTITIONEDTABLE |      1 |    97 |     3   (0)| 00:00:01 |KEY(MC)|KEY(MC)|
-----------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / PARTITIONEDTABLE@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "PARTITIONEDTABLE"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(("PARTITIONKEY"='9' AND "CREATED">=TO_DATE(' 2018-01-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss')))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]
   2 - (rowset=256) "PARTITIONEDTABLE"."ID"[NUMBER,22], "PARTITIONKEY"[VARCHAR2,128], "CREATED"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[PARTITIONEDTABLE]]></t><s><![CDATA[SEL$1]]></s><
	/h></f></q>



61 rows selected.


15:15:00 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGE_AUTO_VIRTd%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
a65p8s82svc75	   0 2702690513 	   1	    209.038185		290 select /* TEST_LIST_RANGE_AUTO_VIRTd */ * from TEST_LIST_RANGE_AUTO_VIRT
										wh


15:15:08 SYS@ORCL> @dplan
Enter value for sql_id: a65p8s82svc75

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	a65p8s82svc75, child number 0
-------------------------------------
select /* TEST_LIST_RANGE_AUTO_VIRTd */ * from
TEST_LIST_RANGE_AUTO_VIRT      where  Trunc(Cast(begin_date AS DATE))
>= to_date('20190501','yyyymmdd')

Plan hash value: 2702690513

----------------------------------------------------------------------------------------------------------------------
| Id  | Operation		| Name			    | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|			    |	     |	     |	  65 (100)|	     |	     |	     |
|   1 |  PARTITION LIST ITERATOR|			    |  72434 |	  10M|	  65   (2)| 00:00:01 |	 KEY |	 KEY |
|*  2 |   TABLE ACCESS FULL	| TEST_LIST_RANGE_AUTO_VIRT |  72434 |	  10M|	  65   (2)| 00:00:01 |	 KEY |	 KEY |
----------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / TEST_LIST_RANGE_AUTO_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE_AUTO_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE_AUTO_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE_AUTO_VIRT"."CREATED"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE_AUTO_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE_AUTO_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE_AUTO_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE_AUTO_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE_AUTO_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE_AUTO_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE_AUTO_VIRT"."CREATED"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE_AUTO_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE_AUTO_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE_AUTO_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE_AUTO_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE_AUTO_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE_AUTO_VIRT]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



97 rows selected.


15:16:07 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTd0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
fvhvnbdvdkdr7	   0 2428588542 	   1	     33.628897		988 select /* TEST_RANGE_LIST_VIRTd0 */ * from TEST_RANGE_LIST_VIRT
										where  Trun


15:16:14 SYS@ORCL> 
15:16:15 SYS@ORCL> 
15:16:15 SYS@ORCL> @dplan
Enter value for sql_id: fvhvnbdvdkdr7

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	fvhvnbdvdkdr7, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTd0 */ * from TEST_RANGE_LIST_VIRT
where  Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd')

Plan hash value: 2428588542

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |    35 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|   5626 |   857K|    35   (0)| 00:00:01 |   594 |1048575|
|   2 |   PARTITION LIST ALL	 |			|   5626 |   857K|    35   (0)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST_VIRT |   5626 |   857K|    35   (0)| 00:00:01 |  1187 |1048575|
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



104 rows selected.



15:15:00 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGE_AUTO_VIRTd%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
a65p8s82svc75	   0 2702690513 	   1	    209.038185		290 select /* TEST_LIST_RANGE_AUTO_VIRTd */ * from TEST_LIST_RANGE_AUTO_VIRT
										wh


15:15:08 SYS@ORCL> @dplan
Enter value for sql_id: a65p8s82svc75

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	a65p8s82svc75, child number 0
-------------------------------------
select /* TEST_LIST_RANGE_AUTO_VIRTd */ * from
TEST_LIST_RANGE_AUTO_VIRT      where  Trunc(Cast(begin_date AS DATE))
>= to_date('20190501','yyyymmdd')

Plan hash value: 2702690513

----------------------------------------------------------------------------------------------------------------------
| Id  | Operation		| Name			    | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	|			    |	     |	     |	  65 (100)|	     |	     |	     |
|   1 |  PARTITION LIST ITERATOR|			    |  72434 |	  10M|	  65   (2)| 00:00:01 |	 KEY |	 KEY |
|*  2 |   TABLE ACCESS FULL	| TEST_LIST_RANGE_AUTO_VIRT |  72434 |	  10M|	  65   (2)| 00:00:01 |	 KEY |	 KEY |
----------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / TEST_LIST_RANGE_AUTO_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE_AUTO_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE_AUTO_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE_AUTO_VIRT"."CREATED"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE_AUTO_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE_AUTO_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE_AUTO_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE_AUTO_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE_AUTO_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_LIST_RANGE_AUTO_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_LIST_RANGE_AUTO_VIRT"."CREATED"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT"."STATUS"[VARCHAR2,7], "TEST_LIST_RANGE_AUTO_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."GENERATED"[VARCHAR2,1], "TEST_LIST_RANGE_AUTO_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."NAMESPACE"[NUMBER,22], "TEST_LIST_RANGE_AUTO_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT"."SHARING"[VARCHAR2,18], "TEST_LIST_RANGE_AUTO_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_LIST_RANGE_AUTO_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE_AUTO_VIRT]]></t><s><![CDATA[SEL$1]]><
	/s></h></f></q>



97 rows selected.

15:15:15 SYS@ORCL> 
15:16:07 SYS@ORCL> 
15:16:07 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_RANGE_LIST_VIRTd0%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
fvhvnbdvdkdr7	   0 2428588542 	   1	     33.628897		988 select /* TEST_RANGE_LIST_VIRTd0 */ * from TEST_RANGE_LIST_VIRT
										where  Trun


15:16:14 SYS@ORCL> 
15:16:15 SYS@ORCL> 
15:16:15 SYS@ORCL> @dplan
Enter value for sql_id: fvhvnbdvdkdr7

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	fvhvnbdvdkdr7, child number 0
-------------------------------------
select /* TEST_RANGE_LIST_VIRTd0 */ * from TEST_RANGE_LIST_VIRT
where  Trunc(Cast(begin_date AS DATE)) >= to_date('20190501','yyyymmdd')

Plan hash value: 2428588542

------------------------------------------------------------------------------------------------------------------
| Id  | Operation		 | Name 		| E-Rows |E-Bytes| Cost (%CPU)| E-Time	 | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT	 |			|	 |	 |    35 (100)| 	 |	 |	 |
|   1 |  PARTITION RANGE ITERATOR|			|   5626 |   857K|    35   (0)| 00:00:01 |   594 |1048575|
|   2 |   PARTITION LIST ALL	 |			|   5626 |   857K|    35   (0)| 00:00:01 |     1 |     2 |
|*  3 |    TABLE ACCESS FULL	 | TEST_RANGE_LIST_VIRT |   5626 |   857K|    35   (0)| 00:00:01 |  1187 |1048575|
------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_RANGE_LIST_VIRT@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_RANGE_LIST_VIRT"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_RANGE_LIST_VIRT"."OWNER"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."OBJECT_NAME"[VARCHAR2,128], "TEST_RANGE_LIST_VIRT"."SUBOBJECT_NAME"[VARCHAR2,128],
	"TEST_RANGE_LIST_VIRT"."OBJECT_ID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."OBJECT_TYPE"[VARCHAR2,23], "TEST_RANGE_LIST_VIRT"."CREATED"[DATE,7],
       "TEST_RANGE_LIST_VIRT"."LAST_DDL_TIME"[DATE,7], "TEST_RANGE_LIST_VIRT"."TIMESTAMP"[VARCHAR2,19],
       "TEST_RANGE_LIST_VIRT"."STATUS"[VARCHAR2,7], "TEST_RANGE_LIST_VIRT"."TEMPORARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."GENERATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SECONDARY"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."NAMESPACE"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."EDITION_NAME"[VARCHAR2,128],
       "TEST_RANGE_LIST_VIRT"."SHARING"[VARCHAR2,18], "TEST_RANGE_LIST_VIRT"."EDITIONABLE"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."ORACLE_MAINTAINED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."APPLICATION"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_RANGE_LIST_VIRT"."DUPLICATED"[VARCHAR2,1], "TEST_RANGE_LIST_VIRT"."SHARDED"[VARCHAR2,1],
       "TEST_RANGE_LIST_VIRT"."CREATED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."CREATED_VSNID"[NUMBER,22],
       "TEST_RANGE_LIST_VIRT"."MODIFIED_APPID"[NUMBER,22], "TEST_RANGE_LIST_VIRT"."MODIFIED_VSNID"[NUMBER,22],
       "BEGIN_DATE"[DATE,7], "TEST_RANGE_LIST_VIRT"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_RANGE_LIST_VIRT]]></t><s><![CDATA[SEL$1]]></
	s></h></f></q>



104 rows selected.


00:17:01 SYS@ORCL> 
00:17:01 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGE_AUTO_VIRT_MONTHd1a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
dwty7z622ypz2	   0 3634996883 	   1	       .871381	      1,059 select /* TEST_LIST_RANGE_AUTO_VIRT_MONTHd1a */ * from TEST_LIST_RANGE_AUTO_VIRT

00:17:07 SYS@ORCL> 
00:17:07 SYS@ORCL> 
00:17:08 SYS@ORCL> @dplan
Enter value for sql_id: dwty7z622ypz2

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	dwty7z622ypz2, child number 0
-------------------------------------
select /* TEST_LIST_RANGE_AUTO_VIRT_MONTHd1a */ * from
TEST_LIST_RANGE_AUTO_VIRT_MONTH      where  Trunc(Cast(begin_date AS
DATE)) >= to_date('20190501','yyyymmdd')

Plan hash value: 3634996883

-----------------------------------------------------------------------------------------------------------------------
| Id  | Operation	   | Name			     | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |				     |	      |       |   178 (100)|	      |       |       |
|   1 |  PARTITION LIST ALL|				     |	 2180 |  1081K|   178	(1)| 00:00:01 |     1 |   323 |
|*  2 |   TABLE ACCESS FULL| TEST_LIST_RANGE_AUTO_VIRT_MONTH |	 2180 |  1081K|   178	(1)| 00:00:01 |     1 |   323 |
-----------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / TEST_LIST_RANGE_AUTO_VIRT_MONTH@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE_AUTO_VIRT_MONTH"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."LAST_DDL_TIME"[DATE,7],
	"TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."LAST_DDL_TIME"[DATE,7],
	"TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."END_DATE"[DATE,7]

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE_AUTO_VIRT_MONTH]]></t><s><![CDATA[SEL$
	1]]></s></h></f></q>



112 rows selected.

00:17:14 SYS@ORCL> 
00:24:31 SYS@ORCL> 
00:24:31 SYS@ORCL> 
00:24:31 SYS@ORCL> 
00:24:32 SYS@ORCL> 
00:24:32 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGE_AUTO_VIRT_MONTHd1b%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
9hxx8w03195nc	   0 3634996883 	   1	       .053035		592 select /* TEST_LIST_RANGE_AUTO_VIRT_MONTHd1b */ * from TEST_LIST_RANGE_AUTO_VIRT

00:24:38 SYS@ORCL> @dplan 
Enter value for sql_id: 9hxx8w03195nc

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	9hxx8w03195nc, child number 0
-------------------------------------
select /* TEST_LIST_RANGE_AUTO_VIRT_MONTHd1b */ * from
TEST_LIST_RANGE_AUTO_VIRT_MONTH      where  Trunc(Cast(begin_date AS
DATE)) >= to_date('20190501','yyyymmdd')

Plan hash value: 3634996883

-----------------------------------------------------------------------------------------------------------------------
| Id  | Operation	   | Name			     | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |				     |	      |       |   520 (100)|	      |       |       |
|   1 |  PARTITION LIST ALL|				     |	 3622 |   551K|   520	(2)| 00:00:01 |     1 |   323 |
|*  2 |   TABLE ACCESS FULL| TEST_LIST_RANGE_AUTO_VIRT_MONTH |	 3622 |   551K|   520	(2)| 00:00:01 |     1 |   323 |
-----------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   2 - SEL$1 / TEST_LIST_RANGE_AUTO_VIRT_MONTH@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE_AUTO_VIRT_MONTH"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(TRUNC(CAST(INTERNAL_FUNCTION("BEGIN_DATE") AS DATE))>=TO_DATE(' 2019-05-01 00:00:00',
	      'syyyy-mm-dd hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."LAST_DDL_TIME"[DATE,7],
	"TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."LAST_DDL_TIME"[DATE,7],
	"TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE_AUTO_VIRT_MONTH]]></t><s><![CDATA[SEL$
	1]]></s></h></f></q>



111 rows selected.


12:52:30 SYS@ORCL> @find_sql
Enter value for sql_fulltext: %TEST_LIST_RANGE_AUTO_VIRT_MONTHd3b1a%
Enter value for sql_id: 

SQL_ID	       CHILD  PLAN_HASH        EXECS	     AVG_ETIME	    AVG_LIO SUBSTR(SQL_FULLTEXT,1,4000)
------------- ------ ---------- ------------ ----------------- ------------ --------------------------------------------------------------------------------
88yz26rygfxfc	   0   18046442 	   1	       .455272	      1,839 select /* TEST_LIST_RANGE_AUTO_VIRT_MONTHd3b1a */ * from TEST_LIST_RANGE_AUTO_VI

12:52:37 SYS@ORCL> @dplan
Enter value for sql_id: 88yz26rygfxfc

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID	88yz26rygfxfc, child number 0
-------------------------------------
select /* TEST_LIST_RANGE_AUTO_VIRT_MONTHd3b1a */ * from
TEST_LIST_RANGE_AUTO_VIRT_MONTH      where  Trunc(Cast(SYSDATE AS
DATE),'MONTH') >= to_date('20190501','yyyymmdd')

Plan hash value: 18046442

------------------------------------------------------------------------------------------------------------------------
| Id  | Operation	    | Name			      | E-Rows |E-Bytes| Cost (%CPU)| E-Time   | Pstart| Pstop |
------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |				      |        |       |   516 (100)|	       |       |       |
|*  1 |  FILTER 	    |				      |        |       |	    |	       |       |       |
|   2 |   PARTITION LIST ALL|				      |  72434 |    10M|   516	 (1)| 00:00:01 |     1 |   323 |
|   3 |    TABLE ACCESS FULL| TEST_LIST_RANGE_AUTO_VIRT_MONTH |  72434 |    10M|   516	 (1)| 00:00:01 |     1 |   323 |
------------------------------------------------------------------------------------------------------------------------

Query Block Name / Object Alias (identified by operation id):
-------------------------------------------------------------

   1 - SEL$1
   3 - SEL$1 / TEST_LIST_RANGE_AUTO_VIRT_MONTH@SEL$1

Outline Data
-------------

  /*+
      BEGIN_OUTLINE_DATA
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('19.1.0')
      DB_VERSION('19.1.0')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$1")
      FULL(@"SEL$1" "TEST_LIST_RANGE_AUTO_VIRT_MONTH"@"SEL$1")
      END_OUTLINE_DATA
  */

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(TRUNC(CAST(SYSDATE@! AS DATE),'fmmonth')>=TO_DATE(' 2019-05-01 00:00:00', 'syyyy-mm-dd
	      hh24:mi:ss'))

Column Projection Information (identified by operation id):
-----------------------------------------------------------

   1 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."END_DATE"[DATE,7]
   2 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."END_DATE"[DATE,7]
   3 - (rowset=138) "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OWNER"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SUBOBJECT_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DATA_OBJECT_ID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."OBJECT_TYPE"[VARCHAR2,23],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED"[DATE,7], "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."LAST_DDL_TIME"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TIMESTAMP"[VARCHAR2,19],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."STATUS"[VARCHAR2,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."TEMPORARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."GENERATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SECONDARY"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."NAMESPACE"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITION_NAME"[VARCHAR2,128],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARING"[VARCHAR2,18],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."EDITIONABLE"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."ORACLE_MAINTAINED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."APPLICATION"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DEFAULT_COLLATION"[VARCHAR2,100],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."DUPLICATED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."SHARDED"[VARCHAR2,1],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."CREATED_VSNID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_APPID"[NUMBER,22],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."MODIFIED_VSNID"[NUMBER,22], "BEGIN_DATE"[DATE,7],
       "TEST_LIST_RANGE_AUTO_VIRT_MONTH"."END_DATE"[DATE,7]

Note
-----
   - Warning: basic plan statistics not available. These are only collected when:
       * hint 'gather_plan_statistics' is used for the statement or
       * parameter 'statistics_level' is set to 'ALL', at session or system level

Query Block Registry:
---------------------

  <q o="2" f="y"><n><![CDATA[SEL$1]]></n><f><h><t><![CDATA[TEST_LIST_RANGE_AUTO_VIRT_MONTH]]></t><s><![CDATA[SEL$1
	]]></s></h></f></q>



138 rows selected.

