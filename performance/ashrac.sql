set lines 500
column f_days new_value v_days
select .1 f_days from dual;
column f_secs new_value v_secs
select 5 f_secs from dual;
--select &seconds f_secs from dual;
column f_bars new_value v_bars
select 5 f_bars from dual;
column aveact format 999.99
column graph format a50


column fpct format 99.99
column spct format 99.99
column tpct format 99.99
column fasl format 999.99
column sasl format 999.99
column first format a40
column second format a40


select to_char(start_time,'DD HH:MI:SS'),
       samples,
       --total,
       --waits,
       --cpu,
       round(fpct * (total/samples),2) fasl,
       decode(fpct,null,null,first) first,
       round(spct * (total/samples),2) sasl,
       decode(spct,null,null,second) second,
        substr(substr(rpad('+',round((cpu*&v_bars)/samples),'+') ||
        rpad('-',round((waits*&v_bars)/samples),'-')  ||
        rpad(' ',p.value * &v_bars,' '),0,(p.value * &v_bars)) ||
        p.value  ||
        substr(rpad('+',round((cpu*&v_bars)/samples),'+') ||
        rpad('-',round((waits*&v_bars)/samples),'-')  ||
        rpad(' ',p.value * &v_bars,' '),(p.value * &v_bars),10) ,0,50)
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
     , substr(max(decode(top.seq,1,decode(top.event,'ON CPU','CPU',event),null)),0,25) first
     , round(max(decode(top.seq,2,pct,null)),2) spct
     , substr(max(decode(top.seq,2,decode(top.event,'ON CPU','CPU',event),null)),0,25) second
     , round(max(decode(top.seq,3,pct,null)),2) tpct
     , substr(max(decode(top.seq,3,decode(top.event,'ON CPU','CPU',event),null)),0,25) third
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
        gv$active_session_history ash
     where
               sample_time > sysdate - &v_days
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
