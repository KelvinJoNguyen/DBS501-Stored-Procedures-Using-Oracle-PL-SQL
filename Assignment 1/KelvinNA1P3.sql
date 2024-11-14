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

-- Part 3 education: increade education level of employee based on input 
CREATE OR REPLACE PROCEDURE education(empID IN NUMBER, educ IN CHAR) AS
-- Declare variables
    empNumber CHAR(6 BYTE);
    empEducation NUMBER(38,0);
    
    oldEducation NUMBER(38,0);

BEGIN
    SELECT empno, edlevel
    INTO empNumber, empEducation
    FROM employee
    WHERE empId = empno;
    
-- Store old education
    oldEducation := empEducation;

-- Determine education level 
    IF educ = 'H' THEN
        empEducation := 16;
    ELSIF educ = 'C' THEN
        empEducation := 19;
    ELSIF educ = 'U' THEN
        empEducation := 20;
    ELSIF educ = 'M' THEN
        empEducation := 23;
    ELSIF educ = 'P' THEN
        empEducation := 25;
     ELSE 
        DBMS_OUTPUT.PUT_LINE ('Error, Input education level:');
        DBMS_OUTPUT.PUT_LINE ('H for Highschool Diploma');
        DBMS_OUTPUT.PUT_LINE ('C for College Diploma');
        DBMS_OUTPUT.PUT_LINE ('U for Univeristy Degree');
        DBMS_OUTPUT.PUT_LINE ('M for Masters');
        DBMS_OUTPUT.PUT_LINE ('P for PhD');
        RETURN;
    END IF;
-- Error handling: if new edlevel is lower than old edlevel
    IF oldEducation > empEducation THEN
        DBMS_OUTPUT.PUT_LINE ('Error: Education level cannot be decreased');
        RETURN;
    END IF;
    
-- Update employee education level
    UPDATE employee
    SET
        edlevel = empEducation
    WHERE
        empId = empno;
    
    
-- Display data 
    DBMS_OUTPUT.PUT_LINE('Empployee Num: ' || empNumber);
    DBMS_OUTPUT.PUT_LINE('Old Education Level: ' || oldEducation);
    DBMS_OUTPUT.PUT_LINE('New Education Level: ' || empEducation);
    
-- Error handling if employee is not found
EXCEPTION WHEN NO_DATA_FOUND
    THEN DBMS_OUTPUT.PUT_LINE ('Employee Not Found');
    
END;



-- Output file script   

SPOOL KelvinNA1P3_Output.txt

SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Assignment 1 Part 3');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

-- Call om emp 200340 Roy
    DBMS_OUTPUT.PUT_LINE('Call om emp 200340 Roy with ed level C:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    education(200340, 'C');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

-- Call om emp 200330 Helena
    DBMS_OUTPUT.PUT_LINE('Call om emp 200330 Helena with ed level H:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    education(200330, 'H');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

 
-- Call om emp 200310 Michelle
    DBMS_OUTPUT.PUT_LINE('Call om emp 200310 Eilleen with ed level U:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    education(200280, 'U');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
-- Call om emp 200310 Michelle
    DBMS_OUTPUT.PUT_LINE('Call om emp 200310 Robert with ed level M:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    education(200240, 'M');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
-- Call om emp 200310 Michelle
    DBMS_OUTPUT.PUT_LINE('Call om emp 200310 Michelle with ed level P:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    education(200310, 'P');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    
-- Error handling invalid employee number
    DBMS_OUTPUT.PUT_LINE('Error handling invalid employee number:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    education(300410, 'M');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;


-- Error handling invalid rating
    DBMS_OUTPUT.PUT_LINE('Error handling invalid edlevel input:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    education(000010, 'W');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
-- Error handling invalid rating
    DBMS_OUTPUT.PUT_LINE('Error handling lower edlevel:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    education(000010, 'H');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

END;
/
SPOOL OFF

