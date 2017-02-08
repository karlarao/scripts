select table_name,num_rows,blocks,compression,compress_for
from dba_tables
where owner='HCCUSER'
and compression = 'ENABLED';

