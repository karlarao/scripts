for i in *.tar.bz2 ; 
do 
	tar -xjvpf $i
	cat *csv >> myash.txt
	echo $i
done

export DATE=$(date +%Y%m%d%H%M%S%N)
tar -cjvpf myash_consolidated_$DATE.tar.bz2 myash.txt
rm myash*csv
rm myash.txt

