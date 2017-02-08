#!/bin/bash

bunzip2 *bz2 
for i in cell*.txt; do mv $i $i.orig; done

# cell_addtl_stats.txt
sed "s/%/ /g ; s/MB\/sec/      /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_addtl_stats.txt.orig > cell_addtl_stats.txt && rm cell_addtl_stats.txt.orig
zip cell_addtl_stats.zip cell_addtl_stats.txt

# cell_cg_iops.txt
sed "s/IO\/sec/      /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_cg_iops.txt.orig > cell_cg_iops.txt && rm cell_cg_iops.txt.orig
zip cell_cg_iops.zip cell_cg_iops.txt

# cell_cg_latency.txt
sed "s/ms\/request/          /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_cg_latency.txt.orig > cell_cg_latency.txt && rm cell_cg_latency.txt.orig
zip cell_cg_latency.zip cell_cg_latency.txt

# cell_cg_mbs.txt
sed "s/MB\/sec/      /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_cg_mbs.txt.orig > cell_cg_mbs.txt && rm cell_cg_mbs.txt.orig
zip cell_cg_mbs.zip cell_cg_mbs.txt

# cell_db_iops.txt
sed "s/IO\/sec/      /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_db_iops.txt.orig > cell_db_iops.txt && rm cell_db_iops.txt.orig
zip cell_db_iops.zip cell_db_iops.txt

# cell_db_latency.txt
sed "s/ms\/request/          /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_db_latency.txt.orig > cell_db_latency.txt && rm cell_db_latency.txt.orig
zip cell_db_latency.zip cell_db_latency.txt

# cell_db_mbs.txt
sed "s/MB\/sec/      /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_db_mbs.txt.orig > cell_db_mbs.txt && rm cell_db_mbs.txt.orig
zip cell_db_mbs.zip cell_db_mbs.txt

# cell_flash_destage.txt
sed "s/IO\/sec/      /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_flash_destage.txt.orig > cell_flash_destage.txt && rm cell_flash_destage.txt.orig
zip cell_flash_destage.zip cell_flash_destage.txt

# cell_flash_space.txt
sed "s/MB/  /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_flash_space.txt.orig > cell_flash_space.txt && rm cell_flash_space.txt.orig
zip cell_flash_space.zip cell_flash_space.txt

# cell_flashlog_outliers.txt
sed "s/IO requests/           /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_flashlog_outliers.txt.orig > cell_flashlog_outliers.txt && rm cell_flashlog_outliers.txt.orig
zip cell_flashlog_outliers.zip cell_flashlog_outliers.txt

# cell_flashlog_skip.txt
sed "s/%/ /g ; s/IO requests/           /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_flashlog_skip.txt.orig > cell_flashlog_skip.txt && rm cell_flashlog_skip.txt.orig
zip cell_flashlog_skip.zip cell_flashlog_skip.txt

# cell_iops.txt
sed "s/IO\/sec/      /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_iops.txt.orig > cell_iops.txt && rm cell_iops.txt.orig
zip cell_iops.zip cell_iops.txt

# cell_latency.txt
sed "s/us\/request/          /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_latency.txt.orig > cell_latency.txt && rm cell_latency.txt.orig
zip cell_latency.zip cell_latency.txt

# cell_mbs.txt
sed "s/MB\/sec/      /g ; s/: /\t/g ; 1 i\cellname\tmetric\tdisk\tvalue\ttime" cell_mbs.txt.orig > cell_mbs.txt && rm cell_mbs.txt.orig
zip cell_mbs.zip cell_mbs.txt

