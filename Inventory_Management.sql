-- =====================================================================
-- INVENTORY AND STOCK MANAGEMENT SYSTEM USING PostgreSQL
-- File    : Inventory_Management.sql
-- Course  : SQL and Data Management (PMDE30605), MBA
-- College : IILM University, Greater Noida
-- Team    : Ishan Mishra, Parvathi, Sreekanth
-- Tested  : PostgreSQL 16 (works in pgAdmin 4 Query Tool)
-- =====================================================================
-- HOW TO RUN (3 simple steps)
--   Step 1: In pgAdmin 4, right-click "Databases" > Create > Database.
--           Name it:  inventory_db   and click Save.
--           (Or run this one line on its own while connected to
--            the default "postgres" database:  CREATE DATABASE inventory_db;)
--   Step 2: Click on inventory_db > Tools > Query Tool.
--   Step 3: Open THIS file (folder icon) and press F5 (Execute).
-- The script can be run again and again. It first removes old tables
-- and then rebuilds everything, so you always get a fresh database.
-- =====================================================================

-- ---------------------------------------------------------------------
-- SECTION 1: REMOVE OLD TABLES (so the script can be re-run safely)
-- ---------------------------------------------------------------------
DROP VIEW  IF EXISTS vw_product_stock;
DROP TABLE IF EXISTS stock_transactions;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS warehouses;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS categories;

-- ---------------------------------------------------------------------
-- SECTION 2: CREATE TABLES (parent tables first, child tables later)
-- ---------------------------------------------------------------------

-- Table 1: Categories (10 rows) - groups of products
CREATE TABLE categories (
    category_id    INTEGER       NOT NULL,
    category_name  VARCHAR(50)   NOT NULL,
    description    VARCHAR(150),
    CONSTRAINT pk_categories      PRIMARY KEY (category_id),
    CONSTRAINT uq_category_name   UNIQUE (category_name)
);

-- Table 2: Suppliers (15 rows) - companies that supply the products
CREATE TABLE suppliers (
    supplier_id     INTEGER       NOT NULL,
    supplier_name   VARCHAR(80)   NOT NULL,
    contact_person  VARCHAR(60),
    phone           VARCHAR(15),
    email           VARCHAR(80),
    city            VARCHAR(40),
    lead_time_days  INTEGER       NOT NULL,   -- days taken to deliver an order
    CONSTRAINT pk_suppliers       PRIMARY KEY (supplier_id),
    CONSTRAINT uq_supplier_name   UNIQUE (supplier_name),
    CONSTRAINT ck_lead_time       CHECK (lead_time_days > 0)
);

-- Table 3: Warehouses (3 rows) - places where stock is kept
CREATE TABLE warehouses (
    warehouse_id    INTEGER       NOT NULL,
    warehouse_name  VARCHAR(60)   NOT NULL,
    city            VARCHAR(40)   NOT NULL,
    state           VARCHAR(40),
    capacity_units  INTEGER,
    manager_name    VARCHAR(60),
    CONSTRAINT pk_warehouses      PRIMARY KEY (warehouse_id),
    CONSTRAINT uq_warehouse_name  UNIQUE (warehouse_name),
    CONSTRAINT ck_capacity        CHECK (capacity_units > 0)
);

-- Table 4: Products (100 rows) - each product belongs to ONE category
--          and is supplied by ONE supplier
CREATE TABLE products (
    product_id     INTEGER        NOT NULL,
    product_name   VARCHAR(80)    NOT NULL,
    category_id    INTEGER        NOT NULL,
    supplier_id    INTEGER        NOT NULL,
    cost_price     NUMERIC(10,2)  NOT NULL,   -- price we pay to the supplier
    unit_price     NUMERIC(10,2)  NOT NULL,   -- price we sell at
    reorder_level  INTEGER        NOT NULL,   -- order again when stock falls below this
    CONSTRAINT pk_products        PRIMARY KEY (product_id),
    CONSTRAINT uq_product_name    UNIQUE (product_name),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories (category_id),
    CONSTRAINT fk_products_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id),
    CONSTRAINT ck_cost_price      CHECK (cost_price > 0),
    CONSTRAINT ck_unit_price      CHECK (unit_price >= cost_price),
    CONSTRAINT ck_reorder_level   CHECK (reorder_level >= 0)
);

-- Table 5: Stock_Transactions (200 rows) - every stock IN and stock OUT
CREATE TABLE stock_transactions (
    transaction_id    INTEGER        NOT NULL,
    product_id        INTEGER        NOT NULL,
    warehouse_id      INTEGER        NOT NULL,
    transaction_date  DATE           NOT NULL,
    transaction_type  VARCHAR(3)     NOT NULL,   -- 'IN' = received, 'OUT' = issued
    quantity          INTEGER        NOT NULL,
    unit_cost         NUMERIC(10,2)  NOT NULL,
    CONSTRAINT pk_stock_transactions PRIMARY KEY (transaction_id),
    CONSTRAINT fk_trans_product
        FOREIGN KEY (product_id)   REFERENCES products (product_id),
    CONSTRAINT fk_trans_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses (warehouse_id),
    CONSTRAINT ck_trans_type      CHECK (transaction_type IN ('IN', 'OUT')),
    CONSTRAINT ck_trans_quantity  CHECK (quantity > 0),
    CONSTRAINT ck_trans_unit_cost CHECK (unit_cost > 0)
);

-- ---------------------------------------------------------------------
-- SECTION 3: INSERT DATA (all records are inserted automatically)
-- ---------------------------------------------------------------------

-- 3.1 Categories (10 rows)
INSERT INTO categories (category_id, category_name, description) VALUES
  (1, 'Electronics', 'TVs, audio devices and smart home electronics'),
  (2, 'Mobile Accessories', 'Chargers, cables, power banks and phone add-ons'),
  (3, 'Computer Peripherals', 'Keyboards, mice, storage and networking items'),
  (4, 'Office Stationery', 'Paper, pens, files and general office supplies'),
  (5, 'Home Appliances', 'Small electrical appliances for home use'),
  (6, 'Kitchenware', 'Cookware, storage and dining products'),
  (7, 'Furniture', 'Office and home furniture'),
  (8, 'Personal Care', 'Grooming and personal hygiene products'),
  (9, 'Packaged Food', 'Packaged grocery and food items'),
  (10, 'Cleaning Supplies', 'Household cleaning products');

-- 3.2 Suppliers (15 rows)
INSERT INTO suppliers (supplier_id, supplier_name, contact_person, phone, email, city, lead_time_days) VALUES
  (1, 'Zenith Electronics Pvt Ltd', 'Anil Kapoor', '9100010001', 'sales@zenithelectronics.example', 'Noida', 7),
  (2, 'Apex Digital Distributors', 'Neha Malhotra', '9100010002', 'orders@apexdigital.example', 'Delhi', 5),
  (3, 'Nova Mobile Accessories Co', 'Rohit Saxena', '9100010003', 'info@novamobile.example', 'Ghaziabad', 4),
  (4, 'Pioneer Computer Peripherals', 'Sunil Arora', '9100010004', 'sales@pioneerperipherals.example', 'Gurugram', 6),
  (5, 'Sharma Stationery Traders', 'Meena Sharma', '9100010005', 'contact@sharmastationery.example', 'Delhi', 3),
  (6, 'Bright Office Solutions', 'Vikas Gupta', '9100010006', 'support@brightoffice.example', 'Faridabad', 5),
  (7, 'Hearth and Home Appliances Ltd', 'Pooja Bansal', '9100010007', 'sales@hearthhome.example', 'Jaipur', 9),
  (8, 'Kitchen Craft Industries', 'Deepak Jain', '9100010008', 'orders@kitchencraft.example', 'Moradabad', 8),
  (9, 'Royal Furnishings Pvt Ltd', 'Imran Qureshi', '9100010009', 'info@royalfurnishings.example', 'Saharanpur', 14),
  (10, 'Glow Personal Care Products', 'Shalini Mehta', '9100010010', 'sales@glowcare.example', 'Mumbai', 10),
  (11, 'PureLife FMCG Distributors', 'Arvind Tiwari', '9100010011', 'orders@purelifefmcg.example', 'Lucknow', 4),
  (12, 'Harvest Foods India Pvt Ltd', 'Kamal Singh', '9100010012', 'sales@harvestfoods.example', 'Karnal', 6),
  (13, 'Sparkle Cleaning Products', 'Rekha Verma', '9100010013', 'info@sparklecleaning.example', 'Kanpur', 5),
  (14, 'Metro Wholesale Supplies', 'Harish Choudhary', '9100010014', 'orders@metrowholesale.example', 'Delhi', 3),
  (15, 'Eastern Imports and Trading Co', 'Sourav Das', '9100010015', 'trade@easternimports.example', 'Kolkata', 12);

-- 3.3 Warehouses (3 rows)
INSERT INTO warehouses (warehouse_id, warehouse_name, city, state, capacity_units, manager_name) VALUES
  (1, 'Greater Noida Central Warehouse', 'Greater Noida', 'Uttar Pradesh', 50000, 'Rakesh Verma'),
  (2, 'Gurugram Distribution Hub', 'Gurugram', 'Haryana', 30000, 'Sandeep Yadav'),
  (3, 'Lucknow Regional Warehouse', 'Lucknow', 'Uttar Pradesh', 20000, 'Farhan Siddiqui');

-- 3.4 Products (100 rows)
INSERT INTO products (product_id, product_name, category_id, supplier_id, cost_price, unit_price, reorder_level) VALUES
  (1, 'LED TV 32 Inch HD Ready', 1, 1, 8200.0, 9675.0, 5),
  (2, 'LED TV 43 Inch Full HD', 1, 15, 15500.0, 18290.0, 12),
  (3, 'Bluetooth Speaker 10W', 1, 2, 780.0, 920.0, 40),
  (4, 'Soundbar 2.1 Channel 60W', 1, 15, 3900.0, 4600.0, 12),
  (5, 'Wireless Earbuds with Charging Case', 1, 2, 950.0, 1120.0, 40),
  (6, 'Smart Fitness Band', 1, 1, 1100.0, 1300.0, 5),
  (7, 'Set Top Box HD', 1, 2, 850.0, 1005.0, 15),
  (8, 'Smart Wi-Fi LED Bulb 9W', 1, 1, 320.0, 380.0, 15),
  (9, 'Indoor Security Camera 2MP', 1, 1, 1250.0, 1475.0, 12),
  (10, 'Rechargeable LED Torch', 1, 2, 240.0, 285.0, 50),
  (11, 'Digital Alarm Clock', 1, 1, 280.0, 330.0, 60),
  (12, 'Portable FM Radio', 1, 15, 420.0, 495.0, 25),
  (13, 'Home Theatre 5.1 System', 1, 15, 7800.0, 9205.0, 5),
  (14, 'Neckband Bluetooth Headset', 1, 2, 520.0, 615.0, 15),
  (15, 'Smart Plug Wi-Fi 16A', 1, 2, 480.0, 565.0, 25),
  (16, 'USB-C Fast Charger 20W', 2, 3, 380.0, 530.0, 20),
  (17, 'Micro USB Data Cable 1m', 2, 2, 70.0, 98.0, 250),
  (18, 'USB-C to Lightning Cable 1m', 2, 3, 190.0, 265.0, 60),
  (19, 'Power Bank 10000mAh', 2, 3, 650.0, 910.0, 30),
  (20, 'Power Bank 20000mAh', 2, 3, 1050.0, 1470.0, 12),
  (21, 'Tempered Glass Screen Guard', 2, 2, 60.0, 84.0, 200),
  (22, 'Mobile Back Cover Silicone', 2, 3, 85.0, 119.0, 250),
  (23, 'Car Mobile Holder', 2, 2, 210.0, 295.0, 80),
  (24, 'Selfie Stick with Tripod', 2, 2, 260.0, 365.0, 60),
  (25, 'Wired Earphones with Mic', 2, 2, 140.0, 195.0, 100),
  (26, 'Wireless Charging Pad 15W', 2, 2, 720.0, 1010.0, 30),
  (27, 'Memory Card 64GB microSD', 2, 3, 480.0, 670.0, 15),
  (28, 'Wireless Optical Mouse', 3, 4, 260.0, 325.0, 50),
  (29, 'USB Wired Keyboard', 3, 2, 310.0, 390.0, 40),
  (30, 'Wireless Keyboard and Mouse Combo', 3, 2, 640.0, 800.0, 15),
  (31, 'Laptop Cooling Pad', 3, 2, 520.0, 650.0, 30),
  (32, 'USB 3.0 Pen Drive 32GB', 3, 4, 330.0, 410.0, 30),
  (33, 'USB 3.0 Pen Drive 64GB', 3, 2, 520.0, 650.0, 15),
  (34, 'External Hard Disk 1TB', 3, 2, 3600.0, 4500.0, 12),
  (35, 'Webcam 1080p', 3, 2, 1450.0, 1810.0, 10),
  (36, 'USB Hub 4-Port', 3, 4, 380.0, 475.0, 25),
  (37, 'Laptop Backpack 15.6 Inch', 3, 4, 850.0, 1060.0, 40),
  (38, 'HDMI Cable 1.5m', 3, 2, 120.0, 150.0, 80),
  (39, 'Wi-Fi Router Dual Band', 3, 4, 1350.0, 1690.0, 10),
  (40, 'A4 Copier Paper 500 Sheets', 4, 6, 210.0, 275.0, 40),
  (41, 'Ball Pen Blue Box of 50', 4, 5, 190.0, 245.0, 100),
  (42, 'Gel Pen Black Pack of 10', 4, 6, 120.0, 155.0, 100),
  (43, 'Spiral Notebook A4 200 Pages', 4, 6, 70.0, 91.0, 150),
  (44, 'Sticky Notes 3x3 Inch', 4, 6, 45.0, 58.0, 150),
  (45, 'Stapler Medium with Pins', 4, 6, 85.0, 110.0, 200),
  (46, 'Paper Punch Two Hole', 4, 5, 140.0, 180.0, 80),
  (47, 'Highlighter Markers Pack of 5', 4, 6, 150.0, 195.0, 100),
  (48, 'Whiteboard Marker Box of 10', 4, 6, 260.0, 340.0, 40),
  (49, 'File Folder Box Type', 4, 6, 90.0, 117.0, 150),
  (50, 'Desk Organiser Mesh', 4, 5, 260.0, 340.0, 40),
  (51, 'Calculator 12 Digit', 4, 5, 310.0, 405.0, 40),
  (52, 'Printer Ink Cartridge Black', 4, 5, 1100.0, 1430.0, 8),
  (53, 'Whiteboard 2x3 Feet', 4, 6, 1500.0, 1950.0, 12),
  (54, 'Electric Kettle 1.5 Litre', 5, 14, 620.0, 755.0, 25),
  (55, 'Mixer Grinder 500W', 5, 14, 1650.0, 2015.0, 10),
  (56, 'Induction Cooktop 2000W', 5, 7, 1750.0, 2135.0, 12),
  (57, 'Fan Heater 2000W', 5, 7, 1500.0, 1830.0, 5),
  (58, 'Table Fan 400mm', 5, 7, 1500.0, 1830.0, 12),
  (59, 'Steam Iron 1100W', 5, 7, 780.0, 950.0, 15),
  (60, 'Pedestal Fan 400mm', 5, 7, 2300.0, 2805.0, 8),
  (61, 'Handheld Vacuum Cleaner', 5, 7, 1900.0, 2320.0, 5),
  (62, 'Sandwich Maker 750W', 5, 14, 850.0, 1035.0, 25),
  (63, 'Non-Stick Frying Pan 24cm', 6, 14, 560.0, 730.0, 25),
  (64, 'Pressure Cooker 5 Litre', 6, 8, 1250.0, 1625.0, 10),
  (65, 'Stainless Steel Lunch Box 3 Container', 6, 14, 520.0, 675.0, 40),
  (66, 'Insulated Water Bottle 1 Litre', 6, 14, 380.0, 495.0, 30),
  (67, 'Glass Food Storage Set 5 Pieces', 6, 14, 640.0, 830.0, 20),
  (68, 'Stainless Steel Cutlery Set 24 Pieces', 6, 14, 780.0, 1015.0, 30),
  (69, 'Kitchen Knife Set 3 Pieces', 6, 14, 260.0, 340.0, 100),
  (70, 'Dinner Set 18 Pieces', 6, 15, 1100.0, 1430.0, 10),
  (71, 'Plastic Storage Container Set', 6, 8, 420.0, 545.0, 20),
  (72, 'Wooden Chopping Board', 6, 15, 210.0, 275.0, 100),
  (73, 'Ergonomic Office Chair', 7, 9, 4200.0, 5250.0, 12),
  (74, 'Study Table with Drawer', 7, 9, 5400.0, 6750.0, 8),
  (75, 'Steel Storage Cabinet 4 Shelf', 7, 9, 6800.0, 8500.0, 8),
  (76, 'Folding Chair Steel', 7, 9, 1150.0, 1440.0, 5),
  (77, 'Bookshelf 5 Tier', 7, 9, 3300.0, 4125.0, 5),
  (78, 'Electric Hair Trimmer', 8, 10, 620.0, 805.0, 25),
  (79, 'Hair Dryer 1200W', 8, 11, 780.0, 1015.0, 15),
  (80, 'Shaving Cream 70g', 8, 10, 70.0, 91.0, 200),
  (81, 'Herbal Shampoo 340ml', 8, 10, 190.0, 245.0, 60),
  (82, 'Body Lotion 400ml', 8, 10, 220.0, 285.0, 40),
  (83, 'Face Wash 100ml', 8, 10, 95.0, 124.0, 200),
  (84, 'Toothpaste 150g Pack of 4', 8, 10, 230.0, 300.0, 50),
  (85, 'Bath Soap Pack of 4', 8, 10, 120.0, 155.0, 100),
  (86, 'Hand Sanitiser 500ml', 8, 10, 250.0, 325.0, 100),
  (87, 'Basmati Rice 5kg', 9, 12, 520.0, 580.0, 40),
  (88, 'Whole Wheat Flour 10kg', 9, 12, 380.0, 425.0, 15),
  (89, 'Refined Sunflower Oil 1 Litre', 9, 12, 130.0, 145.0, 40),
  (90, 'Tea Leaves 500g', 9, 12, 240.0, 270.0, 50),
  (91, 'Instant Coffee 100g', 9, 12, 220.0, 245.0, 100),
  (92, 'Mixed Fruit Jam 500g', 9, 11, 130.0, 145.0, 40),
  (93, 'Roasted Almonds 250g', 9, 12, 360.0, 405.0, 20),
  (94, 'Rolled Oats 1kg', 9, 12, 145.0, 160.0, 40),
  (95, 'Cornflakes 475g', 9, 12, 150.0, 170.0, 100),
  (96, 'Tomato Ketchup 1kg', 9, 12, 120.0, 135.0, 100),
  (97, 'Floor Cleaner Liquid 1 Litre', 10, 11, 140.0, 175.0, 50),
  (98, 'Dishwash Gel 750ml', 10, 13, 130.0, 160.0, 50),
  (99, 'Laundry Detergent Powder 2kg', 10, 13, 240.0, 300.0, 80),
  (100, 'Cotton Mop with Bucket', 10, 13, 450.0, 560.0, 15);

-- 3.5 Stock transactions (200 rows)
INSERT INTO stock_transactions (transaction_id, product_id, warehouse_id, transaction_date, transaction_type, quantity, unit_cost) VALUES
  (1, 14, 2, '2026-04-01', 'IN', 27, 550.24),
  (2, 19, 2, '2026-04-01', 'IN', 77, 651.95),
  (3, 30, 3, '2026-04-01', 'IN', 54, 673.83),
  (4, 75, 1, '2026-04-01', 'IN', 3, 6773.1),
  (5, 96, 1, '2026-04-01', 'IN', 211, 125.06),
  (6, 61, 1, '2026-04-02', 'IN', 12, 1842.19),
  (7, 64, 2, '2026-04-02', 'IN', 45, 1253.95),
  (8, 5, 2, '2026-04-03', 'IN', 25, 917.28),
  (9, 50, 2, '2026-04-03', 'IN', 72, 265.67),
  (10, 13, 3, '2026-04-05', 'IN', 8, 8189.07),
  (11, 90, 2, '2026-04-05', 'IN', 17, 252.93),
  (12, 1, 1, '2026-04-06', 'IN', 15, 8164.75),
  (13, 42, 1, '2026-04-06', 'IN', 265, 118.08),
  (14, 53, 3, '2026-04-06', 'IN', 22, 1502.52),
  (15, 71, 1, '2026-04-06', 'IN', 88, 420.84),
  (16, 12, 1, '2026-04-07', 'IN', 53, 403.73),
  (17, 77, 2, '2026-04-07', 'IN', 4, 3330.63),
  (18, 81, 1, '2026-04-07', 'IN', 116, 188.78),
  (19, 87, 3, '2026-04-07', 'IN', 77, 518.91),
  (20, 95, 2, '2026-04-07', 'IN', 258, 156.88),
  (21, 6, 3, '2026-04-08', 'IN', 19, 1110.2),
  (22, 74, 1, '2026-04-08', 'IN', 18, 5343.23),
  (23, 69, 1, '2026-04-09', 'IN', 281, 263.8),
  (24, 85, 1, '2026-04-09', 'IN', 39, 127.42),
  (25, 45, 1, '2026-04-10', 'IN', 846, 89.55),
  (26, 55, 3, '2026-04-10', 'IN', 23, 1721.29),
  (27, 71, 1, '2026-04-10', 'OUT', 14, 420.0),
  (28, 97, 2, '2026-04-10', 'IN', 214, 143.43),
  (29, 7, 2, '2026-04-11', 'IN', 40, 838.32),
  (30, 10, 1, '2026-04-11', 'IN', 122, 241.09),
  (31, 49, 2, '2026-04-11', 'IN', 241, 88.0),
  (32, 63, 1, '2026-04-12', 'IN', 70, 602.31),
  (33, 66, 1, '2026-04-12', 'IN', 118, 388.0),
  (34, 79, 1, '2026-04-12', 'IN', 55, 760.81),
  (35, 31, 3, '2026-04-13', 'IN', 16, 530.97),
  (36, 88, 1, '2026-04-13', 'IN', 64, 379.85),
  (37, 15, 3, '2026-04-14', 'IN', 84, 479.59),
  (38, 34, 1, '2026-04-14', 'IN', 57, 3670.93),
  (39, 70, 1, '2026-04-14', 'IN', 28, 1187.64),
  (40, 21, 2, '2026-04-16', 'IN', 659, 61.38),
  (41, 35, 3, '2026-04-16', 'IN', 42, 1433.47),
  (42, 58, 2, '2026-04-16', 'IN', 24, 1611.13),
  (43, 59, 1, '2026-04-16', 'IN', 22, 831.3),
  (44, 89, 1, '2026-04-17', 'IN', 187, 127.19),
  (45, 23, 3, '2026-04-18', 'IN', 235, 212.55),
  (46, 56, 1, '2026-04-18', 'IN', 48, 1815.86),
  (47, 8, 3, '2026-04-20', 'IN', 73, 305.2),
  (48, 9, 3, '2026-04-20', 'IN', 41, 1271.48),
  (49, 36, 1, '2026-04-20', 'IN', 109, 386.87),
  (50, 1, 1, '2026-04-24', 'IN', 8, 7983.38),
  (51, 29, 1, '2026-04-24', 'IN', 135, 329.58),
  (52, 17, 2, '2026-04-25', 'IN', 760, 72.17),
  (53, 54, 1, '2026-04-25', 'IN', 76, 656.22),
  (54, 98, 1, '2026-04-25', 'IN', 205, 138.23),
  (55, 41, 3, '2026-04-26', 'IN', 431, 190.77),
  (56, 93, 1, '2026-04-26', 'IN', 78, 357.23),
  (57, 37, 2, '2026-04-27', 'IN', 199, 904.12),
  (58, 68, 1, '2026-04-27', 'IN', 142, 814.8),
  (59, 83, 1, '2026-04-27', 'IN', 688, 93.36),
  (60, 47, 2, '2026-04-29', 'IN', 404, 158.7),
  (61, 91, 2, '2026-04-29', 'IN', 293, 217.48),
  (62, 40, 1, '2026-04-30', 'IN', 110, 225.9),
  (63, 33, 3, '2026-05-01', 'IN', 42, 496.3),
  (64, 51, 2, '2026-05-02', 'IN', 91, 310.34),
  (65, 1, 2, '2026-05-04', 'IN', 11, 8371.0),
  (66, 24, 1, '2026-05-04', 'IN', 123, 274.09),
  (67, 100, 3, '2026-05-04', 'IN', 6, 432.21),
  (68, 71, 1, '2026-05-05', 'OUT', 12, 420.0),
  (69, 60, 2, '2026-05-06', 'IN', 34, 2241.86),
  (70, 38, 3, '2026-05-07', 'IN', 47, 116.39),
  (71, 56, 1, '2026-05-07', 'OUT', 18, 1750.0),
  (72, 67, 1, '2026-05-07', 'IN', 54, 669.19),
  (73, 25, 3, '2026-05-08', 'IN', 44, 146.45),
  (74, 43, 1, '2026-05-09', 'IN', 495, 74.52),
  (75, 2, 3, '2026-05-10', 'IN', 21, 16095.99),
  (76, 62, 2, '2026-05-10', 'IN', 96, 915.31),
  (77, 94, 1, '2026-05-10', 'IN', 75, 145.64),
  (78, 3, 2, '2026-05-11', 'IN', 26, 774.08),
  (79, 44, 3, '2026-05-11', 'IN', 727, 48.03),
  (80, 11, 1, '2026-05-12', 'IN', 132, 276.44),
  (81, 86, 2, '2026-05-12', 'IN', 318, 246.97),
  (82, 18, 1, '2026-05-14', 'IN', 201, 204.52),
  (83, 52, 1, '2026-05-14', 'IN', 4, 1158.89),
  (84, 80, 1, '2026-05-14', 'IN', 921, 71.19),
  (85, 48, 2, '2026-05-16', 'IN', 14, 253.88),
  (86, 72, 3, '2026-05-16', 'IN', 342, 200.47),
  (87, 84, 1, '2026-05-16', 'IN', 240, 220.22),
  (88, 8, 3, '2026-05-17', 'OUT', 21, 320.0),
  (89, 76, 3, '2026-05-19', 'IN', 16, 1228.87),
  (90, 28, 3, '2026-05-20', 'IN', 212, 270.49),
  (91, 22, 2, '2026-05-22', 'IN', 931, 88.05),
  (92, 29, 1, '2026-05-22', 'OUT', 60, 310.0),
  (93, 35, 3, '2026-05-22', 'OUT', 42, 1450.0),
  (94, 4, 2, '2026-05-24', 'IN', 40, 3711.84),
  (95, 82, 1, '2026-05-26', 'IN', 128, 226.04),
  (96, 10, 1, '2026-05-27', 'OUT', 49, 240.0),
  (97, 46, 2, '2026-05-27', 'IN', 352, 150.22),
  (98, 57, 3, '2026-05-29', 'IN', 9, 1490.61),
  (99, 56, 1, '2026-05-30', 'OUT', 8, 1750.0),
  (100, 7, 2, '2026-05-31', 'IN', 31, 817.71),
  (101, 16, 1, '2026-05-31', 'IN', 91, 373.19),
  (102, 70, 1, '2026-05-31', 'IN', 32, 1098.48),
  (103, 71, 1, '2026-06-04', 'OUT', 30, 420.0),
  (104, 96, 3, '2026-06-05', 'IN', 486, 122.42),
  (105, 6, 3, '2026-06-07', 'OUT', 3, 1100.0),
  (106, 6, 3, '2026-06-17', 'OUT', 6, 1100.0),
  (107, 88, 1, '2026-06-20', 'OUT', 26, 380.0),
  (108, 63, 1, '2026-06-22', 'OUT', 20, 560.0),
  (109, 10, 3, '2026-06-24', 'IN', 247, 256.41),
  (110, 56, 1, '2026-06-24', 'OUT', 3, 1750.0),
  (111, 8, 3, '2026-06-26', 'OUT', 17, 320.0),
  (112, 20, 2, '2026-06-27', 'IN', 54, 1130.49),
  (113, 9, 1, '2026-06-28', 'IN', 52, 1328.97),
  (114, 39, 1, '2026-06-28', 'IN', 15, 1340.51),
  (115, 87, 3, '2026-06-30', 'OUT', 13, 520.0),
  (116, 80, 1, '2026-07-01', 'OUT', 409, 70.0),
  (117, 8, 3, '2026-07-02', 'OUT', 14, 320.0),
  (118, 6, 3, '2026-07-07', 'OUT', 4, 1100.0),
  (119, 84, 1, '2026-07-10', 'OUT', 240, 230.0),
  (120, 97, 2, '2026-07-10', 'OUT', 53, 140.0),
  (121, 88, 1, '2026-07-13', 'OUT', 7, 380.0),
  (122, 2, 3, '2026-07-15', 'OUT', 9, 15500.0),
  (123, 12, 1, '2026-07-15', 'IN', 76, 450.9),
  (124, 34, 1, '2026-07-16', 'OUT', 22, 3600.0),
  (125, 59, 2, '2026-07-16', 'IN', 57, 787.74),
  (126, 29, 1, '2026-07-18', 'OUT', 27, 310.0),
  (127, 29, 1, '2026-07-20', 'IN', 192, 318.95),
  (128, 20, 2, '2026-07-23', 'OUT', 54, 1050.0),
  (129, 67, 1, '2026-07-25', 'OUT', 8, 640.0),
  (130, 79, 1, '2026-07-25', 'OUT', 16, 780.0),
  (131, 41, 3, '2026-07-27', 'OUT', 94, 190.0),
  (132, 68, 1, '2026-07-27', 'OUT', 39, 780.0),
  (133, 10, 3, '2026-07-28', 'OUT', 66, 240.0),
  (134, 33, 3, '2026-07-31', 'OUT', 8, 520.0),
  (135, 2, 1, '2026-08-04', 'IN', 39, 15673.74),
  (136, 71, 2, '2026-08-04', 'IN', 89, 452.21),
  (137, 88, 1, '2026-08-05', 'OUT', 13, 380.0),
  (138, 95, 2, '2026-08-09', 'IN', 216, 160.03),
  (139, 82, 1, '2026-08-10', 'OUT', 53, 220.0),
  (140, 16, 1, '2026-08-11', 'OUT', 35, 380.0),
  (141, 95, 2, '2026-08-11', 'OUT', 118, 150.0),
  (142, 97, 2, '2026-08-15', 'OUT', 70, 140.0),
  (143, 15, 3, '2026-08-16', 'OUT', 38, 480.0),
  (144, 80, 1, '2026-08-16', 'IN', 511, 71.34),
  (145, 51, 2, '2026-08-17', 'OUT', 14, 310.0),
  (146, 97, 2, '2026-08-17', 'OUT', 44, 140.0),
  (147, 8, 3, '2026-08-22', 'OUT', 7, 320.0),
  (148, 56, 1, '2026-08-22', 'OUT', 4, 1750.0),
  (149, 39, 1, '2026-08-23', 'OUT', 15, 1350.0),
  (150, 22, 2, '2026-08-27', 'OUT', 145, 85.0),
  (151, 67, 1, '2026-08-28', 'OUT', 7, 640.0),
  (152, 33, 1, '2026-08-29', 'IN', 49, 512.07),
  (153, 33, 1, '2026-08-30', 'OUT', 19, 520.0),
  (154, 58, 2, '2026-08-30', 'OUT', 4, 1500.0),
  (155, 10, 3, '2026-09-03', 'OUT', 65, 240.0),
  (156, 21, 2, '2026-09-04', 'OUT', 325, 60.0),
  (157, 22, 2, '2026-09-04', 'OUT', 243, 85.0),
  (158, 6, 1, '2026-09-05', 'IN', 13, 1117.4),
  (159, 97, 2, '2026-09-05', 'IN', 97, 136.06),
  (160, 2, 1, '2026-09-07', 'OUT', 10, 15500.0),
  (161, 14, 1, '2026-09-10', 'IN', 26, 520.04),
  (162, 45, 1, '2026-09-10', 'OUT', 206, 85.0),
  (163, 94, 1, '2026-09-10', 'OUT', 37, 145.0),
  (164, 2, 3, '2026-09-12', 'OUT', 3, 15500.0),
  (165, 12, 1, '2026-09-12', 'OUT', 53, 420.0),
  (166, 22, 2, '2026-09-12', 'OUT', 201, 85.0),
  (167, 71, 2, '2026-09-12', 'OUT', 28, 420.0),
  (168, 95, 2, '2026-09-12', 'OUT', 101, 150.0),
  (169, 6, 1, '2026-09-13', 'OUT', 6, 1100.0),
  (170, 62, 2, '2026-09-13', 'OUT', 39, 850.0),
  (171, 66, 1, '2026-09-13', 'OUT', 39, 380.0),
  (172, 88, 1, '2026-09-16', 'OUT', 7, 380.0),
  (173, 8, 3, '2026-09-17', 'IN', 39, 345.48),
  (174, 29, 1, '2026-09-17', 'OUT', 111, 310.0),
  (175, 95, 2, '2026-09-17', 'OUT', 113, 150.0),
  (176, 4, 2, '2026-09-18', 'IN', 34, 4157.39),
  (177, 10, 3, '2026-09-20', 'OUT', 53, 240.0),
  (178, 18, 1, '2026-09-20', 'IN', 244, 198.15),
  (179, 2, 1, '2026-09-22', 'OUT', 9, 15500.0),
  (180, 1, 1, '2026-09-23', 'OUT', 4, 8200.0),
  (181, 63, 2, '2026-09-23', 'IN', 82, 557.91),
  (182, 42, 1, '2026-09-29', 'OUT', 119, 120.0),
  (183, 96, 3, '2026-09-29', 'OUT', 177, 120.0),
  (184, 55, 3, '2026-10-01', 'OUT', 5, 1650.0),
  (185, 88, 1, '2026-10-03', 'IN', 30, 391.97),
  (186, 97, 2, '2026-10-03', 'OUT', 59, 140.0),
  (187, 24, 1, '2026-10-07', 'OUT', 56, 260.0),
  (188, 13, 1, '2026-10-10', 'IN', 14, 8033.55),
  (189, 56, 1, '2026-10-15', 'IN', 47, 1692.21),
  (190, 80, 1, '2026-10-15', 'OUT', 242, 70.0),
  (191, 80, 1, '2026-10-16', 'OUT', 206, 70.0),
  (192, 22, 1, '2026-10-17', 'IN', 980, 86.71),
  (193, 63, 1, '2026-10-22', 'OUT', 18, 560.0),
  (194, 4, 1, '2026-10-23', 'IN', 57, 3828.71),
  (195, 72, 3, '2026-10-23', 'OUT', 151, 210.0),
  (196, 80, 1, '2026-10-25', 'OUT', 254, 70.0),
  (197, 95, 2, '2026-10-25', 'OUT', 67, 150.0),
  (198, 29, 1, '2026-10-27', 'OUT', 53, 310.0),
  (199, 49, 2, '2026-10-27', 'OUT', 96, 90.0),
  (200, 22, 1, '2026-10-31', 'OUT', 179, 85.0);

-- ---------------------------------------------------------------------
-- SECTION 4: A VIEW FOR CURRENT STOCK
-- A view is a saved SELECT query. It lets us reuse the formula
--     Current Stock = Total Stock IN - Total Stock OUT
-- for EVERY product (products with no transactions show 0).
-- ---------------------------------------------------------------------
CREATE VIEW vw_product_stock AS
SELECT  p.product_id,
        p.product_name,
        p.category_id,
        p.supplier_id,
        p.cost_price,
        p.reorder_level,
        COALESCE(SUM(CASE WHEN t.transaction_type = 'IN'  THEN t.quantity
                          WHEN t.transaction_type = 'OUT' THEN -t.quantity
                     END), 0) AS current_stock
FROM    products p
        LEFT JOIN stock_transactions t ON p.product_id = t.product_id
GROUP BY p.product_id, p.product_name, p.category_id, p.supplier_id,
         p.cost_price, p.reorder_level;

-- ---------------------------------------------------------------------
-- SECTION 5: QUICK CHECK - row count of every table
-- Expected: categories 10, suppliers 15, warehouses 3,
--           products 100, stock_transactions 200
-- ---------------------------------------------------------------------
SELECT 'categories' AS table_name, COUNT(*) AS total_rows FROM categories
UNION ALL SELECT 'suppliers',          COUNT(*) FROM suppliers
UNION ALL SELECT 'warehouses',         COUNT(*) FROM warehouses
UNION ALL SELECT 'products',           COUNT(*) FROM products
UNION ALL SELECT 'stock_transactions', COUNT(*) FROM stock_transactions;
-- ======================== END OF FILE ================================
