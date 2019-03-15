col percent head '%' for 99990.99
col star for A10 head ''
 
accept seconds prompt "Last Seconds [60] : " default 60;
accept top prompt "Top  Rows    [10] : " default 10;
 
select SQL_ID,TEMP_MB,percent,rpad('*',percent*10/100,'*') star
from
(
select SQL_ID,sum(DELTA_TEMP_MB) TEMP_MB ,(ratio_to_report(sum(DELTA_TEMP_MB)) over ())*100 percent,rank() over(order by sum(DELTA_TEMP_MB) desc) rank
from
(
select SESSION_ID,SESSION_SERIAL#,sample_id,SQL_ID,SAMPLE_TIME,IS_SQLID_CURRENT,SQL_CHILD_NUMBER,temp_space_allocated,
greatest(temp_space_allocated - first_value(temp_space_allocated) over (partition by SESSION_ID,SESSION_SERIAL# order by sample_time rows 1 preceding),0)/power(1024,2) "DELTA_TEMP_MB"
from
v$active_session_history
where
IS_SQLID_CURRENT='Y'
and sample_time > sysdate-&seconds/86400
order by 1,2,3,4
)
group by sql_id
having sum(DELTA_TEMP_MB) > 0
)
where rank < (&top+1)
order by rank
/
