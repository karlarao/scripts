#!/bin/bash

echo "enter start time (format: 2016-03-14T01:00:00-06:00) ->"
read start_time
echo "enter end time (format: 2016-03-15T21:00:00-06:00) ->"
read end_time

export DATE=$(date +%Y%m%d%H%M%S)
mkdir archive_$DATE
mv *scl archive_$DATE
mv 2_* 3_* archive_$DATE

# cell additional stats
cell_addtl_stats="CL_FSUT,CL_CPUT,CL_MEMUT,IORM_MODE,SIO_IO_RV_OF_SEC,SIO_IO_PA_TH_SEC"
# cell iops
cell_iops="CD_IO_RQ_R_LG_SEC,CD_IO_RQ_R_SM_SEC,CD_IO_RQ_W_LG_SEC,CD_IO_RQ_W_SM_SEC"
# cell mbs
cell_mbs="CD_IO_BY_R_LG_SEC,CD_IO_BY_R_SM_SEC,CD_IO_BY_W_LG_SEC,CD_IO_BY_W_SM_SEC"
# cell latency
cell_latency="CD_IO_TM_R_LG_RQ,CD_IO_TM_R_SM_RQ,CD_IO_TM_W_LG_RQ,CD_IO_TM_W_SM_RQ"
# flash space
# cell_flash_space="FC_BY_ALLOCATED,FC_BY_USED,DB_FC_BY_ALLOCATED"
cell_flash_space="FC_BY_ALLOCATED,FC_BY_USED"
# flash destage
cell_flash_destage="FC_IO_RQ_W_OVERWRITE_SEC,FC_IO_RQ_W_FIRST_SEC,FC_IO_RQ_R_MISS_SEC,FC_IO_RQ_W_POPULATE_SEC,FC_IO_RQ_DISK_WRITE_SEC"
# flashlog skip
cell_flashlog_skip="FL_EFFICIENCY_PERCENTAGE_HOUR,FL_IO_W,FL_IO_W_SKIP_BUSY,FL_IO_W_SKIP_LARGE,FL_IO_W_SKIP_NO_BUFFER"
# flashlog outliers
cell_flashlog_outliers="FL_FLASH_FIRST,FL_DISK_FIRST,FL_PREVENTED_OUTLIERS,FL_ACTUAL_OUTLIERS"
# db iops
cell_db_iops="DB_IO_RQ_LG_SEC,DB_IO_RQ_SM_SEC,DB_FD_IO_RQ_LG_SEC,DB_FD_IO_RQ_SM_SEC"
# db mbs
cell_db_mbs="DB_IO_BY_SEC,DB_FC_IO_BY_SEC,DB_FD_IO_BY_SEC,DB_FL_IO_BY_SEC"
# db latency
cell_db_latency="DB_FD_IO_WT_LG_RQ,DB_FD_IO_WT_SM_RQ,DB_IO_WT_LG_RQ,DB_IO_WT_SM_RQ"
# cg iops
cell_cg_iops="CG_IO_RQ_LG_SEC,CG_IO_RQ_SM_SEC,CG_FD_IO_RQ_LG_SEC,CG_FD_IO_RQ_SM_SEC"
# cg mbs
cell_cg_mbs="CG_IO_BY_SEC,CG_FC_IO_BY_SEC,CG_FD_IO_BY_SEC"
# cg latency
cell_cg_latency="CG_FD_IO_WT_LG_RQ,CG_FD_IO_WT_SM_RQ,CG_IO_WT_LG_RQ,CG_IO_WT_SM_RQ"


for i in ${!cell_*}; do
  echo "set dateformat local" >> $i.scl
  echo "LIST METRICHISTORY ${!i} where collectionTime > '$start_time' and collectionTime < '$end_time'" >> $i.scl
  echo "/usr/local/bin/dcli -l root -g /root/cell_group -f ~/$i.scl" >> 2_distribute_scl.sh
  echo "/usr/local/bin/dcli --serial -l root -g /root/cell_group "cellcli -e start $i.scl" | bzip2 > $i.txt.bz2" >> 3_run_scl.sh
done
