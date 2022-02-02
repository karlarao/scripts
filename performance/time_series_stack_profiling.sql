

create these two files, and run genstacks.sh

parameters:
1 - OSPID
2 - number of times to loop


./genstacks 9153 3600

After the profiling run, do this on stacks3.txt for time series visualization 

sed -i -e '1itime , data\' stacks3.txt




# get SPID 

select /* usercheck */ s.sid sid, s.serial# serial#, lpad(p.spid,7) unix_pid 
from gv$process p, gv$session s
where p.addr=s.paddr
and   s.username is not null
and (s.inst_id, s.sid) in (select inst_id, sid from gv$mystat where rownum < 2);





$ cat genstacks.sh 
#!/bin/ksh 

count=$2 
sc=0 
while [ $sc -lt $count ] 
do 
sc=`expr $sc + 1` 
./stack.sh $1 | gawk '{ print strftime("%m/%d/%Y %H:%M:%S"),"| " $0 }' >> stacks2.txt
./stack.sh $1 | sed 's/<-/\'$'\n''/g' | sed 's/+[^+]*//g' | gawk '{ print strftime("%m/%d/%Y %H:%M:%S"),", " $0 }' >> stacks3.txt
sleep 1 
done 



$ cat stack.sh 
#!/bin/ksh 

sqlplus -s 'sys/oracle as sysdba' << EOF 

--spool stacks.txt append 
oradebug setospid $1 
oradebug unlimit 
oradebug SHORT_STACK 

EOF


