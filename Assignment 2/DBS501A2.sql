/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/03/21
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/

SET SERVEROUTPUT ON;
-- User defined collection 
CREATE OR REPLACE TYPE number_list AS TABLE OF NUMBER;

-- 2 Calculate median of list 
CREATE OR REPLACE FUNCTION my_median(inputList IN number_list) RETURN NUMBER IS
-- Create variables
    nMedian NUMBER;
    sortedValues number_list := number_list();
BEGIN
    
    -- Error handling if input list is empty
     IF inputList IS NULL OR inputList.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INPUT LIST IS EMPTY');
        RETURN NULL;
    END IF;

    -- Copy column values to a local list
    FOR i IN 1..inputList.COUNT LOOP
        sortedValues.EXTEND;
        sortedValues(i) := inputList(i);
    END LOOP;

    -- Sort the list
    FOR i IN 1..sortedValues.COUNT - 1 LOOP
        FOR j IN i+1..sortedValues.COUNT LOOP
            IF sortedValues(i) > sortedValues(j) THEN
                sortedValues(i) := sortedValues(i) + sortedValues(j);
                sortedValues(j) := sortedValues(i) - sortedValues(j);
                sortedValues(i) := sortedValues(i) - sortedValues(j);
            END IF;
        END LOOP;
    END LOOP;

    -- Calculate the median
    IF MOD(sortedValues.COUNT, 2) = 1 THEN
        -- If the count is odd
        nMedian := sortedValues((sortedValues.COUNT + 1) / 2);
    ELSE
        -- If the count is even
        nMedian := (sortedValues(sortedValues.COUNT / 2) + sortedValues(sortedValues.COUNT / 2 + 1)) / 2;
    END IF;

    RETURN nMedian;
END;


--3 Calculate mode of list
CREATE OR REPLACE FUNCTION my_mode(inputList number_list) RETURN VARCHAR IS
    -- Declare variables
    output VARCHAR(225);
    modeValues number_list := number_list();
    modeCount NUMBER := 0;
    maxCount NUMBER := 0;
    currentCount NUMBER;

BEGIN
    -- Error handling for empty input 
    IF inputList IS NULL OR inputList.COUNT = 0 THEN
        RETURN 'ERROR INPUT LIST IS EMPTY';
    END IF;
    
    -- Count occurences of each value 
    FOR i IN 1..inputList.COUNT LOOP
        currentCount := 0;
        FOR j IN 1..inputList.COUNT LOOP
            IF inputList(i) = inputList(j) THEN
                currentCount := currentCount + 1;
            END IF;
        END LOOP;
        
        -- If current count has higher count update mode
        IF currentCount > maxCount THEN
            maxCount := currentCount;
            output:= TO_CHAR(inputList(i));
            modeCount := 1;
            
        ELSIF currentCount = maxCount AND output NOT LIKE '%' || TO_CHAR(inputList(i)) || '%' THEN
            output := output || ',' || TO_CHAR(inputList(i));
            modeCount := modeCount + 1;
        END IF;
    END LOOP;
    
    -- Check for found modes    
    IF modeCount >= 1 AND maxCount > 1 THEN
        RETURN 'Mode = ' || output;
    ELSE
        RETURN 'No mode found';
    END IF;
END;


--4 Master procedure that get mean, median, and mode from list of values 
CREATE OR REPLACE PROCEDURE my_math_all(val IN number_list) AS
    -- Declare variables
    nMedian NUMBER;
    nMode VARCHAR(255);
    nMean NUMBER;

BEGIN
    -- Error handling for empty input list
    IF val IS NULL OR val.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INPUT LIST IS EMPTY');
        RETURN;
    END IF;

    -- Calculate mean, median, mode
    SELECT ROUND(AVG(column_value), 2) INTO nMean    FROM TABLE(val);
    nMedian := my_median(val);
    nMode := my_mode(val);

    -- Output results
    DBMS_OUTPUT.PUT_LINE ('Median: ' || nMedian);
    DBMS_OUTPUT.PUT_LINE (nMode);
    DBMS_OUTPUT.PUT_LINE ('Mean: ' || nMean);

END;





-- Output file script   

SPOOL KelvinDBS501A2_Output.txt

SET SERVEROUTPUT ON;
DECLARE
    medianOutput NUMBER;
    modeOutput VARCHAR(255);
    mathAllOutput number_list;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Assignment 2');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Demo of my_median UDF');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Even Numbers:');
    SELECT my_median(CAST(MULTISET(SELECT salary FROM employee) AS number_list)) INTO medianOutput
    FROM dual; -- (There are 42 salaries)
    DBMS_OUTPUT.PUT_LINE(medianOutput);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Odd Numbers:');
    SELECT my_median(number_list(1,5,8,10,20,15,19)) INTO medianOutput
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(medianOutput);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Empty List:');
    SELECT my_median(number_list()) INTO medianOutput
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(medianOutput);
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Demo of my_mode UDF');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('No Modes:');
   SELECT my_mode(number_list(1, 2, 3, 4, 5, 6)) INTO modeOutput
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(modeOutput);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('One Mode:');
    SELECT my_mode(number_list(1, 2, 3, 4, 5, 5, 6)) INTO modeOutput
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(modeOutput);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Two Modes:');
    SELECT my_mode(CAST(MULTISET(SELECT salary FROM employee) AS number_list)) INTO modeOutput
    FROM dual;
    DBMS_OUTPUT.PUT_LINE(modeOutput);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Multiple Modes:');
    SELECT my_mode(number_list(1, 2, 3, 4, 4, 5, 5, 6 , 20, 20, 50, 9,10)) INTO modeOutput
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(modeOutput);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Empty List:');
    SELECT my_mode(number_list()) INTO modeOutput
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE(modeOutput);
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('Demo of my_math_all UDF');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    SELECT CAST(MULTISET(SELECT salary FROM employee) AS number_list) INTO mathAllOutput FROM dual;
    my_math_all(mathAllOutput);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Empty List:');
    my_math_all(number_list());
    DBMS_OUTPUT.NEW_LINE;
    
END;
/
SPOOL OFF

