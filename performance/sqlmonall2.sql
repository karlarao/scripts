set lines 32767

col txt format a500
select /* usercheck */ s.INST_ID ||','|| TO_CHAR(sysdate,'MM/DD/YY HH24:MI:SS') ||','|| s.terminal ||','|| s.machine ||','|| p.username ||','|| s.username ||','|| s.osuser ||','|| s.module ||','|| s.action ||','|| s.program ||','|| s.schemaname ||','||
  s.state ||','||
  s.client_info ||','|| s.status ||','|| s.sid ||','|| s.serial# ||','|| lpad(p.spid,7) ||','||
  sa.plan_hash_value ||','||
  s.sql_id ||','|| 
  replace(replace(replace(substr(sa.sql_text,1,50),',',' '),'/',' '),'"',' ') ||','|| substr(event,1,50) ||','|| s.LAST_CALL_ET txt
from gv$process p, gv$session s, gv$sqlarea sa
where p.addr=s.paddr
and   s.username is not null
and   s.inst_id = p.inst_id 
and   s.sql_address=sa.address(+)
and   s.sql_hash_value=sa.hash_value(+)
and   sa.sql_text NOT LIKE '%usercheck%'
-- and   lower(sa.sql_text) LIKE '%grant%'
and lower(s.username) like nvl('&1', lower(s.username))
-- and s.schemaname = 'SYSADM'
-- and lower(s.program) like '%uscdcmta21%'
-- and s.sid=12
-- and p.spid  = 14967
-- and s.sql_hash_value = 3963449097
-- and s.sql_id = '5p6a4cpc38qg3'
-- and lower(s.client_info) like '%10036368%'
-- and s.module like 'PSNVS%'
-- and s.program like 'PSNVS%'
order by 1 asc
/

exit
