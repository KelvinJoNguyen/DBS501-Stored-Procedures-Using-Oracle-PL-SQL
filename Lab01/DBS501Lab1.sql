/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/02/08
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/
SET SERVEROUTPUT ON;

--1. Get an integer number as parameter and prints either odd or even 
CREATE OR REPLACE PROCEDURE even_odd(num IN NUMBER)AS
BEGIN
  IF MOD(num, 2) = 0 THEN
    DBMS_OUTPUT.PUT_LINE(num || ' is an even number.');
  ELSE
    DBMS_OUTPUT.PUT_LINE(num || ' is an odd number.');
  END IF;
END;


--2. Factorial procedure that gets an integer number n andcalculates and displays its factorial
CREATE OR REPLACE PROCEDURE factorial(n IN NUMBER) AS 
    -- Declare Variables
    result NUMBER := 1;
    i NUMBER := n;
BEGIN
    DBMS_OUTPUT.PUT(n || '!= fact(' || n || ')=');
    LOOP
        result := result * i;
        DBMS_OUTPUT.PUT(i || '*');
        i := i - 1;
    EXIT WHEN i <= 1;
    END LOOP;
        
    DBMS_OUTPUT.PUT_LINE('=' || result);
END;


-- 3. Stored procedure to calculate employee salary - base salary is 10k - increases 5% yearly 
CREATE OR REPLACE PROCEDURE calculate_salary(empID IN NUMBER) AS
    -- Declare variables
    employeeID NUMBER(38,0);
    firstName VARCHAR2(255 BYTE);
    lastName VARCHAR2(255 BYTE);
    hireDate DATE;
    yearsOfEmployment NUMBER;
    salary NUMBER(7,2) := 10000; 
    salaryRaise NUMBER(7,2);
    
BEGIN
    SELECT employee_ID, first_Name, last_Name, hire_Date 
    INTO employeeID,firstName,lastName, hireDate   
    FROM employees 
    WHERE empID = employee_ID;
    
    -- Calculate employee years of employment
    yearsOfEmployment := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM hireDate);

    -- Calculate salary if employee has worked for over a year 
    IF yearsOfEmployment > 1 THEN
        FOR i IN 1..yearsOfEmployment LOOP
            salaryRaise :=  salary * 0.05;
            salary := salary + salaryRaise;     
        END LOOP;
    END IF;
    
    -- Display employee data 
    DBMS_OUTPUT.PUT_LINE('First Name: ' || firstName);
    DBMS_OUTPUT.PUT_LINE('Last Name: ' || lastName);
    DBMS_OUTPUT.PUT_LINE('Salary: $' || salary);
    
-- Error handling if employee is not found
EXCEPTION WHEN NO_DATA_FOUND
    THEN DBMS_OUTPUT.PUT_LINE ('Employee Not Found');

END;
    
    
--4. Stored procedure to get employee info by employee ID    
CREATE OR REPLACE PROCEDURE  find_employee(empID IN NUMBER) AS
    -- Declare Variables
    employeeID NUMBER(38,0);
    firstName VARCHAR2(255 BYTE);
    lastName VARCHAR2(255 BYTE);
    empEmail VARCHAR2(255 BYTE);
    empPhone VARCHAR2(50 BYTE);
    hireDate DATE;
    jobTitle VARCHAR2(255 BYTE);

BEGIN
    SELECT employee_ID, first_Name, last_Name, email, phone, hire_Date, job_title 
    INTO employeeID,firstName,lastName, empEmail, empPhone, hireDate, jobTitle   
    FROM employees 
    WHERE empID = employee_ID;
    
    -- Display employee data 
    DBMS_OUTPUT.PUT_LINE('First Name: ' || firstName);
    DBMS_OUTPUT.PUT_LINE('Last Name: ' || lastName);
    DBMS_OUTPUT.PUT_LINE('Email: ' || empEmail);
    DBMS_OUTPUT.PUT_LINE('Phone: ' || empPhone);
    DBMS_OUTPUT.PUT_LINE('Hire date: ' || hireDate);
    DBMS_OUTPUT.PUT_LINE('Job Title: ' || jobTitle);

-- Error handling if employee is not found
EXCEPTION WHEN NO_DATA_FOUND
    THEN DBMS_OUTPUT.PUT_LINE ('Employee Not Found');

END;
    
    
-- Output file script   

SPOOL KelvinNLab1_Output.txt

SET SERVEROUTPUT ON;

BEGIN
    -- Demonstration of even_odd procedure
    DBMS_OUTPUT.PUT_LINE('even_odd procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    even_Odd(5);
    even_Odd(6);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    -- Demonstration of factorial procedure
    DBMS_OUTPUT.PUT_LINE('factorial procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    factorial(5);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    -- Demonstraion of calculate_salary procedure
    DBMS_OUTPUT.PUT_LINE('calculate_salary procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    calculate_salary(22);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('calculate_salary error handling:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    calculate_salary(200);
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    -- Demonstraion of find_employee procedure
    DBMS_OUTPUT.PUT_LINE('find_employee procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');

    find_Employee(22);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('find_employee error handling:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    find_Employee(200);

END;
/
SPOOL OFF
    







    
    

        







