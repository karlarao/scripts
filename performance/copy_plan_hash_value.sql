accept plan_hash_value_from -
       prompt 'Enter value for plan_hash_value to generate profile from (X0X0X0X0): ' -
       default 'X0X0X0X0'
accept sql_id_to -
       prompt 'Enter value for sql_id to attach profile to (X0X0X0X0): ' -
       default 'X0X0X0X0'
accept child_no_to -
       prompt 'Enter value for child_no to attach profile to (0): ' -
       default 0
accept category -
       prompt 'Enter value for category (DEFAULT): ' -
       default 'DEFAULT'
accept force_matching -
       prompt 'Enter value for force_matching (false): ' -
       default 'false'


--@rg_sqlprof3 '&sql_id_from' &child_no_from '&sql_id_to' &child_no_to '&category' '&force_matching'

declare
ar_profile_hints sys.sqlprof_attr;
cl_sql_text clob;
v_sql_text_found VARCHAR2 (3) := 'YES';
begin
select
   extractvalue(value(d), '/hint') as outline_hints
bulk collect into
   ar_profile_hints
from
   xmltable('/*/outline_data/hint'
      passing (
         select
            xmltype(other_xml) as xmlval
         from
            dba_hist_sql_plan 
         where
            plan_hash_value = '&&plan_hash_value_from'
            and rownum <= 1
            and other_xml is not null
              )
         ) d;

begin
select
   sql_fulltext
into
   cl_sql_text
from
   v$sql
where
   sql_id = '&&sql_id_to'
   and child_number = &&child_no_to;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   v_sql_text_found := 'NO';
   dbms_output.put_line ('SQL_ID ' || '&&sql_id_to' || ' not found in v$sql');
end;

if v_sql_text_found = 'NO' then
   begin
   select
      sql_text
   into
      cl_sql_text
   from
      dba_hist_sqltext
   where
      sql_id = '&&sql_id_to';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      v_sql_text_found := 'NO';
      dbms_output.put_line ('SQL_ID ' || '&&sql_id_to' || ' not found in dba_hist_sqltext');
   end;
end if;

dbms_sqltune.import_sql_profile (
sql_text => cl_sql_text,
profile => ar_profile_hints,
name => 'SP_'||'&&sql_id_to'||'_'||'&&plan_hash_value_from',
category => '&&category',
replace => true,
force_match => &&force_matching
);
end;
/

undef plan_hash_value_from
undef child_no_from
undef sql_id_to
undef child_no_to
undef category
undef force_matching


