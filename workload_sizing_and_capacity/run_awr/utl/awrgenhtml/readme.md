
# General Workflow 

## For each database generate HTML AWRs
* on sqlplus run @awr-generator.sql and follow the prompts
* create a directory for each database and move all output HTML files to respective folders

## (if needed) For each folder parse HTML to text 
* on each folder run parse-awr.sh
* this will consolidate load profile data of all HTML to one csv




