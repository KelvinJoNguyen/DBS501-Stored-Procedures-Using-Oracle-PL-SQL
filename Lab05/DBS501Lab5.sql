/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/03/28
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/

SET SERVEROUTPUT ON;
-- Create error table
CREATE TABLE salaud(
id NUMBER(38,0),
insert_Date DATE,
salary NUMBER(7,2),
comm NUMBER(7,2),
errorCode VARCHAR(250));
SELECT * FROM salaud;

CREATE OR REPLACE TRIGGER trigcom
AFTER INSERT OR UPDATE ON STAFF
FOR EACH ROW
BEGIN
    IF :NEW.comm > (:NEW.salary * .25) AND :NEW.comm + :NEW.salary < 50000 THEN
        -- Rule a and b broken
        INSERT INTO salaud(id, insert_date, salary, comm, errorCode)
        VALUES (:NEW.id, SYSDATE, :NEW.salary, :NEW.comm, 'Commission amount exceeds 25% of the salary AND the sum of salary and commission is less than 50,000.'); 

    ELSIF :NEW.comm > (:NEW.salary * .25) THEN
        -- Rule a is broken
        INSERT INTO salaud(id, insert_date, salary, comm, errorCode)
        VALUES (:NEW.id, SYSDATE, :NEW.salary, :NEW.comm, 'Commission amount exceeds 25% of the salary.');   
    ELSIF (:NEW.comm + :NEW.salary) < 50000 THEN
        -- Rule b is broken
        INSERT INTO salaud(id, insert_date, salary, comm, errorCode)
        VALUES (:NEW.id, SYSDATE, :NEW.salary, :NEW.comm, 'The sum of salary and commission is less than 50,000.');             
    END IF;
END;





-- Output file script   

SPOOL KelvinLab5_Output.txt

SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Lab 5 Demo');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Successful insert');
    DBMS_OUTPUT.PUT_LINE(' Inserting: 351, Smith, 84, Sales, NULL, 50000, 10000');
    INSERT INTO staff(id, name, dept, job, years, salary, comm)
    VALUES(351, 'Allan', 84, 'Sales', NULL, 50000, 10000); 
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Insert breaking rule A');
    DBMS_OUTPUT.PUT_LINE('352, Nguyen, 66, Clerk, NULL, 50000, 25000');
    INSERT INTO staff(id, name, dept, job, years, salary, comm)
    VALUES(352, 'Nguyen', 66, 'Clerk', NULL, 50000, 25000); 
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Insert breaking rule B');
    DBMS_OUTPUT.PUT_LINE('353, Kent, 10, Sales, NULL, 10000, 2000');
    INSERT INTO staff(id, name, dept, job, years, salary, comm)
    VALUES(353, 'Kent', 10, 'Sales', NULL, 10000, 2000); 
    DBMS_OUTPUT.NEW_LINE;

    DBMS_OUTPUT.PUT_LINE('Insert breaking rule A and B');
    DBMS_OUTPUT.PUT_LINE('354, Wayne, 42, Sales, NULL, 10000, 5000');
    INSERT INTO staff(id, name, dept, job, years, salary, comm)
    VALUES(354, 'Wayne', 42, 'Sales', NULL, 10000, 5000); 
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Successful update');
    DBMS_OUTPUT.PUT_LINE(' Updating: ID 200');
    UPDATE staff
    SET salary = 50000,
        comm = 10000
    WHERE id = 200;
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Update breaking rule A');
    DBMS_OUTPUT.PUT_LINE(' Updating: ID 220');
    UPDATE staff
    SET salary = 50000,
        comm = 30000
    WHERE id = 220;
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Update breaking rule B');
    DBMS_OUTPUT.PUT_LINE(' Updating: ID 230');
    UPDATE staff
    SET salary = 30000,
        comm = 6000
    WHERE id = 230;
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Update breaking rule A and B');
    DBMS_OUTPUT.PUT_LINE(' Updating: ID 250');
    UPDATE staff
    SET salary = 20000,
        comm = 15000
    WHERE id = 250;
    DBMS_OUTPUT.NEW_LINE;
    COMMIT;
END;
/
SPOOL OFF

SELECT * FROM STAFF;
SELECT * FROM SALAUD;