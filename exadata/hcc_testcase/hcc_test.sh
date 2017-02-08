
# This is the main script
export DATE=$(date +%Y%m%d%H%M%S%N)

sqlplus -s /NOLOG <<! &
connect hccuser/hccuser
alter session set parallel_force_local=TRUE;
set timing off
set echo off
set lines 300

define table='$1'


exec get_snap_time.begin_snap('&&table')

select count(*) from 
(select count(*) from &&table) a, (select count(*) from &&table) b, (select count(*) from &&table) c, (select count(*) from &&table) d, (select count(*) from &&table) e, (select count(*) from &&table) f, (select count(*) from &&table) g;


exec get_snap_time.end_snap('&&table')


exit;
!


