select * from table( dbms_xplan.display_cursor('&sql_id', null, 'ADVANCED +ALLSTATS LAST +MEMSTATS LAST') );
