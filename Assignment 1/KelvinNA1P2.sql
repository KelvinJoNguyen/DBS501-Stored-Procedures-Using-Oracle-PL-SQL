/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/03/7
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/
SET SERVEROUTPUT ON;

-- Part 2 salary procedure: increase employee salary, bonus and commision based on rating as input
CREATE OR REPLACE PROCEDURE salary(empID IN NUMBER, rating IN NUMBER) AS
-- Declare variables 
    empNumber CHAR(6 BYTE);
    empSalary NUMBER(9,2);
    empBonus NUMBER(9,2);
    empComm NUMBER(9,2);
    
    oldSalary NUMBER(9,2);
    oldBonus NUMBER(9,2);
    oldComm NUMBER(9,2);

BEGIN
    SELECT empno, salary, bonus, comm
    INTO empNumber, empSalary, empBonus, empComm
    FROM employee
    WHERE empId = empno;
    
    -- Store old data 
    oldSalary := empSalary;
    oldBonus := empBonus;
    oldComm := empComm;
    
    -- Calculate slary, bonuses and com
    IF rating = 1 THEN
        empSalary := empSalary + 10000;
        empBonus := empBonus + 300;
        empComm := empComm + (oldSalary * 0.05);
        
    ELSIF rating = 2 THEN
        empSalary := empSalary + 5000;
        empBonus := empBonus + 200;
        empComm := empComm + (oldSalary * 0.02);
    ELSIF rating = 3 THEN
        empSalary := empSalary + 2000;
    ELSE 
        DBMS_OUTPUT.PUT_LINE ('Error, Input rating from 1-3');
        RETURN;
    END IF;
    
     -- Update salary, bonus, and commission in the employee table
     
    UPDATE employee
    SET
        salary = empSalary,
        bonus = empBonus,
        comm = empComm
    WHERE
        empId = empno;
    
    -- Display output
    DBMS_OUTPUT.PUT_LINE('Empployee Num: ' || empNumber);
    DBMS_OUTPUT.PUT_LINE('Old Salary: ' || oldSalary);
    DBMS_OUTPUT.PUT_LINE('Old Bonus: ' || oldBonus);
    DBMS_OUTPUT.PUT_LINE('Old Commision: ' || oldComm);
    DBMS_OUTPUT.PUT_LINE('New Salary: ' || empSalary);
    DBMS_OUTPUT.PUT_LINE('New Bonus: ' || empBonus);
    DBMS_OUTPUT.PUT_LINE('New Commision: ' || empComm);
    
-- Error handling if employee is not found
EXCEPTION WHEN NO_DATA_FOUND
    THEN DBMS_OUTPUT.PUT_LINE ('Employee Not Found');
    
END;


-- Output file script   

SPOOL KelvinNA1P2_Output.txt

SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Assignment 1 Part 2');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
-- Call om emp 200340 Roy
    DBMS_OUTPUT.PUT_LINE('Call om emp 200340 Roy with rating 1:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    salary(200340, 1);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

-- Call om emp 200330 Helena
    DBMS_OUTPUT.PUT_LINE('Call om emp 200330 Helena with rating 2:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    salary(200330, 2);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

 
-- Call om emp 200310 Michelle
    DBMS_OUTPUT.PUT_LINE('Call om emp 200310 Michelle with rating 3:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    salary(200310, 3);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

-- Error handling invalid employee number
    DBMS_OUTPUT.PUT_LINE('Error handling invalid employee number:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    salary(300410, 3);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

  
-- Error handling invalid rating
    DBMS_OUTPUT.PUT_LINE('Error handling invalid rating:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    salary(000020, 5);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

END;
/
SPOOL OFF
    
    
