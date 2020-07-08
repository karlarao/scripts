DEF section_id = '5i';
DEF section_name = 'Stats';
DEF title = 'Set Stats';
DEF main_table = 'DBA_TABLES';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&sqld360_prefix.','&&section_id.');

@@sqld360_0s_pre_nondef


SET SERVEROUTPUT ON FEED OFF TIMING OFF VERI OFF TERM OFF
SPO &&one_spool_filename..sql
DECLARE
 char_min VARCHAR2(4000);
 char_max VARCHAR2(4000);
 num_min  NUMBER;
 num_max  NUMBER;
BEGIN

  DBMS_OUTPUT.PUT_LINE('/*');
  DBMS_OUTPUT.PUT_LINE(' * This script includes all the commands to set basic level (table, index and column without histograms) stats');
  DBMS_OUTPUT.PUT_LINE(' * It is intentionally simple to ensure it completes quickly but at the same time allows to change stats easily enough');
  DBMS_OUTPUT.PUT_LINE(' * Objects are expected in current schema, otherwise just chance the owner with whatever you need');
  DBMS_OUTPUT.PUT_LINE(' */');

  -- process all the tables extracted by SQLd360
  FOR current_table IN (SELECT * 
                          FROM (SELECT t.owner, t.table_name, t.num_rows, t.blocks, t.partitioned
                                  FROM plan_table pt,
                                       dba_tables t
                                 WHERE pt.object_owner = t.owner
                                   AND pt.object_name = t.table_name
                                   AND pt.statement_id = 'LIST_OF_TABLES'
                                   AND pt.remarks = '&&sqld360_sqlid.'
                                 ORDER BY t.owner)
                         WHERE rownum <= 100) LOOP

    DBMS_OUTPUT.PUT_LINE('------------ Table: '||current_table.table_name||'--------------------------');

    DBMS_OUTPUT.PUT_LINE('EXEC DBMS_STATS.SET_TABLE_STATS(user, tabname => '''||current_table.table_name||''', '||
                                                               'numrows => '  ||current_table.num_rows  ||', '  ||
                                                               'numblks => '  ||current_table.blocks    ||' );');

    -- process every index for the current_table
    FOR current_index IN (SELECT index_name, blevel, leaf_blocks, clustering_factor, num_rows, distinct_keys
                            FROM dba_indexes
                           WHERE table_name = current_table.table_name
                             AND table_owner = current_table.owner) LOOP

 
      DBMS_OUTPUT.PUT_LINE('EXEC DBMS_STATS.SET_INDEX_STATS(user, indname => '''||current_index.index_name       ||''', '||
                                                                 'numrows => '  ||current_index.num_rows         ||', '||
                                                                 'numlblks => ' ||current_index.leaf_blocks      ||', '||
                                                                 'numdist => '  ||current_index.distinct_keys    ||', '||
                                                                 'clstfct => '  ||current_index.clustering_factor||', '||                                                                
                                                                 'indlevel => ' ||current_index.blevel||');');                                                              

    END LOOP;

    -- process every column for the current_table
    FOR current_column IN (SELECT column_name, num_distinct, density, num_nulls, avg_col_len, low_value, high_value, data_type
                             FROM dba_tab_cols
                            WHERE table_name = current_table.table_name
                              AND owner = current_table.owner) LOOP

      /*
       *  This piece needs to be extended for min/max and histograms
       *  min/max should be fairly easy, histograms not so much
       */


       DBMS_OUTPUT.PUT_LINE('DECLARE');
       DBMS_OUTPUT.PUT_LINE('  srec DBMS_STATS.STATREC;');

       IF current_column.data_type IN ('CHAR', '96', 'VARCHAR2', '1', 'NCHAR', 'NVARCHAR2') THEN  -- this is partially incorrect, I think NCHAR/NVARCHAR isn't supported
         DBMS_OUTPUT.PUT_LINE('  my_minmax DBMS_STATS.CHARARRAY;');
       ELSIF current_column.data_type IN ('DATE', '12', '180', '181', '231') OR current_column.data_type LIKE 'TIMESTAMP%' THEN
         DBMS_OUTPUT.PUT_LINE('  my_minmax DBMS_STATS.DATEARRAY;');
       ELSIF current_column.data_type IN ('NUMBER', 'FLOAT', '2', '4', '21', '22') THEN
         DBMS_OUTPUT.PUT_LINE('  my_minmax DBMS_STATS.NUMARRAY;');
       ELSIF current_column.data_type IN ('BINARY_FLOAT', '100') THEN
         DBMS_OUTPUT.PUT_LINE('  my_minmax DBMS_STATS.FLTARRAY;');
       ELSIF current_column.data_type IN ('BINARY_DOUBLE', '101') THEN
         DBMS_OUTPUT.PUT_LINE('  my_minmax DBMS_STATS.DBLARRAY;');
       ELSIF current_column.data_type IN ('RAW', '23') THEN
         DBMS_OUTPUT.PUT_LINE('  my_minmax DBMS_STATS.RAWARRAY;');
       END IF;

       DBMS_OUTPUT.PUT_LINE('BEGIN');
       DBMS_OUTPUT.PUT_LINE('srec.epc := 2;');

       IF current_column.data_type IN ('CHAR', '96', 'VARCHAR2', '1', 'NCHAR', 'NVARCHAR2') THEN
         
         SELECT TO_CHAR(UTL_RAW.CAST_TO_VARCHAR2(current_column.low_value)), TO_CHAR(UTL_RAW.CAST_TO_VARCHAR2(current_column.high_value))
           INTO char_min, char_max
           FROM dual;
         DBMS_OUTPUT.PUT_LINE('  my_minmax := DBMS_STATS.CHARARRAY('''||char_min||''','''||char_max||''');');

       ELSIF current_column.data_type IN ('DATE', '12', '180', '181', '231') OR current_column.data_type LIKE 'TIMESTAMP%' THEN
         
         SELECT RTRIM(
                    LTRIM(TO_CHAR(100*(TO_NUMBER(SUBSTR(current_column.low_value,1,2) ,'XX')-100) + (TO_NUMBER(SUBSTR(current_column.low_value,3,2) ,'XX')-100),'0000'))||'-'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.low_value,5,2) ,'XX')  ,'00'))||'-'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.low_value,7,2) ,'XX')  ,'00'))||'/'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.low_value,9,2) ,'XX')-1,'00'))||':'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.low_value,11,2),'XX')-1,'00'))||':'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.low_value,13,2),'XX')-1,'00'))),
                RTRIM(
                    LTRIM(TO_CHAR(100*(TO_NUMBER(SUBSTR(current_column.high_value,1,2) ,'XX')-100) + (TO_NUMBER(SUBSTR(current_column.high_value,3,2) ,'XX')-100),'0000'))||'-'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.high_value,5,2) ,'XX')  ,'00'))||'-'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.high_value,7,2) ,'XX')  ,'00'))||'/'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.high_value,9,2) ,'XX')-1,'00'))||':'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.high_value,11,2),'XX')-1,'00'))||':'||
                    LTRIM(TO_CHAR(     TO_NUMBER(SUBSTR(current_column.high_value,13,2),'XX')-1,'00')))
           INTO char_min, char_max
           FROM dual;
         DBMS_OUTPUT.PUT_LINE('  my_minmax := DBMS_STATS.DATEARRAY(TO_DATE('''||char_min||''',''YYYY-MM-DD/HH24:MI:SS''),TO_DATE('''||char_max||''',''YYYY-MM-DD/HH24:MI:SS''));');

       ELSIF current_column.data_type IN ('NUMBER', 'FLOAT', '2', '4', '21', '22') THEN
        
         SELECT UTL_RAW.CAST_TO_NUMBER(current_column.low_value), UTL_RAW.CAST_TO_NUMBER(current_column.high_value)
           INTO num_min, num_max
           FROM dual;
         DBMS_OUTPUT.PUT_LINE('  my_minmax := DBMS_STATS.NUMARRAY('''||num_min||''','''||num_max||''');');

       ELSIF current_column.data_type IN ('BINARY_FLOAT', '100') THEN

         SELECT TO_CHAR(UTL_RAW.CAST_TO_BINARY_FLOAT(current_column.low_value)), TO_CHAR(UTL_RAW.CAST_TO_BINARY_FLOAT(current_column.high_value))
           INTO char_min, char_max
           FROM dual;
         DBMS_OUTPUT.PUT_LINE('  my_minmax := DBMS_STATS.FLTARRAY('''||char_min||''','''||char_max||''');');

       ELSIF current_column.data_type IN ('BINARY_DOUBLE', '101') THEN

         SELECT TO_CHAR(UTL_RAW.CAST_TO_BINARY_DOUBLE(current_column.low_value)), TO_CHAR(UTL_RAW.CAST_TO_BINARY_DOUBLE(current_column.high_value))
           INTO char_min, char_max
           FROM dual;
         DBMS_OUTPUT.PUT_LINE('  my_minmax := DBMS_STATS.DBLARRAY('''||char_min||''','''||char_max||''');');

       ELSIF current_column.data_type IN ('RAW', '23') THEN

         DBMS_OUTPUT.PUT_LINE('  my_minmax := DBMS_STATS.RAWARRAY('''||current_column.low_value||''','''||current_column.high_value||''');');

       END IF;

       DBMS_OUTPUT.PUT_LINE('DBMS_STATS.PREPARE_COLUMN_VALUES(srec,my_minmax);');
       DBMS_OUTPUT.PUT_LINE('DBMS_STATS.SET_COLUMN_STATS(user, tabname => '''||current_table.table_name   ||''', '||
                                                              'colname => '''||current_column.column_name ||''', '||
                                                              'distcnt => '  ||current_column.num_distinct||', '||
                                                              'density => '  ||current_column.density     ||', '||
                                                              'nullcnt => '  ||current_column.num_nulls   ||', '||
                                                              'avgclen => '  ||current_column.avg_col_len ||', '||
                                                              'srec => srec);');   

       DBMS_OUTPUT.PUT_LINE('  COMMIT; ');
       DBMS_OUTPUT.PUT_LINE('END; ');
       DBMS_OUTPUT.PUT_LINE('/ ');                                                          

    END LOOP;


  END LOOP;


END;
/
SPO OFF
SET TERM ON
HOS zip -mq &&sqld360_main_filename._&&sqld360_file_time. &&one_spool_filename..sql