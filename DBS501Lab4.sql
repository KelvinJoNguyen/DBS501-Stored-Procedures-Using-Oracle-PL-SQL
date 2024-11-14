/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/03/14
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/
SET SERVEROUTPUT ON;

-- pig_latin UDF: Check if name has a vowel - if it does remove the first letter and add to the end then add 'ay'
-- If name does not have vowel add 'ay to the end 
CREATE OR REPLACE FUNCTION pig_latin(inName IN employees.first_name%type)
RETURN CHAR
IS 
-- Declare variables 
    pigName employees.first_name%type;
    letter CHAR(1);
BEGIN
    SELECT first_name
    INTO pigName
    FROM employees
    WHERE inNAme = first_name;

-- Check for vowel 
    IF SUBSTR(pigName, 1, 1) = 'A' OR 
    SUBSTR(pigName, 1, 1) = 'E' OR
    SUBSTR(pigName, 1, 1) = 'I' OR
    SUBSTR(pigName, 1, 1) = 'O' OR
    SUBSTR(pigName, 1, 1) = 'U' THEN
    
        letter := SUBSTR(pigName, 1, 1);
        pigName:= SUBSTR(pigName, 2);
        pigName:= pigName || LOWER(letter) || 'ay';
  
    ELSE
        pigName:= pigName || 'ay';
    END IF;
    
    RETURN pigName;
    
-- Error handling, invalid employee name  
    EXCEPTION WHEN NO_DATA_FOUND
    THEN RETURN 'Employee Not Found! Please enter an employee''s name';
    
END;

-- experience UDF: Return level of experience based on years of experience 
CREATE OR REPLACE FUNCTION experience(input IN NUMBER)
RETURN CHAR
IS
    resultCount NUMBER;
    output CHAR:= '';
BEGIN
    SELECT COUNT(*) 
    INTO resultCount
    FROM staff
    WHERE years = input;
    
    IF resultCount > 0 THEN
        IF input >= 0 AND input <= 4 THEN
            RETURN output||'Junior';
        ELSIF input >= 5 AND input <= 9 THEN
            RETURN output || 'Intermediate';
        ELSIF input >= 10 THEN
            RETURN output||'Experienced';
        END IF;
    ELSE
        RETURN 'No employee with ' || TO_CHAR(input) || ' years of experience';
    END IF;

END;



-- Output file script   

SPOOL KelvinLab4_Output.txt

SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Lab 4');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

-- pig_latin UDF 
    DBMS_OUTPUT.PUT_LINE('Demo of pig_latin UDF');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

    DBMS_OUTPUT.PUT_LINE('UDF call on Annabelle');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
DECLARE
    conName employees.first_name%type;
BEGIN
    conName := pig_latin('Annabelle');
    DBMS_OUTPUT.PUT_LINE(conName);
END;    
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('UDF call on Summer');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
DECLARE
    conName employees.first_name%type;
BEGIN
    conName := pig_latin('Summer');
    DBMS_OUTPUT.PUT_LINE(conName);
END;    
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

-- pig_latin UDF error handling 
    DBMS_OUTPUT.PUT_LINE('Demo of pig_latin UDF error handling- Invalid employee name ');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
DECLARE
    conName employees.first_name%type;
BEGIN
    conName := pig_latin('Kelvin');
    DBMS_OUTPUT.PUT_LINE(conName);
END;      
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;


 -- experience UDF 
    DBMS_OUTPUT.PUT_LINE('Demo of experience UDF');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('UDF call on 3 years');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
BEGIN
    DBMS_OUTPUT.PUT_LINE(experience(3));
END;   
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('UDF call on 7 years');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
BEGIN
    DBMS_OUTPUT.PUT_LINE(experience(7));
END;   
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('UDF call on 10 years');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
BEGIN
    DBMS_OUTPUT.PUT_LINE(experience(10));
END;   
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;

-- experience UDF error handling 
    DBMS_OUTPUT.PUT_LINE('Demo of experience UDF error handling- Invalid employee year ');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
BEGIN
    DBMS_OUTPUT.PUT_LINE(experience(30));
END;
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
 
END;
/
SPOOL OFF

