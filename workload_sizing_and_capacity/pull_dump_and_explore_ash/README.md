# pull_dump_and_explore_ash
pull (from any database), dump (to your local machine), and explore ash


- 0_gvash_to_csv_hist.sql (change the date filters accordingly) 
	- dump to csv
- 1_cr_table.sql 
	- create final table
- 2_gen_ext.ctl (change the stage directory accordingly - /u02/tmp/myash.csv)
	- generate external script
- 3_cr_ext.sql 
	- create external table
- 4_initial_insert.sql 
	- insert from external table to final table (you can skip this)
- 5_dash_waitchains_ext.sql (change the date filters accordingly) 
	- query wait chains from external table
- example_output_waitchains.txt 
	- example output of wait chains


# Example output 

> SQL> @dash_waitchains_ext session_id||'>>'||program2||'>>'||event2||'>>'||sql_id||'>>'||sql_opname||'>>'||p1text||'>>'||p1||'>>'||blocking_session 1=1

![](http://i.imgur.com/bY885Uh.png)


# HOWTO graph

![](http://i.imgur.com/WHUCK4z.gif)
