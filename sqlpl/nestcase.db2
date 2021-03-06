-----------------------------------------------------------------------------
-- (c) Copyright IBM Corp. 2007 All rights reserved.
-- 
-- The following sample of source code ("Sample") is owned by International 
-- Business Machines Corporation or one of its subsidiaries ("IBM") and is 
-- copyrighted and licensed, not sold. You may use, copy, modify, and 
-- distribute the Sample in any form without payment to IBM, for the purpose of 
-- assisting you in the development of your applications.
-- 
-- The Sample code is provided to you on an "AS IS" basis, without warranty of 
-- any kind. IBM HEREBY EXPRESSLY DISCLAIMS ALL WARRANTIES, EITHER EXPRESS OR 
-- IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Some jurisdictions do 
-- not allow for the exclusion or limitation of implied warranties, so the above 
-- limitations or exclusions may not apply to you. IBM shall not be liable for 
-- any damages you suffer as a result of using, copying, modifying or 
-- distributing the Sample, even if IBM has been advised of the possibility of 
-- such damages.
-----------------------------------------------------------------------------
--
-- SOURCE FILE NAME: nestcase.db2
--    
-- SAMPLE: To create the BUMP_SALARY SQL procedure 
--
-- To create the SQL procedure:
-- 1. Connect to the database
-- 2. Enter the command "db2 -td@ -vf nestcase.db2"
--
-- To call the SQL procedure from the command line:
-- 1. Connect to the database
-- 2. Enter the following command:
--    db2 "CALL bump_salary (51)" 
--
-- You can also call this SQL procedure by compiling and running the
-- C embedded SQL client application, "nestcase", using the nestcase.sqc
-- source file available in the sqlpl samples directory.
-----------------------------------------------------------------------------
--
-- For more information on the sample scripts, see the README file.
--
-- For information on creating SQL procedures, see the Application
-- Development Guide.
--
-- For information on using SQL statements, see the SQL Reference.
--
-- For the latest information on programming, building, and running DB2 
-- applications, visit the DB2 application development website: 
--     http://www.software.ibm.com/data/db2/udb/ad
-----------------------------------------------------------------------------

CREATE PROCEDURE bump_salary (IN deptnumber SMALLINT) 
LANGUAGE SQL 
BEGIN 
   DECLARE SQLSTATE CHAR(5);
   DECLARE v_salary DOUBLE;
   DECLARE v_id SMALLINT;
   DECLARE v_years SMALLINT;
   DECLARE at_end INT DEFAULT 0;
   DECLARE not_found CONDITION FOR SQLSTATE '02000';

   DECLARE C1 CURSOR FOR
     SELECT id, CAST(salary AS DOUBLE), years 
     FROM staff 
     WHERE dept = deptnumber;
   DECLARE CONTINUE HANDLER FOR not_found 
     SET at_end = 1;

   OPEN C1;
   FETCH C1 INTO v_id, v_salary, v_years;
   WHILE at_end = 0 DO
     CASE 
       WHEN (v_salary < 15000 * v_years)
         THEN CASE
           WHEN (15500*v_years > 99000)
             THEN UPDATE staff 
               SET salary = 99000 
               WHERE id = v_id;
           ELSE UPDATE staff
               SET salary = 15500* v_years
               WHERE id = v_id;
         END CASE;
       WHEN (v_salary < 30000 * v_years)
         THEN CASE 
           WHEN (v_salary < 20000 * v_years)
             THEN CASE
               WHEN (20000*v_years > 99000)
                 THEN UPDATE staff
                   SET salary = 99000
                   WHERE id = v_id;
               ELSE UPDATE staff 
                 SET salary = 20000 * v_years 
                 WHERE id = v_id;
              END CASE;
           ELSE UPDATE staff 
             SET salary = v_salary * 1.10 
             WHERE id = v_id;
         END CASE;
       ELSE UPDATE staff 
         SET job = 'PREZ' 
         WHERE id = v_id;
     END CASE;
     FETCH C1 INTO v_id, v_salary, v_years;
   END WHILE;
   CLOSE C1;
END @
