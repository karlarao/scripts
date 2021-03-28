## run_awr-quickextract
* Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
* http://karlarao.wordpress.com
* NOTE for customers: for sizing data gathering just execute the steps 1 and 2

```
------------------------------------
The scripts capture the following data sets:
------------------------------------

> Top Events - AAS CPU, latency, wait class
> SYSSTAT - Executes/sec, commits/sec, rollbacks/sec, logons/sec
> Memory - physical memory, PGA, SGA
> IO - IOPS breakdown, MB/s
> CPU - Load Average, NUM_CPUs,
> Storage - total storage size, per tablespace size
> Services - distribution of workload/modules
> Top SQL - PIOs, LIOs, modules, SQL type, SQL_ID, PX
> ASH data - detailed session activity (1sec and 10sec intervals)


------------------------------------
STEP 1: COLLECT AWR DATA (to be done by the customer)
------------------------------------

Unzip the scripts on a directory, for example: /home/oracle/dba/run_awr-quickextract

On the server, as SYSDBA run the following script on each database 
        if non-CDB environment:  @run_all.sql 
        if CDB environment:      @run_all_cdb.sql 

The data collection end result will all be CSV files which will be consolidated on STEP 2


------------------------------------
STEP 2: CONSOLIDATE ALL FILES (to be done by the customer)
------------------------------------

After running the scripts consolidate all files in one zip file.

mkdir csvfiles_$HOSTNAME
mv *csv csvfiles_$HOSTNAME/
zip -r csvfiles_$HOSTNAME.zip csvfiles_$HOSTNAME


------------------------------------
STEP 3: EXTRACT & PACKAGE CSV FILES (to be done by the consultant/troubleshooter)
------------------------------------

- This section should be done on your laptop or another server
- The packaged CSV files are the files used for sizing and workload characterization

3a) Put all ZIP files in one folder, then extract the CSV files with the following commands:

mkdir zipfiles
for i in *.zip; do unzip $i -d zipfiles; done
cd zipfiles


3b) Package all CSV files

sh run_final_csv
zip awrcsvfiles.zip *txt
```