-- Doug Gault/Kerry Osborne/Karl Arao
-- pull host CPU speed info from inside Oracle across platforms even through TNS
-- =================================================================================================
-- Look at the database to decide whether JAVA is installed. If so, Create the JAVA & PL/SQL objects 
-- =================================================================================================
SET feedback OFF;
SET SERVEROUTPUT ON SIZE 1000000;
CALL DBMS_JAVA.SET_OUTPUT(1000000);
--
DECLARE
  l_java_installed NUMBER;
  l_output DBMS_OUTPUT.chararr;
  l_lines       INTEGER := 1000;
  l_java_object VARCHAR2(32767);
  l_pls_wrapper VARCHAR2(32767);
  l_drop_java   varchar2(32767);
BEGIN
  --
  -- Check to see if Java is installed in the database
  --
  SELECT COUNT(*)
  INTO l_java_installed
  FROM all_registry_banners
  WHERE banner LIKE '%JAVA_Virtual Machine%';
  --
  -- If Java is installed, create the Java Objects and execute
  --
  IF (l_java_installed > 0) THEN
    --
    -- Create the Java Object that get the CPU info.
    --
    l_java_object := q'! 
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED "ENK_GET_CPUINFO" AS
import java.io.*;
public class ENK_GET_CPUINFO {
  public static void executeCommand() {
    try {
      String[] finalCommand;
      if (isWindows()) {
        finalCommand = new String[4];
        // Use the appropriate path for your windows version.
        //finalCommand[0] = "C:\\winnt\\system32\\cmd.exe";    // Windows NT/2000
        finalCommand[0] = "C:\\windows\\system32\\cmd.exe";    // Windows XP/2003
        //finalCommand[0] = "C:\\windows\\syswow64\\cmd.exe";  // Windows 64-bit
        finalCommand[1] = "/y";
        finalCommand[2] = "/c";
      }
      else if (isLinux()) {
        finalCommand = new String[3];
        finalCommand[0] = "/bin/sh";
        finalCommand[1] = "-c";
        finalCommand[2] = "PATH=/usr/local/bin:/bin:/usr/bin;cat /proc/cpuinfo | grep -i name | sort | uniq | cut -b 13-";
      }
      else if (isSolaris()) {
        finalCommand = new String[3];
        finalCommand[0] = "/bin/sh";
        finalCommand[1] = "-c";
        finalCommand[2] = "PATH=/usr/local/bin:/bin:/usr/bin;prsinfo -v | grep -i processor | uniq";
      }
      else if (isAIX()) {
        finalCommand = new String[3];
        finalCommand[0] = "/bin/sh";
        finalCommand[1] = "-c";
        finalCommand[2] = "PATH=/usr/local/bin:/bin:/usr/bin;uname -m";
      }
      else {
        finalCommand = new String[3];
        finalCommand[0] = "/bin/sh";
        finalCommand[1] = "-c";
        finalCommand[2] = "PATH=/usr/local/bin:/bin:/usr/bin;uname -a";
      }
      final Process pr = Runtime.getRuntime().exec(finalCommand);
      pr.waitFor();
      new Thread(new Runnable(){
        public void run() {
          BufferedReader br_in = null;
          try {
            br_in = new BufferedReader(new InputStreamReader(pr.getInputStream()));
            String buff = null;
            while ((buff = br_in.readLine()) != null) {
              System.out.println("Process out :" + buff);
              try {Thread.sleep(100); } catch(Exception e) {}
            }
            br_in.close();
          }
          catch (IOException ioe) {
            System.out.println("Exception caught printing process output.");
            ioe.printStackTrace();
          }
          finally {
            try {
              br_in.close();
            } catch (Exception ex) {}
          }
        }
      }).start();
      new Thread(new Runnable(){
        public void run() {
          BufferedReader br_err = null;
          try {
            br_err = new BufferedReader(new InputStreamReader(pr.getErrorStream()));
            String buff = null;
            while ((buff = br_err.readLine()) != null) {
              System.out.println("Process err :" + buff);
              try {Thread.sleep(100); } catch(Exception e) {}
            }
            br_err.close();
          }
          catch (IOException ioe) {
            System.out.println("Exception caught printing process error.");
            ioe.printStackTrace();
          }
          finally {
            try {
              br_err.close();
            } catch (Exception ex) {}
          }
        }
      }).start();
    }
    catch (Exception ex) {
      System.out.println(ex.getLocalizedMessage());
    }
  }
  public static boolean isWindows() {
    if (System.getProperty("os.name").toLowerCase().indexOf("windows") != -1)
      return true;
    else
      return false;
  }
  public static boolean isLinux() {
    if (System.getProperty("os.name").toLowerCase().indexOf("linux") != -1)
      return true;
    else
      return false;
  }
  public static boolean isSolaris() {
    if (System.getProperty("os.name").toLowerCase().indexOf("solaris") != -1)
      return true;
    else
      return false;
  }
  public static boolean isAIX() {
    if (System.getProperty("os.name").toLowerCase().indexOf("aix") != -1)
      return true;
    else
      return false;
  }
};!';
--
EXECUTE IMMEDIATE l_java_object;
    --
    -- Create the PL/SQL Wrapper
    --
    l_pls_wrapper := q'! 
CREATE OR REPLACE PROCEDURE ENK_GET_CPU_INFO
AS LANGUAGE JAVA 
NAME 'ENK_GET_CPUINFO.executeCommand()';!';
    
    EXECUTE IMMEDIATE l_pls_wrapper;
    
COMMIT;

  ELSE
    --
    -- Java is not installed - Tell the user
    --
    dbms_output.put_line('The JAVA VM was not found in the databse. Please install and run this script again');
  END IF;
END;
/
-- =================================================================================================
-- Now that the objects have been created, run them and get the output.
--   
-- NOTE: This has to be in a separate PL/SQL Block as the object is not recognized in the same block
-- =================================================================================================

DECLARE 
  l_java_installed NUMBER := 0;
  l_proc_exists    NUMBER := 0;
  l_output DBMS_OUTPUT.chararr;
  l_lines       INTEGER := 1000;
BEGIN

  SELECT COUNT(*)
  INTO l_java_installed
  FROM all_registry_banners
  WHERE banner LIKE '%JAVA_Virtual Machine%';
  
  select count(*) 
  into l_proc_exists 
  from user_objects 
  where object_name = 'ENK_GET_CPU_INFO';
  --
  -- If Java is installed, create the Java Objects and execute
  --
  IF (l_java_installed > 0) and (l_proc_exists >0 ) THEN
    --
    -- Now execute the pls wrapper to get the CPU info
    --
    DBMS_OUTPUT.enable(1000000);
    DBMS_JAVA.set_output(1000000);
    ENK_GET_CPU_INFO;
    DBMS_OUTPUT.get_lines(l_output, l_lines);
    FOR i IN 1 .. l_lines
    LOOP
      DBMS_OUTPUT.put_line(l_output(i));
    END LOOP;
  ELSE
    --
    -- OBJECTS is not installed - Tell the user
    --
    dbms_output.put_line('The JAVA VM or the ENK_GET_CPU_INFO object was not found in the databse.');
  END IF;

END;
/
-- =================================================================================================
-- Clean up after ourselves and drop the PL/SQL and JAVA objects
--   
-- NOTE: This has to be in a separate PL/SQL Block as the object is not recognized in the same block
-- =================================================================================================

DECLARE 
  l_drop_java   varchar2(32767);
  l_java_installed NUMBER := 0;
  l_proc_exists    NUMBER := 0;
BEGIN 
 SELECT COUNT(*)
  INTO l_java_installed
  FROM all_registry_banners
  WHERE banner LIKE '%JAVA_Virtual Machine%';
  
  select count(*) 
  into l_proc_exists 
  from user_objects 
  where object_name = 'ENK_GET_CPU_INFO';
  --
  -- If Java is installed, create the Java Objects and execute
  --
  IF (l_java_installed > 0) and (l_proc_exists >0 ) THEN
    --
    -- Now Drop the PL/SQL Wrapper 
    -- 
    EXECUTE IMMEDIATE 'drop procedure ENK_GET_CPU_INFO';
    --
    -- And then drop the Java Object(s)
    --
l_drop_java := q'!
DECLARE
    CURSOR curs1 IS
      SELECT OBJECT_NAME, OBJECT_TYPE FROM SYS.ALL_OBJECTS  where  OBJECT_NAME = 'ENK_GET_CPUINFO'
      order by CASE OBJECT_TYPE WHEN 'JAVA SOURCE' THEN 1
      WHEN 'JAVA CLASS' THEN 2
      ELSE 3 END;
  
    ONAME VARCHAR2(30);
    OTYPE VARCHAR2(30);
    
    BEGIN
      open curs1;
      fetch curs1 into ONAME, OTYPE;
      if curs1%notfound then
           return;
      else  
         if OTYPE='JAVA CLASS' THEN
            execute immediate 'DROP JAVA CLASS "' || ONAME || '"';
          ELSIF OTYPE='JAVA SOURCE' THEN
            execute immediate 'DROP JAVA SOURCE "' || ONAME || '"';
          ELSE
            execute immediate 'DROP JAVA RESOURCE "' || ONAME || '"';
          end if;
      end if;
    EXCEPTION
       WHEN OTHERS THEN
         if OTYPE = 'JAVA CLASS' then
           ONAME := DBMS_JAVA.derivedFrom(ONAME, 'DEMO', 'CLASS');
           execute immediate 'DROP JAVA SOURCE "' || ONAME || '"';
         end if; 
    CLOSE curs1;
    END;!';

   EXECUTE IMMEDIATE l_drop_java;

ELSE
    --
    -- OBJECTS is not installed - Tell the user
    --
    dbms_output.put_line('Objects Not installed / Nothing to do.');
END IF;

end;
/
