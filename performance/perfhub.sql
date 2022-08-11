alter session disable parallel query;

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_24hrs_db.html
select dbms_perf.report_perfhub(is_realtime=>0,type=>'active',outer_start_time=>sysdate-1,selected_start_time=>sysdate-1) from dual;
spool off

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_realtime_24hrs_db.html
select dbms_perf.report_perfhub(is_realtime=>1,type=>'active',outer_start_time=>sysdate-1,selected_start_time=>sysdate-1) from dual;
spool off

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_realtime_12hrs_db.html
select dbms_perf.report_perfhub(is_realtime=>1,type=>'active',outer_start_time=>sysdate-12/24,selected_start_time=>sysdate-12/24) from dual;
spool off

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_realtime_6hrs_db.html
select dbms_perf.report_perfhub(is_realtime=>1,type=>'active',outer_start_time=>sysdate-6/24,selected_start_time=>sysdate-6/24) from dual;
spool off

set ver off pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool rwp_sqlmon_&&sqlmon_sqlid._perfhub_sqlid.html
select dbms_perf.report_sql(sql_id => '&&sqlmon_sqlid.', is_realtime=>0,type=>'active') from dual;
spool off


