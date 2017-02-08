## Check the service name used by each session
select inst_id, username, SERVICE_NAME, RESOURCE_CONSUMER_GROUP, count(*) 
from gv$session 
where SERVICE_NAME <> 'SYS$BACKGROUND'
group by inst_id, username, SERVICE_NAME, RESOURCE_CONSUMER_GROUP order by 2,3,1;

## List the Active Resource Consumer Groups since instance startup
select INST_ID, NAME, ACTIVE_SESSIONS, EXECUTION_WAITERS, REQUESTS, CPU_WAIT_TIME, CPU_WAITS, CONSUMED_CPU_TIME, YIELDS, QUEUE_LENGTH, ACTIVE_SESSION_LIMIT_HIT 
from gV$RSRC_CONSUMER_GROUP 
-- where name in ('SYS_GROUP','BATCH','OLTP','OTHER_GROUPS') 
order by 2,1;

## Session level details
SET pagesize 50
SET linesize 155
SET wrap off
COLUMN name format a11 head "Consumer|Group"
COLUMN sid format 9999
COLUMN username format a16
COLUMN CONSUMED_CPU_TIME head "Consumed|CPU time|(s)" format 999999.9
COLUMN IO_SERVICE_TIME head "I/O time|(s)" format 999999.9
COLUMN CPU_WAIT_TIME head "CPU Wait|Time (s)" FOR 99999
COLUMN CPU_WAITS head "CPU|Waits" format 99999
COLUMN YIELDS head "Yields" format 99999
COLUMN state format a10
COLUMN osuser format a8
COLUMN machine format a16
COLUMN PROGRAM format a12
 
SELECT
          rcg.name
        , rsi.sid
        , s.username
        , rsi.state
        , rsi.YIELDS
        , rsi.CPU_WAIT_TIME / 1000 AS CPU_WAIT_TIME
        , rsi.CPU_WAITS
        , rsi.CONSUMED_CPU_TIME / 1000 AS CONSUMED_CPU_TIME
        , rsi.IO_SERVICE_TIME /1000 AS IO_SERVICE_TIME
        , s.osuser
        , s.program
        , s.machine
        , sw.event
FROM V$RSRC_SESSION_INFO rsi INNER JOIN v$rsrc_consumer_group rcg
ON rsi.CURRENT_CONSUMER_GROUP_ID = rcg.id
INNER JOIN v$session s ON rsi.sid=s.sid
INNER JOIN v$session_wait sw ON s.sid = sw.sid
WHERE rcg.id !=0 -- _ORACLE_BACKGROUND_GROUP_
and (sw.event != 'SQL*Net message from client' or rsi.state='RUNNING')
ORDER BY rcg.name, s.username,rsi.cpu_wait_time + rsi.IO_SERVICE_TIME + rsi.CONSUMED_CPU_TIME ASC, rsi.state, sw.event, s.username, rcg.name,s.machine,s.osuser
/

## By consumer group - time series
set linesize 160
set pagesize 60
set colsep '  '
 
column total                    head "Total Available|CPU Seconds"      format 99990
column consumed                 head "Used|Oracle Seconds"              format 99990.9
column consumer_group_name      head "Consumer|Group Name"              format a25      wrap off
column "throttled"              head "Oracle Throttled|Time (s)"        format 99990.9
column cpu_utilization          head "% of Host CPU"                    format 99990.9
break on time skip 2 page
 
select to_char(begin_time, 'YYYY-DD-MM HH24:MI:SS') time,
consumer_group_name,
60 * (select value from v$osstat where stat_name = 'NUM_CPUS') as total,
cpu_consumed_time / 1000 as consumed,
cpu_consumed_time / (select value from v$parameter where name = 'cpu_count') / 600 as cpu_utilization,
cpu_wait_time / 1000 as throttled,
IO_MEGABYTES
from v$rsrcmgrmetric_history
order by begin_time,consumer_group_name
/

## High level
set linesize 160
set pagesize 50
set colsep '  '  
column "Total Available CPU Seconds"    head "Total Available|CPU Seconds"      format 99990
column "Used Oracle Seconds"            head "Used Oracle|Seconds"              format 99990.9
column "Used Host CPU %"                head "Used Host|CPU %"                  format 99990.9
column "Idle Host CPU %"                head "Idle Host|CPU %"                  format 99990.9
column "Total Used Seconds"             head "Total Used|Seconds"               format 99990.9
column "Idle Seconds"                   head "Idle|Seconds"                     format 99990.9
column "Non-Oracle Seconds Used"        head "Non-Oracle|Seconds Used"          format 99990.9
column "Oracle CPU %"                   head "Oracle|CPU %"                     format 99990.9
column "Non-Oracle CPU %"               head "Non-Oracle|CPU %"                 format 99990.9
column "throttled"                      head "Oracle Throttled|Time (s)"        format 99990.9
 
select to_char(rm.BEGIN_TIME,'YYYY-MM-DD HH24:MI:SS') as BEGIN_TIME
        ,60 * (select value from v$osstat where stat_name = 'NUM_CPUS') as "Total Available CPU Seconds"
        ,sum(rm.cpu_consumed_time) / 1000 as "Used Oracle Seconds"
        ,min(s.value) as "Used Host CPU %"
        ,(60 * (select value from v$osstat where stat_name = 'NUM_CPUS')) * (min(s.value) / 100) as "Total Used Seconds"
        ,((100 - min(s.value)) / 100) * (60 * (select value from v$osstat where stat_name = 'NUM_CPUS')) as "Idle Seconds"
        ,((60 * (select value from v$osstat where stat_name = 'NUM_CPUS')) * (min(s.value) / 100)) - sum(rm.cpu_consumed_time) / 1000 as "Non-Oracle Seconds Used"
        ,100 - min(s.value) as "Idle Host CPU %"
        ,((((60 * (select value from v$osstat where stat_name = 'NUM_CPUS')) * (min(s.value) / 100)) - sum(rm.cpu_consumed_time) / 1000) / (60 * (select value from v$osstat where stat_name = 'NUM_CPUS')))*100 as "Non-Oracle CPU %"
        ,(((sum(rm.cpu_consumed_time) / 1000) / (60 * (select value from v$osstat where stat_name = 'NUM_CPUS'))) * 100) as "Oracle CPU %"
        , sum(rm.cpu_wait_time) / 1000 as throttled
from    gv$rsrcmgrmetric_history rm
        inner join
        gV$SYSMETRIC_HISTORY s
        on rm.begin_time = s.begin_time
where   s.metric_id = 2057
  and   s.group_id = 2
group by rm.begin_time,s.begin_time
order by rm.begin_time
/
