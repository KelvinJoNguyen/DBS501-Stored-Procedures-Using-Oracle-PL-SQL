/*************************************************************************************
*
* Student Name : Kelvin Nguyen
* Student ID  : 104087226
* Email: knguyen123@myseneca.ca
* Date: 2024/02/15
* Course/Section: DBS501/NSA
*
* I have done all the coding by myself and only copied the code that my professor
* provided to complete my workshops and assignments.
*
**************************************************************************************/
SET SERVEROUTPUT ON;

--1. Factorial procedure that gets an integer number n andcalculates and displays its factorial using recursion
CREATE OR REPLACE PROCEDURE factorial(n IN NUMBER, nFact OUT NUMBER) AS 
BEGIN
    IF n = 0 THEN
        nFact:= 1;
    ELSE
        factorial(n-1, nFact);
        DBMS_OUTPUT.PUT(n || '*' || nFact);
        nFact := n * nFact;
        DBMS_OUTPUT.PUT_LINE('=' || nFact);
    END IF;
END;


-- 2. Calculate fibonacci sequence up to n
CREATE OR REPLACE PROCEDURE fibonacci(n IN NUMBER) AS
       PROCEDURE fibRecursive(current IN NUMBER, previous IN NUMBER, remaining IN NUMBER) IS
    BEGIN
        IF remaining > 1 THEN
            -- Output current Fibonacci number
            DBMS_OUTPUT.PUT(current || ' ');

            -- Call recursively for the next Fibonacci number
            fibRecursive(current + previous, current, remaining - 1);
        ELSIF remaining = 1 THEN
            -- Output the last Fibonacci number
            DBMS_OUTPUT.PUT(current || ' ');
        END IF;
    END;
BEGIN
    -- Output exactly n Fibonacci numbers using recursion
    IF n < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Please enter a non-negative number.');
    ELSE
        -- Start recursion with initial values 0 and 1
        fibRecursive(0, 1, n);
        DBMS_OUTPUT.PUT_LINE(''); 
    END IF;
END;


-- 3. Updatethe price of all products in a given category and the given amount to be addedto the current price
CREATE OR REPLACE PROCEDURE update_price_by_cat(category_id IN products.category_id%TYPE, amount IN NUMBER) 
AS
    rowsUpdated NUMBER;
BEGIN
    -- Check if the given category exists
    DECLARE
        categoryExists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO categoryExists
        FROM products
        WHERE category_id = update_price_by_cat.category_id;

        IF categoryExists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Category does not exist.');
            RETURN;
        END IF;
    END;

    -- Update the price for the specified category
    UPDATE products
    SET list_price = list_price + amount
    WHERE category_id = update_price_by_cat.category_id
    AND list_price > 0;

    -- Get the number of updated rows
    rowsUpdated := SQL%ROWCOUNT;

    -- Display result
    DBMS_OUTPUT.PUT_LINE('Number of updated rows: ' || rowsUpdated);
END; 

-- 4. Increase average price of products depending on average price
CREATE OR REPLACE PROCEDURE update_price_under_avg AS
    rowsUpdated NUMBER;
    avgPrice NUMBER(9,2);
BEGIN
    -- Calculate the average price of all products
    SELECT AVG(list_price) INTO avgPrice
    FROM products;

    DBMS_OUTPUT.PUT_LINE('Average price of products: $' || avgPrice);
    -- Update products based on the calculated average price
    BEGIN
        IF avgPrice <= 1000 THEN
            -- Update by 2% if price is less than the calculated average
            UPDATE products
            SET list_price = list_price * 1.02
            WHERE list_price < avgPrice;

            rowsUpdated := SQL%ROWCOUNT;
        ELSE
            -- Update by 1% if price is less than the calculated average
            UPDATE products
            SET list_price = list_price * 1.01
            WHERE list_price < avgPrice;

            rowsUpdated := SQL%ROWCOUNT;
        END IF;
    -- Error handling
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error occurred');
            RETURN;
    END;

        DBMS_OUTPUT.PUT_LINE('Number of updated rows: ' || rowsUpdated);
END;


--5. Show number of products based on cheap, fair or expensive price category
CREATE OR REPLACE PROCEDURE product_price_report AS
    avgPrice NUMBER;
    minPrice NUMBER;
    maxPrice NUMBER;
    cheapCount NUMBER := 0;
    fairCount NUMBER := 0;
    expensiveCount NUMBER := 0;
BEGIN
    -- Find average, min, and max prices
    SELECT AVG(list_price), MIN(list_price), MAX(list_price)
    INTO avgPrice, minPrice, maxPrice
    FROM products;

    -- Categorize products based on prices
    FOR product_rec IN (SELECT list_price FROM products) LOOP
        IF product_rec.list_price < (avgPrice - minPrice) / 2 THEN
            cheapCount := cheapCount + 1;
            
        ELSIF product_rec.list_price > (maxPrice - avgPrice) / 2 THEN
            expensiveCount := expensiveCount + 1;
        ELSE
            fairCount := fairCount + 1;
        END IF;
        
    END LOOP;

    -- Display the result
    DBMS_OUTPUT.PUT_LINE('Cheap: ' || cheapCount);
    DBMS_OUTPUT.PUT_LINE('Fair: ' || fairCount);
    DBMS_OUTPUT.PUT_LINE('Expensive: ' || expensiveCount);
    -- Error handling
    EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error occurred');
END;
    
    

    
-- Output file script   

SPOOL KelvinNLab2_Output.txt

SET SERVEROUTPUT ON;

BEGIN

-- 1. Demonstration of factorial procedure
    DBMS_OUTPUT.PUT_LINE('factorial procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DECLARE 
        z NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Input: 5');
        factorial(5,z);
         DBMS_OUTPUT.NEW_LINE;
         
        DBMS_OUTPUT.PUT_LINE('Input: 12');
        factorial(12,z);
         DBMS_OUTPUT.NEW_LINE;
        
        DBMS_OUTPUT.PUT_LINE('Input: 30');
        factorial(30,z);
    END;
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
--2. Demonstration of fibonacci procedure
    DBMS_OUTPUT.PUT_LINE('fibonacci procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Input: 5');
        fibonacci(5);
        DBMS_OUTPUT.NEW_LINE;
        
        DBMS_OUTPUT.PUT_LINE('Input: 14');
        fibonacci(14);
    END;
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
-- 3. Demonstration of update_price_by_cat procedure
    DBMS_OUTPUT.PUT_LINE('update_price_by_cat procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    BEGIN
        update_price_by_cat(1, 5);
        DBMS_OUTPUT.PUT_LINE('Error handling:');
        update_price_by_cat(25, 5);
    END;
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    
-- 4. Demonstration of update_price_under_avg procedure
    DBMS_OUTPUT.PUT_LINE('update_price_under_avg procedure started: ');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    BEGIN
        update_price_under_avg;
    END;
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
-- 5. Demonstration of product_price_report procedure
    DBMS_OUTPUT.PUT_LINE('product_price_report procedure started:');
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    BEGIN
        product_price_report;
    END;
    DBMS_OUTPUT.PUT_LINE('--------------------------------');
    DBMS_OUTPUT.NEW_LINE;
END;
/
SPOOL OFF
    







    
    

        







