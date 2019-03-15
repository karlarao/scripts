 
 
spool monitorkrl.txt
 
select
  dbms_sql_monitor.report_sql_monitor(sql_id => '&sql_id',
                                      type => decode(upper('&&ptype'),'A', 'ACTIVE', 'H' , 'HTML', 'TEXT'), --'TEXT'  'HTML'  'ACTIVE'
                                      report_level => 'ALL') as report
FROM DUAL;
SPOOL OFF;
