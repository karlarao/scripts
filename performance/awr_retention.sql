set lines 300
-- TO VIEW RETENTION INFORMATION
select * from dba_hist_wr_control;
set lines 300
select b.name, a.DBID,
   ((TRUNC(SYSDATE) + a.SNAP_INTERVAL - TRUNC(SYSDATE)) * 86400)/60 AS SNAP_INTERVAL_MINS,
      ((TRUNC(SYSDATE) + a.RETENTION - TRUNC(SYSDATE)) * 86400)/60 AS RETENTION_MINS,
         ((TRUNC(SYSDATE) + a.RETENTION - TRUNC(SYSDATE)) * 86400)/60/60/24 AS RETENTION_DAYS,
	    TOPNSQL
	    from dba_hist_wr_control a, v$database b
	    where a.dbid = b.dbid;
