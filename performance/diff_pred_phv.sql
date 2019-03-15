SPO difpred2.txt;
SET HEA ON LIN 80 NEWP 1 PAGES 100 LIN 300 TRIMS ON TI OFF TIMI OFF;
 
-- shows which plan lines have different predicates for given phv
WITH d AS (
SELECT plan_hash_value,
 id,
 COUNT(DISTINCT access_predicates) distinct_access_predicates,
 COUNT(DISTINCT filter_predicates) distinct_filter_predicates
 FROM gv$sql_plan_statistics_all
 WHERE plan_hash_value = &&plan_hash_value.
 GROUP BY
 plan_hash_value,
 id
HAVING MIN(NVL(access_predicates, 'X')) != MAX(NVL(access_predicates, 'X'))
 OR MIN(NVL(filter_predicates, 'X')) != MAX(NVL(filter_predicates, 'X'))
)
SELECT v.id,
 'access' type,
 v.sql_id,
 v.inst_id,
 v.child_number,
 v.access_predicates predicates
 FROM d,
 gv$sql_plan_statistics_all v
 WHERE v.plan_hash_value = d.plan_hash_value
 AND v.id = d.id
 AND d.distinct_access_predicates > 1
 UNION ALL
SELECT v.id,
 'filter' type,
 v.sql_id,
 v.inst_id,
 v.child_number,
 v.filter_predicates predicates
 FROM d,
 gv$sql_plan_statistics_all v
 WHERE v.plan_hash_value = d.plan_hash_value
 AND v.id = d.id
 AND d.distinct_filter_predicates > 1
 ORDER BY
 1, 2, 6, 3, 4, 5;
 
SET HEA ON LIN 80 NEWP 1 PAGES 14 LIN 80 TRIMS OFF TI OFF TIMI OFF;
SPO OFF;

