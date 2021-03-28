
# NOTE: need to change User Id column to String for the calcfield to work
cat $1 | sed 's/ //g' | awk -F',' '{print "ELSEIF [User Id]='\''"$2 "'\'' THEN '\''" $1 "'\''" }'

