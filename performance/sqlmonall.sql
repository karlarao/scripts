set lines 32767
col terminal format a4
col machine format a4
col os_login format a4
col oracle_login format a4
col osuser format a4
col module format a5
col program format a8
col schemaname format a5
-- col state format a8
col client_info format a5
col status format a4
col sid format 99999
col serial# format 99999
col unix_pid format a8
col txt format a50
col action format a8
select /* usercheck */ s.INST_ID, s.terminal terminal, s.machine machine, p.username os_login, s.username oracle_login, s.osuser osuser, s.module, s.action, s.program, s.schemaname,
  s.state,
  s.client_info, s.status status, s.sid sid, s.serial# serial#, lpad(p.spid,7) unix_pid, -- s.sql_hash_value, 
  sa.plan_hash_value, -- remove in 817, 9i
  s.sql_id,     -- remove in 817, 9i
  substr(sa.sql_text,1,1000) txt
from gv$process p, gv$session s, gv$sqlarea sa
where p.addr=s.paddr
and   s.username is not null
and   s.inst_id = p.inst_id
and   s.sql_address=sa.address(+)
and   s.sql_hash_value=sa.hash_value(+)
and   sa.sql_text NOT LIKE '%usercheck%'
-- and   lower(sa.sql_text) LIKE '%grant%'
and lower(s.username) like nvl('&username', lower(s.username))
-- and s.schemaname = 'SYSADM'
-- and lower(s.program) like '%uscdcmta21%'
-- and s.sid=12
-- and p.spid  = 14967
-- and s.sql_hash_value = 3963449097
-- and s.sql_id = '5p6a4cpc38qg3'
-- and lower(s.client_info) like '%10036368%'
-- and s.module like 'PSNVS%'
-- and s.program like 'PSNVS%'
order by status desc;
