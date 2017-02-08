THIS IS A BUNDLED VERSION OF https://github.com/karlarao/gvash_to_csv

# rungash - Karl Arao

this pulls the ASH data every 10 mins, very useful for active data guard environment 
where you don't have much historical data once the instance crashes 
the assumption is whenever the crash happens and this tool is running there will 
be enough information dumped on the filesystem (csv) to be able to figure out the SQLs 
running during that period of crash.. well at least the 10mins before the crash 

6 samples every hour across the databases 
144 samples every day
1008 samples in a week 
and anywhere during that week you should be able to hit the crash and get the diagnostics done

untar/unzip the file
then do 

nohup sh rungash.sh &



# This can also be deployed as a Metric Extension, check here for the step by step https://github.com/karlarao/gvash_to_csv/releases/download/v1.0/Metric.Extension.-.gvash.to.csv.docx



