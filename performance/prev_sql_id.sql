set serveroutput off


--put your sql here
select min(sales_date) from hr.partition1;


select prev_sql_id p_sqlid from v$session where sid=sys_context('userenv','sid');
@dplan
