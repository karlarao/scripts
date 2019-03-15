#!/bin/bash

for i in `ls -1 | egrep "sqld360_|planx_|sqlmon_|dir_" | grep -v sqld360_main.sql | grep -v sqld360_driver.sql`
do 
	mv $i archive
done
