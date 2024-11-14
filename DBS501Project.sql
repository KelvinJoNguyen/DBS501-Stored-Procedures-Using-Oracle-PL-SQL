/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/04/11
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/
SET SERVEROUTPUT ON;


-- 2. Add a new row to the STAFF table 
CREATE OR REPLACE PROCEDURE staff_add(inName IN VARCHAR2, inJob IN VARCHAR2, inSalary IN NUMBER, inComm IN NUMBER) AS 
-- Declare variables
    newEmpID staff.id%TYPE;
    maxID staff.id%TYPE;
  
BEGIN
-- Find latest ID, increment by 10 
    SELECT MAX(id) INTO maxID FROM staff;
    newEmpID := maxID + 10;
-- Name must be inputted
    IF inName IS NULL THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Employee name cannot be NULL.');
        RETURN;
    END IF;
    
-- Job must be inputted - check for proper job
    IF inJob NOT IN ('Sales', 'Clerk', 'Mgr') THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Job input must be Sales, Clerk or Mgr.');
        RETURN;
    END IF;
    
-- Salary must be inputted
    IF inSalary <= 0 THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Salary cannot be 0.');
        RETURN;
    END IF;
    
-- Commision must be inputted
    IF inComm <= 0 THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Commision cannot be 0.');
        RETURN;
    END IF;
    
-- Insert record into staff table
    INSERT INTO staff(id, name, dept, job, years, salary, comm)
    VALUES(newEmpID, inName, 90, inJob, 1, inSalary, inComm);
    -- Display record insert
    DBMS_OUTPUT.PUT_LINE ('INSERTED:');
    DBMS_OUTPUT.PUT_LINE ('ID: ' || newEmpID);
    DBMS_OUTPUT.PUT_LINE ('Name: '|| inName);
    DBMS_OUTPUT.PUT_LINE ('Dept: 90');
    DBMS_OUTPUT.PUT_LINE ('Job: '|| inJob);
    DBMS_OUTPUT.PUT_LINE ('Years: 1');
    DBMS_OUTPUT.PUT_LINE ('Salary: $'|| inSalary);
    DBMS_OUTPUT.PUT_LINE ('Commission: $'|| inComm);
    DBMS_OUTPUT.NEW_LINE;
END staff_add;


SPOOL KelvinProQ2_Output.txt

SET SERVEROUTPUT ON;
-- Testing staff_add procedure
BEGIN
    DBMS_OUTPUT.PUT_LINE ('Testing staff_add');
    DBMS_OUTPUT.NEW_LINE;
    
    -- Correct Insert
    DBMS_OUTPUT.PUT_LINE ('Valid record');
    staff_add('Osborn', 'Mgr', 60000, 800); 
    staff_add('Parker', 'Sales', 40000, 500); 
    DBMS_OUTPUT.NEW_LINE;
    
    -- No Name
    DBMS_OUTPUT.PUT_LINE ('Invalid record with no name');
    staff_add('','Mgr',60000, 800); 
    DBMS_OUTPUT.NEW_LINE;
    
    -- Wrong Job
    DBMS_OUTPUT.PUT_LINE ('Invalid record with wrong job ');
    staff_add('Gillis', 'CEO', 60000, 800); 
    DBMS_OUTPUT.NEW_LINE;
    
    -- No salary
    DBMS_OUTPUT.PUT_LINE ('Invalid record with no salary');
    staff_add('Gillis', 'Mgr', 0, 800); 
    DBMS_OUTPUT.NEW_LINE;
    
    -- No comm    
    DBMS_OUTPUT.PUT_LINE ('Invalid record with no commission');
    staff_add('Gillis', 'Mgr', 60000, 0); 
    DBMS_OUTPUT.NEW_LINE;
END;
/
SPOOL OFF


-- 3. Error checking for JOB
-- Audit table 
CREATE TABLE staffAuditTbl(
id NUMBER(38,0),
incjob CHAR(5 BYTE));

-- Trigger- If a job title is added or changed, if it is invalid it wll be recorded in audit table
CREATE OR REPLACE TRIGGER ins_job
BEFORE INSERT OR UPDATE ON STAFF
FOR EACH ROW
BEGIN
    IF :NEW.job NOT IN ('Sales', 'Clerk', 'Mgr') THEN
        INSERT INTO staffAuditTbl(id, incjob)
        VALUES (:NEW.id, :NEW.job);
    END IF;
END;

-- Testing ins_job trigger 
BEGIN
    -- Wrong Job
     INSERT INTO staff(id, name, dept, job, years, salary, comm)
     VALUES(600, 'Rowin', 90, 'CEO', 1, 40000, 200);
     
     INSERT INTO staff(id, name, dept, job, years, salary, comm)
     VALUES(700, 'Fogol', 90, 'Prez', 1, 40000, 200);
     
     INSERT INTO staff(id, name, dept, job, years, salary, comm)
     VALUES(800, 'Kent', 90, 'CFO', 1, 40000, 200);
END;
SELECT * FROM staffAuditTbl;



--4 Get total compensation of an employee
CREATE OR REPLACE PROCEDURE total_cmp(inID IN NUMBER, totalComp OUT NUMBER) AS 
-- Declare variables
    empSalary NUMBER(7,2);
    empComm NUMBER(7,2);
BEGIN
    -- Get employee salary and commission
    SELECT salary, comm 
    INTO empSalary, empComm
    FROM staff
    WHERE id = inID;
    
    --Calculate total comp
    totalComp := empSalary + empComm;
-- Error handling if employee is not found
EXCEPTION WHEN NO_DATA_FOUND
    THEN DBMS_OUTPUT.PUT_LINE ('Employee Not Found');
END;


SPOOL KelvinProQ4_Output.txt

SET SERVEROUTPUT ON;
-- Testing total_comp
DECLARE
getComp NUMBER(7,2);
BEGIN
DBMS_OUTPUT.PUT_LINE ('Testing total_comp');
    DBMS_OUTPUT.NEW_LINE;
-- correct input
total_cmp(350, getComp);
DBMS_OUTPUT.PUT_LINE ('Total comp for emp 350: $' || getComp);
DBMS_OUTPUT.NEW_LINE;
total_cmp(340, getComp);
DBMS_OUTPUT.PUT_LINE ('Total comp for emp 340: $' || getComp);
    DBMS_OUTPUT.NEW_LINE;
-- Error handling
DBMS_OUTPUT.PUT_LINE ('error handling, invalid id');
total_cmp(600, getComp);
total_cmp(902, getComp);
END;
/
SPOOL OFF


-- 5
-- Add oldcomm and newcomm columns to staffAudTbl
ALTER TABLE staffAuditTbl
ADD (OLDCOMM NUMBER(7,2), NEWCOMM NUMBER(7,2));

SELECT * FROM staffAuditTbl;

-- Go through each record in staff and update comm
CREATE OR REPLACE PROCEDURE set_comm AS 
    CURSOR cStaff IS
        SELECT job, salary, comm
        FROM staff
        FOR UPDATE;
    
    newComm staff.comm%TYPE;
BEGIN
    FOR rec IN cStaff LOOP
        -- Calculate new comm based on job
        CASE rec.job
            WHEN 'Mgr' THEN
               newComm := rec.salary * 0.20; 
            WHEN 'Clerk' THEN
               newComm := rec.salary * 0.10; 
            WHEN 'Sales' THEN
               newComm := rec.salary * 0.30; 
            WHEN 'Prez' THEN
               newComm := rec.salary * 0.50; 
        END CASE;
        
        -- Update record
        UPDATE staff
        SET comm = newComm
        WHERE CURRENT OF cStaff;
    END LOOP;
END set_comm;

-- Create trigger to store before and after comm update 
CREATE OR REPLACE TRIGGER upd_comm
AFTER UPDATE OF comm ON staff
FOR EACH ROW
BEGIN
    IF :OLD.comm IS NULL OR :NEW.comm IS NULL OR :OLD.comm <> :NEW.comm THEN
       INSERT INTO staffAuditTbl(id, incjob, oldComm, newComm)
        VALUES (:OLD.id, NULL, :OLD.comm, :NEW.comm);
    END IF;
END;

--Testing set_comm procedure and upd_comm trigger 
BEGIN
set_comm;
END;


-- 6. Staff trigger cobines upd_comm and ins_job functionality. Inserts info into staffAuditTbl depedning on operation type 
DROP TABLE staffAuditTbl;

CREATE TABLE staffAuditTbl(
id NUMBER(38,0),
action CHAR(5 BYTe),
incjob CHAR(5 BYTE),
OLDCOMM NUMBER(7,2), 
NEWCOMM NUMBER(7,2));

CREATE OR REPLACE TRIGGER staff_trigg
AFTER INSERT OR UPDATE OR DELETE ON staff
FOR EACH ROW
DECLARE
    trigOp CHAR;
BEGIN
    -- Determine operation
    IF INSERTING THEN
        trigOp := 'I';
    ELSIF UPDATING THEN
        trigOp := 'U';
    ELSIF DELETING THEN
        trigOp := 'D';
    END IF;
    
    IF INSERTING OR UPDATING THEN
        -- Insert record if job input is wrong
        IF :NEW.job NOT IN ('Sales', 'Clerk', 'Mgr') THEN
            INSERT INTO staffAuditTbl(id, action, incjob, oldComm, newComm)
            VALUES (:NEW.id, trigOp, :NEW.job, NULL, NULL);
        END IF;
  
        -- Insert record if salary has changed
        IF :OLD.comm <> :NEW.comm THEN
            INSERT INTO staffAuditTbl(id, action, incjob, oldComm, newComm)
            VALUES (:OLD.id, trigOp, NULL, :OLD.comm, :NEW.comm);
        END IF;
    ELSIF DELETING THEN    
        -- Insert record if deleting
        INSERT INTO staffAuditTbl(id, action, incjob, oldComm, newComm)
        VALUES (:OLD.id, trigOp, NULL, NULL, NULL);
    END IF;
END;


-- Testing staff_trigg
BEGIN 
    INSERT INTO staff(id, name, dept, job, years, salary, comm)
    VALUES(500, 'Majors', 90, 'Sales', 1, 40000, 200);
    
    INSERT INTO staff(id, name, dept, job, years, salary, comm)
    VALUES(600, 'Rowin', 90, 'CEO', 1, 40000, 200);
    
     
    UPDATE staff
    SET comm = 500
    WHERE id = 340;
    
    DELETE FROM staff
    WHERE id = 350;
END;

SELECT * FROM staffAuditTbl;


--7 Take the NAME as input and provide an output of the name which alternates between upper case and lower case characters
CREATE OR REPLACE FUNCTION fun_name(inName IN VARCHAR2) RETURN VARCHAR2 IS
    result VARCHAR2(1000);
BEGIN
    FOR i IN 1..LENGTH(inName) LOOP
        IF MOD(i, 2) = 1 THEN
            result := result || UPPER(SUBSTR(inName, i, 1));
        ELSE
            result := result || LOWER(SUBSTR(inName, i, 1));
        END IF;
    END LOOP;
    
    RETURN result;
END;

-- Testing fun_name
SELECT fun_name(NAME) FROM staff
WHERE id = 350;

SELECT fun_name(NAME) FROM staff
WHERE id = 340;

-- 8 Vowel counter
CREATE OR REPLACE FUNCTION vowel_cnt(inText IN VARCHAR2) RETURN NUMBER IS
    vCount NUMBER := 0;
BEGIN
    FOR i IN 1..LENGTH(inText) LOOP
        IF UPPER(SUBSTR(inText, i, 1)) IN ('A', 'E', 'I', 'O', 'U') THEN
            vCount := vCount + 1;
        END IF;
    END LOOP;
    
    RETURN vCount;
END vowel_cnt;

-- Test vowel_cnt
SELECT vowel_cnt(JOB) 
FROM STAFF;

SELECT vowel_cnt(JOB) 
FROM STAFF 
WHERE id =600;


-- 9 staff_pick package creation
CREATE OR REPLACE PACKAGE staff_pick AS
--1. Add a new row to the STAFF table 
    PROCEDURE staff_add(inName IN VARCHAR2, inJob IN VARCHAR2, inSalary IN NUMBER, inComm IN NUMBER);
--2. Get total compensation of an employee
    PROCEDURE total_cmp(inID IN NUMBER, totalComp OUT NUMBER);
--3. Calculate and update comm for table
    PROCEDURE set_comm;
--4. Make every other letter lower case
    FUNCTION fun_name(inName IN VARCHAR2) RETURN VARCHAR2;
--5. Count number of vowels for each row 
    FUNCTION vowel_cnt(inText IN VARCHAR2) RETURN NUMBER;
END staff_pick;


CREATE OR REPLACE PACKAGE BODY staff_pick AS
--1.
PROCEDURE staff_add(inName IN VARCHAR2, inJob IN VARCHAR2, inSalary IN NUMBER, inComm IN NUMBER) IS
    newEmpID staff.id%TYPE;
    maxID staff.id%TYPE;
  
BEGIN
-- Find latest ID, increment by 10 
    SELECT MAX(id) INTO maxID FROM staff;
    newEmpID := maxID + 10;
-- Name must be inputted
    IF inName IS NULL THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Employee name cannot be NULL.');
        RETURN;
    END IF;
    
-- Job must be inputted - check for proper job
    IF inJob NOT IN ('Sales', 'Clerk', 'Mgr') THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Job input must be Sales, Clerk or Mgr.');
        RETURN;
    END IF;
    
-- Salary must be inputted
    IF inSalary <= 0 THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Salary cannot be 0.');
        RETURN;
    END IF;
    
-- Commision must be inputted
    IF inComm <= 0 THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Commision cannot be 0.');
        RETURN;
    END IF;
    
-- Insert record into staff table
    INSERT INTO staff(id, name, dept, job, years, salary, comm)
    VALUES(newEmpID, inName, 90, inJob, 1, inSalary, inComm);
    -- Display record insert
    DBMS_OUTPUT.PUT_LINE ('INSERTED:');
    DBMS_OUTPUT.PUT_LINE ('ID: ' || newEmpID);
    DBMS_OUTPUT.PUT_LINE ('Name: '|| inName);
    DBMS_OUTPUT.PUT_LINE ('Dept: 90');
    DBMS_OUTPUT.PUT_LINE ('Job: '|| inJob);
    DBMS_OUTPUT.PUT_LINE ('Years: 1');
    DBMS_OUTPUT.PUT_LINE ('Salary: $'|| inSalary);
    DBMS_OUTPUT.PUT_LINE ('Commission: $'|| inComm);
    DBMS_OUTPUT.NEW_LINE;
    
END staff_add;

--2.
PROCEDURE total_cmp(inID IN NUMBER, totalComp OUT NUMBER) IS 
-- Declare variables
    empSalary NUMBER(7,2);
    empComm NUMBER(7,2);
BEGIN
    -- Get employee salary and commission
    SELECT salary, comm 
    INTO empSalary, empComm
    FROM staff
    WHERE id = inID;
    
    --Calculate total comp
    totalComp := empSalary + empComm;
-- Error handling if employee is not found
EXCEPTION WHEN NO_DATA_FOUND
    THEN DBMS_OUTPUT.PUT_LINE ('Employee Not Found');
END total_cmp;

--3.
PROCEDURE set_comm AS 
    CURSOR cStaff IS
        SELECT job, salary, comm
        FROM staff
        FOR UPDATE;
    
    newComm staff.comm%TYPE;
BEGIN
    FOR rec IN cStaff LOOP
        -- Calculate new comm based on job
        CASE rec.job
            WHEN 'Mgr' THEN
               newComm := rec.salary * 0.20; 
            WHEN 'Clerk' THEN
               newComm := rec.salary * 0.10; 
            WHEN 'Sales' THEN
               newComm := rec.salary * 0.30; 
            WHEN 'Prez' THEN
               newComm := rec.salary * 0.50; 
        END CASE;
        
        -- Update record
        UPDATE staff
        SET comm = newComm
        WHERE CURRENT OF cStaff;
    END LOOP;
END set_comm;


--4.
FUNCTION fun_name(inName IN VARCHAR2) RETURN VARCHAR2 IS
    result VARCHAR2(1000);
BEGIN
    FOR i IN 1..LENGTH(inName) LOOP
        IF MOD(i, 2) = 1 THEN
            result := result || UPPER(SUBSTR(inName, i, 1));
        ELSE
            result := result || LOWER(SUBSTR(inName, i, 1));
        END IF;
    END LOOP;
    
    RETURN result;
END fun_name;

--5.
FUNCTION vowel_cnt(inText IN VARCHAR2) RETURN NUMBER IS
    vCount NUMBER := 0;
BEGIN
    FOR i IN 1..LENGTH(inText) LOOP
        IF UPPER(SUBSTR(inText, i, 1)) IN ('A', 'E', 'I', 'O', 'U') THEN
            vCount := vCount + 1;
        END IF;
    END LOOP;
    
    RETURN vCount;
END vowel_cnt;

END staff_pick;


SPOOL KelvinProQ9_Output.txt
SET SERVEROUTPUT ON;

-- Testing staff_pick package
DECLARE
getComp NUMBER(7,2);
funName VARCHAR2(9 BYTE);
BEGIN
    DBMS_OUTPUT.PUT_LINE ('Testing staff_pick package');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE ('Calling staff_add');
    staff_pick.staff_add('Osborn', 'Mgr', 60000, 800); 
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE ('Calling total_cmp');
    staff_pick.total_cmp(350, getComp);
    DBMS_OUTPUT.PUT_LINE ('Total comp for emp 350: $' || getComp);
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE ('Calling fun_name');
    SELECT staff_pick.fun_name(NAME) INTO funName FROM staff
    WHERE id = 350;
    DBMS_OUTPUT.PUT_LINE ('Remixed name: ' || funName);

END;
/
SPOOL OFF