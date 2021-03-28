
# Extract CSV Data from AWR HTML Reports


HTML AWR reports have been converted to asciidoc via pandoc

[pandoc](https://pandoc.org/)

pandoc --columns=65000 --eol=lf --ascii -f html -t asciidoc INFILE -o OUTfILE

## Why do this?

Because sometimes the only available AWR data is from HTML reports that have been saved.

Otherwise and AWR diff report would have be quite useful.

So, get data from the following report sections


Begin Time
Elapsed Time 
DB Time

Both Elapsed and DB Time are reported in minutes, and converted to seconds.

Time, Executions and Average times from 

- Load Profile
- Top 5 Timed Foreground events
- CPU stats
- Memory stats
- Time Model Statistics
- Operating System Statistics
- Operating System Statistics (detail)
- Foreground Wait Class
- SQL ordered by Elapsed Time
- SQL ordered by CPU Time
- SQL ordered by User I/O Wait Time

Some of the SQL stats
Top 10 from each of :

- Top Foreground Wait Events
- Top Background Wait Events


Example:

```bash
./parse-awr.pl awrrpt*.txt

Begin Time: 25-Sep-17 08:00:01
Elapsed Seconds: 39600.6
DB Seconds: 629137.2
 
Begin Time: 06-Nov-17 08:00:01
Elapsed Seconds: 32400.6
DB Seconds: 523926

Begin Time: 07-Nov-17 02:00:02
Elapsed Seconds: 3599.4
DB Seconds: 91552.8

Begin Time: 12-Dec-17 09:00:01
Elapsed Seconds: 10800
DB Seconds: 162718.8

Begin Time: 12-Dec-17 12:00:01
Elapsed Seconds: 21600.6
DB Seconds: 282987


>  ls -l *.csv
-rwxr-xr-x 1 oracle dba  4363 Jun 19 15:28 background-wait-events.csv
-rwxr-xr-x 1 oracle dba  3136 Jun 19 15:28 foreground-wait-class.csv
-rwxr-xr-x 1 oracle dba  4387 Jun 19 15:28 foreground-wait-events.csv
-rwxr-xr-x 1 oracle dba   414 Jun 19 15:28 host-cpu.csv
-rwxr-xr-x 1 oracle dba   343 Jun 19 15:28 instance-cpu.csv
-rwxr-xr-x 1 oracle dba  5035 Jun 19 15:28 load-profile.csv
-rwxr-xr-x 1 oracle dba  1474 Jun 19 15:28 memory-stats.csv
-rwxr-xr-x 1 oracle dba 11000 Jun 19 15:28 os-stats-detail.csv
-rwxr-xr-x 1 oracle dba  6377 Jun 19 15:28 os-stats.csv
-rwxr-xr-x 1 oracle dba  9361 Jun 19 15:28 sql-by-cpu.csv
-rwxr-xr-x 1 oracle dba  9124 Jun 19 15:28 sql-by-elapsed.csv
-rwxr-xr-x 1 oracle dba  9229 Jun 19 15:28 sql-by-io.csv
-rwxr-xr-x 1 oracle dba  5729 Jun 19 15:28 time-model-stats.csv
-rwxr-xr-x 1 oracle dba  2180 Jun 19 15:28 top-foreground-events.csv
```

## Adding to the Report Formats

There are many versions of Oracle, and correspondingly different Headings in the reports.

For instance, the reports I was working with had a section heading called 'Top 5 Timed Foreground Events'.

If the reports you are using instead have a heading of 'Top 10 Foreground Events by Total Wait Time', then the script will not find the data you want.

Ideally, there would be a configuration file to deal with this. However, there isn't one, and I cannot add one at this time.
(Pull Requests *will* be considered )

So the solution will be to edit the %rptFormat associative array and add the necessary data.

Let's say you have a report `dellemc_awr_1_153556_153557.html`, and after running it you see there is little data:

```text
$  ./parse-awr.sh
pandoc --columns=65000 --eol=lf --ascii -f html -t asciidoc dellemc_awr_1_153556_153557.html -o dellemc_awr_1_153556_153557.txt

     Begin Time: 23-Feb-20 04:30:04
Elapsed Seconds: 1802.4
     DB Seconds: 17496.6


$  ls -l *.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 background-wait-events.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 foreground-wait-class.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 foreground-wait-events.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 host-cpu.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 instance-cpu.csv
-rwxr-xr-x 1 jkstill dba 1292 Mar 21 16:08 load-profile.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 memory-stats.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 os-stats-detail.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 os-stats.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 sql-by-cpu.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 sql-by-elapsed.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 sql-by-io.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 time-model-stats.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:08 top-foreground-events.csv

```

Here are the headings currently available in the script:

```perl
   # first non-blank field that indicates start of heading per section
   # array values [first column name, column position, number of metrics to keep,output file]

   %rptFormat = (
      'Load Profile'                            => ['Per Second',1,99999,'load-profile'],
      'Top 5 Timed Foreground Events'           => ['Event',0,99999,'top-foreground-events'],
      'Host CPU'                                => ['Load Average Begin',0,99999,'host-cpu'],
      'Instance CPU'                            => ['%Total CPU',0,99999,'instance-cpu'],
      'Memory Statistics'                       => ['Begin',1,99999,'memory-stats'],
      'Time Model Statistics'                   => ['Statistic Name',0,99999,'time-model-stats'],
      'Operating System Statistics'             => ['Statistic',0,99999,'os-stats'],
      'Operating System Statistics - Detail'    => ['Snap Time',0,99999,'os-stats-detail'],
      'Foreground Wait Class'                   => ['Wait Class',0,99999,'foreground-wait-class'],
      'Foreground Wait Events'                  => ['Event',0,10,'foreground-wait-events'],
      'Background Wait Events'                  => ['Event',0,10,'background-wait-events'],
      'SQL ordered by Elapsed Time'             => ['Elapsed Time (s)',0,99999,'sql-by-elapsed'],
      'SQL ordered by CPU Time'                 => ['CPU Time (s)',0,99999,'sql-by-cpu'],
      'SQL ordered by User I/O Wait Time'       => ['User I/O Time (s)',0,99999,'sql-by-io'],
   );
```

Looking at the generated text file, you check for one of the headings:

```text
$  grep 'Top 5 Timed Foreground Events' dellemc_awr_1_153556_153557.txt
$
```

... and find that heading doesn't exist.

Well, what headings do exist?

Here is one way to get them:

```text

$  grep -B 6 '\[cols' dellemc_awr_1_153556_153557.txt | grep -E '^[A-Z]{1}[a-z]+'
Load Profile
Instance Efficiency Percentages (Target 100%)
Top 10 Foreground Events by Total Wait Time
Wait Classes by Total Wait Time
Host CPU
Instance CPU
Memory Statistics
Cache Sizes
Shared Pool Statistics
Operating System Statistics
Operating System Statistics - Detail
Service Statistics
Complete List of SQL Text
Key Instance Activity Stats
Other Instance Activity Stats
Instance Activity Stats - Absolute Values
Instance Activity Stats - Thread Activity
Tablespace IO Stats
File IO Stats
Buffer Pool Statistics
Checkpoint Activity
Instance Recovery Stats
Buffer Pool Advisory
Shared Pool Advisory
Streams Pool Advisory
Java Pool Advisory
Buffer Wait Statistics
Undo Segment Stats
Latch Sleep Breakdown
Latch Miss Sources
Mutex Sleep Summary
Segments by Logical Reads
Segments by Physical Reads
Segments by Physical Read Requests
Segments by UnOptimized Reads
Segments by Direct Physical Reads
Segments by Physical Writes
Segments by Physical Write Requests
Segments by Direct Physical Writes
Segments by Table Scans
Segments by DB Blocks Changes
Segments by Row Lock Waits
Dictionary Cache Stats
Library Cache Activity
Streams CPU/IO Usage
Persistent Queues Rate
Persistent Queue Subscribers
Resource Limit Stats
Shared Servers Activity
Shared Servers Rates
Shared Servers Utilization
```

How did that work?

Looking at the file you see that each heading is at some point followed by the columns:

Here for instance is the Top 10 Foreground Events by Total Wait Time

```text
Top 10 Foreground Events by Total Wait Time

[cols=",>,>,>,>,",options="header",]
|========================================================================
|Event |Waits |Total Wait Time (sec) |Wait Avg(ms) |% DB time |Wait Class
```

So now we can add that to %rptFormat

```

   # first non-blank field that indicates start of heading per section
   # array values [first column name, column position, number of metrics to keep,output file]

   %rptFormat = (
      'Load Profile'                            => ['Per Second',1,99999,'load-profile'],
      'Top 5 Timed Foreground Events'           => ['Event',0,99999,'top-foreground-events'],
      'Top 10 Foreground Events by Total Wait Time'     
                                                => ['Event',0,99999,'top-10-foreground-events'],
      'Host CPU'                                => ['Load Average Begin',0,99999,'host-cpu'],
      'Instance CPU'                            => ['%Total CPU',0,99999,'instance-cpu'],
      'Memory Statistics'                       => ['Begin',1,99999,'memory-stats'],
      'Time Model Statistics'                   => ['Statistic Name',0,99999,'time-model-stats'],
      'Operating System Statistics'             => ['Statistic',0,99999,'os-stats'],
      'Operating System Statistics - Detail'    => ['Snap Time',0,99999,'os-stats-detail'],
      'Foreground Wait Class'                   => ['Wait Class',0,99999,'foreground-wait-class'],
      'Foreground Wait Events'                  => ['Event',0,10,'foreground-wait-events'],
      'Background Wait Events'                  => ['Event',0,10,'background-wait-events'],
      'SQL ordered by Elapsed Time'             => ['Elapsed Time (s)',0,99999,'sql-by-elapsed'],
      'SQL ordered by CPU Time'                 => ['CPU Time (s)',0,99999,'sql-by-cpu'],
      'SQL ordered by User I/O Wait Time'       => ['User I/O Time (s)',0,99999,'sql-by-io'],
   );
```

Now we get a `top-10-foreground-events.csv` file.

```text
?  ./parse-awr.sh
pandoc --columns=65000 --eol=lf --ascii -f html -t asciidoc dellemc_awr_1_153556_153557.html -o dellemc_awr_1_153556_153557.txt

     Begin Time: 23-Feb-20 04:30:04
Elapsed Seconds: 1802.4
     DB Seconds: 17496.6

$
>  ls -l *.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 background-wait-events.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 foreground-wait-class.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 foreground-wait-events.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 host-cpu.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 instance-cpu.csv
-rwxr-xr-x 1 jkstill dba 1292 Mar 21 16:16 load-profile.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 memory-stats.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 os-stats-detail.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 os-stats.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 sql-by-cpu.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 sql-by-elapsed.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 sql-by-io.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 time-model-stats.csv
-rwxr-xr-x 1 jkstill dba  900 Mar 21 16:16 top-10-foreground-events.csv
-rwxr-xr-x 1 jkstill dba    0 Mar 21 16:16 top-foreground-events.csv
```

Some contents of the file:

```text
$  head -4 top-10-foreground-events.csv
BeginTime,ElapsedSeconds,DBSeconds,Event,Waits,Total Wait Time (sec),Wait Avg(ms),% DB time,Wait Class
23-Feb-20 04:30:04,1802.4,17496.6,DB CPU,,8764,,50.1,
23-Feb-20 04:30:04,1802.4,17496.6,db file sequential read,6706669,4410.5,1,25.2,User I/O
23-Feb-20 04:30:04,1802.4,17496.6,db file scattered read,2519592,3746.6,1,21.4,User I/O
```

Now, you just need to do the same for the other headings required.

The zero byte files are being output due to headings in %rptFormat for which no data was found.

Just comment out those you don't need.

This is a very ad hoc script, so I am not applying any good practices to it, as it is rather volatile and subject to change.



