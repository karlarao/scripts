
-- (c) Kyle Hailey 2007


set termout off 
set lines 500
column f_days new_value v_days
--select &days f_days from dual;
column f_secs new_value v_secs
select 900 f_secs from dual;
--select &seconds f_secs from dual;
column f_bars new_value v_bars
select 20 f_bars from dual;
column aveact format 999.99
column graph format a80
set termout on


column fpct format 9.99
column spct format 9.99
column tpct format 9.99
column aas1 format 9.99
column aas2 format 9.99
column first format a30
column second format a30
column third format a30

select to_char(start_time,'DD HH:MI:SS'),
       samples,
       --total,
       --waits,
       --cpu,
       round(fpct * (total/samples),2) aas1,
       decode(fpct,null,null,first) first,
       round(spct * (total/samples),2) aas2,
       decode(spct,null,null,second) second,
        substr(substr(rpad('+',round((cpu*&v_bars)/samples),'+') ||
        rpad('-',round((waits*&v_bars)/samples),'-')  ||
        rpad(' ',p.value * &v_bars,' '),0,(p.value * &v_bars)) ||
        p.value  ||
        substr(rpad('+',round((cpu*&v_bars)/samples),'+') ||
        rpad('-',round((waits*&v_bars)/samples),'-')  ||
        rpad(' ',p.value * &v_bars,' '),(p.value * &v_bars),10) ,0,30)
        graph
     --  spct,
     --  decode(spct,null,null,second) second,
     --  tpct,
     --  decode(tpct,null,null,third) third
from (
select start_time
     , max(samples) samples
     , sum(top.total) total
     , round(max(decode(top.seq,1,pct,null)),2) fpct
     , substr(max(decode(top.seq,1,decode(top.event,'ON CPU','CPU',event),null)),0,30) first
     , round(max(decode(top.seq,2,pct,null)),2) spct
     , substr(max(decode(top.seq,2,decode(top.event,'ON CPU','CPU',event),null)),0,30) second
     , round(max(decode(top.seq,3,pct,null)),2) tpct
     , substr(max(decode(top.seq,3,decode(top.event,'ON CPU','CPU',event),null)),0,30) third
     , sum(waits) waits
     , sum(cpu) cpu
from (
  select
       to_date(tday||' '||tmod*&v_secs,'YYMMDD SSSSS') start_time
     , event
     , total
     , row_number() over ( partition by id order by total desc ) seq
     , ratio_to_report( sum(total)) over ( partition by id ) pct
     , max(samples) samples
     , sum(decode(event,'ON CPU',total,0))    cpu
     , sum(decode(event,'ON CPU',0,total))    waits
  from (
    select
         to_char(sample_time,'YYMMDD')                      tday
       , trunc(to_char(sample_time,'SSSSS')/&v_secs)          tmod
       , to_char(sample_time,'YYMMDD')||trunc(to_char(sample_time,'SSSSS')/&v_secs) id
       , decode(ash.session_state,'ON CPU','ON CPU',ash.event)     event
       , sum(decode(session_state,'ON CPU',1,decode(session_type,'BACKGROUND',0,1))) total
       , (max(sample_id)-min(sample_id)+1)                    samples
     from
        dba_hist_active_sess_history ash
     where sample_time between TIMESTAMP'&_start_time' and TIMESTAMP'&_end_time'
     group by  trunc(to_char(sample_time,'SSSSS')/&v_secs)
            ,  to_char(sample_time,'YYMMDD')
            ,  decode(ash.session_state,'ON CPU','ON CPU',ash.event)
     order by
               to_char(sample_time,'YYMMDD'),
               trunc(to_char(sample_time,'SSSSS')/&v_secs)
  )  chunks
  group by id, tday, tmod, event, total
) top
group by start_time
) aveact,
  v$parameter p
where p.name='cpu_count'
order by start_time
/
