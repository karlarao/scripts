##################################################################################################
#  Name:        Oracle.py                                                                        #
#  Author:      Randy Johnson                                                                    #
#  Description: This is a Python library for Oracle. It is an attempt to create a library for    #
#               functions that are common to many DBA scripts.                                   #
#  Contents:    LoadOratab(OratabFilename='/etc/oratab')                                         #
#               RunSqlplus(Sql, ErrChk=False, ConnectString='/ as sysdba')                       #
#               RunRman(RCV, ErrChk=True, ConnectString='target /'                               #
#               ErrorCheck(Stdout, ComponentList=['ALL_COMPONENTS'])                             #
#               LookupError(Error)                                                               #
#               PrintError(Sql, Stdout, ErrorList)                                               #
#               LoadFacilities(FacilitiesFile)                                                   #
#               SetOracleEnv(Sid, Oratab='/etc/oratab')                                          #
#                                                                                                #
# History:                                                                                       #
#                                                                                                #
# Date       Ver. Who              Change Description                                            #
# ---------- ---- ---------------- ------------------------------------------------------------- #
# 04/06/2012 1.00 Randy Johnson    Initial release.                                              #
# 04/24/2012 1.10 Randy Johnson    Fixed bug caused when LD_LIBRARY_PATH is not set.             #
# 07/10/2014 1.20 Randy Johnson    Added a ton of settings and column formatting to RunSqlplus.  #
#                                                                                                #
# Todo's                                                                                         #
#                                                                                                #
##################################################################################################

# --------------------------------------
# ---- Import Python Modules -----------
# --------------------------------------
from subprocess import PIPE, Popen, STDOUT
from os         import environ
from os.path    import isfile
from re         import match, search
from string     import join, strip
from sys        import exit, exc_info
from signal     import SIGPIPE, SIG_DFL, signal
import traceback


# For handling termination in stdout pipe.
#  ex. when you run: oerrdump | head
#--------------------------------------------
signal(SIGPIPE, SIG_DFL)


# --------------------------------------
# ---- Function Definitions ------------
# --------------------------------------
# Def  : FormatExceptionInfo()
# Desc : Format and print Python stack trace
# Args : maxTBlevel (default 5). Levels of the call stack.
# Retn : cla=name of exception class, exc=details of exception,
#        trbk=traceback info (call stack)
#---------------------------------------------------------------------------
def FormatExceptionInfo(maxTBlevel=5):
  cla, exc, trbk = exc_info()
  excName = cla.__name__
  try:
    excArgs = exc.__dict__["args"]
  except KeyError:
    excArgs = "<no args>"
  excTb = traceback.format_tb(trbk, maxTBlevel)

  print excName, excArgs
  for line in excTb:
    print line
  return(excName, excArgs, excTb)
# End FormatExceptionInfo()


# Def : LoadOratab()
# Desc: Parses the oratab file and returns a dictionary structure of:
#        {'dbm'      : '/u01/app/oracle/product/11.2.0.3/dbhome_1',
#         'biuat'    : '/u01/app/oracle/product/11.2.0.3/dbhome_1',
#         ...
#        }
#       Note** the start/stop flag is parsed but not saved.
#       If the fully qualified oratab file name is passed in it is prepended
#       to a list of standard locations (/etc/oratab, /var/opt/oracle/oratab)
#       This list of oratab locations are then searched in order. The first
#       one to be successfully opened will be used.
# Args: OratabFile (optional, defaults to /etc/oratab)
# Retn: Oratab (dictionary object)
#---------------------------------------------------------------------------
def LoadOratab(OratabFilename=''):
  OraSid   =  ''
  OraHome  = ''
  OraFlag  = ''
  Oratab = {}
  OratabLocations = ['/etc/oratab','/var/opt/oracle/oratab']

  # If an oratab file name has been passed in...
  if (OratabFilename != ''):
    # If the oratab file name passed in is not already in the list of common locations...
    if (not (OratabFilename in OratabLocations)):
      OratabLocations.insert(0, OratabFilename)

  for OratabFilename in OratabLocations:
    if (isfile(OratabFilename)):
      try:
        otab = open(OratabFilename)
        break                          # exit the loop if the file can be opened.
      except:
        FormatExceptionInfo()
        print '\nCannot open oratab file: ' + OratabFile + ' for read.'
        return {}

  OratabContents = otab.read().split('\n')
  for line in OratabContents:
    pos = line.find('#')
    if (pos >= 0):                     # Comment character found.
      line = line[0:pos]
    line = line.strip()
    if (line != ''):
      Count = line.count(':')
      if (Count == 2):
        try:
          (OraSid, OraHome, OraFlag) = line.split(':')
          Oratab[OraSid] = OraHome
        except:
          pass
      elif (Count == 1):
        try:
          (OraSid, OraHome) = line.split(':')
          Oratab[OraSid] = OraHome
        except:
          pass
  return(Oratab)
# End LoadOratab()


# Def : RunSqlplus()
# Desc: Calls sqlplus and runs a sql script passed in in the Sql parameter.
#       Optionally calls ErrorCheck() to scan for errors then calls PrintError
#       if any are found. The call stack looks like this...
#       CallingRoutine
#          ^    +-----> RunSqlplus()
#          |                +-----> ErrorCheck()
#          |                +-----> PrintError()
#          |                            +-----> LookupError()
#          |                                          |
#          |                +--> if error exit(rc)    |
#          +------------------------------------------+
#
#          1) Calling routing calls RunSqlplus
#                - 1 parameter. SQL to run (string)
#                - Returns Result Set (1 string)
#          2) RunSqlplus calls ErrorCheck
#                - 2 parameters. Stdout (string), and ComponentList (List of components for looking up potential errors)
#                - Returns 2 values. Return code (int), and ErrorStack which is a list of lists ([ErrorString, line]
#          3) RunSqlplus calls PrintError
#                - Only if return code from ErrorCheck != 0 (an error was found)
#                - Calls PrintError with three parameters:
#                    Sql       = the original SQL statement run.
#                    Stdout    = the output generated by the sqlplus session.
#                    ErrorList = the list of error codes and lines containing the errors (see #2 above).
#                - Returns Stdout to calling routine.
#
# Args: Sql, string containing SQL to execute.
#       ErrChk, True/False determines whether or not to check output for errors.
#       ConnectString, used for connecting to the database
# Retn: If ErrChk=True then return:
#          rc (return code, integer, 0=no errors)
#          Output (string, stdout+stderr)
#          ErrorList (list, error stack)
#       If ErrChk=False then return Stdout only
#---------------------------------------------------------------------------
def RunSqlplus(Sql, ErrChk=False, ConnectString='/ as sysdba'):
  SqlHeader = ''
  
  #SqlHeader  = "-- alter session set nls_date_format = 'YYYYMMDD HH24:MI:SS';\n"
  #SqlHeader += "-- set serveroutput on size 1000000 format wrapped\n"
  #SqlHeader += "-- set serveroutput on size unlimited\n"
  #SqlHeader += "-- set truncate after linesize on\n"
  #SqlHeader += "\n"
  SqlHeader += "btitle                          off\n"
  SqlHeader += "repfooter                       off\n"
  SqlHeader += "repheader                       off\n"
  SqlHeader += "ttitle                          off\n"
  SqlHeader += "set appinfo                     off\n"
  SqlHeader += "set arraysize                   500\n"
  SqlHeader += "set autocommit                  off\n"
  SqlHeader += "set autoprint                   off\n"
  SqlHeader += "set autorecovery                off\n"
  SqlHeader += "set autotrace                   off\n"
  SqlHeader += "set blockterminator             \".\"\n"
  SqlHeader += "set cmdsep                      off\n"
  SqlHeader += "set colsep                      \" \"\n"
  SqlHeader += "set concat                      \".\"\n"
  SqlHeader += "set copycommit                  0\n"
  SqlHeader += "set copytypecheck               on\n"
  SqlHeader += "set define                      \"&\"\n"
  SqlHeader += "set describe                    depth 1 linenum off indent on\n"
  SqlHeader += "set document                    off\n"
  SqlHeader += "set echo                        off\n"
  SqlHeader += "set embedded                    off\n"
  SqlHeader += "set errorlogging                off\n"
  SqlHeader += "set escape                      off\n"
  SqlHeader += "set escchar                     off\n"
  SqlHeader += "set exitcommit                  on\n"
  SqlHeader += "set feedback                    off\n"
  SqlHeader += "set flagger                     off\n"
  SqlHeader += "set flush                       on\n"
  SqlHeader += "set heading                     on\n"
  SqlHeader += "set headsep                     \"|\"\n"
  SqlHeader += "set linesize                    32767\n"
  SqlHeader += "set loboffset                   1\n"
  SqlHeader += "set logsource                   \"\"\n"
  SqlHeader += "set long                        10000000\n"
  SqlHeader += "set longchunksize               10000000\n"
  SqlHeader += "set markup html                 off \n"
  SqlHeader += "set newpage                     1\n"
  SqlHeader += "set null                        \"\"\n"
  SqlHeader += "set numformat                   \"\"\n"
  SqlHeader += "set numwidth                    15\n"
  SqlHeader += "set pagesize                    50\n"
  SqlHeader += "set pause                       off\n"
  SqlHeader += "set pno                         0\n"
  SqlHeader += "set recsep                      wrap\n"
  SqlHeader += "set recsepchar                  \" \"\n"
  SqlHeader += "set securedcol                  off\n"
  SqlHeader += "set serveroutput                on size unlimited\n"
  SqlHeader += "set shiftinout                  invisible\n"
  SqlHeader += "set showmode                    off\n"
  SqlHeader += "set space                       1\n"
  SqlHeader += "set sqlblanklines               off\n"
  SqlHeader += "set sqlcase                     mixed\n"
  SqlHeader += "set sqlcontinue                 \"> \"\n"
  SqlHeader += "set sqlnumber                   on\n"
  SqlHeader += "set sqlprefix                   \"#\"\n"
  SqlHeader += "set sqlterminator               \";\"\n"
  SqlHeader += "set suffix                      sql\n"
  SqlHeader += "set tab                         off\n"
  SqlHeader += "set termout                     on\n"
  SqlHeader += "set time                        off\n"
  SqlHeader += "set timing                      off\n"
  SqlHeader += "set trimout                     on\n"
  SqlHeader += "set trimspool                   on\n"
  SqlHeader += "set underline                   \"-\"\n"
  SqlHeader += "set verify                      off\n"
  SqlHeader += "set wrap                        on\n"
  SqlHeader += "set xmloptimizationcheck        off\n"
  SqlHeader += "\n"
  
  SqlHeader += "column BLOCKS                   format 999,999,999,999\n"
  SqlHeader += "column BYTES                    format 999,999,999,999\n"
  SqlHeader += "column BYTES_CACHED             format 999,999,999,999\n"
  SqlHeader += "column BYTES_COALESCED          format 999,999,999,999\n"
  SqlHeader += "column BYTES_FREE               format 999,999,999,999\n"
  SqlHeader += "column BYTES_USED               format 999,999,999,999\n"
  SqlHeader += "column CLU_COLUMN_NAME          format a40\n"
  SqlHeader += "column CLUSTER_NAME             format a30\n"
  SqlHeader += "column CLUSTER_TYPE             format a10\n"
  SqlHeader += "column COLUMN_NAME              format a40\n"
  SqlHeader += "column COMPATIBILITY            format a15\n"
  SqlHeader += "column CONSTRAINT_NAME          format a30\n"
  SqlHeader += "column DATABASE_COMPATIBILITY   format a15\n"
  SqlHeader += "column DB_LINK                  format a20\n"
  SqlHeader += "column DBNAME                   format a10\n"
  SqlHeader += "column DIRECTORY_NAME           format a30\n"
  SqlHeader += "column DIRECTORY_PATH           format a100\n"
  SqlHeader += "column EXTENTS                  format 999,999\n"
  SqlHeader += "column FILE_NAME                format a50\n"
  SqlHeader += "column FUNCTION_NAME            format a30\n"
  SqlHeader += "column GBYTES                   format 999,999,999\n"
  SqlHeader += "column GRANTEE                  format a15\n"
  SqlHeader += "column GRANTEE_NAME             format a15\n"
  SqlHeader += "column HOST                     format a20\n"
  SqlHeader += "column HOST_NAME                format a15\n"
  SqlHeader += "column INDEX_NAME               format a30\n"
  SqlHeader += "column INDEX_OWNER              format a15\n"
  SqlHeader += "column INDEX_TYPE               format a10\n"
  SqlHeader += "column INSTANCE_NAME            format a10\n"
  SqlHeader += "column IOT_NAME                 format a30\n"
  SqlHeader += "column IOT_TYPE                 format a15\n"
  SqlHeader += "column JOB_MODE                 format a10\n"
  SqlHeader += "column KSPPINM                  format a20\n"
  SqlHeader += "column KSPPSTVL                 format a20\n"
  SqlHeader += "column MASTER_OWNER             format a15\n"
  SqlHeader += "column MBYTES                   format 999,999,999\n"
  SqlHeader += "column MEMBER                   format a60\n"
  SqlHeader += "column MESSAGE                  format a50\n"
  SqlHeader += "column MVIEW_NAME               format a30\n"
  SqlHeader += "column MVIEW_TABLE_OWNER        format a15\n"
  SqlHeader += "column NAME                     format a50\n"
  SqlHeader += "column NUM_ROWS                 format 999,999,999\n"
  SqlHeader += "column OBJECT_NAME              format a30\n"
  SqlHeader += "column OBJECT_OWNER             format a15\n"
  SqlHeader += "column OBJECT_TYPE              format a13\n"
  SqlHeader += "column OPERATION                format a10\n"
  SqlHeader += "column OPNAME                   format a40\n"
  SqlHeader += "column OWNER                    format a15\n"
  SqlHeader += "column OWNER_NAME               format a15\n"
  SqlHeader += "column PARTITION_NAME           format a30\n"
  SqlHeader += "column PARTNAME                 format a30\n"
  SqlHeader += "column PARTTYPE                 format a10\n"
  SqlHeader += "column PATH                     format a40\n"
  SqlHeader += "column R_CONSTRAINT_NAME        format a30\n"
  SqlHeader += "column R_OWNER                  format a15\n"
  SqlHeader += "column SEGMENT_NAME             format a30\n"
  SqlHeader += "column SEGMENT_TYPE             format a10\n"
  SqlHeader += "column SEQUENCE_NAME            format a30\n"
  SqlHeader += "column SEQUENCE_OWNER           format a15\n"
  SqlHeader += "column SNAPNAME                 format a30\n"
  SqlHeader += "column SNAPSHOT                 format a30\n"
  SqlHeader += "column STATE                    format a10\n"
  SqlHeader += "column STATISTIC                format a50\n"
  SqlHeader += "column SYNONYM_NAME             format a30\n"
  SqlHeader += "column TABLE_NAME               format a30\n"
  SqlHeader += "column TABLE_OWNER              format a15\n"
  SqlHeader += "column TABLE_SCHEMA             format a15\n"
  SqlHeader += "column TABLESPACE_NAME          format a30\n"
  SqlHeader += "column TARGET_DESC              format a35\n"
  SqlHeader += "column TRIGGER_NAME             format a30\n"
  SqlHeader += "column TRIGGER_OWNER            format a15\n"
  SqlHeader += "column TYPE_NAME                format a30\n"
  SqlHeader += "column TYPE_OWNER               format a15\n"
  SqlHeader += "column USED_BLOCKS              format 999,999,999,999\n"
  SqlHeader += "column USERNAME                 format a20\n"
  SqlHeader += "column VALUE                    format a30\n"
  SqlHeader += "column VIEW_NAME                format a30\n"
  SqlHeader += "column VIEW_TYPE                format a10\n"
  
  Sql = SqlHeader + Sql

  # Unset the SQLPATH environment variable.
  if ('SQLPATH' in environ.keys()):
    del environ['SQLPATH']

  if (ConnectString == '/ as sysdba'):
    if (not('ORACLE_SID' in environ.keys())):
      print 'ORACLE_SID must be set if connect string is:' + ' \'' + ConnectString + '\''
      return (1, '', [])
    if (not('ORACLE_HOME' in environ.keys())):
      OracleSid, OracleHome = SetOracleEnv(environ['ORACLE_SID'])

  # Set the location of the ORACLE_HOME. If ORACLE_HOME is not set
  # then we'll use the first one we find in the oratab file.
  if ('ORACLE_HOME' in environ.keys()):
    OracleHome = environ['ORACLE_HOME']
    Sqlplus = OracleHome + '/bin/sqlplus'
  else:
    Oratab = LoadOratab()
    if (len(Oratab) >= 1):
      SidList = Oratab.keys()
      OracleSid  = SidLit[0]
      OracleHome = Oratab[SidList[0]]
      environ['ORACLE_HOME'] = OracleHome
      Sqlplus = OracleHome + '/bin/sqlplus'
    else:
      print 'ORACLE_HOME is not set'
      return (1, '', [])

  # Start Sqlplus and login
  Sqlproc = Popen([Sqlplus, '-S', '-R', '3', ConnectString], stdin=PIPE, stdout=PIPE, stderr=STDOUT, \
   shell=False, universal_newlines=True, close_fds=True)

  # Execute the SQL
  Sqlproc.stdin.write(Sql)

  # Fetch the output
  Stdout, SqlErr = Sqlproc.communicate()
  Stdout = Stdout.strip()      # remove leading/trailing whitespace

  # Check for sqlplus errors
  if (ErrChk):
    from Oracle import ErrorCheck, LookupError
    # Components are installed applications/components such as sqlplus, import, export, rdbms, network, ...
    # ComponentList contains a list of all components for which the error code will be searched.
    # For example a component of rdbms will result in ORA-nnnnn errors being included in the search.
    # ALL_COMPONENTS is an override in the ErrorCheck function that results in *all* installed components
    # being selected. Searching all component errors is pretty fast so for now we'll just search them all.
    # -------------------------------------------------------------------------------------------------------
    #ComponentList = ['sqlplus','rdbms','network','crs','css','evm','has','oracore','plsql','precomp','racg','srvm','svrmgr']
    #ComponentList = ['ALL_COMPONENTS']
    ComponentList = ['sqlplus','rdbms', 'oracore']

    # Brief explanation of what is returned by ErrorCheck()
    # ------------------------------------------------------
    # rc is the return code (0 is good, anything else is bad). ErrorList is a list of list structures
    # (a 2 dimensional arrray in other languages). Each outer element of the array represents 1 error found
    # Sql output. Each inner element has two parts (2 fields), element[0] is the Oracle error code and
    # element[1] is the full line of text in which the error was found.
    # For example an ErrorList might look like this:
    # [['ORA-00001', 'ORA-00001: unique constraint...'],['ORA-00018', 'ORA-00018, 00000, "maximum number of..."']]
    (rc, ErrorList) = ErrorCheck(Stdout, ComponentList)
    return(rc,Stdout,ErrorList)
  else:
    return(Stdout)
# End RunSqlplus()


# Def : RunRman()
# Desc: Runs rman commands.
# Args: RCV, string, containing rman commands or run block to execute.
#       ErrChk, True/False determines whether or not to check output for errors.
#       ConnectString, used for connecting to the database
# Retn: If ErrChk=True then return:
#          rc (return code, integer, 0=no errors)
#          Output (string, stdout+stderr)
#          ErrorList (list, error stack)
#       If ErrChk=False then return Stdout only
#---------------------------------------------------------------------------
def RunRman(RCV, ErrChk=True, ConnectString='target /'):
  if (ConnectString == '/ as sysdba'):
    if (not('ORACLE_SID' in environ.keys())):
      print 'ORACLE_SID must be set if connect string is:' + ' \'' + ConnectString + '\''
      return (1, '', [])
    if (not('ORACLE_HOME' in environ.keys())):
      OracleSid, OracleHome = SetOracleEnv(environ['ORACLE_SID'])

  # Set the location of the ORACLE_HOME. If ORACLE_HOME is not set
  # then we'll use the first one we find in the oratab file.
  if ('ORACLE_HOME' in environ.keys()):
    OracleHome = environ['ORACLE_HOME']
    Rman = OracleHome + '/bin/rman'
  else:
    Oratab = LoadOratab()
    if (len(Oratab) >= 1):
      SidList = Oratab.keys()
      OracleSid  = SidList[0]
      OracleHome = Oratab[SidList[0]]
      environ['ORACLE_HOME'] = OracleHome
      Rman = OracleHome + '/bin/rman'
    else:
      print 'ORACLE_HOME is not set'
      return (1, '', [])

  # Start Rman and login
  proc = Popen([Rman, 'target', '/'], bufsize=-1, stdin=PIPE, stdout=PIPE, stderr=STDOUT, \
   shell=False, universal_newlines=True, close_fds=True)

  # Execute the Sql and fetch the output -
  # Stderr is just a placeholder. We redirected stderr to stdout as follows 'stderr=STDOUT'.
  (Stdout, Stderr) = proc.communicate(RCV)

  # Check for rman errors
  if (ErrChk):
    from Oracle import ErrorCheck, ErrorCheck, LookupError, LoadFacilities
    # Components are installed applications/components such as sqlplus, import, export, rdbms, network, ...
    # ComponentList contains a list of all components for which the error code will be searched.
    # For example a component of rdbms will result in ORA-nnnnn errors being included in the search.
    # ALL_COMPONENTS is an override in the ErrorCheck function that results in *all* installed components
    # being selected. Searching all component errors is pretty fast so for now we'll just search them all.
    # -------------------------------------------------------------------------------------------------------
    #ComponentList = ['sqlplus','rdbms','network','crs','css','evm','has','oracore','plsql','precomp','racg','srvm','svrmgr']
    ComponentList = ['ALL_COMPONENTS']

    # Brief explanation of what is returned by ErrorCheck()
    # ------------------------------------------------------
    # rc is the return code (0 is good, anything else is bad). ErrorList is a list of list structures
    # (a 2 dimensional arrray in other languages). Each outer element of the array represents 1 error found
    # Sql output. Each inner element has two parts (2 fields), element[0] is the Oracle error code and
    # element[1] is the full line of text in which the error was found.
    # For example an ErrorList might look like this:
    # [['ORA-00001', 'ORA-00001: unique constraint...'],['ORA-00018', 'ORA-00018, 00000, "maximum number of..."']]
    (rc, ErrorList) = ErrorCheck(Stdout, ComponentList)
    return(rc,Stdout,ErrorList)
  else:
    return(Stdout)
# End RunRman()


# Def : ErrorCheck()
# Desc: Check tnsping, sqlplus, crsctl, srvctl output for errors.
# Args: Output(output you want to scan for errors)
# Retn: Returns 0=no errors or 1=error found, and error stack (in list form)
#-------------------------------------------------------------------------
def ErrorCheck(Stdout, ComponentList=['ALL_COMPONENTS']):
  from Oracle import LoadFacilities

  FacilityList = []
  ErrorStack   = []
  rc           = 0

  if ('ORACLE_HOME' in environ.keys()):
    OracleHome = environ['ORACLE_HOME']
    FacilitiesFile = OracleHome + '/lib/facility.lis'
    FacilitiesDD = LoadFacilities(FacilitiesFile)
  else:
    print 'ORACLE_HOME is not set'
    return (1, [])


    # Determine what errors to check for....
  for key in sorted(FacilitiesDD.keys()):
    if (ComponentList[0].upper() == 'ALL_COMPONENTS'):
      for Component in ComponentList:
        FacilityList.append(key.upper())
    else:
      for Component in ComponentList:
        if (Component == FacilitiesDD[key]['Component']):
          FacilityList.append(key.upper())

  # Component:
  #  Facility class is major error type such as SP1, SP2, IMP, TNS, ...
  #  Component class is the application such as sqlplus, rdbms, imp, network.
  #  A component can have several error facilities. For example the sqlplus
  #  has 5:
  #    grep sqlplus  /u01/app/oracle/product/11.2.0.3/dbhome_1/lib/facility.lis
  #    cpy:sqlplus:*:
  #    sp1:sqlplus:*:
  #    sp2:sqlplus:*:
  #    sp3:sqlplus:*:
  #    spw:sqlplus:*:
  #
  #  The error SP2-06063 breaks down as Component=sqlplus, Facility=sp2, Error=06063. See below:
  #    SP2-06063 : 06063,0, "When SQL*Plus starts, and after CONNECT commands, the site profile\n"
  #    SP2-06063 : // *Document: NO
  #    SP2-06063 : // *Cause:  Usage message.
  #    SP2-06063 : // *Action:

  for line in Stdout.split('\n'):
    for Facility in FacilityList:
      # Check for warning and error messages
      matchObj = search(Facility + '-[0-9]+', line)
      if (matchObj):
        ErrorString = matchObj.group()
        rc = 1
        ErrorStack.append([ErrorString, line])

  return(rc, ErrorStack)
# End ErrorCheck()

# Def : LookupError()
# Desc: Parses the ficiliy file and returns a list of lists (2 dim array)
#       containing:
#         facility:component:rename:description
# Args: Facility file name.
# Retn: FacilitiesDD
#---------------------------------------------------------------------------
def LookupError(Error):
  MsgList     = []
  HeaderFound = False

  if ('ORACLE_HOME' in environ.keys()):
    OracleHome = environ['ORACLE_HOME']
    FacilitiesFile = OracleHome + '/lib/facility.lis'
    FacilitiesDD = LoadFacilities(FacilitiesFile)
  else:
    print 'ORACLE_HOME is not set'
    return (1, [])

  try:
    (Facility,ErrCode) = Error.lower().split('-')
  except:
    print '\nInvalid error code.'
    exit(1)

  if (not Facility in FacilitiesDD.keys()):
    print '\nInvalid facility:', Facility
    exit(1)
  else:
    MessagesFile = OracleHome + '/' + FacilitiesDD[Facility]['Component'] + '/' + 'mesg' + '/' + Facility + 'us.msg'

  try:
    msgfil = open(MessagesFile, 'r')
  except:
    print '\nCannot open Messages file: ' + MessagesFile + ' for read.'
    exit(1)

  MsgFileContents = msgfil.readlines()

  for line in MsgFileContents:
    # lines I'm looking for look like this "00003, 00000, "INTCTL: error while se..."
    # So just looking for something that starts with a string of digits and contains
    # the error code I'm looking for.
    if (HeaderFound):
        matchObj = match(r'//,*', line)
        if (matchObj):
          MsgList.append(line.strip())
        else:
          return(MsgList)
    else:
      matchObj = match('[0]*' + ErrCode + ',', line)
      if (matchObj):
          ErrCode = matchObj.group()
          ErrCode = ErrCode[0:ErrCode.find(',')]
          MsgList.append(line.strip())
          HeaderFound = True

  if (len(MsgList) == 0):
    # If error code could not be found let's trim off leading 0's and try again...
    ErrCode = str(int(ErrCode))
    for line in MsgFileContents:
      if (HeaderFound):
          matchObj = match(r'//,*', line)
          if (matchObj):
            MsgList.append(line.strip())
          else:
            return(MsgList)
      else:
        matchObj = match('[0]*' + ErrCode + ',', line)
        if (matchObj):
            ErrCode = matchObj.group()
            ErrCode = ErrCode[0:ErrCode.find(',')]
            MsgList.append(line.strip())
            HeaderFound = True

  if (len(MsgList) == 0):
    print 'Error not found  : ' + ErrCode
    print 'Msg file         : ' + MessagesFile

  return(MsgList)
# End LookupError()


# Def : PrintError()
# Desc: Print a formatted error message.
# Args: ErrorMsg (the error message to be printed)
# Retn:
#---------------------------------------------------------------------------
def PrintError(Sql, Stdout, ErrorList):
  print '\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
  print Sql
  print '\n----\n'
  print Stdout
  print '\n----'
  print
  for Error in ErrorList:
    OracleError = Error[0]
    ErrorString = Error[1]
    Explanation = LookupError(OracleError)
    if (len(Explanation) > 0):
      print '\nExplanation:'
      print '---------------'
      for line in Explanation:
        print line
  print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n'
  return
# End PrintError()


# Def : LoadFacilities()
# Desc: Parses the ficiliy file and returns a list of lists (2 dim array)
#       containing:
#         facility:component:rename:description
# Args: Facility file name.
# Retn: FacilitiesDD
#---------------------------------------------------------------------------
def LoadFacilities(FacilitiesFile):
  FacDict = {}
  FacDD   = {}

  try:
    facfil = open(FacilitiesFile, 'r')
  except:
    formatExceptionInfo()
    print '\nCannot open facilities file: ' + FacilitiesFile + ' for read.'
    exit(1)

  FacFileContents = facfil.read().split('\n')
  for line in FacFileContents:
    if (not (search(r'^\s*$', line))):   # skip blank lines
      if (line.find('#') >= 0):
        line=line[0:line.find('#')]
      if (line.count(':') == 3):   # ignore lines that do not contain 3 :'s
        (Facility, Component, OldName, Description) = line.split(':')
        FacList = [strip(Facility), strip(Component), strip(OldName), strip(Description)]
        if (Facility != ''):
          FacDict = {
           'Component'   : strip(Component),
           'OldName'      : strip(OldName),
           'Description' : strip(Description)
          }
          FacDD[strip(Facility)] = FacDict
  return(FacDD)
# End LoadFacilities()

# Def : SetOracleEnv()
# Desc: Setup your environemnt, eg. ORACLE_HOME, ORACLE_SID. (Parses oratab
#       file).
# Args: Sid = The ORACLE_SID of the home you want to configure for
# Retn: OracleHome = $ORACLE_HOME
#---------------------------------------------------------------------------
def SetOracleEnv(Sid, Oratab='/etc/oratab'):
  OracleSid = ''
  OracleHome = ''

  Oratab = LoadOratab()
  SidCount = len(Oratab.keys())

  if (SidCount > 0):
    if (Sid in Oratab.keys()):
      OracleSid  = Sid
    else:
      OracleSid = Oratab.keys()[0]           # Just grab the first ORACLE_SID if none provided.

  if (OracleSid == ''):
    print 'Cannot configure Oracle environment. Try setting your Oracle environment manually.'
    exit(1)
  else:
    OracleHome = Oratab[OracleSid]
    environ['ORACLE_SID']  = OracleSid
    environ['ORACLE_HOME'] = OracleHome

    if ('LD_LIBRARY_PATH' in environ.keys()):
      if (environ['LD_LIBRARY_PATH'] != ''):
        environ['LD_LIBRARY_PATH'] = OracleHome + '/lib' + ':' + environ['LD_LIBRARY_PATH']       # prepend to LD_LIBRARY_PATH
      else:
        environ['LD_LIBRARY_PATH'] = OracleHome + '/lib'
    else:
      environ['LD_LIBRARY_PATH'] = OracleHome + '/lib'

  return(OracleSid, OracleHome)
# End SetOracleEnv()

# Function: GetPassword()
# Desc    : Retrieve database password from the password file.
# Args    : db_unique_name, database username
# Retn    : If success then returns passwprd. If not return
#           blank.
# ------------------------------------------------------------
def GetPassword(Name, User, Decrypt, PasswdFilename='/home/oracle/dba/etc/.passwd'):

  try:
    PasswdFile = open(PasswdFilename, 'r')
    pwdContents = PasswdFile.read()

  except:
    print '\nCannot open password file for read:', PasswdFilename

  for pwdLine in pwdContents.split('\n'):
    if (not (match(r'^\s*$', pwdLine))):               # skip blank lines
      if (not (match(r'^\s#\s*$', pwdLine))):          # skip commented lines
        if (pwdLine.count(':') == 2):                  # ignore lines that do not contain 2 colon's (:).
          (pwDbname, pwUser, pwPass) = pwdLine.split(':')
          if ((pwDbname == Name) and ( pwUser.upper() == User.upper()) and (pwPass != '')):
            if (Decrypt):
              pwPass = pwPass.decode('base64','strict')
            return(pwPass)
  return('')
# End GetPassword()

# def GetDbState()
# Desc: Get the current state of the database (down, mounted, open)
# Args: $0 is the database connect string
# Retn: MOUNTED/OPEN/STARTED
#-------------------------------------------------------------------------
def GetDbState(Sid):
  StateQry    = ''
  DbState    = 'STOPPED'
  rc         = 0
  ErrorStack = []

  StateQry  = "set lines 2000"                                 + '\n'
  StateQry += "set pages 0"                                   + '\n'
  StateQry += "set feedback off"                              + '\n'
  StateQry += "set echo off"                                  + '\n'
  StateQry += "set pagesize 0"                                + '\n'
  StateQry += "SELECT '" + Sid + "'||'~'||"
  StateQry +=        "'db_state'||'~'||upper(status)"         + '\n'
  StateQry += "  FROM v$instance;"                            + '\n'
  StateQry += "EXIT"                                          + '\n'

  # Fetch parameters from the database
  (rc,Stdout,ErrorList) = RunSqlplus(StateQry, True)
  if (Stdout.find('ORA-01034') >= 0):
    DbState = 'STOPPED'
  else:
    strlen = len(Sid + '~db_state~')
    pos = Stdout.find(Sid + '~db_state~')
    DbState = Stdout[strlen:]

  return DbState
# End GetDbState()



# Def : FormatNumber()
# Desc: Simple function to format numbers with commas to separate thousands.
# Args: s    = numeric_string
#       tSep = thousands_separation_character (default is ',')
#       dSep = decimal_separation_character (default is '.')
# Retn: formatted string
#---------------------------------------------------------------------------
def FormatNumber( s, tSep=',', dSep='.'):
  # Splits a general float on thousands. GIGO on general input.
  if s == None:
    return(0)
  if not isinstance( s, str ):
    s = str( s )

  cnt=0
  numChars=dSep+'0123456789'
  ls=len(s)
  while cnt < ls and s[cnt] not in numChars: cnt += 1

  lhs = s[ 0:cnt ]
  s = s[ cnt: ]
  if dSep == '':
    cnt = -1
  else:
    cnt = s.rfind( dSep )
  if cnt > 0:
    rhs = dSep + s[ cnt+1: ]
    s = s[ :cnt ]
  else:
    rhs = ''

  splt=''
  while s != '':
    splt= s[ -3: ] + tSep + splt
    s = s[ :-3 ]

  return(lhs + splt[ :-1 ] + rhs)
# End FormatNumber
