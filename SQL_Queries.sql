-- =====================================================================
-- SQL QUERIES - INVENTORY AND STOCK MANAGEMENT SYSTEM (PostgreSQL)
-- File    : SQL_Queries.sql
-- Course  : SQL and Data Management (PMDE30605), MBA, IILM University
-- Run FIRST: Inventory_Management.sql  (creates and fills the database)
-- =====================================================================
-- HOW TO USE THIS FILE IN pgAdmin 4
--  1. Open the Query Tool on the database inventory_db.
--  2. Open this file. Do NOT press F5 for the whole file: pgAdmin shows
--     the result of only the LAST statement.
--  3. Instead, select ONE query with the mouse (from SELECT to the
--     semicolon) and press F5. The result appears in the Data Output tab.
--  4. Each query has: what it does, and the expected output.
--  5. Parts G and H change data. Run them LAST, one block at a time.
-- Stock Available = Total Stock IN - Total Stock OUT
-- Inventory Value = Current Stock x Cost Price
-- =====================================================================

-- ===================================================================
-- PART A: BASIC QUERIES
-- ===================================================================

-- QUERY 1: Display all products
-- What it does: SELECT * means 'show all columns'. FROM products tells
-- PostgreSQL which table to read. ORDER BY product_id sorts the rows
-- so the output is easy to read.
-- Expected output:
--   product_id | product_name                        | category_id | supplier_id | cost_price | unit_price | reorder_level
--   -----------+-------------------------------------+-------------+-------------+------------+------------+--------------
--   1          | LED TV 32 Inch HD Ready             | 1           | 1           | 8200.00    | 9675.00    | 5
--   2          | LED TV 43 Inch Full HD              | 1           | 15          | 15500.00   | 18290.00   | 12
--   3          | Bluetooth Speaker 10W               | 1           | 2           | 780.00     | 920.00     | 40
--   4          | Soundbar 2.1 Channel 60W            | 1           | 15          | 3900.00    | 4600.00    | 12
--   5          | Wireless Earbuds with Charging Case | 1           | 2           | 950.00     | 1120.00    | 40
--   ... (100 rows in total, first 5 shown)
SELECT *
FROM products
ORDER BY product_id;

-- QUERY 2: Display all suppliers
-- What it does: Shows every column of the suppliers table, including
-- the contact person and the lead time (days the supplier takes to
-- deliver).
-- Expected output:
--   supplier_id | supplier_name                | contact_person | phone      | email                            | city      | lead_time_days
--   ------------+------------------------------+----------------+------------+----------------------------------+-----------+---------------
--   1           | Zenith Electronics Pvt Ltd   | Anil Kapoor    | 9100010001 | sales@zenithelectronics.example  | Noida     | 7
--   2           | Apex Digital Distributors    | Neha Malhotra  | 9100010002 | orders@apexdigital.example       | Delhi     | 5
--   3           | Nova Mobile Accessories Co   | Rohit Saxena   | 9100010003 | info@novamobile.example          | Ghaziabad | 4
--   4           | Pioneer Computer Peripherals | Sunil Arora    | 9100010004 | sales@pioneerperipherals.example | Gurugram  | 6
--   5           | Sharma Stationery Traders    | Meena Sharma   | 9100010005 | contact@sharmastationery.example | Delhi     | 3
--   ... (15 rows in total, first 5 shown)
SELECT *
FROM suppliers
ORDER BY supplier_id;

-- QUERY 3: Display all warehouses
-- What it does: Shows the three warehouses with their city, capacity
-- and manager.
-- Expected output:
--   warehouse_id | warehouse_name                  | city          | state         | capacity_units | manager_name
--   -------------+---------------------------------+---------------+---------------+----------------+----------------
--   1            | Greater Noida Central Warehouse | Greater Noida | Uttar Pradesh | 50000          | Rakesh Verma
--   2            | Gurugram Distribution Hub       | Gurugram      | Haryana       | 30000          | Sandeep Yadav
--   3            | Lucknow Regional Warehouse      | Lucknow       | Uttar Pradesh | 20000          | Farhan Siddiqui
SELECT *
FROM warehouses
ORDER BY warehouse_id;

-- QUERY 4: Find products belonging to a particular category
-- What it does: WHERE keeps only the rows that match a condition.
-- Category 1 is 'Electronics' (see the categories table), so only
-- Electronics products appear. Change the number to see another
-- category.
-- Expected output:
--   product_id | product_name                        | unit_price
--   -----------+-------------------------------------+-----------
--   1          | LED TV 32 Inch HD Ready             | 9675.00
--   2          | LED TV 43 Inch Full HD              | 18290.00
--   3          | Bluetooth Speaker 10W               | 920.00
--   4          | Soundbar 2.1 Channel 60W            | 4600.00
--   5          | Wireless Earbuds with Charging Case | 1120.00
--   ... (15 rows in total, first 5 shown)
SELECT product_id, product_name, unit_price
FROM products
WHERE category_id = 1
ORDER BY product_id;

-- QUERY 5: Display products with their prices
-- What it does: cost_price is what we pay the supplier and unit_price
-- is what we sell at. The third column is calculated: profit_per_unit
-- = unit_price - cost_price. DESC shows the costliest product first.
-- Expected output:
--   product_id | product_name                  | cost_price | unit_price | profit_per_unit
--   -----------+-------------------------------+------------+------------+----------------
--   2          | LED TV 43 Inch Full HD        | 15500.00   | 18290.00   | 2790.00
--   1          | LED TV 32 Inch HD Ready       | 8200.00    | 9675.00    | 1475.00
--   13         | Home Theatre 5.1 System       | 7800.00    | 9205.00    | 1405.00
--   75         | Steel Storage Cabinet 4 Shelf | 6800.00    | 8500.00    | 1700.00
--   74         | Study Table with Drawer       | 5400.00    | 6750.00    | 1350.00
--   ... (100 rows in total, first 5 shown)
SELECT product_id, product_name, cost_price, unit_price,
       unit_price - cost_price AS profit_per_unit
FROM products
ORDER BY unit_price DESC;

-- QUERY 6: Display all stock transactions
-- What it does: Shows every stock movement. transaction_type is IN
-- (stock received) or OUT (stock issued).
-- Expected output:
--   transaction_id | product_id | warehouse_id | transaction_date | transaction_type | quantity | unit_cost
--   ---------------+------------+--------------+------------------+------------------+----------+----------
--   1              | 14         | 2            | 2026-04-01       | IN               | 27       | 550.24
--   2              | 19         | 2            | 2026-04-01       | IN               | 77       | 651.95
--   3              | 30         | 3            | 2026-04-01       | IN               | 54       | 673.83
--   4              | 75         | 1            | 2026-04-01       | IN               | 3        | 6773.10
--   5              | 96         | 1            | 2026-04-01       | IN               | 211      | 125.06
--   ... (200 rows in total, first 5 shown)
SELECT *
FROM stock_transactions
ORDER BY transaction_id;

-- ===================================================================
-- PART B: AGGREGATION QUERIES
-- ===================================================================

-- QUERY 7: Count total products
-- What it does: COUNT(*) counts the rows in the table. AS gives the
-- result column a readable name.
-- Expected output:
--   total_products
--   --------------
--   100
SELECT COUNT(*) AS total_products
FROM products;

-- QUERY 8: Count products in each category
-- What it does: GROUP BY puts rows with the same category_id into one
-- group. COUNT(*) then counts the rows inside each group. (Query 25
-- shows the same idea with category names.)
-- Expected output:
--   category_id | product_count
--   ------------+--------------
--   1           | 15
--   2           | 12
--   3           | 12
--   4           | 14
--   5           | 9
--   ... (10 rows in total, first 5 shown)
SELECT category_id, COUNT(*) AS product_count
FROM products
GROUP BY category_id
ORDER BY category_id;

-- QUERY 9: Calculate total stock received
-- What it does: SUM(quantity) adds all quantities. WHERE
-- transaction_type = 'IN' keeps only the stock received transactions.
-- Expected output:
--   total_stock_received
--   --------------------
--   18405
SELECT SUM(quantity) AS total_stock_received
FROM stock_transactions
WHERE transaction_type = 'IN';

-- QUERY 10: Calculate total stock issued
-- What it does: Same as Query 9, but we keep only the OUT transactions
-- (stock issued or sold).
-- Expected output:
--   total_stock_issued
--   ------------------
--   5333
SELECT SUM(quantity) AS total_stock_issued
FROM stock_transactions
WHERE transaction_type = 'OUT';

-- QUERY 11: Calculate current stock for each product
-- What it does: Formula: Stock Available = Total IN - Total OUT. The
-- CASE part says: if the row is IN, add the quantity; otherwise
-- subtract it. SUM then adds these numbers for every product.
-- (Products with no transactions at all are not listed here; they have
-- zero stock and appear in Query 21.)
-- Expected output:
--   product_id | current_stock
--   -----------+--------------
--   1          | 30
--   2          | 29
--   3          | 26
--   4          | 131
--   5          | 25
--   ... (92 rows in total, first 5 shown)
SELECT product_id,
       SUM(CASE WHEN transaction_type = 'IN' THEN quantity
                ELSE -quantity END) AS current_stock
FROM stock_transactions
GROUP BY product_id
ORDER BY product_id;

-- QUERY 11B: Current stock for each product in each warehouse
-- What it does: Same formula as Query 11, but grouped by product AND
-- warehouse. This shows how much of each product is kept in each
-- warehouse.
-- Expected output:
--   product_id | warehouse_id | current_stock
--   -----------+--------------+--------------
--   1          | 1            | 19
--   1          | 2            | 11
--   2          | 1            | 20
--   2          | 3            | 9
--   3          | 2            | 26
--   ... (106 rows in total, first 5 shown)
SELECT product_id, warehouse_id,
       SUM(CASE WHEN transaction_type = 'IN' THEN quantity
                ELSE -quantity END) AS current_stock
FROM stock_transactions
GROUP BY product_id, warehouse_id
ORDER BY product_id, warehouse_id;

-- QUERY 12: Calculate total inventory value
-- What it does: Inventory value = Current Stock x Cost Price. We use
-- the view vw_product_stock (created in Inventory_Management.sql)
-- which already holds current_stock for every product. SUM adds the
-- value of all products.
-- Expected output:
--   total_inventory_value
--   ---------------------
--   4704180.00
SELECT SUM(current_stock * cost_price) AS total_inventory_value
FROM vw_product_stock;

-- QUERY 13: Find average product price
-- What it does: AVG calculates the average. ROUND(..., 2) keeps two
-- decimal places.
-- Expected output:
--   average_product_price
--   ---------------------
--   1319.92
SELECT ROUND(AVG(unit_price), 2) AS average_product_price
FROM products;

-- ===================================================================
-- PART C: JOIN QUERIES
-- ===================================================================

-- QUERY 14: Display product names with category names
-- What it does: A JOIN connects two tables through a common column.
-- Here products.category_id matches categories.category_id. p and c
-- are short names (aliases) for the tables.
-- Expected output:
--   product_id | product_name                        | category_name
--   -----------+-------------------------------------+--------------
--   1          | LED TV 32 Inch HD Ready             | Electronics
--   2          | LED TV 43 Inch Full HD              | Electronics
--   3          | Bluetooth Speaker 10W               | Electronics
--   4          | Soundbar 2.1 Channel 60W            | Electronics
--   5          | Wireless Earbuds with Charging Case | Electronics
--   ... (100 rows in total, first 5 shown)
SELECT p.product_id, p.product_name, c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id
ORDER BY p.product_id;

-- QUERY 15: Display products with supplier names
-- What it does: Same idea as Query 14. products.supplier_id is matched
-- with suppliers.supplier_id to get the supplier name.
-- Expected output:
--   product_id | product_name                        | supplier_name
--   -----------+-------------------------------------+-------------------------------
--   1          | LED TV 32 Inch HD Ready             | Zenith Electronics Pvt Ltd
--   2          | LED TV 43 Inch Full HD              | Eastern Imports and Trading Co
--   3          | Bluetooth Speaker 10W               | Apex Digital Distributors
--   4          | Soundbar 2.1 Channel 60W            | Eastern Imports and Trading Co
--   5          | Wireless Earbuds with Charging Case | Apex Digital Distributors
--   ... (100 rows in total, first 5 shown)
SELECT p.product_id, p.product_name, s.supplier_name
FROM products p
JOIN suppliers s ON p.supplier_id = s.supplier_id
ORDER BY p.product_id;

-- QUERY 16: Display warehouse-wise stock transactions
-- What it does: Joins transactions with warehouses and groups them by
-- warehouse and type. It shows how many IN and OUT transactions each
-- warehouse handled and the total quantity moved.
-- Expected output:
--   warehouse_name                  | transaction_type | number_of_transactions | total_quantity
--   --------------------------------+------------------+------------------------+---------------
--   Greater Noida Central Warehouse | IN               | 58                     | 9110
--   Greater Noida Central Warehouse | OUT              | 43                     | 2763
--   Gurugram Distribution Hub       | IN               | 35                     | 5932
--   Gurugram Distribution Hub       | OUT              | 18                     | 1774
--   Lucknow Regional Warehouse      | IN               | 26                     | 3363
--   ... (6 rows in total, first 5 shown)
SELECT w.warehouse_name, t.transaction_type,
       COUNT(*) AS number_of_transactions,
       SUM(t.quantity) AS total_quantity
FROM stock_transactions t
JOIN warehouses w ON t.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name, t.transaction_type
ORDER BY w.warehouse_name, t.transaction_type;

-- QUERY 17: Display complete stock transaction details using JOINs
-- What it does: Joins all five tables to show one complete, readable
-- report: the transaction, the product, its category, its supplier and
-- the warehouse. quantity x unit_cost gives the transaction value.
-- Expected output:
--   transaction_id | transaction_date | product_name                      | category_name        | supplier_name               | warehouse_name                  | transaction_type | quantity | unit_cost | transaction_value
--   ---------------+------------------+-----------------------------------+----------------------+-----------------------------+---------------------------------+------------------+----------+-----------+------------------
--   1              | 2026-04-01       | Neckband Bluetooth Headset        | Electronics          | Apex Digital Distributors   | Gurugram Distribution Hub       | IN               | 27       | 550.24    | 14856.48
--   2              | 2026-04-01       | Power Bank 10000mAh               | Mobile Accessories   | Nova Mobile Accessories Co  | Gurugram Distribution Hub       | IN               | 77       | 651.95    | 50200.15
--   3              | 2026-04-01       | Wireless Keyboard and Mouse Combo | Computer Peripherals | Apex Digital Distributors   | Lucknow Regional Warehouse      | IN               | 54       | 673.83    | 36386.82
--   4              | 2026-04-01       | Steel Storage Cabinet 4 Shelf     | Furniture            | Royal Furnishings Pvt Ltd   | Greater Noida Central Warehouse | IN               | 3        | 6773.10   | 20319.30
--   5              | 2026-04-01       | Tomato Ketchup 1kg                | Packaged Food        | Harvest Foods India Pvt Ltd | Greater Noida Central Warehouse | IN               | 211      | 125.06    | 26387.66
--   ... (200 rows in total, first 5 shown)
SELECT t.transaction_id, t.transaction_date, p.product_name,
       c.category_name, s.supplier_name, w.warehouse_name,
       t.transaction_type, t.quantity, t.unit_cost,
       t.quantity * t.unit_cost AS transaction_value
FROM stock_transactions t
JOIN products   p ON t.product_id   = p.product_id
JOIN categories c ON p.category_id  = c.category_id
JOIN suppliers  s ON p.supplier_id  = s.supplier_id
JOIN warehouses w ON t.warehouse_id = w.warehouse_id
ORDER BY t.transaction_id;

-- ===================================================================
-- PART D: BUSINESS ANALYSIS QUERIES
-- ===================================================================

-- QUERY 18: Identify products below their reorder level
-- What it does: A product needs restocking when current stock is lower
-- than its reorder level. WHERE compares the two columns. shortage
-- shows how many units are missing. Products with zero stock are
-- included.
-- Expected output:
--   product_id | product_name                 | current_stock | reorder_level | shortage
--   -----------+------------------------------+---------------+---------------+---------
--   99         | Laundry Detergent Powder 2kg | 0             | 80            | 80
--   85         | Bath Soap Pack of 4          | 39            | 100           | 61
--   25         | Wired Earphones with Mic     | 44            | 100           | 56
--   84         | Toothpaste 150g Pack of 4    | 0             | 50            | 50
--   92         | Mixed Fruit Jam 500g         | 0             | 40            | 40
--   ... (27 rows in total, first 5 shown)
SELECT product_id, product_name, current_stock, reorder_level,
       reorder_level - current_stock AS shortage
FROM vw_product_stock
WHERE current_stock < reorder_level
ORDER BY shortage DESC;

-- QUERY 19: Find the most frequently issued products
-- What it does: Counts how many OUT transactions each product has. The
-- product with the highest count is in highest demand. LIMIT 10 shows
-- only the top 10 rows.
-- Expected output:
--   product_name               | times_issued | units_issued
--   ---------------------------+--------------+-------------
--   Shaving Cream 70g          | 4            | 1111
--   Mobile Back Cover Silicone | 4            | 768
--   Cornflakes 475g            | 4            | 399
--   USB Wired Keyboard         | 4            | 251
--   Rechargeable LED Torch     | 4            | 233
--   ... (10 rows in total, first 5 shown)
SELECT p.product_name,
       COUNT(*) AS times_issued,
       SUM(t.quantity) AS units_issued
FROM stock_transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_type = 'OUT'
GROUP BY p.product_name
ORDER BY times_issued DESC, units_issued DESC
LIMIT 10;

-- QUERY 20: Identify the warehouse with the highest stock
-- What it does: Calculates IN minus OUT for each warehouse and sorts
-- from highest to lowest. The first row is the warehouse holding the
-- most stock (in units).
-- Expected output:
--   warehouse_name                  | current_stock
--   --------------------------------+--------------
--   Greater Noida Central Warehouse | 6347
--   Gurugram Distribution Hub       | 4158
--   Lucknow Regional Warehouse      | 2567
SELECT w.warehouse_name,
       SUM(CASE WHEN t.transaction_type = 'IN' THEN t.quantity
                ELSE -t.quantity END) AS current_stock
FROM stock_transactions t
JOIN warehouses w ON t.warehouse_id = w.warehouse_id
GROUP BY w.warehouse_name
ORDER BY current_stock DESC;

-- QUERY 21: Find products with zero available stock
-- What it does: Uses the view and keeps only the products where
-- current_stock is exactly 0. These products cannot be sold until they
-- are restocked.
-- Expected output:
--   product_id | product_name              | reorder_level
--   -----------+---------------------------+--------------
--   20         | Power Bank 20000mAh       | 12
--   26         | Wireless Charging Pad 15W | 30
--   27         | Memory Card 64GB microSD  | 15
--   32         | USB 3.0 Pen Drive 32GB    | 30
--   35         | Webcam 1080p              | 10
--   ... (12 rows in total, first 5 shown)
SELECT product_id, product_name, reorder_level
FROM vw_product_stock
WHERE current_stock = 0
ORDER BY product_id;

-- QUERY 22: Calculate monthly stock movement
-- What it does: TO_CHAR turns a date into 'YYYY-MM' so that all
-- transactions of a month are grouped together. For each month we show
-- stock IN, stock OUT and the net movement (IN minus OUT).
-- Expected output:
--   year_month | stock_in | stock_out | net_movement
--   -----------+----------+-----------+-------------
--   2026-04    | 8753     | 14        | 8739
--   2026-05    | 5906     | 210       | 5696
--   2026-06    | 854      | 118       | 736
--   2026-07    | 325      | 1070      | -745
--   2026-08    | 904      | 586       | 318
--   ... (7 rows in total, first 5 shown)
SELECT TO_CHAR(transaction_date, 'YYYY-MM') AS year_month,
       SUM(CASE WHEN transaction_type = 'IN'  THEN quantity ELSE 0 END) AS stock_in,
       SUM(CASE WHEN transaction_type = 'OUT' THEN quantity ELSE 0 END) AS stock_out,
       SUM(CASE WHEN transaction_type = 'IN'  THEN quantity
                ELSE -quantity END) AS net_movement
FROM stock_transactions
GROUP BY TO_CHAR(transaction_date, 'YYYY-MM')
ORDER BY year_month;

-- QUERY 23: Find the top five products by inventory value
-- What it does: Inventory value = current stock x cost price. ORDER BY
-- ... DESC puts the highest value first and LIMIT 5 keeps the top
-- five. These products have the most money tied up.
-- Expected output:
--   product_name              | current_stock | cost_price | inventory_value
--   --------------------------+---------------+------------+----------------
--   Soundbar 2.1 Channel 60W  | 131           | 3900.00    | 510900.00
--   LED TV 43 Inch Full HD    | 29            | 15500.00   | 449500.00
--   LED TV 32 Inch HD Ready   | 30            | 8200.00    | 246000.00
--   Home Theatre 5.1 System   | 22            | 7800.00    | 171600.00
--   Laptop Backpack 15.6 Inch | 199           | 850.00     | 169150.00
SELECT product_name, current_stock, cost_price,
       current_stock * cost_price AS inventory_value
FROM vw_product_stock
ORDER BY inventory_value DESC
LIMIT 5;

-- ===================================================================
-- PART E: SIMPLE ADVANCED QUERIES
-- ===================================================================

-- QUERY 24: Find products whose inventory value is above average (subquery)
-- What it does: A subquery is a query inside brackets. The inner query
-- calculates the average inventory value of all products. The outer
-- query keeps only the products whose value is higher than that
-- average.
-- Expected output:
--   product_name              | current_stock | inventory_value
--   --------------------------+---------------+----------------
--   Soundbar 2.1 Channel 60W  | 131           | 510900.00
--   LED TV 43 Inch Full HD    | 29            | 449500.00
--   LED TV 32 Inch HD Ready   | 30            | 246000.00
--   Home Theatre 5.1 System   | 22            | 171600.00
--   Laptop Backpack 15.6 Inch | 199           | 169150.00
--   ... (33 rows in total, first 5 shown)
SELECT product_name, current_stock,
       current_stock * cost_price AS inventory_value
FROM vw_product_stock
WHERE current_stock * cost_price >
      (SELECT AVG(current_stock * cost_price) FROM vw_product_stock)
ORDER BY inventory_value DESC;

-- QUERY 25: Find categories having more than five products (GROUP BY and HAVING)
-- What it does: GROUP BY makes one group per category. WHERE cannot
-- filter groups, so we use HAVING to keep only groups with more than 5
-- products. Furniture (5 products) and Cleaning Supplies (4 products)
-- are left out.
-- Expected output:
--   category_name        | product_count
--   ---------------------+--------------
--   Electronics          | 15
--   Office Stationery    | 14
--   Computer Peripherals | 12
--   Mobile Accessories   | 12
--   Kitchenware          | 10
--   ... (8 rows in total, first 5 shown)
SELECT c.category_name, COUNT(*) AS product_count
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
HAVING COUNT(*) > 5
ORDER BY product_count DESC, c.category_name;

-- ===================================================================
-- PART F: EXTRA QUERIES FOR BUSINESS ANALYSIS AND VERIFICATION
-- ===================================================================

-- QUERY E1: Inventory value by category
-- What it does: Joins the stock view with categories and adds up the
-- inventory value of each category. Shows where the money is invested.
-- Expected output:
--   category_name        | units_in_stock | inventory_value
--   ---------------------+----------------+----------------
--   Electronics          | 936            | 1781050.00
--   Computer Peripherals | 812            | 497050.00
--   Kitchenware          | 1005           | 473640.00
--   Home Appliances      | 367            | 439890.00
--   Office Stationery    | 3545           | 432975.00
--   ... (10 rows in total, first 5 shown)
SELECT c.category_name,
       SUM(v.current_stock) AS units_in_stock,
       SUM(v.current_stock * v.cost_price) AS inventory_value
FROM vw_product_stock v
JOIN categories c ON v.category_id = c.category_id
GROUP BY c.category_name
ORDER BY inventory_value DESC;

-- QUERY E2: Supplier summary
-- What it does: For every supplier: number of products supplied, how
-- many of them are below reorder level, the inventory value and the
-- lead time. Useful for supplier performance review.
-- Expected output:
--   supplier_name                  | lead_time_days | products_supplied | below_reorder | inventory_value
--   -------------------------------+----------------+-------------------+---------------+----------------
--   Eastern Imports and Trading Co | 12             | 6                 | 0             | 1270030.00
--   Apex Digital Distributors      | 5              | 19                | 7             | 564190.00
--   Zenith Electronics Pvt Ltd     | 7              | 5                 | 0             | 430470.00
--   Metro Wholesale Supplies       | 3              | 9                 | 1             | 397490.00
--   Hearth and Home Appliances Ltd | 9              | 6                 | 0             | 314620.00
--   ... (15 rows in total, first 5 shown)
SELECT s.supplier_name, s.lead_time_days,
       COUNT(*) AS products_supplied,
       SUM(CASE WHEN v.current_stock < v.reorder_level THEN 1 ELSE 0 END) AS below_reorder,
       SUM(v.current_stock * v.cost_price) AS inventory_value
FROM vw_product_stock v
JOIN suppliers s ON v.supplier_id = s.supplier_id
GROUP BY s.supplier_name, s.lead_time_days
ORDER BY inventory_value DESC;

-- QUERY E3: Restocking list with supplier and lead time
-- What it does: Lists the products that must be ordered, with the
-- supplier to contact and the number of days the supplier needs to
-- deliver. Products with a long lead time should be ordered first.
-- Expected output:
--   product_name                  | current_stock | reorder_level | supplier_name               | lead_time_days
--   ------------------------------+---------------+---------------+-----------------------------+---------------
--   Bookshelf 5 Tier              | 4             | 5             | Royal Furnishings Pvt Ltd   | 14
--   Ergonomic Office Chair        | 0             | 12            | Royal Furnishings Pvt Ltd   | 14
--   Steel Storage Cabinet 4 Shelf | 3             | 8             | Royal Furnishings Pvt Ltd   | 14
--   Bath Soap Pack of 4           | 39            | 100           | Glow Personal Care Products | 10
--   Electric Hair Trimmer         | 0             | 25            | Glow Personal Care Products | 10
--   ... (27 rows in total, first 5 shown)
SELECT v.product_name, v.current_stock, v.reorder_level,
       s.supplier_name, s.lead_time_days
FROM vw_product_stock v
JOIN suppliers s ON v.supplier_id = s.supplier_id
WHERE v.current_stock < v.reorder_level
ORDER BY s.lead_time_days DESC, v.product_name;

-- QUERY V1: Check: no product has negative stock in any warehouse
-- What it does: Integrity check. HAVING keeps only the
-- product-warehouse pairs whose stock is below zero. The correct
-- result is: 0 rows (no stock was issued that was never received).
-- Expected output:
--   product_id | warehouse_id | current_stock
--   -----------+--------------+--------------
--   (0 rows)
SELECT product_id, warehouse_id,
       SUM(CASE WHEN transaction_type = 'IN' THEN quantity
                ELSE -quantity END) AS current_stock
FROM stock_transactions
GROUP BY product_id, warehouse_id
HAVING SUM(CASE WHEN transaction_type = 'IN' THEN quantity
                ELSE -quantity END) < 0;

-- QUERY V2: Check: total IN minus total OUT equals total current stock
-- What it does: Reconciliation check. Both columns must show the same
-- number, which proves that the per-product stock calculation is
-- correct.
-- Expected output:
--   total_in_minus_total_out | total_of_current_stock
--   -------------------------+-----------------------
--   13072                    | 13072
SELECT (SELECT SUM(quantity) FROM stock_transactions WHERE transaction_type = 'IN')
     - (SELECT SUM(quantity) FROM stock_transactions WHERE transaction_type = 'OUT')
       AS total_in_minus_total_out,
       (SELECT SUM(current_stock) FROM vw_product_stock) AS total_of_current_stock;

-- ===================================================================
-- PART G: UPDATE EXAMPLE
-- ===================================================================

-- QUERY G1: Update one record (supplier lead time)
-- UPDATE changes existing rows. Always use WHERE, otherwise ALL rows
-- are changed. Here the supplier with ID 3 now promises delivery in 3
-- days instead of 4. We check the row before and after the change.
SELECT supplier_id, supplier_name, lead_time_days
FROM suppliers
WHERE supplier_id = 3;
-- Expected output:
--   supplier_id | supplier_name              | lead_time_days
--   ------------+----------------------------+---------------
--   3           | Nova Mobile Accessories Co | 4
UPDATE suppliers
SET lead_time_days = 3
WHERE supplier_id = 3;
SELECT supplier_id, supplier_name, lead_time_days
FROM suppliers
WHERE supplier_id = 3;
-- Expected output:
--   supplier_id | supplier_name              | lead_time_days
--   ------------+----------------------------+---------------
--   3           | Nova Mobile Accessories Co | 3

-- ===================================================================
-- PART H: TRANSACTION MANAGEMENT (BEGIN, COMMIT, ROLLBACK)
-- ===================================================================
-- A transaction groups SQL statements into one unit of work. BEGIN
-- starts it. COMMIT saves the changes permanently. ROLLBACK cancels
-- all changes made since BEGIN. Select and run each block (from BEGIN
-- to COMMIT/ROLLBACK) in ONE go. pgAdmin 4 Query Tool is in
-- auto-commit mode by default, so an explicit BEGIN is needed.

-- DEMO H1: ROLLBACK - undo a mistake
-- Someone wrongly multiplies the price of all Electronics products by
-- 10. Inside the transaction we can see the wrong prices. ROLLBACK
-- cancels the mistake and the original prices come back.
BEGIN;
UPDATE products
SET unit_price = unit_price * 10
WHERE category_id = 1;
SELECT product_id, product_name, unit_price
FROM products
WHERE category_id = 1
ORDER BY product_id
LIMIT 3;
-- Expected output:
--   product_id | product_name            | unit_price
--   -----------+-------------------------+-----------
--   1          | LED TV 32 Inch HD Ready | 96750.00
--   2          | LED TV 43 Inch Full HD  | 182900.00
--   3          | Bluetooth Speaker 10W   | 9200.00
ROLLBACK;
SELECT product_id, product_name, unit_price
FROM products
WHERE category_id = 1
ORDER BY product_id
LIMIT 3;
-- Expected output:
--   product_id | product_name            | unit_price
--   -----------+-------------------------+-----------
--   1          | LED TV 32 Inch HD Ready | 9675.00
--   2          | LED TV 43 Inch Full HD  | 18290.00
--   3          | Bluetooth Speaker 10W   | 920.00

-- DEMO H2: COMMIT - save a stock receipt permanently
-- We receive 100 units of 'Bath Soap Pack of 4' (product 85), which
-- was below its reorder level of 100. The new IN transaction is saved
-- with COMMIT. Current stock changes from 39 to 139, so the product
-- leaves the low-stock list.
SELECT product_name, current_stock, reorder_level
FROM vw_product_stock
WHERE product_id = 85;
-- Expected output:
--   product_name        | current_stock | reorder_level
--   --------------------+---------------+--------------
--   Bath Soap Pack of 4 | 39            | 100
BEGIN;
INSERT INTO stock_transactions
       (transaction_id, product_id, warehouse_id, transaction_date,
        transaction_type, quantity, unit_cost)
VALUES (201, 85, 1, '2026-11-02', 'IN', 100, 120.00);
COMMIT;
SELECT product_name, current_stock, reorder_level
FROM vw_product_stock
WHERE product_id = 85;
-- Expected output:
--   product_name        | current_stock | reorder_level
--   --------------------+---------------+--------------
--   Bath Soap Pack of 4 | 139           | 100

-- DEMO H3: RESTORE the original data (so that all outputs above stay valid)
-- This removes the demo transaction 201 and puts the supplier lead
-- time back to 4 days. Run it after the demos so that the database is
-- exactly as created by Inventory_Management.sql.
DELETE FROM stock_transactions
WHERE transaction_id = 201;
UPDATE suppliers
SET lead_time_days = 4
WHERE supplier_id = 3;
SELECT COUNT(*) AS total_transactions
FROM stock_transactions;
-- Expected output:
--   total_transactions
--   ------------------
--   200

-- ======================== END OF FILE ================================
