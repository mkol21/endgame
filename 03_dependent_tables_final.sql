-- GAP Retail Database - Data Population Script (Optimized Batch Version)
-- 03_dependent_tables_final.sql - Populating Dependent Tables with Batch Processing
-- Optimized version with batch processing to avoid lock timeouts

USE gapdbase;

-- Increase lock wait timeout for this session (5 minutes)
SET innodb_lock_wait_timeout = 300;

-- Disable safe mode for faster loading
SET SQL_SAFE_UPDATES = 0;

-- Temporarily disable foreign key checks for faster loading
SET FOREIGN_KEY_CHECKS = 0;

-- Save current SQL mode and set more permissive mode
SET @OLD_SQL_MODE = @@SESSION.sql_mode;
SET SESSION sql_mode = '';

-- Drop any existing temporary tables to avoid conflicts
DROP TEMPORARY TABLE IF EXISTS temp_first_names;
DROP TEMPORARY TABLE IF EXISTS temp_last_names;
DROP TEMPORARY TABLE IF EXISTS temp_email_domains;
DROP TEMPORARY TABLE IF EXISTS temp_streets;
DROP TEMPORARY TABLE IF EXISTS temp_cities;
DROP TEMPORARY TABLE IF EXISTS temp_product_types;
DROP TEMPORARY TABLE IF EXISTS temp_product_features;
DROP TEMPORARY TABLE IF EXISTS temp_product_adjectives;
DROP TEMPORARY TABLE IF EXISTS temp_product_brands;
DROP TEMPORARY TABLE IF EXISTS temp_seasons;
DROP TEMPORARY TABLE IF EXISTS temp_promo_types;
DROP TEMPORARY TABLE IF EXISTS temp_customers;
DROP TEMPORARY TABLE IF EXISTS temp_addresses;
DROP TEMPORARY TABLE IF EXISTS temp_products;
DROP TEMPORARY TABLE IF EXISTS temp_promotions;

-- Clear existing data to avoid conflicts
DELETE FROM shopping_cart_items;
DELETE FROM shopping_cart;
DELETE FROM loyalty_accounts;
DELETE FROM addresses;
DELETE FROM customers;
DELETE FROM promotions;
DELETE FROM products;

-- -----------------------------------------------------
-- Generate 50 customers with batch processing
-- -----------------------------------------------------

-- Create a temporary table for first names
CREATE TEMPORARY TABLE temp_first_names (
    first_name VARCHAR(50)
);

INSERT INTO temp_first_names (first_name) VALUES 
('James'), ('Mary'), ('John'), ('Patricia'), ('Robert'), ('Jennifer'), ('Michael'), ('Linda'), 
('William'), ('Elizabeth'), ('David'), ('Susan'), ('Richard'), ('Jessica'), ('Joseph'), ('Sarah'), 
('Thomas'), ('Karen'), ('Charles'), ('Nancy'), ('Christopher'), ('Lisa'), ('Daniel'), ('Margaret'), 
('Matthew'), ('Betty'), ('Anthony'), ('Sandra'), ('Mark'), ('Ashley');

-- Create a temporary table for last names
CREATE TEMPORARY TABLE temp_last_names (
    last_name VARCHAR(50)
);

INSERT INTO temp_last_names (last_name) VALUES 
('Smith'), ('Johnson'), ('Williams'), ('Jones'), ('Brown'), ('Davis'), ('Miller'), ('Wilson'), 
('Moore'), ('Taylor'), ('Anderson'), ('Thomas'), ('Jackson'), ('White'), ('Harris'), ('Martin'), 
('Thompson'), ('Garcia'), ('Martinez'), ('Robinson'), ('Clark'), ('Rodriguez'), ('Lewis'), ('Lee'), 
('Walker'), ('Hall'), ('Allen'), ('Young'), ('Hernandez'), ('King');

-- Create a temporary table for email domains
CREATE TEMPORARY TABLE temp_email_domains (
    domain VARCHAR(50)
);

INSERT INTO temp_email_domains (domain) VALUES 
('gmail.com'), ('yahoo.com'), ('hotmail.com'), ('outlook.com'), ('icloud.com');

-- Create temporary table to store customer data
CREATE TEMPORARY TABLE temp_customers (
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    DateJoined DATE,
    DateOfBirth DATE,
    Gender VARCHAR(20),
    PreferredLanguage VARCHAR(10),
    MarketingPreferences JSON,
    IsActive BOOLEAN
);

-- Generate customer data in the temporary table
INSERT INTO temp_customers
SELECT 
    f.first_name,
    l.last_name,
    LOWER(CONCAT(
        SUBSTR(f.first_name, 1, 1),
        l.last_name, 
        ROW_NUMBER() OVER (),  -- Use row number for uniqueness
        '@', e.domain
    )) AS Email,
    CONCAT('(', LPAD(FLOOR(RAND() * 1000), 3, '0'), ') ',
           LPAD(FLOOR(RAND() * 1000), 3, '0'), '-', 
           LPAD(FLOOR(RAND() * 10000), 4, '0')) AS Phone,
    DATE_SUB(CURRENT_DATE, INTERVAL FLOOR(RAND() * 1825) DAY) AS DateJoined,
    DATE_SUB(CURRENT_DATE, INTERVAL (18 + FLOOR(RAND() * 60)) YEAR) AS DateOfBirth,
    ELT(FLOOR(RAND() * 3) + 1, 'Male', 'Female', 'Non-binary') AS Gender,
    ELT(FLOOR(RAND() * 5) + 1, 'en', 'es', 'fr', 'zh', 'de') AS PreferredLanguage,
    JSON_OBJECT(
        'email_offers', IF(RAND() > 0.3, 'true', 'false'),
        'sms_alerts', IF(RAND() > 0.5, 'true', 'false'),
        'app_notifications', IF(RAND() > 0.4, 'true', 'false'),
        'seasonal_catalogs', IF(RAND() > 0.7, 'true', 'false')
    ) AS MarketingPreferences,
    IF(RAND() > 0.05, 1, 0) AS IsActive
FROM 
    temp_first_names f,
    temp_last_names l,
    temp_email_domains e
LIMIT 50;

-- Insert customers in a single transaction
START TRANSACTION;
INSERT INTO customers (FirstName, LastName, Email, Phone, DateJoined, DateOfBirth, Gender, 
                       PreferredLanguage, MarketingPreferences, IsActive)
SELECT * FROM temp_customers;
COMMIT;

-- -----------------------------------------------------
-- Generate addresses with batch processing (100 addresses)
-- -----------------------------------------------------

-- Create temporary tables for address components
CREATE TEMPORARY TABLE temp_streets (
    street VARCHAR(100)
);

INSERT INTO temp_streets (street) VALUES 
('Main St'), ('Oak Ave'), ('Park Rd'), ('Maple Ln'), ('Washington Blvd'), ('Cedar St'), 
('Lake Ave'), ('Elm St'), ('Pine St'), ('River Rd'), ('Highland Ave'), ('Forest Dr'), 
('Meadow Ln'), ('Valley Rd'), ('Mountain View Dr');

CREATE TEMPORARY TABLE temp_cities (
    city VARCHAR(100),
    state VARCHAR(50),
    postal_prefix VARCHAR(3)
);

INSERT INTO temp_cities (city, state, postal_prefix) VALUES 
('New York', 'NY', '100'), ('Los Angeles', 'CA', '900'), ('Chicago', 'IL', '606'), 
('Houston', 'TX', '770'), ('Phoenix', 'AZ', '850'), ('Philadelphia', 'PA', '191'), 
('San Antonio', 'TX', '782'), ('San Diego', 'CA', '921'), ('Dallas', 'TX', '752'), 
('San Jose', 'CA', '951');

-- Create temporary table for addresses
CREATE TEMPORARY TABLE temp_addresses (
    CustomerID INT,
    AddressLine1 VARCHAR(100),
    AddressLine2 VARCHAR(100),
    City VARCHAR(100),
    StateProvince VARCHAR(50),
    PostalCode VARCHAR(20),
    Country VARCHAR(50),
    IsDefaultShipping BOOLEAN,
    IsDefaultBilling BOOLEAN,
    AddressType ENUM('HOME', 'BUSINESS', 'SHIPPING', 'BILLING'),
    IsVerified BOOLEAN
);

-- Generate address data in the temporary table
INSERT INTO temp_addresses
SELECT 
    c.CustomerID,
    CONCAT(FLOOR(RAND() * 9999) + 1, ' ', s.street) AS AddressLine1,
    IF(RAND() > 0.7, CONCAT('Apt ', FLOOR(RAND() * 999) + 1), NULL) AS AddressLine2,
    ct.city,
    ct.state,
    CONCAT(ct.postal_prefix, LPAD(FLOOR(RAND() * 99), 2, '0')) AS PostalCode,
    'USA',
    IF(address_num = 1, 1, 0) AS IsDefaultShipping,
    IF(address_num = 1, 1, 0) AS IsDefaultBilling,
    CASE 
        WHEN address_num = 1 THEN 'HOME'
        ELSE 'BUSINESS'
    END AS AddressType,
    IF(RAND() > 0.1, 1, 0) AS IsVerified
FROM 
    (
        SELECT 
            CustomerID,
            address_num
        FROM 
            customers
            CROSS JOIN (
                SELECT 1 AS address_num UNION ALL
                SELECT 2 WHERE (RAND() > 0.5)
            ) AS nums
        ORDER BY 
            CustomerID, address_num
    ) AS c,
    temp_streets s,
    temp_cities ct
WHERE RAND() <= 1.0
LIMIT 100;

-- Insert addresses in a single transaction
START TRANSACTION;
INSERT INTO addresses (CustomerID, AddressLine1, AddressLine2, City, StateProvince, PostalCode, 
                      Country, IsDefaultShipping, IsDefaultBilling, AddressType, IsVerified)
SELECT * FROM temp_addresses;
COMMIT;

-- -----------------------------------------------------
-- Populate loyalty_accounts table (50 rows)
-- -----------------------------------------------------

-- Create all loyalty accounts in a single transaction
START TRANSACTION;
INSERT INTO loyalty_accounts (CustomerID, PointsBalance, TierLevel, TierStartDate, TierEndDate, LifetimePoints)
SELECT 
    CustomerID,
    FLOOR(RAND() * 10000) AS PointsBalance,
    ELT(FLOOR(RAND() * 3) + 1, 'Core', 'Enthusiast', 'Icon') AS TierLevel,
    DATE_SUB(CURRENT_DATE, INTERVAL FLOOR(RAND() * 365) DAY) AS TierStartDate,
    DATE_ADD(CURRENT_DATE, INTERVAL FLOOR(RAND() * 365) DAY) AS TierEndDate,
    FLOOR(RAND() * 50000) + 10000 AS LifetimePoints
FROM 
    customers
LIMIT 50;
COMMIT;

-- -----------------------------------------------------
-- Populate products table (100 rows)
-- -----------------------------------------------------

-- Create temporary table for product names and details
CREATE TEMPORARY TABLE temp_product_types (
    product_type VARCHAR(50),
    description_prefix VARCHAR(100)
);

INSERT INTO temp_product_types (product_type, description_prefix) VALUES
('T-Shirt', 'Classic cotton t-shirt with'),
('Jeans', 'Comfortable denim jeans with'),
('Dress', 'Stylish dress with'),
('Sweater', 'Warm knit sweater with'),
('Jacket', 'Durable jacket with'),
('Shorts', 'Casual shorts with'),
('Hoodie', 'Cozy hoodie with'),
('Polo Shirt', 'Classic polo shirt with'),
('Skirt', 'Fashionable skirt with'),
('Button-Up Shirt', 'Professional button-up shirt with');

CREATE TEMPORARY TABLE temp_product_features (
    feature VARCHAR(100)
);

INSERT INTO temp_product_features (feature) VALUES
('a relaxed fit'), ('a slim fit'), ('a regular fit'), ('a loose fit'), ('a tailored fit'),
('a crew neck'), ('a v-neck'), ('a scoop neck'), ('a boat neck'), ('a turtleneck'),
('short sleeves'), ('long sleeves'), ('three-quarter sleeves'), ('no sleeves'), ('rolled sleeves');

CREATE TEMPORARY TABLE temp_product_adjectives (
    adjective VARCHAR(50)
);

INSERT INTO temp_product_adjectives (adjective) VALUES
('Classic'), ('Modern'), ('Vintage'), ('Essential'), ('Premium'),
('Signature'), ('Contemporary'), ('Trendy'), ('Timeless'), ('Stylish');

CREATE TEMPORARY TABLE temp_product_brands (
    brand VARCHAR(50)
);

INSERT INTO temp_product_brands (brand) VALUES
('GAP'), ('GAP'), ('GAP'), ('Old Navy'), ('Banana Republic');

CREATE TEMPORARY TABLE temp_seasons (
    year INT,
    season VARCHAR(20)
);

INSERT INTO temp_seasons (year, season) VALUES
(2023, 'Fall'), (2023, 'Winter'),
(2024, 'Spring'), (2024, 'Summer'), (2024, 'Fall'), (2024, 'Winter'),
(2025, 'Spring'), (2025, 'Summer');

-- Create temporary table for products
CREATE TEMPORARY TABLE temp_products (
    ProductName VARCHAR(100),
    ProductDescription TEXT,
    Brand VARCHAR(50),
    CategoryID INT,
    SupplierID INT,
    ProductLifecycleStatus ENUM('Draft', 'Active', 'Discontinued', 'Seasonal'),
    MSRP DECIMAL(10,2),
    StandardCost DECIMAL(10,2),
    Weight DECIMAL(6,2),
    Dimensions VARCHAR(50),
    SeasonYear INT,
    SeasonName VARCHAR(20)
);

-- Generate product data in the temporary table
INSERT INTO temp_products
SELECT 
    CONCAT(
        adj.adjective, ' ',
        pt.product_type
    ) AS ProductName,
    CONCAT(
        pt.description_prefix, ' ', 
        f1.feature, ' and ', 
        f2.feature, '. Perfect for any occasion.'
    ) AS ProductDescription,
    b.brand AS Brand,
    -- Select a category that makes sense for the product type
    (
        SELECT CategoryID FROM categories 
        WHERE CategoryName IN (
            CASE 
                WHEN pt.product_type IN ('T-Shirt', 'Polo Shirt', 'Button-Up Shirt') THEN 'Men\'s Shirts'
                WHEN pt.product_type IN ('Jeans') THEN 'Men\'s Pants'
                WHEN pt.product_type IN ('Dress') THEN 'Women\'s Blouses'
                WHEN pt.product_type IN ('Sweater', 'Hoodie') THEN 'Men\'s Sweaters'
                WHEN pt.product_type IN ('Jacket') THEN 'Men\'s Jackets & Coats'
                WHEN pt.product_type IN ('Shorts') THEN 'Men\'s Shorts'
                WHEN pt.product_type IN ('Skirt') THEN 'Women\'s Skirts'
                ELSE 'Men\'s Shirts' -- Default to Men's Shirts if no match
            END
        )
        ORDER BY RAND() 
        LIMIT 1
    ) AS CategoryID,
    -- Use a hardcoded supplier ID range of 1-10 to avoid supplier lookup issues
    1 + FLOOR(RAND() * 10) AS SupplierID,
    ELT(FLOOR(RAND() * 4) + 1, 'Draft', 'Active', 'Discontinued', 'Seasonal') AS ProductLifecycleStatus,
    (19.99 + (RAND() * 100)) AS MSRP,
    ((19.99 + (RAND() * 100)) * 0.4) AS StandardCost,
    (0.2 + RAND() * 2) AS Weight,
    CONCAT(FLOOR(10 + RAND() * 40), 'x', FLOOR(10 + RAND() * 40), 'x', FLOOR(2 + RAND() * 8), 'cm') AS Dimensions,
    se.year AS SeasonYear,
    se.season AS SeasonName
FROM 
    temp_product_types pt,
    temp_product_adjectives adj,
    temp_product_features f1,
    temp_product_features f2,
    temp_product_brands b,
    temp_seasons se
WHERE 
    f1.feature != f2.feature
LIMIT 100;

-- Process products in batches of 25
SET @batch_size = 25;
SET @total_products = 100;
SET @processed = 0;

WHILE @processed < @total_products DO
    START TRANSACTION;
    INSERT INTO products (ProductName, ProductDescription, Brand, CategoryID, SupplierID, 
                        ProductLifecycleStatus, MSRP, StandardCost, Weight, Dimensions, 
                        SeasonYear, SeasonName)
    SELECT * FROM temp_products LIMIT @processed, @batch_size;
    
    SET @processed = @processed + @batch_size;
    COMMIT;
END WHILE;

-- -----------------------------------------------------
-- Populate promotions table (50 rows)
-- -----------------------------------------------------

-- Create temporary table for promotion names and types
CREATE TEMPORARY TABLE temp_promo_types (
    promo_name VARCHAR(100),
    promo_description TEXT,
    discount_type ENUM('PERCENTAGE', 'FIXED_AMOUNT', 'BUY_X_GET_Y', 'BUNDLE')
);

INSERT INTO temp_promo_types (promo_name, promo_description, discount_type) VALUES
('Summer Sale', 'Special discounts on summer apparel and accessories', 'PERCENTAGE'),
('Winter Clearance', 'End of season clearance on winter items', 'PERCENTAGE'),
('Back to School', 'Special savings for back to school shopping', 'PERCENTAGE'),
('Holiday Special', 'Celebrate the holidays with special savings', 'PERCENTAGE'),
('Flash Sale', 'Limited time offer with deep discounts', 'PERCENTAGE'),
('Member Exclusive', 'Special offer for loyalty program members', 'PERCENTAGE'),
('First Purchase', 'Discount on your first purchase', 'PERCENTAGE'),
('Refer a Friend', 'Discount when you refer a friend', 'FIXED_AMOUNT'),
('Birthday Reward', 'Special discount during your birthday month', 'FIXED_AMOUNT'),
('Free Shipping', 'Free shipping on orders over a certain amount', 'FIXED_AMOUNT');

-- Create temporary table for promotions
CREATE TEMPORARY TABLE temp_promotions (
    PromotionName VARCHAR(100),
    PromotionCode VARCHAR(20),
    Description TEXT,
    StartDate TIMESTAMP,
    EndDate TIMESTAMP,
    DiscountType ENUM('PERCENTAGE', 'FIXED_AMOUNT', 'BUY_X_GET_Y', 'BUNDLE'),
    DiscountValue DECIMAL(10,2),
    MinimumPurchase DECIMAL(10,2),
    MaximumDiscount DECIMAL(10,2),
    UsageLimit INT,
    IsStackable BOOLEAN,
    IsActive BOOLEAN,
    TargetCustomerSegment VARCHAR(50)
);

-- Generate promotion data in the temporary table
INSERT INTO temp_promotions
SELECT 
    CONCAT(pt.promo_name, ' ', YEAR(CURRENT_DATE), '-', ROW_NUMBER() OVER()) AS PromotionName,
    CONCAT(
        UPPER(SUBSTRING(REPLACE(pt.promo_name, ' ', ''), 1, 4)),
        YEAR(CURRENT_DATE),
        LPAD(ROW_NUMBER() OVER(), 3, '0')
    ) AS PromotionCode,
    pt.promo_description AS Description,
    DATE_SUB(CURRENT_DATE, INTERVAL FLOOR(RAND() * 180) DAY) AS StartDate,
    DATE_ADD(CURRENT_DATE, INTERVAL FLOOR(RAND() * 180) DAY) AS EndDate,
    pt.discount_type AS DiscountType,
    CASE 
        WHEN pt.discount_type = 'PERCENTAGE' THEN FLOOR(5 + (RAND() * 50))
        WHEN pt.discount_type = 'FIXED_AMOUNT' THEN FLOOR(5 + (RAND() * 50))
        WHEN pt.discount_type = 'BUY_X_GET_Y' THEN FLOOR(1 + (RAND() * 3))
        ELSE FLOOR(5 + (RAND() * 30))
    END AS DiscountValue,
    IF(RAND() > 0.3, FLOOR(25 + (RAND() * 100)), NULL) AS MinimumPurchase,
    IF(RAND() > 0.5, FLOOR(50 + (RAND() * 200)), NULL) AS MaximumDiscount,
    IF(RAND() > 0.7, FLOOR(100 + (RAND() * 1000)), NULL) AS UsageLimit,
    IF(RAND() > 0.7, 1, 0) AS IsStackable,
    IF(RAND() > 0.2, 1, 0) AS IsActive,
    ELT(FLOOR(RAND() * 5) + 1, 'New', 'Silver', 'Gold', 'Platinum', 'All') AS TargetCustomerSegment
FROM 
    temp_promo_types pt,
    temp_promo_types pt2  -- Join to itself to generate more rows
LIMIT 50;

-- Process promotions in a single transaction
START TRANSACTION;
INSERT INTO promotions (PromotionName, PromotionCode, Description, StartDate, EndDate, 
                      DiscountType, DiscountValue, MinimumPurchase, MaximumDiscount, 
                      UsageLimit, IsStackable, IsActive, TargetCustomerSegment)
SELECT * FROM temp_promotions;
COMMIT;

-- -----------------------------------------------------
-- Populate shopping_cart table (50 rows)
-- -----------------------------------------------------

-- Create shopping carts for 50 customers or all if fewer than 50
START TRANSACTION;
INSERT INTO shopping_cart (CustomerID)
SELECT 
    CustomerID
FROM 
    customers
ORDER BY 
    RAND()
LIMIT 50;
COMMIT;

-- Drop all temporary tables
DROP TEMPORARY TABLE IF EXISTS temp_first_names;
DROP TEMPORARY TABLE IF EXISTS temp_last_names;
DROP TEMPORARY TABLE IF EXISTS temp_email_domains;
DROP TEMPORARY TABLE IF EXISTS temp_streets;
DROP TEMPORARY TABLE IF EXISTS temp_cities;
DROP TEMPORARY TABLE IF EXISTS temp_product_types;
DROP TEMPORARY TABLE IF EXISTS temp_product_features;
DROP TEMPORARY TABLE IF EXISTS temp_product_adjectives;
DROP TEMPORARY TABLE IF EXISTS temp_product_brands;
DROP TEMPORARY TABLE IF EXISTS temp_seasons;
DROP TEMPORARY TABLE IF EXISTS temp_promo_types;
DROP TEMPORARY TABLE IF EXISTS temp_customers;
DROP TEMPORARY TABLE IF EXISTS temp_addresses;
DROP TEMPORARY TABLE IF EXISTS temp_products;
DROP TEMPORARY TABLE IF EXISTS temp_promotions;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Restore original SQL mode
SET SESSION sql_mode = @OLD_SQL_MODE;

-- End of 03_dependent_tables_final.sql
-- Next file to be executed: 04_child_tables.sql