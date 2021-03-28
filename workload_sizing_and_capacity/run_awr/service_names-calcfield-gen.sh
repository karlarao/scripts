
# NOTE: need to change Service Hash column to String for the calcfield to work
cat $1 | awk -F' ' '{print "ELSEIF [Service Hash]='\''"$3 "'\'' THEN '\''" $2 "'\''" }' | sort | uniq

