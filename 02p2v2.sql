-- GAP Retail Database - Data Population Script
-- 02_p2v2.sql - Populating Suppliers Table
-- This script continues from 02_p1v2.sql to complete the base independent tables
use gapdbase;
-- Start transaction for safer data loading
START TRANSACTION;

-- Temporarily disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

-- Clear existing data to avoid conflicts
DELETE FROM suppliers;

-- -----------------------------------------------------
-- Populate suppliers (100 rows)
-- -----------------------------------------------------
INSERT INTO suppliers (SupplierName, ContactName, ContactEmail, ContactPhone, Address, TaxID, PaymentTerms, LeadTimeDays, MinimumOrderQuantity, PreferredCurrency, SupplierRating) VALUES
-- Apparel Manufacturing Suppliers
('TextileTech Manufacturing', 'Brian Wong', 'b.wong@textiletech.com', '415-555-3000', '1200 Industrial Blvd, San Francisco, CA 94124', '95-4821764', 'Net 45', 14, 500, 'USD', 4.8),
('EcoFabric Solutions', 'Amara Patel', 'apatel@ecofabric.com', '510-555-3001', '780 Green Valley Rd, Oakland, CA 94612', '82-1735429', 'Net 30', 21, 250, 'USD', 4.7),
('Premium Cottons Ltd', 'Thomas Reeves', 'treeves@premiumcottons.com', '212-555-3002', '155 W 35th St, New York, NY 10001', '13-5768421', 'Net 30', 18, 750, 'USD', 4.5),
('Sustainable Textiles Inc', 'Lisa Chen', 'lchen@sustextiles.com', '503-555-3003', '2200 NW Quimby St, Portland, OR 97210', '93-2148765', 'Net 45', 14, 300, 'USD', 4.9),
('Global Fabric Innovations', 'Marcus Johnson', 'mjohnson@gfi-textiles.com', '310-555-3004', '8500 Beverly Blvd, Los Angeles, CA 90048', '95-8164732', 'Net 60', 21, 1000, 'USD', 4.4),
('Apex Apparel Manufacturing', 'Sarah Williams', 'swilliams@apexapparel.com', '214-555-3005', '1800 Manufacturing Way, Dallas, TX 75207', '75-4213985', 'Net 45', 15, 500, 'USD', 4.6),
('SilkRoute Fabrics', 'Raj Patel', 'raj@silkroutefabrics.com', '+91-98765-43210', '42 Textile Park, Mumbai, Maharashtra 400018, India', 'AADCS4374L', 'Net 60', 35, 1000, 'INR', 4.3),
('Denim Masters Inc', 'Carlos Mendez', 'cmendez@denimmasters.com', '919-555-3007', '450 Blue Jean Way, Greensboro, NC 27401', '56-9835421', 'Net 30', 21, 400, 'USD', 4.4),
('Cotton Fields Cooperative', 'Emma Barnes', 'ebarnes@cottonfields.org', '662-555-3008', '1200 Cotton Row, Greenwood, MS 38930', '64-1258793', 'Net 45', 18, 600, 'USD', 4.2),
('Far East Textiles Ltd', 'Lucy Wong', 'lwong@fareasttextiles.com', '+852-5123-4567', 'Block C, Industrial Estate, Kowloon, Hong Kong', 'HK82763451', 'Net 60', 28, 1200, 'HKD', 4.1),

-- Specialty Fabric Suppliers
('Performance Fabrics USA', 'Nathan Rodriguez', 'nrodriguez@pfusa.com', '305-555-3010', '8700 NW 36th St, Miami, FL 33178', '65-4218793', 'Net 30', 14, 300, 'USD', 4.7),
('Stretch Technologies', 'Olivia Wilson', 'owilson@stretchtech.com', '857-555-3011', '120 Innovation Dr, Cambridge, MA 02142', '04-8792165', 'Net 45', 12, 200, 'USD', 4.8),
('Organic Cotton Collective', 'David Greene', 'dgreene@organiccotton.org', '512-555-3012', '2500 Eco Way, Austin, TX 78704', '74-2589361', 'Net 30', 18, 250, 'USD', 4.9),
('LuxFabric Imports', 'Isabella Romano', 'iromano@luxfabric.com', '+39-0234-567890', 'Via della Seta 42, Milan, 20121, Italy', 'IT45678912345', 'Net 60', 32, 200, 'EUR', 4.6),
('TechWeave Materials', 'Alex Zhang', 'azhang@techweave.com', '408-555-3014', '1800 Innovation Way, San Jose, CA 95131', '94-1873526', 'Net 45', 14, 150, 'USD', 4.8),
('Sustainable Hemp Textiles', 'Maya Johnson', 'mjohnson@hemptext.com', '303-555-3015', '420 Green St, Boulder, CO 80301', '84-6532197', 'Net 30', 15, 200, 'USD', 4.5),
('Woolmark Australia', 'James Wilson', 'jwilson@woolmark.com.au', '+61-2-9876-5432', '45 Merino Road, Sydney, NSW 2000, Australia', 'AU67453298', 'Net 45', 35, 300, 'AUD', 4.7),
('Bamboo Fabric Collective', 'Leila Wong', 'lwong@bamboofabric.org', '808-555-3017', '245 Sustainable Way, Honolulu, HI 96815', '99-4651287', 'Net 30', 21, 200, 'USD', 4.4),
('Arctic Performance Materials', 'Erik Johansson', 'erik@arcticmaterials.com', '+46-8-1234-5678', 'Textilvägen 10, Stockholm, 11152, Sweden', 'SE556987123401', 'Net 60', 28, 250, 'SEK', 4.3),
('Recycled Poly Innovations', 'Carmen Diaz', 'cdiaz@recycledpoly.com', '206-555-3019', '1200 Green Manufacturing Dr, Seattle, WA 98108', '91-2765438', 'Net 45', 16, 400, 'USD', 4.6),

-- Trim and Accessory Suppliers
('Button & Zipper Supply Co', 'Henry Chang', 'hchang@buttonzipper.com', '312-555-3020', '1450 Fastener St, Chicago, IL 60607', '36-7584912', 'Net 30', 10, 1000, 'USD', 4.5),
('Global Trim Solutions', 'Nora Kim', 'nkim@globaltrim.com', '+82-2-3456-7890', '123 Accessory Blvd, Seoul, 04523, South Korea', 'KR10839562', 'Net 45', 24, 1500, 'KRW', 4.2),
('FastFit Closures Inc', 'Paul Roberts', 'proberts@fastfit.com', '704-555-3022', '850 Zipper Lane, Charlotte, NC 28208', '56-4327891', 'Net 30', 12, 500, 'USD', 4.4),
('Precision Thread & Cord', 'Laura Martinez', 'lmartinez@precisionthread.com', '617-555-3023', '75 Textile Row, Boston, MA 02210', '04-9876521', 'Net 30', 10, 200, 'USD', 4.7),
('EcoTrim Sustainable Materials', 'Ryan Green', 'rgreen@ecotrim.org', '415-555-3024', '890 Recycled Way, San Francisco, CA 94103', '94-5671832', 'Net 30', 14, 300, 'USD', 4.8),
('Fashion Hardware Ltd', 'Sophia Lee', 'slee@fashionhardware.com', '+852-2345-6789', 'Unit 1205, Fashion Centre, Kowloon, Hong Kong', 'HK76543210', 'Net 45', 21, 800, 'HKD', 4.3),
('Elite Embellishments', 'Victoria Taylor', 'vtaylor@eliteembellish.com', '323-555-3026', '8700 Beverly Blvd, Los Angeles, CA 90048', '95-3216748', 'Net 30', 14, 250, 'USD', 4.6),
('RivetKing Fasteners', 'Daniel Wang', 'dwang@rivetking.com', '+86-21-5432-1098', '888 Fastener Road, Shanghai, 200120, China', 'CN91827346', 'Net 60', 28, 2000, 'CNY', 4.1),
('Sustainable Labels Inc', 'Jennifer Morris', 'jmorris@sustainablelabels.com', '503-555-3028', '1200 Green Tag Way, Portland, OR 97204', '93-7654821', 'Net 30', 14, 1000, 'USD', 4.5),
('Premium Elastic & Webbing', 'Michael Torres', 'mtorres@premiumelastic.com', '212-555-3029', '299 7th Ave, New York, NY 10001', '13-4598761', 'Net 45', 12, 400, 'USD', 4.7),

-- Packaging Suppliers
('EcoPack Solutions', 'Grace Kim', 'gkim@ecopack.com', '206-555-3030', '1800 Green Package Rd, Seattle, WA 98108', '91-8762453', 'Net 30', 14, 1000, 'USD', 4.6),
('Premium Retail Packaging', 'Andrew Johnson', 'ajohnson@prempack.com', '212-555-3031', '550 Fashion Ave, New York, NY 10018', '13-7651489', 'Net 30', 10, 5000, 'USD', 4.5),
('Sustainable Packaging Co', 'Maria Rodriguez', 'mrodriguez@sustainpack.com', '510-555-3032', '2200 Eco Way, Oakland, CA 94607', '94-2357816', 'Net 45', 14, 2000, 'USD', 4.8),
('Global Box & Carton', 'Steve Wu', 'swu@globalbox.com', '+86-20-8765-4321', '123 Packaging District, Guangzhou, 510000, China', 'CN10293847', 'Net 60', 25, 10000, 'CNY', 4.2),
('PaperSource Sustainable', 'Rebecca Green', 'rgreen@papersource.org', '303-555-3034', '1650 Recycled Rd, Denver, CO 80205', '84-1593762', 'Net 30', 15, 3000, 'USD', 4.7),
('Clear Garment Bags Inc', 'Jason Lee', 'jlee@cleargarmentbags.com', '213-555-3035', '900 Plastic Way, Los Angeles, CA 90015', '95-4682713', 'Net 30', 10, 2500, 'USD', 4.3),
('Box & Tape Supply Co', 'Kevin Richards', 'krichards@boxtape.com', '404-555-3036', '2400 Package Blvd, Atlanta, GA 30318', '58-9761324', 'Net 30', 12, 1000, 'USD', 4.4),
('Premium Retail Display', 'Michelle Watson', 'mwatson@retaildisplay.com', '312-555-3037', '1200 Merchandising St, Chicago, IL 60607', '36-5987412', 'Net 45', 18, 100, 'USD', 4.6),
('GreenWrap Innovations', 'Derek Stone', 'dstone@greenwrap.com', '512-555-3038', '750 Sustainable Loop, Austin, TX 78701', '74-5132896', 'Net 30', 14, 500, 'USD', 4.5),
('Recycled Mailers Ltd', 'Tiffany Brooks', 'tbrooks@recycledmailers.com', '617-555-3039', '88 Green Shipping St, Boston, MA 02210', '04-8572163', 'Net 30', 10, 2000, 'USD', 4.7),

-- Manufacturing Equipment & Technology Suppliers
('ApparelTech Solutions', 'Raymond Chen', 'rchen@appareltech.com', '650-555-3040', '2300 Tech Drive, Palo Alto, CA 94304', '94-8763521', 'Net 60', 28, 1, 'USD', 4.8),
('SewPro Equipment', 'Diana Miller', 'dmiller@sewpro.com', '704-555-3041', '1500 Machine Way, Charlotte, NC 28206', '56-4378921', 'Net 60', 35, 1, 'USD', 4.7),
('Fabric Cutting Systems', 'Jeffrey Wang', 'jwang@fabriccutting.com', '+886-2-2345-6789', '123 Precision Road, Taipei, 10617, Taiwan', 'TW54321098', 'Net 45', 30, 1, 'TWD', 4.6),
('Automated Sewing Technologies', 'Natasha Brown', 'nbrown@autosew.com', '617-555-3043', '250 Innovation Park, Cambridge, MA 02142', '04-5893162', 'Net 60', 45, 1, 'USD', 4.5),
('Label & RFID Systems', 'Howard Lee', 'hlee@labelrfid.com', '310-555-3044', '900 Tech Plaza, Los Angeles, CA 90045', '95-1762843', 'Net 45', 21, 2, 'USD', 4.7),
('Industrial Thread Equipment', 'Christine Wang', 'cwang@threadequip.com', '+49-89-1234-5678', 'Industriestraße 45, Munich, 80939, Germany', 'DE345678912', 'Net 60', 45, 1, 'EUR', 4.4),
('Quality Control Tech', 'Brandon Harris', 'bharris@qctech.com', '415-555-3046', '330 Quality Drive, San Francisco, CA 94107', '94-3875612', 'Net 45', 28, 1, 'USD', 4.8),
('Distribution Automation', 'Patricia Martinez', 'pmartinez@distauto.com', '214-555-3047', '1800 Logistics Way, Dallas, TX 75247', '75-9871234', 'Net 60', 35, 1, 'USD', 4.6),
('Smart Inventory Systems', 'Eric Chang', 'echang@smartinventory.com', '206-555-3048', '2200 Tech Blvd, Seattle, WA 98109', '91-4587612', 'Net 60', 30, 1, 'USD', 4.9),
('Warehouse Robotics Inc', 'Susan Johnson', 'sjohnson@warehouserobotics.com', '408-555-3049', '1650 Automation Parkway, San Jose, CA 95131', '94-7651832', 'Net 60', 60, 1, 'USD', 4.7),

-- Raw Materials Suppliers
('Cotton Source Worldwide', 'George Wilson', 'gwilson@cottonsource.com', '662-555-3050', '800 Cotton Field Rd, Greenwood, MS 38930', '64-5876123', 'Net 45', 30, 500, 'USD', 4.5),
('EcoFiber Innovations', 'Lauren Chen', 'lchen@ecofiber.com', '415-555-3051', '550 Green Material St, San Francisco, CA 94103', '94-1267853', 'Net 30', 21, 400, 'USD', 4.9),
('Synthetic Fiber Technologies', 'David Park', 'dpark@synthfiber.com', '+82-51-987-6543', '456 Industrial Complex, Busan, 48060, South Korea', 'KR98765432', 'Net 45', 28, 1000, 'KRW', 4.3),
('Renewable Materials Co', 'Amanda Green', 'agreen@renewable.com', '503-555-3053', '1800 Sustainable Rd, Portland, OR 97201', '93-4578612', 'Net 30', 18, 300, 'USD', 4.8),
('Global Dye Solutions', 'Richard Thompson', 'rthompson@globaldye.com', '+91-22-3456-7890', '78 Chemical Zone, Mumbai, Maharashtra 400701, India', 'AAACG7890D', 'Net 60', 35, 100, 'INR', 4.2),
('Blue Ocean Buttons & Trims', 'Margaret Lee', 'mlee@blueoceanbt.com', '+86-574-1234-5678', '888 Fashion Hardware Zone, Ningbo, 315000, China', 'CN19283746', 'Net 45', 30, 5000, 'CNY', 4.0),
('ThreadWorks Intl', 'Peter Johnson', 'pjohnson@threadworks.com', '704-555-3056', '420 Yarn Way, Charlotte, NC 28205', '56-8142379', 'Net 30', 14, 200, 'USD', 4.6),
('Zippers & Fasteners Ltd', 'Nancy Chen', 'nchen@zipfast.com', '+886-4-2345-6789', '123 Hardware St, Taichung, 40764, Taiwan', 'TW12345678', 'Net 45', 21, 2000, 'TWD', 4.4),
('Natural Dye Collective', 'Mark Greenwood', 'mgreenwood@naturaldye.org', '808-555-3058', '78 Organic Way, Hilo, HI 96720', '99-3215487', 'Net 30', 28, 50, 'USD', 4.7),
('Recycled Metals & Hardware', 'Lisa King', 'lking@recycledmetals.com', '510-555-3059', '1200 Green Industrial Way, Oakland, CA 94607', '94-8721653', 'Net 45', 21, 300, 'USD', 4.5),

-- Specialty Product Suppliers
('Premium Denim Mills', 'Jonathan Davis', 'jdavis@premiumdenim.com', '213-555-3060', '900 Fashion District, Los Angeles, CA 90015', '95-1478236', 'Net 45', 21, 200, 'USD', 4.7),
('Luxury Knits Inc', 'Caroline Kim', 'ckim@luxuryknits.com', '+39-02-8765-4321', 'Via del Tessuto 34, Milan, 20129, Italy', 'IT12345678912', 'Net 60', 35, 100, 'EUR', 4.6),
('Heritage Wool & Cashmere', 'Robert Mackenzie', 'rmackenzie@heritagewool.com', '+44-20-7946-1234', '45 Textile Lane, Edinburgh, EH1 1TF, UK', 'GB123456789', 'Net 60', 28, 50, 'GBP', 4.8),
('Active Performance Textiles', 'Brandon Smith', 'bsmith@activeperformance.com', '303-555-3063', '2400 Sports Way, Boulder, CO 80301', '84-7359821', 'Net 45', 14, 150, 'USD', 4.5),
('Sleepwear Fabrics Ltd', 'Jessica Lee', 'jlee@sleepwearfabrics.com', '415-555-3064', '350 Comfort Ave, San Francisco, CA 94110', '94-3651872', 'Net 30', 16, 200, 'USD', 4.6),
('Kids & Baby Textiles', 'Emma Watson', 'ewatson@kidstextiles.com', '503-555-3065', '800 Gentle Touch Rd, Portland, OR 97205', '93-2581476', 'Net 30', 14, 100, 'USD', 4.9),
('OutdoorLife Fabrics', 'Tyler Johnson', 'tjohnson@outdoorlife.com', '206-555-3066', '1200 Adventure Way, Seattle, WA 98116', '91-3748265', 'Net 45', 21, 150, 'USD', 4.7),
('Beach & Swim Specialists', 'Nicole Martinez', 'nmartinez@beachswim.com', '305-555-3067', '950 Ocean Drive, Miami Beach, FL 33139', '65-8245973', 'Net 30', 16, 100, 'USD', 4.6),
('Workwear Durables', 'Craig Daniels', 'cdaniels@workweardurables.com', '214-555-3068', '1500 Industrial Blvd, Fort Worth, TX 76106', '75-4923186', 'Net 45', 21, 200, 'USD', 4.5),
('High Fashion Silks', 'Victoria Wang', 'vwang@fashionsilks.com', '+86-571-8765-4321', '777 Silk Road, Hangzhou, 310000, China', 'CN76543210', 'Net 60', 35, 50, 'CNY', 4.4),

-- Sustainable & Ethical Suppliers
('Fair Trade Textiles', 'Sophia Martinez', 'smartinez@fairtrade.org', '415-555-3070', '2200 Ethical Way, San Francisco, CA 94110', '94-7823156', 'Net 30', 28, 200, 'USD', 4.8),
('Organic Materials Alliance', 'Benjamin Green', 'bgreen@organicalliance.org', '206-555-3071', '800 Sustainable Ave, Seattle, WA 98122', '91-6352871', 'Net 45', 21, 150, 'USD', 4.9),
('Earth-Friendly Packaging', 'Olivia Johnson', 'ojohnson@earthpack.com', '303-555-3072', '1650 Green Way, Boulder, CO 80302', '84-1952376', 'Net 30', 14, 500, 'USD', 4.7),
('Ethical Production Network', 'Daniel Martinez', 'dmartinez@ethicalnetwork.org', '+91-80-2345-6789', '42 Fair Trade Zone, Bangalore, Karnataka, 560001, India', 'AABCE4567F', 'Net 60', 30, 100, 'INR', 4.5),
('Carbon-Neutral Materials', 'Laura Green', 'lgreen@carbonneutral.com', '503-555-3074', '900 Zero Impact Way, Portland, OR 97210', '93-7581642', 'Net 45', 21, 200, 'USD', 4.8),
('Upcycled Textile Co', 'Marcus Reed', 'mreed@upcycledtextile.com', '718-555-3075', '120 Reclaimed St, Brooklyn, NY 11211', '13-4598712', 'Net 30', 16, 100, 'USD', 4.6),
('Women-Owned Weaving Coop', 'Elena Vasquez', 'evasquez@womenweaving.org', '+52-222-345-6789', 'Calle Artesanal 45, Puebla, 72000, Mexico', 'MXVASE770513', 'Net 45', 28, 50, 'MXN', 4.7),
('Plastic-Free Packaging', 'Jeremy Stone', 'jstone@plasticfree.org', '510-555-3077', '350 Zero Waste Blvd, Berkeley, CA 94710', '94-6173582', 'Net 30', 14, 300, 'USD', 4.9),
('Indigenous Crafts Alliance', 'Maria Johnson', 'mjohnson@indigenouscrafts.org', '505-555-3078', '800 Heritage Way, Santa Fe, NM 87501', '85-1367254', 'Net 45', 28, 25, 'USD', 4.6),
('Certified B Corp Textiles', 'Thomas Green', 'tgreen@bcorptextiles.com', '802-555-3079', '1200 Sustainable Dr, Burlington, VT 05401', '03-4582716', 'Net 30', 21, 150, 'USD', 4.7),

-- Technology & Service Providers
('Retail Analytics Systems', 'Jennifer Park', 'jpark@retailanalytics.com', '650-555-3080', '2400 Data Drive, San Mateo, CA 94403', '94-5178632', 'Net 60', 15, 1, 'USD', 4.8),
('Inventory Management Solutions', 'Robert Chen', 'rchen@invmgmt.com', '408-555-3081', '1800 Software Pkwy, San Jose, CA 95134', '94-2638751', 'Net 45', 10, 1, 'USD', 4.7),
('Distribution Software Inc', 'Linda Wang', 'lwang@distsoftware.com', '425-555-3082', '750 Enterprise Way, Bellevue, WA 98007', '91-4832765', 'Net 60', 15, 1, 'USD', 4.6),
('Supply Chain Analytics', 'David Miller', 'dmiller@scanalytics.com', '312-555-3083', '900 Logistics Plaza, Chicago, IL 60654', '36-8547123', 'Net 60', 21, 1, 'USD', 4.9),
('Retail POS Systems', 'Karen Johnson', 'kjohnson@retailpos.com', '214-555-3084', '1650 Tech Blvd, Dallas, TX 75207', '75-3614829', 'Net 45', 14, 1, 'USD', 4.5),
('E-commerce Platform Solutions', 'Jason Lee', 'jlee@ecommsolutions.com', '415-555-3085', '580 Market St, San Francisco, CA 94104', '94-7158236', 'Net 60', 15, 1, 'USD', 4.7),
('Cloud Retail Management', 'Michael Zhang', 'mzhang@cloudretail.com', '212-555-3086', '350 5th Ave, New York, NY 10118', '13-5876142', 'Net 60', 10, 1, 'USD', 4.8),
('Customer Analytics Inc', 'Stephanie Wilson', 'swilson@custanalytics.com', '206-555-3087', '1200 Data Way, Seattle, WA 98109', '91-5823674', 'Net 45', 14, 1, 'USD', 4.6),
('Retail Marketing Systems', 'Christopher Davis', 'cdavis@retailmarketing.com', '310-555-3088', '8400 Wilshire Blvd, Beverly Hills, CA 90211', '95-4631872', 'Net 60', 21, 1, 'USD', 4.7),
('Payment Processing Solutions', 'Elizabeth Mendez', 'emendez@paymentsol.com', '617-555-3089', '200 State St, Boston, MA 02109', '04-7865132', 'Net 45', 7, 1, 'USD', 4.9);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Commit transaction to save data
COMMIT;

-- End of 02_p2v2.sql
-- Next file to be executed: 03_dependent_tables.sql