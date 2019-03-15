#!/bin/bash

ps -ef | grep pmon | grep -v grep | grep -v perl | grep -v ASM |\
while read PMON; do
   INST=`echo $PMON | awk {' print $8 '} | cut -f3 -d_`
  echo "instance: $INST"

  export ORACLE_SID=$INST
  export ORAENV_ASK=NO
  . oraenv

  sqlplus -s /nolog <<-EOF
  connect / as sysdba


show parameter db_name

var OH varchar2(200);
EXEC dbms_system.get_env('ORACLE_HOME', :OH) ;
PRINT OH

EOF
echo '-----'
echo
echo
done
