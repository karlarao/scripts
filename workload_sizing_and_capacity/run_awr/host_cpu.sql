COLUMN name NEW_VALUE _instname NOPRINT
select lower(instance_name) name from v$instance;

-- cpu info for linux, aix and solaris. expect some errors
SET TERM OFF ECHO OFF FEED OFF VER OFF HEA OFF PAGES 0 COLSEP ', ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;
SPO hostcommands_driver.sql
SELECT decode(  platform_id,
                13,'HOS cat /proc/cpuinfo | grep -i name | sort | uniq | cat - /sys/devices/virtual/dmi/id/product_name >> cpuinfo_model_name-&_instname..txt', -- Linux x86 64-bit
                6,'HOS lsconf | grep Processor >> cpuinfo_model_name-&_instname..txt', -- AIX-Based Systems (64-bit)
                2,'HOS psrinfo -v >> cpuinfo_model_name-&_instname..txt', -- Solaris[tm] OE (64-bit)
                4,'HOS machinfo >> cpuinfo_model_name-&_instname..txt' -- HP-UX IA (64-bit)
        ) from v$database, product_component_version
where 1=1
and to_number(substr(product_component_version.version,1,2)) > 9
and lower(product_component_version.product) like 'oracle%';
SPO OFF
SET DEF ON
@hostcommands_driver.sql
set feed on echo on

