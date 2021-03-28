#!/bin/bash 
# run this as root 
# ./cpu_topology.sh 

dmidecode | grep -i "product name" 
cat /proc/cpuinfo | grep -i "model name" | uniq
function filter(){
sed 's/^.*://g' | xargs echo
}
echo "processors  (OS CPU count)         " `grep processor /proc/cpuinfo | filter`
echo "physical id (processor socket)     " `grep 'physical id' /proc/cpuinfo | filter`
echo "siblings    (logical CPUs/socket)  " `grep siblings /proc/cpuinfo | filter`
echo "core id     (# assigned to a core) " `grep 'core id' /proc/cpuinfo | filter`
echo "cpu cores   (physical cores/socket)" `grep 'cpu cores' /proc/cpuinfo | filter`

