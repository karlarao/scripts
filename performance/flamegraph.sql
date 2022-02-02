

select /* usercheck */ s.sid sid, s.serial# serial#, lpad(p.spid,7) unix_pid 
from gv$process p, gv$session s
where p.addr=s.paddr
and   s.username is not null
and (s.inst_id, s.sid) in (select inst_id, sid from gv$mystat where rownum < 2);



-- make sure that you have this set as ROOT
-- [root@localhost ~]# echo -1 > /proc/sys/kernel/perf_event_paranoid


$ cat flamegraph.sql


set lines 200
with d as
(
select '&procid' spid,
       '&&prefix._perf_graph.data' newfilename,
       '&&prefix._perf_graph.data-folded' folded_filename,
       '&&prefix._flamegraph.svg' flamegraph_filename,
       '&&prefix.' tarname
  from dual
)
SELECT
       'perf record -g -p ' || spid || chr(10) ||
       'mv perf.data ' || newfilename || chr(10) ||
       'perf script -i ' || newfilename || ' | ./stackcollapse-perf.pl > ' || folded_filename || chr(10) ||
       'cat ' || folded_filename || '| ./flamegraph.pl > ' || flamegraph_filename || chr(10) ||
       'tar -cjvpf ' || tarname || '_perf_data.tar.bz2 ' || tarname || '*' 
       as commands
  from d
;



COMMANDS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
perf record -g -p 12345
mv perf.data testcase1_perf_graph.data
perf script -i testcase1_perf_graph.data | ./stackcollapse-perf.pl > testcase1_perf_graph.data-folded
cat testcase1_perf_graph.data-folded| ./flamegraph.pl > testcase1_flamegraph.svg
tar -cjvpf testcase1_perf_data.tar.bz2 testcase1*



