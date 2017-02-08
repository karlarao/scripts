
$ORACLE_HOME/rdbms/admin/awrinfo.sql;
Master Note on AWR Warehouse (Doc ID 1907335.1)

AWR warehouse objects



CAW_SPACE_USAGE        :   Populates  resource  consumpOon  dashboard  for  AWR. 
CAW_PROPERTIES         :  InformaOon  about  locaOon  of  dump  files,  interval,  retenOon  Ome,  etc.  for  AWR  Warehouse.
CAW_PRIV_GRANTS        :  View  privileges  within  the  EM  Console 
CAW_LOAD_WORKERS       :  Only  used  during  an  actual  ETL  load  process  to  the  AWR  Warehouse
CAW_SRC_DBS            :  Main  info  about  source  db’s,  version,  ETL  status,  etc. 
CAW_SRC_DB_INSTANCES   :  Instance  informaOon  about  source  databases. 
CAW_LOAD_METADATA      :  AWR  dump  file  local,  last  load,  etc.
CAW_LOAD_ERRORS        :   Populates  the  errors  view  in  the  console. 
CAW_DBID_MAPPING       :  Used  to  map  all  data  between  Enterprise  Manager,  AWR  Warehouse  and  Database  IdenOfiers. 



warehouse objects 

SQL> select object_name, object_type, owner from dba_objects where object_name like 'CAW%' order by 2;
OBJECT_NAME             OBJECT_TYPE  OWNER
CAW_LOAD_METADATA_PK    INDEX        DBSNMP
CAW_LOAD_METADATA_IDX1  INDEX        DBSNMP
CAW_PRIV_GRANTS_UK1     INDEX        DBSNMP
CAW_SRC_DBS_PK          INDEX        DBSNMP
CAW_DBID_MAPPING_UK1    INDEX        DBSNMP
CAW_SRC_DBS_UK1         INDEX        DBSNMP
CAW_EM_ID_SEQ           SEQUENCE     DBSNMP
CAW_DUMP_ID_SEQ         SEQUENCE     DBSNMP
CAW_DELETE_SEQ          SEQUENCE     DBSNMP
CAW_DBID_SEQ            SEQUENCE     DBSNMP
CAW_SRC_ID_SEQ          SEQUENCE     DBSNMP
CAW_DBID_MAPPING_SEQ    SEQUENCE     DBSNMP
CAW_PRIV_GRANTS         TABLE        DBSNMP
CAW_LOAD_METADATA       TABLE        DBSNMP
CAW_PROPERTIES          TABLE        DBSNMP
CAW_SPACE_USAGE         TABLE        DBSNMP
CAW_LOAD_WORKERS        TABLE        DBSNMP
CAW_LOAD_ERRORS         TABLE        DBSNMP
CAW_DBID_MAPPING        TABLE        DBSNMP
CAW_SRC_DB_INSTANCES    TABLE        DBSNMP
CAW_SRC_DBS             TABLE        DBSNMP


21 rows selected.




SQL> select * from dbsnmp.caw_src_dbs;

Error starting at line : 1 in command -
select * from dbsnmp.caw_src_dbs
Error at Command Line : 1 Column : 22
Error report -
SQL Error: ORA-00942: table or view does not exist
00942. 00000 -  "table or view does not exist"
*Cause:
*Action:


SQL> select 'grant select on ' || object_name || ' to karlarao;' from dba_objects where object_name like 'CAW%';
'GRANTSELECTON'||OBJECT_NAME||'TOKARLARAO;'
grant select on CAW_DBID_MAPPING to karlarao;
grant select on CAW_DBID_MAPPING_SEQ to karlarao;
grant select on CAW_DBID_MAPPING_UK1 to karlarao;
grant select on CAW_DBID_SEQ to karlarao;
grant select on CAW_DELETE_SEQ to karlarao;
grant select on CAW_DUMP_ID_SEQ to karlarao;
grant select on CAW_EM_ID_SEQ to karlarao;
grant select on CAW_LOAD_ERRORS to karlarao;
grant select on CAW_LOAD_METADATA to karlarao;
grant select on CAW_LOAD_METADATA_IDX1 to karlarao;
grant select on CAW_LOAD_METADATA_PK to karlarao;
grant select on CAW_LOAD_WORKERS to karlarao;
grant select on CAW_PRIV_GRANTS to karlarao;
grant select on CAW_PRIV_GRANTS_UK1 to karlarao;
grant select on CAW_PROPERTIES to karlarao;
grant select on CAW_SPACE_USAGE to karlarao;
grant select on CAW_SRC_DBS to karlarao;
grant select on CAW_SRC_DBS_PK to karlarao;
grant select on CAW_SRC_DBS_UK1 to karlarao;
grant select on CAW_SRC_DB_INSTANCES to karlarao;
grant select on CAW_SRC_ID_SEQ to karlarao;


21 rows selected.

