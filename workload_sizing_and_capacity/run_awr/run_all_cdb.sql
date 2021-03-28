-- run_all.sql
-- Karl Arao, Oracle ACE (bit.ly/karlarao), OCP-DBA, RHCE
-- http://karlarao.wordpress.com
--

DEF v_object_prefix = 'v$';
DEF skip_11g_script = '';
COL skip_11g_script NEW_V skip_11g_script;
SELECT ' -- skip 11g ' skip_11g_column, ' echo skip 11g ' skip_11g_script FROM &&v_object_prefix.instance WHERE version LIKE '11%' or version LIKE '10%';

DEF skip_12c_script = '';
COL skip_12c_script NEW_V skip_12c_script;
SELECT ' -- skip 12c ' skip_12c_column, ' echo skip 12c ' skip_12c_script FROM &&v_object_prefix.instance WHERE version LIKE '12%' or version LIKE '18%' or version LIKE '19%';


@run_awr_topevents.sql
@run_awr_sysstat.sql
@run_awr_sgapga.sql
@run_awr_cpuwl.sql
@run_awr_cpuwl_ash.sql
@run_awr_iowl.sql
@run_awr_iostat_filetype.sql
@run_awr_storagesize.sql
@run_awr_netclient.sql
@run_awr_services.sql
@run_awr_topsql.sql
@host_cpu.sql
@&&skip_12c_script.gvash_to_csv_hist.sql
--@&&skip_12c_script.gvash_to_csv.sql
@&&skip_11g_script.0_gvash_cdb_calcfield_12c.sql
@&&skip_11g_script.0_gvash_to_csv_hist_12c.sql
--@&&skip_11g_script.0_gvash_to_csv_12c.sql
@run_awr_topsegments_rw_io.sql
@run_awr_topsegments_space_used.sql
@s06_run_awr_topsql_bigobj_topn_v3_by_elap.sql
@s06_run_awr_topsql_bigobj_topn_v3_by_elap_exec.sql
@s06_run_awr_topsql_bigobj_topn_v3_by_exec.sql
@s01_celliorm.sql
@s01_cellver.sql
@s02_asmfree.sql
@s03_db_size.sql
@s04_ts_size.sql
@s05_obj_size.sql
@s10_hcc_tables_ts.sql
@0_parsing_schema.sql
@0_service_names.sql
-- @run_awr_planx.sql
-- @run_esp_master.sql
-- @run_awr_miner.sql

exit
