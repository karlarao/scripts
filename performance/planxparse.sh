#!/bin/bash

if [ $# -ne 1 ] ; then 
	"pass args"
	exit 1	
fi

PLANX=$1


# parse planx 
cat $PLANX | awk '/DBA_HIST_SQLSTAT TOTAL \(ordered/,/AWR_PLAN_CHANGE/' | awk 'NF' | grep -v DBA_HIST_SQLSTAT | grep -v AWR_PLAN_CHANGE | grep -v "SNAP" | grep -v "~~~" | grep -v "\-\-\-" | sed 's/,//g' | awk -F ' ' '{print $9, $14, $15}' > krlavg.txt

# create awk file
cat > krlavg.awk << EOF
{
sum_exec+=\$1
sum_elap+=\$2
sum_cpu+=\$3

executions=sum_exec/NR

if ( executions < 1 ) {
  executions=1
}

}

END{
print "avg_exec:",executions
print "avg_elap:",sum_elap/NR
print "avg_cpu:",sum_cpu/NR
print "avg_elap/exec:",(sum_elap/NR)/executions
print "avg_cp/execu:",(sum_cpu/NR)/executions
}
EOF

# run awk 
cat krlavg.txt | awk -f krlavg.awk

rm krlavg.awk 
