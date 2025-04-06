-- GAP Retail Database - Data Population Script (v2)
-- 02_p1v2.sql - Populating Base Independent Tables
-- This script populates tables that have no foreign key dependencies

-- Enable safe mode for testing
SET SQL_SAFE_UPDATES = 0;

-- Start transaction for safer data loading
START TRANSACTION;

-- Temporarily disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

-- Clear existing data to avoid conflicts
DELETE FROM payment_methods;
DELETE FROM payment_status;

-- -----------------------------------------------------
-- Insert default payment methods
-- -----------------------------------------------------
INSERT INTO payment_methods (MethodName, ProcessingFee, PaymentGateway) VALUES
('Visa', 2.9, 'Stripe'),
('Mastercard', 2.9, 'Stripe'),
('American Express', 3.5, 'Stripe'),
('Discover', 2.9, 'Stripe'),
('PayPal', 3.4, 'PayPal'),
('Apple Pay', 2.0, 'Apple'),
('Google Pay', 2.2, 'Google'),
('Store Credit', 0, 'Internal'),
('Gift Card', 0, 'Internal'),
('Debit Card', 1.5, 'Stripe'),
('Bank Transfer', 1.0, 'ACH'),
('Affirm', 4.0, 'Affirm'),
('Klarna', 4.2, 'Klarna'),
('Afterpay', 4.0, 'Afterpay'),
('Venmo', 2.9, 'PayPal'),
('Cash', 0, 'Internal'),
('Rewards Points', 0, 'Internal');

-- -----------------------------------------------------
-- Insert default payment statuses
-- -----------------------------------------------------
INSERT INTO payment_status (StatusName, StatusDescription) VALUES
('Pending', 'Payment is pending processing'),
('Authorized', 'Payment has been authorized but not captured'),
('Completed', 'Payment has been completed successfully'),
('Failed', 'Payment has failed'),
('Refunded', 'Payment has been refunded'),
('Partially Refunded', 'Payment has been partially refunded'),
('Voided', 'Payment authorization has been voided'),
('Declined', 'Payment was declined by the payment processor'),
('Cancelled', 'Payment was cancelled before processing'),
('In Dispute', 'Payment is under dispute by the customer'),
('Chargeback', 'Payment has been charged back by the customer');

-- -----------------------------------------------------
-- Clear and insert parent categories
-- -----------------------------------------------------
DELETE FROM categories WHERE ParentCategoryID IS NULL;
INSERT INTO categories (CategoryName, CategoryDescription, ParentCategoryID) VALUES
('Men', 'Men\'s clothing', NULL),
('Women', 'Women\'s clothing', NULL),
('Kids', 'Kids\' clothing', NULL),
('Baby', 'Baby clothing and accessories', NULL),
('Accessories', 'Accessories for all', NULL);

-- -----------------------------------------------------
-- Populate additional categories with unique names
-- -----------------------------------------------------
INSERT INTO categories (CategoryName, CategoryDescription, ParentCategoryID) VALUES
-- Men's subcategories (parent 1)
('Men\'s Shirts', 'Men\'s button-down and casual shirts', 1),
('Men\'s Pants', 'Men\'s pants and trousers', 1),
('Men\'s Sweaters', 'Men\'s sweaters and cardigans', 1),
('Men\'s Jackets & Coats', 'Men\'s outerwear', 1),
('Men\'s Activewear', 'Men\'s athletic and workout apparel', 1),
('Men\'s Suits', 'Men\'s formal wear and suits', 1),
('Men\'s Shorts', 'Men\'s shorts', 1),
('Men\'s Underwear', 'Men\'s underwear and boxers', 1),
('Men\'s Sleepwear', 'Men\'s pajamas and loungewear', 1),
('Men\'s Swimwear', 'Men\'s swim trunks and board shorts', 1),
('Men\'s Socks', 'Men\'s socks and hosiery', 1),

-- Women's subcategories (parent 2)
('Women\'s Blouses', 'Women\'s blouses and dressy tops', 2),
('Women\'s Sweaters & Cardigans', 'Women\'s knitwear', 2),
('Women\'s Pants & Leggings', 'Women\'s pants and leggings', 2),
('Women\'s Jeans', 'Women\'s jeans and denim', 2),
('Women\'s Skirts', 'Women\'s skirts', 2),
('Women\'s Jackets & Coats', 'Women\'s outerwear', 2),
('Women\'s Activewear', 'Women\'s athletic and workout apparel', 2),
('Women\'s Sleepwear', 'Women\'s pajamas and loungewear', 2),
('Women\'s Intimates', 'Women\'s underwear and lingerie', 2),
('Women\'s Swimwear', 'Women\'s swimsuits and cover-ups', 2),
('Women\'s Maternity', 'Maternity clothing', 2),
('Women\'s Shorts', 'Women\'s shorts', 2),

-- Kids subcategories (parent 3)
('Kids\' Shirts & Tops', 'Kids\' shirts and tops', 3),
('Kids\' Pants & Jeans', 'Kids\' pants and jeans', 3),
('Kids\' Outerwear', 'Kids\' jackets and coats', 3),
('Kids\' Activewear', 'Kids\' athletic apparel', 3),
('Kids\' Swimwear', 'Kids\' swim apparel', 3),
('Kids\' Sleepwear', 'Kids\' pajamas', 3),
('Kids\' Underwear', 'Kids\' underwear', 3),
('Kids\' School Uniforms', 'School uniform essentials', 3),

-- Baby subcategories (parent 4)
('Baby Bodysuits & Rompers', 'Baby one-pieces', 4),
('Baby Tops & Bottoms', 'Baby separates', 4),
('Baby Sets & Outfits', 'Coordinated baby outfits', 4),
('Baby Sleepwear', 'Baby pajamas and sleep sacks', 4),
('Baby Outerwear', 'Baby jackets and outerwear', 4),
('Baby Swimwear', 'Baby swim apparel', 4),

-- Accessories subcategories (parent 5)
('Bags & Purses', 'Handbags, totes, and backpacks', 5),
('Jewelry', 'Fashion jewelry', 5),
('Hats & Caps', 'Headwear', 5),
('Belts', 'Fashion belts', 5),
('Scarves & Wraps', 'Neck accessories', 5),
('Sunglasses', 'Fashion eyewear', 5),
('Watches', 'Wristwatches', 5),
('Hair Accessories', 'Hair bands, clips, and more', 5),
('Tech Accessories', 'Phone cases and tech accessories', 5);

-- -----------------------------------------------------
-- Populate warehouses (50 rows)
-- -----------------------------------------------------
DELETE FROM warehouses;
INSERT INTO warehouses (WarehouseName, WarehouseLocation, WarehouseCapacity, ContactPhone, ContactEmail, OperatingHours) VALUES
-- East Coast Warehouses
('East Regional DC', 'Secaucus, NJ', 1250000, '201-555-1000', 'east.dc@gap.com', 'Mon-Fri: 6am-10pm, Sat: 8am-6pm'),
('Northeast Fulfillment Center', 'Philadelphia, PA', 980000, '215-555-1001', 'philly.dc@gap.com', 'Mon-Sun: 24 hours'),
('Southeast DC', 'Atlanta, GA', 1100000, '404-555-1002', 'atlanta.dc@gap.com', 'Mon-Sun: 24 hours'),
('Mid-Atlantic Distribution', 'Richmond, VA', 720000, '804-555-1003', 'richmond.dc@gap.com', 'Mon-Fri: 7am-9pm, Sat: 8am-5pm'),
('Florida Fulfillment Center', 'Jacksonville, FL', 850000, '904-555-1004', 'jax.dc@gap.com', 'Mon-Sat: 7am-11pm'),
('New England Distribution', 'Boston, MA', 560000, '617-555-1005', 'boston.dc@gap.com', 'Mon-Fri: 6am-8pm'),
('NYC Metro Center', 'Edison, NJ', 500000, '732-555-1006', 'edison.dc@gap.com', 'Mon-Fri: 24 hours, Sat: 8am-8pm'),
('North Carolina DC', 'Charlotte, NC', 670000, '704-555-1007', 'charlotte.dc@gap.com', 'Mon-Sat: 7am-9pm'),
('South Florida DC', 'Miami, FL', 480000, '305-555-1008', 'miami.dc@gap.com', 'Mon-Fri: 7am-8pm'),
('Tennessee Distribution Center', 'Nashville, TN', 590000, '615-555-1009', 'nashville.dc@gap.com', 'Mon-Fri: 6am-9pm'),

-- Central Region Warehouses
('Central Regional DC', 'Columbus, OH', 1300000, '614-555-1100', 'columbus.dc@gap.com', 'Mon-Sun: 24 hours'),
('Midwest Fulfillment Center', 'Chicago, IL', 1050000, '312-555-1101', 'chicago.dc@gap.com', 'Mon-Sun: 24 hours'),
('Texas Primary DC', 'Dallas, TX', 1200000, '214-555-1102', 'dallas.dc@gap.com', 'Mon-Sun: 24 hours'),
('Texas Secondary DC', 'Houston, TX', 850000, '713-555-1103', 'houston.dc@gap.com', 'Mon-Sat: 6am-10pm'),
('Minnesota Distribution Center', 'Minneapolis, MN', 670000, '612-555-1104', 'minneapolis.dc@gap.com', 'Mon-Fri: 7am-9pm'),
('Michigan DC', 'Detroit, MI', 580000, '313-555-1105', 'detroit.dc@gap.com', 'Mon-Fri: 6am-8pm'),
('Missouri Fulfillment Center', 'St. Louis, MO', 620000, '314-555-1106', 'stlouis.dc@gap.com', 'Mon-Sat: 7am-9pm'),
('Colorado Distribution', 'Denver, CO', 530000, '303-555-1107', 'denver.dc@gap.com', 'Mon-Fri: 7am-8pm'),
('Indiana Warehouse', 'Indianapolis, IN', 470000, '317-555-1108', 'indy.dc@gap.com', 'Mon-Fri: 6am-8pm'),
('Wisconsin DC', 'Milwaukee, WI', 410000, '414-555-1109', 'milwaukee.dc@gap.com', 'Mon-Fri: 7am-7pm'),

-- West Coast Warehouses
('West Regional DC', 'Fresno, CA', 1400000, '559-555-1200', 'fresno.dc@gap.com', 'Mon-Sun: 24 hours'),
('Pacific Northwest DC', 'Seattle, WA', 890000, '206-555-1201', 'seattle.dc@gap.com', 'Mon-Sun: 6am-10pm'),
('SoCal Distribution Center', 'Riverside, CA', 1100000, '951-555-1202', 'riverside.dc@gap.com', 'Mon-Sun: 24 hours'),
('Bay Area Fulfillment', 'Oakland, CA', 750000, '510-555-1203', 'oakland.dc@gap.com', 'Mon-Sat: 6am-9pm'),
('Arizona Distribution', 'Phoenix, AZ', 680000, '602-555-1204', 'phoenix.dc@gap.com', 'Mon-Sat: 5am-9pm'),
('Oregon Warehouse', 'Portland, OR', 510000, '503-555-1205', 'portland.dc@gap.com', 'Mon-Fri: 6am-8pm'),
('Nevada Fulfillment Center', 'Reno, NV', 630000, '775-555-1206', 'reno.dc@gap.com', 'Mon-Sat: 6am-8pm'),
('San Diego DC', 'San Diego, CA', 490000, '619-555-1207', 'sandiego.dc@gap.com', 'Mon-Fri: 6am-8pm'),
('Utah Distribution', 'Salt Lake City, UT', 520000, '801-555-1208', 'slc.dc@gap.com', 'Mon-Fri: 7am-9pm'),
('Hawaii Distribution', 'Honolulu, HI', 280000, '808-555-1209', 'honolulu.dc@gap.com', 'Mon-Fri: 7am-7pm'),

-- International Warehouses
('Canada Main DC', 'Toronto, ON, Canada', 950000, '+1-416-555-1300', 'toronto.dc@gap.com', 'Mon-Fri: 7am-9pm'),
('Canada West DC', 'Vancouver, BC, Canada', 580000, '+1-604-555-1301', 'vancouver.dc@gap.com', 'Mon-Fri: 7am-7pm'),
('UK Distribution Center', 'Milton Keynes, UK', 870000, '+44-1908-555-1302', 'uk.dc@gap.com', 'Mon-Fri: 8am-8pm'),
('European Main DC', 'Amsterdam, Netherlands', 920000, '+31-20-555-1303', 'europe.dc@gap.com', 'Mon-Fri: 8am-8pm'),
('France Distribution', 'Paris, France', 610000, '+33-1-5555-1304', 'france.dc@gap.com', 'Mon-Fri: 9am-7pm'),
('Germany Fulfillment', 'Frankfurt, Germany', 680000, '+49-69-5555-1305', 'germany.dc@gap.com', 'Mon-Fri: 8am-8pm'),
('Italy Warehouse', 'Milan, Italy', 540000, '+39-02-5555-1306', 'italy.dc@gap.com', 'Mon-Fri: 9am-7pm'),
('Spain Distribution', 'Madrid, Spain', 520000, '+34-91-5555-1307', 'spain.dc@gap.com', 'Mon-Fri: 9am-7pm'),
('Japan Main DC', 'Tokyo, Japan', 630000, '+81-3-5555-1308', 'japan.dc@gap.com', 'Mon-Fri: 9am-7pm'),
('China Distribution', 'Shanghai, China', 780000, '+86-21-5555-1309', 'china.dc@gap.com', 'Mon-Fri: 9am-7pm'),

-- Specialty Warehouses
('E-Commerce Fulfillment East', 'Allentown, PA', 1050000, '484-555-1400', 'ecom.east@gap.com', 'Mon-Sun: 24 hours'),
('E-Commerce Fulfillment West', 'Stockton, CA', 980000, '209-555-1401', 'ecom.west@gap.com', 'Mon-Sun: 24 hours'),
('Outlet Merchandise DC', 'Lancaster, PA', 640000, '717-555-1402', 'outlet.dc@gap.com', 'Mon-Fri: 7am-7pm'),
('Seasonal Storage East', 'Baltimore, MD', 580000, '410-555-1403', 'seasonal.east@gap.com', 'Mon-Fri: 8am-6pm'),
('Seasonal Storage West', 'Rialto, CA', 540000, '909-555-1404', 'seasonal.west@gap.com', 'Mon-Fri: 8am-6pm'),
('Returns Processing Center', 'Columbus, OH', 490000, '614-555-1405', 'returns.processing@gap.com', 'Mon-Sat: 7am-9pm'),
('Archive & Special Items', 'Burbank, CA', 320000, '818-555-1406', 'archive.storage@gap.com', 'Mon-Fri: 9am-5pm'),
('Flagship Store Support', 'New York, NY', 290000, '212-555-1407', 'flagship.support@gap.com', 'Mon-Fri: 8am-8pm'),
('International Shipping Hub', 'Miami, FL', 420000, '305-555-1408', 'intl.shipping@gap.com', 'Mon-Fri: 24 hours'),
('Specialty Brands DC', 'Fishkill, NY', 670000, '845-555-1409', 'specialty.dc@gap.com', 'Mon-Fri: 7am-7pm');

-- -----------------------------------------------------
-- Populate stores (20 rows - reduced for brevity)
-- -----------------------------------------------------
DELETE FROM stores;
INSERT INTO stores (StoreName, Location, StorePhone, StoreEmail, ManagerName, OperatingHours, StoreSize, RegionID, SupportsPickup) VALUES
-- Northeast Region (RegionID 1)
('GAP New York - Fifth Ave', '680 5th Ave, New York, NY 10019', '212-555-2000', 'nyc.5ave@gap.com', 'Sarah Johnson', 'Mon-Sat: 10am-8pm, Sun: 11am-7pm', 12500, 1, TRUE),
('GAP Boston - Newbury', '140 Newbury St, Boston, MA 02116', '617-555-2001', 'boston.newbury@gap.com', 'Michael Chen', 'Mon-Sat: 10am-8pm, Sun: 11am-6pm', 8700, 1, TRUE),
('GAP Philadelphia - Walnut', '1510 Walnut St, Philadelphia, PA 19102', '215-555-2002', 'philly.walnut@gap.com', 'Jessica Williams', 'Mon-Sat: 10am-8pm, Sun: 11am-6pm', 9200, 1, TRUE),
('GAP Brooklyn - Atlantic Center', '625 Atlantic Ave, Brooklyn, NY 11217', '718-555-2003', 'brooklyn.atlantic@gap.com', 'David Singh', 'Mon-Sat: 10am-9pm, Sun: 11am-7pm', 10500, 1, TRUE),

-- Southeast Region (RegionID 2)
('GAP Atlanta - Lenox Square', '3393 Peachtree Rd NE, Atlanta, GA 30326', '404-555-2100', 'atlanta.lenox@gap.com', 'Melissa Johnson', 'Mon-Sat: 10am-9pm, Sun: 12pm-7pm', 9800, 2, TRUE),
('GAP Miami - Dadeland Mall', '7535 N Kendall Dr, Miami, FL 33156', '305-555-2101', 'miami.dadeland@gap.com', 'Carlos Rodriguez', 'Mon-Sat: 10am-9:30pm, Sun: 11am-7pm', 8900, 2, TRUE),
('GAP Orlando - Florida Mall', '8001 S Orange Blossom Trl, Orlando, FL 32809', '407-555-2102', 'orlando.florida@gap.com', 'Sophia Martinez', 'Mon-Sat: 10am-9pm, Sun: 11am-7pm', 8400, 2, TRUE),
('GAP Charlotte - SouthPark', '4400 Sharon Rd, Charlotte, NC 28211', '704-555-2103', 'charlotte.southpark@gap.com', 'William Davis', 'Mon-Sat: 10am-9pm, Sun: 12pm-6pm', 8300, 2, TRUE),

-- Midwest Region (RegionID 3)
('GAP Chicago - Michigan Avenue', '555 N Michigan Ave, Chicago, IL 60611', '312-555-2200', 'chicago.michigan@gap.com', 'Natalie Roberts', 'Mon-Sat: 10am-9pm, Sun: 11am-7pm', 11000, 3, TRUE),
('GAP Minneapolis - Mall of America', '60 E Broadway, Bloomington, MN 55425', '952-555-2201', 'minneapolis.moa@gap.com', 'Owen Campbell', 'Mon-Sat: 10am-9:30pm, Sun: 11am-7pm', 9500, 3, TRUE),
('GAP Detroit - Somerset Collection', '2800 W Big Beaver Rd, Troy, MI 48084', '248-555-2202', 'detroit.somerset@gap.com', 'Lily Evans', 'Mon-Sat: 10am-9pm, Sun: 12pm-6pm', 8400, 3, TRUE),
('GAP St. Louis - Saint Louis Galleria', '1155 Saint Louis Galleria, St. Louis, MO 63117', '314-555-2203', 'stlouis.galleria@gap.com', 'Gabriel Morgan', 'Mon-Sat: 10am-9pm, Sun: 11am-6pm', 7800, 3, TRUE),

-- Southwest Region (RegionID 4)
('GAP Dallas - NorthPark Center', '8687 N Central Expy, Dallas, TX 75225', '214-555-2300', 'dallas.northpark@gap.com', 'Violet Adams', 'Mon-Sat: 10am-9pm, Sun: 12pm-6pm', 9200, 4, TRUE),
('GAP Houston - The Galleria', '5085 Westheimer Rd, Houston, TX 77056', '713-555-2301', 'houston.galleria@gap.com', 'Grayson Bennett', 'Mon-Sat: 10am-9pm, Sun: 11am-7pm', 8800, 4, TRUE),
('GAP Phoenix - Scottsdale Fashion Square', '7014 E Camelback Rd, Scottsdale, AZ 85251', '480-555-2302', 'phoenix.scottsdale@gap.com', 'Paisley Rogers', 'Mon-Sat: 10am-9pm, Sun: 11am-6pm', 8300, 4, TRUE),
('GAP Austin - The Domain', '11410 Century Oaks Terrace, Austin, TX 78758', '512-555-2303', 'austin.domain@gap.com', 'Nolan Perry', 'Mon-Sat: 10am-9pm, Sun: 12pm-6pm', 8100, 4, TRUE),

-- West Coast Region (RegionID 5)
('GAP San Francisco - Union Square', '890 Market St, San Francisco, CA 94102', '415-555-2400', 'sf.unionsquare@gap.com', 'Eliana Turner', 'Mon-Sat: 10am-8pm, Sun: 11am-7pm', 10500, 5, TRUE),
('GAP Los Angeles - The Grove', '189 The Grove Dr, Los Angeles, CA 90036', '323-555-2401', 'la.grove@gap.com', 'Silas Holmes', 'Mon-Sat: 10am-9pm, Sun: 11am-8pm', 9800, 5, TRUE),
('GAP Seattle - Westlake Center', '400 Pine St, Seattle, WA 98101', '206-555-2402', 'seattle.westlake@gap.com', 'London Cooper', 'Mon-Sat: 10am-8pm, Sun: 11am-6pm', 8900, 5, TRUE),
('GAP Portland - Pioneer Place', '700 SW 5th Ave, Portland, OR 97204', '503-555-2403', 'portland.pioneer@gap.com', 'Roman Jenkins', 'Mon-Sat: 10am-8pm, Sun: 11am-6pm', 8200, 5, TRUE);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Commit transaction to save data
COMMIT;

-- End of 02_p1v2.sql