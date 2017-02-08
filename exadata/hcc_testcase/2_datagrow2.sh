(( n=0 ))
while (( n<10 ));do
(( n=n+1 ))
sqlplus -s /NOLOG <<! &
connect hccuser/hccuser;
set timing on
set time on
alter session enable parallel dml;
insert /*+ APPEND */ into hcctable select * from hcctable;
commit;
select /*+ parallel(32) */ count(*) from hcctable
exit;
!
wait
done
wait

