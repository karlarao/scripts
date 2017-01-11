
-- troubleshooting steps

1) check alert log for this error message 

  Wed Sep 21 13:39:19 2011 > WAITED TOO LONG FOR A ROW CACHE ENQUEUE LOCK! pid=37
  System State dumped to trace file /oracle/diag/rdbms/..../.trc

2) check for v$session

  select sid,username,sql_id,event current_event,p1text,p1,p2text,p2,p3text,p3
  from v$session
  where event='row cache lock'
  /

3) check for ASH 

  select *
  from dba_hist_active_sess_history
  where sample_time between to_date('26-MAR-14 12:49:00','DD-MON-YY HH24:MI:SS')
  and to_date('26-MAR-14 12:54:00','DD-MON-YY HH24:MI:SS')
  and event = 'row cache lock'
  order by sample_id
  /


4) check SGA resize operations 

  select component, oper_type, initial_size, final_size, to_char (start_time, 'dd/mm/yy hh24:mi') start_date, to_char (end_time, 'dd/mm/yy hh24:mi') end_date
  from v$memory_resize_ops
  where status = 'complete'
  order by start_time desc, component
  /

5) get enqueue type 

  select *
  from v$rowcache
  where cache# IN (select P1
  from dba_hist_active_sess_history
  where sample_time between to_date('26-MAR-14 12:49:00','DD-MON-YY HH24:MI:SS')
  and to_date('26-MAR-14 12:54:00','DD-MON-YY HH24:MI:SS')
  and event = 'row cache lock' )
  /

-- get most affected latch 
  select latch#, child#, sleeps
  from v$latch_children
  where name='row cache objects'
  and sleeps > 0
  order by sleeps desc;

-- get detailed latch miss info 
  select "WHERE", sleep_count, location
  from v$latch_misses
  where parent_name='row cache objects'
  and sleep_count > 0;

6) ash wait chains 


7) ash query dump 

  select *
  from dba_hist_active_sess_history
  where sample_time between to_date('26-MAR-14 12:49:00','DD-MON-YY HH24:MI:SS')
  and to_date('26-MAR-14 12:54:00','DD-MON-YY HH24:MI:SS')
  and event = 'row cache lock' order by sample_id
  /

8) last resort 

  conn / as sysdba
  alter session set max_dump_file_size=unlimited;
  alter session set events 'immediate trace name SYSTEMSTATE level 266';
  alter session set events 'immediate trace name SYSTEMSTATE level 266';
  alter session set events 'immediate trace name SYSTEMSTATE level 266';




-- modes 

WAITEVENT: "row cache lock" Reference Note (Doc ID 34609.1)
Parameters:

P1 = cache - ID of the dictionary cache
P2 = mode - Mode held
P3 = request - Mode requested


cache - ID of the dictionary cache
Row cache lock we are waiting for. Note that the actual CACHE# values differ between Oracle versions. The cache can be found using this select - "PARAMETER" is the cache name:
SELECT cache#, type, parameter 
FROM v$rowcache 
WHERE cache# = &P1
In a RAC environment the row cache locks use global enqueues of type "Q[A-Z]" with the lock id being the hashed object name.


mode - Mode held
The mode the lock is currently held in:
KQRMNULL 0 null mode - not locked
KQRMS 3 share mode
KQRMX 5 exclusive mode
KQRMFAIL 10 fail to acquire instance lock


request - Mode requested
The mode the lock is requested in:
KQRMNULL 0 null mode - not locked
KQRMS 3 share mode
KQRMX 5 exclusive mode
KQRMFAIL 10 fail to acquire instance lock