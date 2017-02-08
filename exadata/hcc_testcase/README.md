THIS IS A BUNDLED VERSION OF [https://github.com/karlarao/hcc_testcase](https://github.com/karlarao/hcc_testcase)

# hcc_testcase
- Karl Arao, OakTable, Oracle ACE, OCP-DBA, RHCE
- http://karlarao.wordpress.com


### The general workflow:

* First, setup the environment
    * 1_cr_table2.sh
    * 2_datagrow2.sh
* Then estimate the compression
    * hcc_estimate.sql
* Then create the actual HCC tables
    * hcc_tables.sql
    * hcc_tablespaces.sql
    * hcc_segments.sql
* Check the estimate vs real
    * hcc_validate.sql
* and validate the rows
    * hcc_comptype_rows.sql
    * hcc_comptype_all.sql
* Run some sample SQLs on HCC tables and instrument each run
    * run_stats_create.sql
    * hcc_test.sh
    * run_stats_hcc_query.sql
    * run_stats_query_all.sql
* You can also run some DML on the tables and validate the rows
* Lastly re-compress

The doc <a href="https://github.com/karlarao/hcc_testcase/raw/master/HCC%20test%20case.docx" target="_blank">"HCC test case.docx"</a> shows more detailed step by step 
