
-- historical backup size
COLUMN dbid NEW_VALUE _dbid NOPRINT
select dbid from v$database;
COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;
COLUMN name NEW_VALUE _hostname NOPRINT
select lower(host_name) name from v$instance;
spool awr_storagesize_rman-&_instname-&_hostname..csv
select
trim('&_instname') instname,
trim('&_dbid') db_id,
trim('&_hostname') hostname,
status,
input_type,
TO_CHAR(start_time, 'MM/DD/YY HH24:MI:SS') as "start",
round(elapsed_seconds)/60/60 etimehours,
round(input_bytes/1024/1024/1024,2) inGB,
round(output_bytes/1024/1024/1024,2) outGB,
output_device_type device,
autobackup_done,
optimized
from V$RMAN_BACKUP_JOB_DETAILS
order by start_time asc;
spool off


-- monitor backup job details
set lines 300
col status format a10
col elapsed_seconds format 9999
col time_taken_display format a10
col device format a10
select status,
input_type,
TO_CHAR(start_time, 'mm/dd/yy HH24:MI:SS') as "start",
TO_CHAR(end_time, 'mm/dd/yy HH24:MI:SS') as "end",
time_taken_display,
round(elapsed_seconds) etimesec,
round(input_bytes/1024/1024,2) inMB,
round(output_bytes/1024/1024,2) outMB,
output_device_type device,
autobackup_count autobackupcnt,
autobackup_done, 
optimized
from V$RMAN_BACKUP_JOB_DETAILS
order by start_time desc;


	STATUS     INPUT_TYPE    start             end               TIME_TAKEN   ETIMESEC       INMB      OUTMB DEVICE     AUTOBACKUPCNT AUT OPT
	---------- ------------- ----------------- ----------------- ---------- ---------- ---------- ---------- ---------- ------------- --- ---
	COMPLETED  DB FULL       05/13/12 22:00:23 05/13/12 23:53:32 01:53:09         6789  754403.19  176368.39 DISK                   0 NO  NO  <-- check this
	COMPLETED  RECVR AREA    05/13/12 12:41:17 05/13/12 13:02:45 00:21:28         1288      18407      18408 SBT_TAPE               0 NO  NO


col handle format a90  
select 
       bs_key
       , bp_key
       , ctime "Date"
       , decode(backup_type, 'L', 'Archive Log', 'D', 'Full', 'Incremental') backup_type
       , handle
       , bsize "Size MB"
  from (select 
        bs.recid  bs_key
        , bp.recid bp_key
        , to_char(bp.completion_time,'MM/DD/YY HH24:MI:SS') ctime
     	, backup_type
     	, bp.handle
     	, round(bp.bytes/1024/1024,2) bsize
     from v$backup_set bs, v$backup_piece bp
     where bs.set_stamp = bp.set_stamp
     and bs.set_count  = bp.set_count
     and bp.status = 'A')
order by bp_key;


      6838       6811 05/13/12 22:07:21 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.19252.783208847              2767.29 <-- sum this
      6839       6812 05/13/12 22:07:24 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.13502.783208845               2525.3
      6840       6813 05/13/12 22:16:26 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.18826.783208851              6591.71
      6841       6814 05/13/12 22:21:31 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.20032.783209259              6558.54
      6842       6815 05/13/12 22:23:15 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.18391.783208855              11098.1
      6843       6816 05/13/12 22:25:00 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.20232.783209271               7274.8
      6844       6817 05/13/12 22:31:29 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.18802.783209797               7294.7
      6845       6818 05/13/12 22:32:13 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.23966.783210107               4496.9
      6847       6819 05/13/12 22:45:24 Full        +RECO/hcmprddal/backupset/2012_05_13/nnndf0_tag20120513t220034_0.11778.783210205              10830.4
      6820       6820 05/13/12 22:45:33 Full        +RECO/hcmprddal/autobackup/2012_05_13/s_783211529.21347.783211533                              168.17
      6848       6821 05/13/12 23:04:14 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.23108.783211649                 8679
      6849       6822 05/13/12 23:06:52 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.17853.783211643              10002.6
      6850       6823 05/13/12 23:08:58 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.24151.783211647             11193.67
      6851       6824 05/13/12 23:10:00 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.19736.783211645             10606.14
      6852       6825 05/13/12 23:25:20 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.6809.783212671                 10511
      6853       6826 05/13/12 23:25:27 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.23085.783212823              9293.11
      6854       6827 05/13/12 23:30:04 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.19984.783212951             10712.42
      6855       6828 05/13/12 23:31:41 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.20337.783213009             11244.82
      6856       6829 05/13/12 23:32:28 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.19514.783214307               361.01
      6857       6830 05/13/12 23:46:02 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.21222.783213929             10979.44
      6859       6831 05/13/12 23:46:41 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.20665.783213933             11336.96
      6860       6832 05/13/12 23:51:24 Archive Log +RECO/hcmprddal/backupset/2012_05_13/annnf0_tag20120513t224650_0.18571.783214213             11339.21
      6833       6833 05/13/12 23:51:39 Full        +RECO/hcmprddal/autobackup/2012_05_13/s_783215495.24204.783215499                              168.17
      6861       6834 05/13/12 23:52:56 Full        +RECO/hcmprddal/backupset/2012_05_13/ncnnf0_tag20120513t235239_0.20261.783215575               168.14
      6836       6836 05/13/12 23:53:20 Full        +RECO/hcmprddal/autobackup/2012_05_13/s_783215585.20326.783215599                              168.17

      
select ctime "Date"
       , decode(backup_type, 'L', 'Archive Log', 'D', 'Full', 'Incremental') backup_type
       , bsize "Size MB"
  from (select trunc(bp.completion_time) ctime
     	, backup_type
     	, round(sum(bp.bytes/1024/1024),2) bsize
     from v$backup_set bs, v$backup_piece bp
     where bs.set_stamp = bp.set_stamp
     and bs.set_count  = bp.set_count
     and bp.status = 'A'
     group by trunc(bp.completion_time), backup_type)
  order by 1, 2;
  
	08-MAY-12 Archive Log   66320.11
	08-MAY-12 Full          62308.11
	09-MAY-12 Archive Log  123752.54
	09-MAY-12 Full           62672.6
	10-MAY-12 Archive Log  191471.09
	10-MAY-12 Full          63824.41
	11-MAY-12 Archive Log  193624.71
	11-MAY-12 Full          67058.27
	12-MAY-12 Archive Log  271107.19
	12-MAY-12 Full         160251.41
	13-MAY-12 Archive Log  283299.57
	13-MAY-12 Full          60446.87
	14-MAY-12 Archive Log   226546.6
	14-MAY-12 Full         119567.71

http://www.comp.dit.ie/btierney/oracle11gdoc/backup.111/b28270/rcmreprt.htm#CHDBIGHG



-- last backup status log
set lines 2000
set pages 10000
select SID,RECID,STAMP,SESSION_RECID,SESSION_STAMP,OUTPUT
from  V_$RMAN_OUTPUT
order by 1,2,3,4,5;

