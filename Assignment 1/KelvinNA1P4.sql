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

-- Part 4 

-- Looks for the given customer ID in the database. If the customer exists, it sets the variable found to 1 otherwise set to 0
CREATE OR REPLACE PROCEDURE find_customer(cusId IN NUMBER, found OUT NUMBER) AS
    -- Declare variables
    customer_count NUMBER;
    customerName customers.name%type;

BEGIN
    SELECT COUNT(*) 
    INTO customer_count
    FROM customers
    WHERE customer_id = cusId;
    
    -- Set the found variable based on the existence of the customer
    IF customer_count > 0 THEN
        SELECT name 
        INTO customerName
        FROM customers
        WHERE customer_id = cusId;
        
        found := 1; -- Customer found
        DBMS_OUTPUT.PUT_LINE('Customer with ID ' || cusId || ' found: ' || customerName);
    ELSE
        found := 0; -- Customer not found
        DBMS_OUTPUT.PUT_LINE('Error customer not found.');
    END IF;
END;


-- Find product and gets price
CREATE OR REPLACE PROCEDURE find_product(productId IN NUMBER, price OUT products.list_price%TYPE) AS
BEGIN
    SELECT list_price
    INTO price
    FROM products
    WHERE product_id = productId;
    
    DBMS_OUTPUT.PUT_LINE ('Product ID- ' || productId || ' : $' || price);
    -- Error handling if data is not found
EXCEPTION WHEN NO_DATA_FOUND THEN 
    DBMS_OUTPUT.PUT_LINE ('Product Not Found');
    price := 0;
END;


-- Add a new order for customer
CREATE OR REPLACE PROCEDURE add_order (customer_id IN NUMBER, new_order_id OUT NUMBER) AS
-- Declare variables
    latestOrder NUMBER(38,0);
    customerFound NUMBER;
BEGIN

    SELECT MAX(order_id) 
    INTO latestOrder
    FROM orders;
-- Make new order number
    new_order_id := latestOrder + 1;

-- error handle customer id
    find_customer(customer_id, customerFound);

    IF customerFound = 1 THEN
-- Insert new data 
    INSERT INTO orders (
        order_id,
        customer_id,
        status,
        salesman_id,
        order_date
    )VALUES(
        new_order_id,
        customer_id,
        'Shipped',
        56,
        SYSDATE
    );
    
    --Output order info     
    DBMS_OUTPUT.PUT_LINE ('Order: ' || new_order_id || ' added');
    DBMS_OUTPUT.PUT_LINE ('Customer: ' || customer_id);
    DBMS_OUTPUT.PUT_LINE ('Order status: Shipped');
    DBMS_OUTPUT.PUT_LINE ('Salesman: 56'); 
    DBMS_OUTPUT.PUT_LINE ('Date ordered: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    
    END IF;

END;

-- Add item to order 
CREATE OR REPLACE PROCEDURE add_order_item(
    orderId IN order_items.order_id%type, 
    itemId IN order_items.item_id%type, 
    productId IN order_items.product_id%type, 
    quantity IN order_items.quantity%type, 
    price IN order_items.unit_price%type) AS
    
-- Delcare variables
orderFound NUMBER;
productFound NUMBER;
BEGIN

    SELECT COUNT(*) 
    INTO orderFound
    FROM order_items
    WHERE orderId = order_Id;
    
 -- Validate orderId
    IF orderFound > 1 THEN
    DBMS_OUTPUT.PUT_LINE ('Adding: ');
    find_Product(productId, productFound);
    DBMS_OUTPUT.PUT_LINE ('QTY: ' || quantity);
    DBMS_OUTPUT.NEW_LINE;

-- Validate productId
        IF productFound > 0 THEN
            INSERT INTO order_items (
                order_id,
                item_id,
                product_id,
                quantity,
                unit_price
            ) VALUES (
                orderId,
                itemId,
                productId,
                quantity,
                price
            );
        END IF;
    
    ELSIF orderFound = 0 THEN
    DBMS_OUTPUT.PUT_LINE ('Error: Invalid order ID. Please create new order before adding items');
    RETURN;

    END IF;
    
END;

-- Display order details 
CREATE OR REPLACE PROCEDURE display_order(orderIdParam IN NUMBER) AS
    orderId orders.order_id%TYPE;
    customerId orders.customer_id%TYPE;
    itemId order_items.item_id%TYPE;
    productId order_items.product_id%TYPE;
    qty order_items.quantity%TYPE;
    price order_items.unit_price%TYPE;
    totalPrice NUMBER := 0;
BEGIN
 -- Find order information
    SELECT order_id, customer_id
    INTO orderId, customerId
    FROM orders
    WHERE order_id = orderIdParam;

    -- Display order information
    DBMS_OUTPUT.PUT_LINE('Order summary:');
    DBMS_OUTPUT.PUT_LINE('Order ID: ' || orderId);
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || customerId);
    DBMS_OUTPUT.PUT_LINE('------------------------');

        -- Find and display order items
    FOR itemRecord IN (SELECT item_id, product_id, quantity, unit_price
                     FROM order_items
                     WHERE order_id = orderIdParam) 
    LOOP
        itemId := itemRecord.item_id;
        productId := itemRecord.product_id;
        qty := itemRecord.quantity;
        price := itemRecord.unit_price;

        -- Display item information
        DBMS_OUTPUT.PUT_LINE('Item ID: ' || itemId);
        DBMS_OUTPUT.PUT_LINE('Product ID: ' || productId);
        DBMS_OUTPUT.PUT_LINE('Quantity: ' || qty);
        DBMS_OUTPUT.PUT_LINE('Price: $' || price);

        -- Calculate and accumulate total price
        totalPrice := totalPrice + (qty * price);

        DBMS_OUTPUT.PUT_LINE('------------------------');
    END LOOP;

    -- Display total price
    DBMS_OUTPUT.PUT_LINE('Total Price: $' || totalPrice);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Order ID not found.');
        
END;

-- Call tasks 
CREATE OR REPLACE PROCEDURE master_proc(task IN NUMBER, parm1 IN NUMBER) AS
    output NUMBER;
BEGIN 
    IF task = 1 THEN
        find_customer(parm1, output);
    ELSIF task = 2 THEN
        find_product(parm1, output);
    ELSIF task = 3 THEN
        add_order(parm1, output);
    ELSIF task = 4 THEN
        display_order(parm1); 
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Error: Invalid task');
    END IF;
END;



-- Output file script   

SPOOL KelvinNA1P4_Output.txt

SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Assignment 1 Part 4');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('1. find_customer – with a valid customer ID');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(1, 23);  
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('2. find_customer – with a invalid customer ID');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(1, 00);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('3. find_product – with a valid product ID');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(2, 8);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('4. find_product – with a invalid product ID');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(2, 0);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('5. add_order – with a valid customer ID');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(3, 1);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('6. add_order – with a invalid customer ID');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(3, 0);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('7. add_order_item – should execute successfully 5 times');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
 
    add_order_item(2, 14, 1, 3, 550);
    add_order_item(2, 15, 3, 6, 607.99);
    add_order_item(3, 16, 18, 10, 750.65);
    add_order_item(3, 17, 21, 12, 801.85);
    add_order_item(5, 18, 25, 15, 100);

    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('8. add_order_item – should execute with an invalid order ID');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    add_order_item(0, 14, 1, 3, 200);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('9. display_order – with a valid order ID which has at least 5 order items');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(4, 1);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
        
    DBMS_OUTPUT.PUT_LINE('10. display_order – with an invalid order ID');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(4, 0);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;
    
    DBMS_OUTPUT.PUT_LINE('11. invalid master_proc call');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    master_proc(5, 1);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------');
    DBMS_OUTPUT.NEW_LINE;

END;
/
SPOOL OFF

