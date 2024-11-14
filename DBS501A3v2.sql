/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/04/04
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/

SET SERVEROUTPUT ON;
DROP TABLE EMPAUDIT;
-- Create error table
CREATE TABLE EMPAUDIT(
empId CHAR(6 BYTE),
errorCode CHAR,
operation CHAR,
workDept CHAR(3 BYTE),
salary NUMBER(7,2),
comm NUMBER(7,2),
bonus NUMBER(7,2));

CREATE TABLE vacation(
empId CHAR(6 BYTE),
hireDate DATE,
vacationDays NUMBER(3));

--2.Check if new or updated employee bonus or comm breaks rules
CREATE OR REPLACE TRIGGER varpaychk
BEFORE INSERT OR UPDATE ON EMPLOYEE
FOR EACH ROW
DECLARE
bonusPct NUMBER;
commissionPct NUMBER;
totalPct NUMBER;
trigOp CHAR;
BEGIN

    bonusPct := :NEW.bonus / :NEW.salary * 100;
    commissionPct := :NEW.comm / :NEW.salary * 100;
    totalPct := bonusPct + commissionPct;

    IF INSERTING THEN
    trigOp := 'I';
    ELSIF UPDATING THEN
    trigOp := 'U';
    END IF;

-- Bonus should be less than 20% of salary 
    IF bonusPct > 20  THEN
        INSERT INTO EMPAUDIT(empId, errorCode, operation, workDept, salary, comm, bonus)
        VALUES (:NEW.empNo, 'B', trigOp, 'N/A', :NEW.salary, :NEW.comm, :NEW.bonus); 

-- Commsion should be less than 25% of salary
    ELSIF commissionPct > 25 THEN
        INSERT INTO EMPAUDIT(empId, errorCode, operation, workDept, salary, comm, bonus)
        VALUES (:NEW.empNo, 'C', trigOp, 'N/A', :NEW.salary, :NEW.comm, :NEW.bonus);   
        
-- Sum of of Bonus and comm should be less than 40% of salary 
    ELSIF totalPct > 40 THEN
        INSERT INTO EMPAUDIT(empId, errorCode, operation, workDept, salary, comm, bonus)
        VALUES (:NEW.empNo, 'S', trigOp, 'N/A', :NEW.salary, :NEW.comm, :NEW.bonus);             
    END IF;
END;

--3 Set employee's manager / move employees if manager is removed 
CREATE OR REPLACE TRIGGER nomgr
BEFORE INSERT OR UPDATE OR DELETE ON EMPLOYEE
FOR EACH ROW
DECLARE
    resultCount NUMBER;
    emptFound NUMBER;
    trigOp CHAR;
BEGIN

    IF INSERTING THEN
        trigOp := 'I';
    ELSIF UPDATING THEN
     trigOp := 'U';
    ELSIF DELETING THEN
        trigOp := 'D';
    END IF;

-- Find if there is a manager in that department
    IF UPDATING OR INSERTING THEN
        SELECT COUNT(*) 
        INTO resultCount
        FROM employee
        WHERE workDept = :NEW.workDept AND job = 'MANAGER';
        -- If there is no manager set employe dept to 000
        IF resultCount = 0 THEN
            INSERT INTO EMPAUDIT(empId, errorCode, operation, workDept, salary, comm, bonus)
            VALUES (:NEW.empNo, 'M', trigOp, :NEW.workDept, :NEW.salary, :NEW.comm, :NEW.bonus);
        END IF;
    -- If deleting manager set all employees working under them to 000
      ELSIF DELETING AND :OLD.job = 'MANAGER' THEN
        FOR emp_rec IN (SELECT empNo FROM employee WHERE workDept = :NEW.workDept) 
        LOOP
            UPDATE employee
            SET workDept = '000'
            WHERE empNo = emp_rec.empNo;
        END LOOP;
    END IF;
END;

DROP TRIGGER nomgr;


--4 Record employee vacation days based on hire date 
CREATE OR REPLACE TRIGGER empvac
AFTER INSERT OR UPDATE OR DELETE ON EMPLOYEE
FOR EACH ROW
DECLARE
    resultCount NUMBER;
    emptFound NUMBER;
    trigOp CHAR;
BEGIN
    
    IF INSERTING OR UPDATING THEN
    IF  ROUND(MONTHS_BETWEEN(SYSDATE, :NEW.hireDate) / 12) < 10 THEN
    -- insert 15 days 
     INSERT INTO vacation(empId, hireDate, vacationDays)
            VALUES (:NEW.empNo, :NEW.hireDate, 15);
            
    ELSIF ROUND(MONTHS_BETWEEN(SYSDATE, :NEW.hireDate) / 12) >= 10 AND ROUND(MONTHS_BETWEEN(SYSDATE, :NEW.hireDate) / 12) <= 19 THEN
       -- insert 20 days 
        INSERT INTO vacation(empId, hireDate, vacationDays)
            VALUES (:NEW.empNo, :NEW.hireDate, 20);
    
     ELSIF ROUND(MONTHS_BETWEEN(SYSDATE, :NEW.hireDate) / 12) >= 20 AND ROUND(MONTHS_BETWEEN(SYSDATE, :NEW.hireDate) / 12) <= 29 THEN
       -- insert 25 days 
        INSERT INTO vacation(empId, hireDate, vacationDays)
            VALUES (:NEW.empNo, :NEW.hireDate, 25);
            
         ELSIF ROUND(MONTHS_BETWEEN(SYSDATE, :NEW.hireDate) / 12) >= 30 THEN
       -- insert 30 days 
        INSERT INTO vacation(empId, hireDate, vacationDays)
            VALUES (:NEW.empNo, :NEW.hireDate, 30);
    END IF;
    
    ELSIF DELETING THEN
        DELETE FROM VACATION WHERE empId = :OLD.empNo;
    END IF;
END;


--Testing
--varpaychk
-- Correct INSERT 
INSERT INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
VALUES (200400, 'Bruce', 'Wayne', 'E21', '0000', SYSDATE, 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000);
-- Break bonus rule 
INSERT INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
VALUES (200401, 'Clark', 'Kent', 'E21', '0000', SYSDATE, 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 10000, 500);
-- Break commission rule
INSERT INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
VALUES (200402, 'Barry', 'Allan', 'E21', '0000', SYSDATE, 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 100, 12000);
-- Break commision + bonus rule
INSERT INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
VALUES (200403, 'Hal', 'Jordan', 'E21', '0000', SYSDATE, 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 7000, 10000);
-- Multi INSERT
INSERT ALL 
    INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
    VALUES (200404, 'John', 'Kennedy', 'E21', '0000', SYSDATE, 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000)
    INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
    VALUES (200405, 'Abe', 'Lincoln', 'E21', '0000', SYSDATE, 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 100, 12000)
    INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
    VALUES (200406, 'Dick', 'Nixon', 'E21', '0000', SYSDATE, 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000)
SELECT * FROM DUAL;


-- Correct UPDATE:
UPDATE employee
SET bonus = 500
WHERE empNo = 000320;
-- Break bonus rule  
UPDATE employee
SET bonus = 20000
WHERE empNo = 000330;
-- Break commission rule
UPDATE employee
SET bonus = 20000
WHERE empNo = 000340;
---- Break commision + bonus rule
UPDATE employee
SET bonus = 24000
WHERE empNo = 200010;


SELECT * FROM employee;
SELECT * FROM EMPAUDIT;
ROLLBACK;

-- empVac
-- Hired less than 10 years 
INSERT INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
VALUES (200400, 'Bruce', 'Wayne', 'E21', '0000', TO_DATE('2014-04-04', 'YYYY-MM-DD'), 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000);
-- Hired 15 years ago
INSERT INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
VALUES (200401, 'Clark', 'Kent', 'E21', '0000', TO_DATE('2009-04-04', 'YYYY-MM-DD'), 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000);
-- Hired 24 years ago
INSERT INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
VALUES (200402, 'Barry', 'Allan', 'E21', '0000', TO_DATE('2000-04-04', 'YYYY-MM-DD'), 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000);
-- Hired 35 years ago
INSERT INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
VALUES (200403, 'Hal', 'Jordan', 'E21', '0000', TO_DATE('1989-04-04', 'YYYY-MM-DD'), 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000);

-- Multi insert 
INSERT ALL 
    INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
    VALUES (200404, 'John', 'Kennedy', 'E21', '0000', TO_DATE('2014-04-04', 'YYYY-MM-DD'), 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000)
    INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
    VALUES (200405, 'Abe', 'Lincoln', 'E21', '0000', TO_DATE('2009-04-04', 'YYYY-MM-DD'), 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 100, 12000)
    INTO employee (empNo, firstName, lastNAme, workDept, phoneNo, hireDate, job, edlevel, sex, birthDate, salary, bonus, comm)
    VALUES (200406, 'Dick', 'Nixon', 'E21', '0000', TO_DATE('2000-04-04', 'YYYY-MM-DD'), 'CLERK', 16, 'M', TO_DATE('2001-04-04', 'YYYY-MM-DD'), 40000, 500, 1000)
SELECT * FROM DUAL;
-- Update 
UPDATE employee
SET hireDate = TO_DATE('2014-04-04', 'YYYY-MM-DD')
WHERE empNo = 000320;
-- Break bonus rule  
UPDATE employee
SET hireDate = TO_DATE('2009-04-04', 'YYYY-MM-DD')
WHERE empNo = 000330;
-- Break commission rule
UPDATE employee
SET hireDate = TO_DATE('2000-04-04', 'YYYY-MM-DD')
WHERE empNo = 000340;
---- Break commision + bonus rule
UPDATE employee
SET hireDate = TO_DATE('1989-04-04', 'YYYY-MM-DD')
WHERE empNo = 200010;

-- Delete
DELETE FROM EMPLOYEE
WHERE empNo = 200400;

SELECT * FROM employee;
SELECT * FROM vacation;


SPOOL KelvinA3_ErrorOutput.txt

SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Assignment 3 Error Handling Demo');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
-- Update invalid id varpaychk
    DBMS_OUTPUT.PUT_LINE('Update invalid id varpaychk');
    DBMS_OUTPUT.NEW_LINE;
    UPDATE employee
    SET bonus = 24000
    WHERE empNo = 40000;
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Update invalid id vacation');
    DBMS_OUTPUT.NEW_LINE;
    UPDATE employee
    SET hireDate = TO_DATE('1989-04-04', 'YYYY-MM-DD')
    WHERE empNo = 300000;

END;
/
SPOOL OFF
rollback;



