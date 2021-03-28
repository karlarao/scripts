#!/bin/bash


formatOut='asciidoc'
formatExt='txt'

for file in awr*.html
do
	outFile=$(basename $file | cut -f1 -d\. ).${formatExt}
	echo pandoc --columns=65000 --ascii -f html -t $formatOut $file -o $outFile
	pandoc --columns=65000 --ascii -f html -t $formatOut $file -o $outFile
done

parse-awr.pl awr*.txt

