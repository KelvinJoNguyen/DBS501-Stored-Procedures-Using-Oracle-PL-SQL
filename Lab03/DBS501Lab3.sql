/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/02/22
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/
SET SERVEROUTPUT ON;

-- 1. Take in numbers in two arrays. Display first array for days and second array for months
CREATE OR REPLACE TYPE NUMBER_ARRAY AS TABLE OF NUMBER;
CREATE OR REPLACE PROCEDURE array_Date(
    pDays IN NUMBER_ARRAY,
    pMonths IN NUMBER_ARRAY
)
AS
    -- Declare a custom exceptions
    InvalidArraySize EXCEPTION;
    InvalidNum EXCEPTION;

    -- Declare a variable
    resultStr VARCHAR2(4000);
    currentDate DATE;

BEGIN
    -- Validate the size of the input arrays
    IF pDays.COUNT > 31 OR pMonths.COUNT > 12 OR pDays.COUNT < 1 OR pMonths.COUNT < 1 THEN
    -- Raise the custom exception for invalid array sizes
        RAISE InvalidArraySize;
    END IF;

    -- Process each month in the second array
    FOR i IN 1..pMonths.COUNT LOOP
        -- Validate that the month is within the valid range (1 to 12)
        IF pMonths(i) < 1 OR pMonths(i) > 12 THEN
            RAISE InvalidNum;
        END IF;

        -- Set the current date to the first day of the month
        currentDate := TO_DATE('01-' || pMonths(i) || '-2022', 'DD-MM-YYYY');

        -- Process each day in the first array
        FOR j IN 1..pDays.COUNT LOOP
            -- Validate that the day is within the valid range (1 to 31)
            IF pDays(j) < 1 OR pDays(j) > 31 THEN
                RAISE InvalidArraySize;
            END IF;

            -- Calculate the final date by adding the day to the current month
            currentDate := currentDate + pDays(j);

            -- Format the result and append to the result string
            resultStr := resultStr || TO_CHAR(currentDate, 'Day, Month DD, YYYY') || CHR(10);
        END LOOP;
    END LOOP;

    -- Display result
    DBMS_OUTPUT.PUT_LINE(resultStr);
    
EXCEPTION
    WHEN InvalidArraySize THEN
        DBMS_OUTPUT.PUT_LINE('Invalid array size');
    WHEN InvalidNum THEN
        DBMS_OUTPUT.PUT_LINE('The first array must have numbers between 1 and 31, and the second array must have numbers between 1 and 12.');
    WHEN OTHERS THEN
        -- Handle any other exceptions 
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred');
END;

-- 2. Go through each emp last name - ignore name if it starts with vowel, if not replace vowels with * 
CREATE OR REPLACE PROCEDURE name_fun AS
    CURSOR employeeCur IS
        SELECT last_name FROM employees; 
        vModifiedName VARCHAR2(15);
BEGIN
    FOR empRec IN employeeCur LOOP
        -- Check if the name starts with a vowel using the CASE function
        CASE
            WHEN REGEXP_LIKE(empRec.last_name, '^[aeiouAEIOU]') THEN
                -- Ignore name
                NULL;
            ELSE
                -- Replace all vowels with *
                vModifiedName := REGEXP_REPLACE(empRec.last_name, '[aeiouAEIOU]', '*');
                -- Right pad the modified name with +
                vModifiedName := RPAD(vModifiedName, 15, '+');
                -- Display the modified name
                DBMS_OUTPUT.PUT_LINE(vModifiedName);
        END CASE;
    END LOOP;
END;



-- Output script
SET SERVEROUTPUT ON;
SPOOL KelvinNLab3_Output.txt

BEGIN
    DBMS_OUTPUT.PUT_LINE('array_date procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DECLARE
        v_days NUMBER_ARRAY := NUMBER_ARRAY(1, 5, 7);
        v_months NUMBER_ARRAY := NUMBER_ARRAY(2, 4);
    BEGIN
        array_date(v_days, v_months);
    END;
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Error handling demonstration: too many values');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DECLARE
        v_days NUMBER_ARRAY := NUMBER_ARRAY(1, 5, 7);
        v_months NUMBER_ARRAY := NUMBER_ARRAY(1, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 9, 8);
    BEGIN
        array_date(v_days, v_months);
    END;
    DBMS_OUTPUT.PUT_LINE('Error handling demonstration: Wrong values');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DECLARE
        v_days NUMBER_ARRAY := NUMBER_ARRAY(1, 5, 7);
        v_months NUMBER_ARRAY := NUMBER_ARRAY(1, 4, 5, 6, 22);
    BEGIN
        array_date(v_days, v_months);
    END;
    
    DBMS_OUTPUT.PUT_LINE('name_fun procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    name_fun();
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
END;
/
SPOOL OFF




