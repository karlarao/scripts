----------------------------------------------------------------------------------------
--
-- File name:   diff_predicates.sql
--
-- Purpose:     Identify mismatched predicates between multiple child cursors in 
--              the cursor cache.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for a SQL_ID.
--
-- Description:
--
--              Based on a blog post by Randolf Giest.
-- http://oracle-randolf.blogspot.com/2009/07/planhashvalue-how-equal-and-stable-are_26.html
--
-- Mods:        This is the 2nd version of this script. Formating is better now.
--
-- Notes:       12c introduces some funkiness to the line number of the plan when 
--              Adaptive Optimization kicks in. Use dplan_adaptive.sql to see actual
--              plan line numbers for adaptive plans.
--
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
col access_predicates format a40 word_wrapped
col filter_predicates format a40 word_wrapped

break on sql_id skip 2 on plan_hash_value skip 1

set pages 100
set lines 4000

with stmts as
(
select sql_id, plan_hash_value, child_number
from
(
select sql_id, plan_hash_value, child_number, 
		count(child_number) over (partition by sql_id, plan_hash_value) ct_cno
from v$sql 
where sql_id like ('&sql_id')
)
where ct_cno > 1
) 
,
plan_steps as
(
select  sql_id, plan_hash_value, id, access_predicates, filter_predicates, 
		count(id) ct_steps  
from	v$sql_plan
where 	(sql_id, plan_hash_value, child_number) IN (select * from stmts)
group by sql_id, plan_hash_value, id, access_predicates, filter_predicates
)
,
dup_chk as
(
select sql_id, plan_hash_value, id, access_predicates, filter_predicates,
		count(id) over (partition by sql_id, plan_hash_value, id) ct_id
from plan_steps
)
select sql_id, plan_hash_value PHV, 
(select min(child_number) from v$sql_plan b 
 where b.sql_id = a.sql_id 
 and b.plan_hash_value = a.plan_hash_value 
 and nvl(b.access_predicates,'X') = nvl(a.access_predicates,'X')
 and nvl(b.filter_predicates,'X') = nvl(a.filter_predicates,'X')) child_no,
id, access_predicates, filter_predicates
from dup_chk a
where ct_id > 1
order by sql_id, plan_hash_value, id , child_no;



