col percent head '%' for 99990.99
col star for A10 head ''
 
accept seconds prompt "Last Seconds [60] : " default 60;
accept top prompt "Top  Rows    [10] : " default 10;
 
select SQL_ID,round(PGA_MB,1) PGA_MB,percent,rpad('*',percent*10/100,'*') star
from
(
select SQL_ID,sum(DELTA_PGA_MB) PGA_MB ,(ratio_to_report(sum(DELTA_PGA_MB)) over ())*100 percent,rank() over(order by sum(DELTA_PGA_MB) desc) rank
from
(
select SESSION_ID,SESSION_SERIAL#,sample_id,SQL_ID,SAMPLE_TIME,IS_SQLID_CURRENT,SQL_CHILD_NUMBER,PGA_ALLOCATED,
greatest(PGA_ALLOCATED - first_value(PGA_ALLOCATED) over (partition by SESSION_ID,SESSION_SERIAL# order by sample_time rows 1 preceding),0)/power(1024,2) "DELTA_PGA_MB"
from
v$active_session_history
where
IS_SQLID_CURRENT='Y'
and sample_time > sysdate-&seconds/86400
order by 1,2,3,4
)
group by sql_id
having sum(DELTA_PGA_MB) > 0
)
where rank < (&top+1)
order by rank
/
