spool hcc_estimate.txt append
set serveroutput on
DECLARE
  l_blkcnt_cmp       BINARY_INTEGER;
  l_blkcnt_uncmp     BINARY_INTEGER;
  l_row_cmp          BINARY_INTEGER;
  l_row_uncmp        BINARY_INTEGER;
  l_cmp_ratio        NUMBER;
  l_comptype_str     VARCHAR2(100);
BEGIN
  FOR i IN (SELECT table_name
            FROM user_tables
            WHERE compression = 'DISABLED'
            AND table_name in (&1) -- put table names here
            ORDER BY table_name)
  LOOP
    FOR j IN 1..5
    LOOP
      dbms_compression.get_compression_ratio(
        -- input parameters
        scratchtbsname   => 'TS_SCRATCH',       -- scratch tablespace
        ownname          => user,            -- owner of the table
        tabname          => i.table_name,    -- table name
        partname         => NULL,            -- partition name
        comptype         => power(2,j),      -- compression algorithm
        -- output parameters
        blkcnt_cmp       => l_blkcnt_cmp,    -- number of compressed blocks
        blkcnt_uncmp     => l_blkcnt_uncmp,  -- number of uncompressed blocks
        row_cmp          => l_row_cmp,       -- number of rows in a compressed block
        row_uncmp        => l_row_uncmp,     -- number of rows in an uncompressed block
        cmp_ratio        => l_cmp_ratio,     -- compression ratio
        comptype_str     => l_comptype_str   -- compression type
      );
      dbms_output.put_line(i.table_name||' - '||'type: '||l_comptype_str||' ratio: '||to_char(l_cmp_ratio,'99.999'));
    END LOOP;
  END LOOP;
END;
/
spool off

