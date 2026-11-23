-- =====================================================================
-- DATA CLEANING AND TRANSFORMATION DEMO - Inventory Management (PostgreSQL)
-- File    : Data_Cleaning.sql
-- Run FIRST: Inventory_Management.sql
-- =====================================================================
-- IDEA: Real data is often dirty. Here we create two small RAW (staging)
-- tables with deliberate mistakes, find the mistakes and correct them.
-- The five operational tables (products, stock_transactions, ...) are
-- NEVER changed in this file, so the final dataset stays safe.
-- This file can be re-run: it deletes and recreates the raw tables.
-- Run it step by step: select one step and press F5.
-- =====================================================================

-- ===================================================================
-- STEP 0: CREATE THE RAW TABLES WITH DIRTY DATA
-- ===================================================================

DROP TABLE IF EXISTS raw_products;
DROP TABLE IF EXISTS raw_stock_entries;

-- Staging tables have NO constraints, so they accept dirty data.
CREATE TABLE raw_products (
    raw_id         INTEGER,
    product_name   VARCHAR(80),
    category_name  VARCHAR(50),
    unit_price     NUMERIC(10,2),
    reorder_level  INTEGER
);

CREATE TABLE raw_stock_entries (
    entry_id          INTEGER,
    product_id        INTEGER,
    warehouse_id      INTEGER,
    entry_date        DATE,
    transaction_type  VARCHAR(5),
    quantity          INTEGER
);

INSERT INTO raw_products (raw_id, product_name, category_name, unit_price, reorder_level) VALUES
  (1,  'Wireless Optical Mouse',        'Computer Peripherals', 325.00,  40),
  (2,  'USB Wired Keyboard',            'computer peripherals', 390.00,  40),
  (3,  'Wireless Optical Mouse',        'Computer Peripherals', 325.00,  40),   -- exact duplicate of row 1
  (4,  '  Bluetooth Speaker 10W ',      'ELECTRONICS',          920.00,  40),   -- extra spaces, capital letters
  (5,  'Smart Fitness Band',            'Electronic',           1350.00, 30),   -- wrong category spelling
  (6,  'Power Bank 10000mAh',           'Mobile Accessory',     910.00,  60),   -- wrong category spelling
  (7,  'power bank 10000mah',           'Mobile Accessories',   910.00,  60),   -- duplicate in lower case
  (8,  'USB-C Fast Charger 20W',        'mobile accessories',   NULL,    50),   -- missing price
  (9,  'A4 Copier Paper 500 Sheets',    'Office stationery',    275.00,  NULL), -- missing reorder level
  (10, 'Gel Pen Black Pack of 10',      NULL,                   155.00,  100),  -- missing category
  (11, 'Electric Kettle 1.5 Litre',     'Home Appliance',       760.00,  20),   -- wrong category spelling
  (12, 'Pressure Cooker 5 Litre',       'kitchenware',          1625.00, 15),
  (13, 'Table Fan 400mm',               'Home Appliances',      1850.00, 10),
  (14, 'Tea Leaves 500g',               'Packaged food',        290.00,  50);

INSERT INTO raw_stock_entries (entry_id, product_id, warehouse_id, entry_date, transaction_type, quantity) VALUES
  (1,  28,  1, '2026-11-03', 'IN',    150),
  (2,  28,  1, '2026-11-03', 'IN',    150),    -- exact duplicate of entry 1
  (3,  40,  2, '2026-11-04', 'in',    300),    -- type in small letters
  (4,  55,  1, '2026-11-04', 'OUT',   -20),    -- negative quantity
  (5,  63,  3, '2026-11-05', 'OUT',   0),      -- zero quantity
  (6,  17,  2, '2026-11-05', 'IN',    NULL),   -- missing quantity
  (7,  999, 1, '2026-11-06', 'IN',    50),     -- product 999 does not exist
  (8,  90,  1, '2026-11-06', 'Out ',  5),      -- type with mixed case and space
  (9,  85,  1, '2026-11-07', 'IN',    100),
  (10, 12,  2, '2026-11-07', 'OUT',   3);


-- ===================================================================
-- STEP 1: LOOK AT THE RAW DATA
-- ===================================================================

-- 1.1 View raw products
-- Always look at the data first. Notice the spaces, capital letters,
-- spelling differences, NULL values and repeated rows.
SELECT * FROM raw_products ORDER BY raw_id;
-- Expected output:
--   raw_id | product_name               | category_name        | unit_price | reorder_level
--   -------+----------------------------+----------------------+------------+--------------
--   1      | Wireless Optical Mouse     | Computer Peripherals | 325.00     | 40
--   2      | USB Wired Keyboard         | computer peripherals | 390.00     | 40
--   3      | Wireless Optical Mouse     | Computer Peripherals | 325.00     | 40
--   4      |   Bluetooth Speaker 10W    | ELECTRONICS          | 920.00     | 40
--   5      | Smart Fitness Band         | Electronic           | 1350.00    | 30
--   6      | Power Bank 10000mAh        | Mobile Accessory     | 910.00     | 60
--   7      | power bank 10000mah        | Mobile Accessories   | 910.00     | 60
--   8      | USB-C Fast Charger 20W     | mobile accessories   | NULL       | 50
--   9      | A4 Copier Paper 500 Sheets | Office stationery    | 275.00     | NULL
--   10     | Gel Pen Black Pack of 10   | NULL                 | 155.00     | 100
--   11     | Electric Kettle 1.5 Litre  | Home Appliance       | 760.00     | 20
--   12     | Pressure Cooker 5 Litre    | kitchenware          | 1625.00    | 15
--   13     | Table Fan 400mm            | Home Appliances      | 1850.00    | 10
--   14     | Tea Leaves 500g            | Packaged food        | 290.00     | 50

-- 1.2 View raw stock entries
-- Notice the negative, zero and missing quantities, the unknown
-- product 999 and the different spellings of IN/OUT.
SELECT * FROM raw_stock_entries ORDER BY entry_id;
-- Expected output:
--   entry_id | product_id | warehouse_id | entry_date | transaction_type | quantity
--   ---------+------------+--------------+------------+------------------+---------
--   1        | 28         | 1            | 2026-11-03 | IN               | 150
--   2        | 28         | 1            | 2026-11-03 | IN               | 150
--   3        | 40         | 2            | 2026-11-04 | in               | 300
--   4        | 55         | 1            | 2026-11-04 | OUT              | -20
--   5        | 63         | 3            | 2026-11-05 | OUT              | 0
--   6        | 17         | 2            | 2026-11-05 | IN               | NULL
--   7        | 999        | 1            | 2026-11-06 | IN               | 50
--   8        | 90         | 1            | 2026-11-06 | Out              | 5
--   9        | 85         | 1            | 2026-11-07 | IN               | 100
--   10       | 12         | 2            | 2026-11-07 | OUT              | 3

-- ===================================================================
-- STEP 2: IDENTIFY THE PROBLEMS
-- ===================================================================

-- 2.1 Duplicate products
-- LOWER and TRIM make the text lower case and remove extra spaces, so
-- 'Power Bank 10000mAh' and 'power bank 10000mah' are treated as the
-- same product. GROUP BY with HAVING COUNT(*) > 1 lists names that
-- appear more than once.
SELECT LOWER(TRIM(product_name)) AS product_name_clean, COUNT(*) AS times_found
FROM raw_products
GROUP BY LOWER(TRIM(product_name))
HAVING COUNT(*) > 1;
-- Expected output:
--   product_name_clean     | times_found
--   -----------------------+------------
--   power bank 10000mah    | 2
--   wireless optical mouse | 2

-- 2.2 Missing values
-- IS NULL finds empty cells. We look at the three columns that must
-- not be empty.
SELECT raw_id, product_name, category_name, unit_price, reorder_level
FROM raw_products
WHERE category_name IS NULL OR unit_price IS NULL OR reorder_level IS NULL
ORDER BY raw_id;
-- Expected output:
--   raw_id | product_name               | category_name      | unit_price | reorder_level
--   -------+----------------------------+--------------------+------------+--------------
--   8      | USB-C Fast Charger 20W     | mobile accessories | NULL       | 50
--   9      | A4 Copier Paper 500 Sheets | Office stationery  | 275.00     | NULL
--   10     | Gel Pen Black Pack of 10   | NULL               | 155.00     | 100

-- 2.3 Inconsistent category names
-- DISTINCT shows each different spelling once. The master table
-- categories has only one correct spelling for each category.
SELECT DISTINCT category_name
FROM raw_products
ORDER BY category_name;
-- Expected output:
--   category_name
--   --------------------
--   Computer Peripherals
--   ELECTRONICS
--   Electronic
--   Home Appliance
--   Home Appliances
--   Mobile Accessories
--   Mobile Accessory
--   Office stationery
--   Packaged food
--   computer peripherals
--   kitchenware
--   mobile accessories
--   NULL

-- 2.4 Category names that do not match the master table
-- A LEFT JOIN keeps all raw rows. Where there is no match in
-- categories the master column is NULL, so these are the wrong
-- spellings.
SELECT r.raw_id, r.category_name
FROM raw_products r
LEFT JOIN categories c ON r.category_name = c.category_name
WHERE c.category_name IS NULL AND r.category_name IS NOT NULL
ORDER BY r.raw_id;
-- Expected output:
--   raw_id | category_name
--   -------+---------------------
--   2      | computer peripherals
--   4      | ELECTRONICS
--   5      | Electronic
--   6      | Mobile Accessory
--   8      | mobile accessories
--   9      | Office stationery
--   11     | Home Appliance
--   12     | kitchenware
--   14     | Packaged food

-- 2.5 Invalid quantities
-- A stock quantity must be a positive number. We search for zero,
-- negative and missing quantities.
SELECT entry_id, product_id, transaction_type, quantity
FROM raw_stock_entries
WHERE quantity IS NULL OR quantity <= 0
ORDER BY entry_id;
-- Expected output:
--   entry_id | product_id | transaction_type | quantity
--   ---------+------------+------------------+---------
--   4        | 55         | OUT              | -20
--   5        | 63         | OUT              | 0
--   6        | 17         | IN               | NULL

-- 2.6 Stock entries for products that do not exist
-- The same LEFT JOIN idea: entries whose product_id is not found in
-- the master products table.
SELECT r.entry_id, r.product_id
FROM raw_stock_entries r
LEFT JOIN products p ON r.product_id = p.product_id
WHERE p.product_id IS NULL;
-- Expected output:
--   entry_id | product_id
--   ---------+-----------
--   7        | 999

-- ===================================================================
-- STEP 3: CORRECT THE PROBLEMS (only the RAW tables are changed)
-- ===================================================================

-- 3.1 Remove extra spaces from product names
-- TRIM removes spaces at the start and end of the text.
UPDATE raw_products
SET product_name = TRIM(product_name);
-- Result: UPDATE 14

-- 3.2 Remove duplicate products
-- For every product name (ignoring capital letters and spaces) we keep
-- the row with the smallest raw_id and delete the others. Rows 3 and 7
-- are removed.
DELETE FROM raw_products
WHERE raw_id NOT IN (SELECT MIN(raw_id)
                     FROM raw_products
                     GROUP BY LOWER(TRIM(product_name)));
-- Result: DELETE 2

-- 3.3 Correct inconsistent category names (all categories in one statement)
-- CASE chooses the correct spelling for every wrong spelling. The
-- WHERE part makes sure that empty (NULL) categories are not touched
-- here.
UPDATE raw_products
SET category_name = CASE
    WHEN LOWER(TRIM(category_name)) IN ('electronics', 'electronic')               THEN 'Electronics'
    WHEN LOWER(TRIM(category_name)) IN ('mobile accessories', 'mobile accessory')  THEN 'Mobile Accessories'
    WHEN LOWER(TRIM(category_name)) IN ('computer peripherals', 'computer peripheral') THEN 'Computer Peripherals'
    WHEN LOWER(TRIM(category_name)) = 'office stationery'                          THEN 'Office Stationery'
    WHEN LOWER(TRIM(category_name)) IN ('home appliances', 'home appliance')       THEN 'Home Appliances'
    WHEN LOWER(TRIM(category_name)) = 'kitchenware'                                THEN 'Kitchenware'
    WHEN LOWER(TRIM(category_name)) = 'packaged food'                              THEN 'Packaged Food'
    ELSE category_name
END
WHERE category_name IS NOT NULL;
-- Result: UPDATE 11

-- 3.4 Fill the missing category
-- After checking the master products table, 'Gel Pen Black Pack of 10'
-- belongs to Office Stationery.
UPDATE raw_products
SET category_name = 'Office Stationery'
WHERE raw_id = 10;
-- Result: UPDATE 1

-- 3.5 Fill the missing price from the master table
-- A subquery reads the correct price of the same product from the
-- products table.
UPDATE raw_products
SET unit_price = (SELECT unit_price FROM products
                  WHERE product_name = 'USB-C Fast Charger 20W')
WHERE raw_id = 8;
-- Result: UPDATE 1

-- 3.6 Fill the missing reorder level from the master table
-- Same method as 3.5.
UPDATE raw_products
SET reorder_level = (SELECT reorder_level FROM products
                     WHERE product_name = 'A4 Copier Paper 500 Sheets')
WHERE raw_id = 9;
-- Result: UPDATE 1

-- 3.7 Make IN / OUT spelling consistent
-- UPPER makes capital letters and TRIM removes spaces, so 'in' and
-- 'Out ' become 'IN' and 'OUT'.
UPDATE raw_stock_entries
SET transaction_type = UPPER(TRIM(transaction_type));
-- Result: UPDATE 10

-- 3.8 Delete invalid quantities
-- Zero, negative and missing quantities cannot be real stock
-- movements, so these rows are deleted.
DELETE FROM raw_stock_entries
WHERE quantity IS NULL OR quantity <= 0;
-- Result: DELETE 3

-- 3.9 Delete entries with an unknown product
-- Stock cannot be recorded for a product that does not exist. (NOT IN
-- checks against the master list of products.)
DELETE FROM raw_stock_entries
WHERE product_id NOT IN (SELECT product_id FROM products);
-- Result: DELETE 1

-- 3.10 Remove duplicate stock entries
-- Same idea as 3.2. Entries with the same product, warehouse, date,
-- type and quantity are duplicates. We keep the smallest entry_id.
DELETE FROM raw_stock_entries
WHERE entry_id NOT IN (SELECT MIN(entry_id)
                       FROM raw_stock_entries
                       GROUP BY product_id, warehouse_id, entry_date,
                                transaction_type, quantity);
-- Result: DELETE 1

-- ===================================================================
-- STEP 4: VERIFY THE CLEAN DATA
-- ===================================================================

-- 4.1 Clean products
-- Compare with Step 1.1: 12 rows remain, no duplicates, no NULL values
-- and correct category names.
SELECT * FROM raw_products ORDER BY raw_id;
-- Expected output:
--   raw_id | product_name               | category_name        | unit_price | reorder_level
--   -------+----------------------------+----------------------+------------+--------------
--   1      | Wireless Optical Mouse     | Computer Peripherals | 325.00     | 40
--   2      | USB Wired Keyboard         | Computer Peripherals | 390.00     | 40
--   4      | Bluetooth Speaker 10W      | Electronics          | 920.00     | 40
--   5      | Smart Fitness Band         | Electronics          | 1350.00    | 30
--   6      | Power Bank 10000mAh        | Mobile Accessories   | 910.00     | 60
--   8      | USB-C Fast Charger 20W     | Mobile Accessories   | 530.00     | 50
--   9      | A4 Copier Paper 500 Sheets | Office Stationery    | 275.00     | 40
--   10     | Gel Pen Black Pack of 10   | Office Stationery    | 155.00     | 100
--   11     | Electric Kettle 1.5 Litre  | Home Appliances      | 760.00     | 20
--   12     | Pressure Cooker 5 Litre    | Kitchenware          | 1625.00    | 15
--   13     | Table Fan 400mm            | Home Appliances      | 1850.00    | 10
--   14     | Tea Leaves 500g            | Packaged Food        | 290.00     | 50

-- 4.2 Clean stock entries
-- Compare with Step 1.2: 5 valid rows remain.
SELECT * FROM raw_stock_entries ORDER BY entry_id;
-- Expected output:
--   entry_id | product_id | warehouse_id | entry_date | transaction_type | quantity
--   ---------+------------+--------------+------------+------------------+---------
--   1        | 28         | 1            | 2026-11-03 | IN               | 150
--   3        | 40         | 2            | 2026-11-04 | IN               | 300
--   8        | 90         | 1            | 2026-11-06 | OUT              | 5
--   9        | 85         | 1            | 2026-11-07 | IN               | 100
--   10       | 12         | 2            | 2026-11-07 | OUT              | 3

-- 4.3 Check that no problem is left
-- Each count must be 0.
SELECT (SELECT COUNT(*) FROM raw_products WHERE category_name IS NULL OR unit_price IS NULL OR reorder_level IS NULL) AS missing_values,
       (SELECT COUNT(*) FROM raw_products r LEFT JOIN categories c ON r.category_name = c.category_name WHERE c.category_name IS NULL) AS wrong_categories,
       (SELECT COUNT(*) FROM raw_stock_entries WHERE quantity IS NULL OR quantity <= 0) AS bad_quantities;
-- Expected output:
--   missing_values | wrong_categories | bad_quantities
--   ---------------+------------------+---------------
--   0              | 0                | 0

-- ===================================================================
-- STEP 5: TRANSFORMATION - TURN STOCK NUMBERS INTO A BUSINESS STATUS
-- ===================================================================

-- 5.1 Stock status of every product (counts)
-- Transformation means changing data into a more useful form. CASE
-- labels each product as 'Out of Stock', 'Low Stock' or 'Adequate'.
-- Then we count how many products are in each status. This only reads
-- data; nothing is changed.
SELECT CASE WHEN current_stock = 0 THEN 'Out of Stock'
            WHEN current_stock < reorder_level THEN 'Low Stock'
            ELSE 'Adequate' END AS stock_status,
       COUNT(*) AS number_of_products
FROM vw_product_stock
GROUP BY CASE WHEN current_stock = 0 THEN 'Out of Stock'
              WHEN current_stock < reorder_level THEN 'Low Stock'
              ELSE 'Adequate' END
ORDER BY number_of_products DESC;
-- Expected output:
--   stock_status | number_of_products
--   -------------+-------------------
--   Adequate     | 73
--   Low Stock    | 15
--   Out of Stock | 12

-- ===================================================================
-- STEP 6: CONFIRM THAT THE OPERATIONAL DATA IS SAFE
-- ===================================================================

-- 6.1 Row counts of the operational tables
-- They must still be 100 products and 200 transactions: cleaning never
-- touched them.
SELECT (SELECT COUNT(*) FROM products) AS products,
       (SELECT COUNT(*) FROM stock_transactions) AS stock_transactions;
-- Expected output:
--   products | stock_transactions
--   ---------+-------------------
--   100      | 200

-- ======================== END OF FILE ================================
