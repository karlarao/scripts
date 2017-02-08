THIS IS A BUNDLED VERSION OF https://github.com/karlarao/cellmetricstoolkit

-- cellmetricstoolkit
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--

read on the doc "HOWTO – extract cell metrics by Flash vs Hard Disk_v2"

Here's the general workflow: 
* 1_gen_scl.sh
* 2_distribute_scl.sh
* 3_run_scl.sh
* transfer files to your desktop or another server w/ ample space
* 4_process_files.sh 
* email/ftp zip files
* 5_unzip.sh 
* graph the new data 

all the dashboard/visualization are under the folder "tableau workbooks"
they all currenly point to "J:\tmp2\cellmetrics", so refresh the datasource accordingly
