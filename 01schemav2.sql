-- GAP Retail Database Schema (v2) --
-- Enhanced version with support for new use cases
-- Generated for: mkol21 | Generated on: 2025-04-06 06:05:37

DROP DATABASE IF EXISTS GapDBase;
CREATE DATABASE IF NOT EXISTS gapdbase;
USE gapdbase;

-- Independent entity tables first (no foreign key dependencies)

CREATE TABLE categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    CategoryDescription TEXT,
    ParentCategoryID INT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category_name (CategoryName)
) ENGINE=InnoDB;

-- Add self-reference after table creation to avoid initialization issues
ALTER TABLE categories 
ADD CONSTRAINT fk_parent_category 
FOREIGN KEY (ParentCategoryID) REFERENCES categories(CategoryID)
ON DELETE SET NULL;

CREATE TABLE payment_methods (
    PaymentMethodID INT AUTO_INCREMENT PRIMARY KEY,
    MethodName VARCHAR(50) NOT NULL UNIQUE,
    IsActive BOOLEAN DEFAULT TRUE,
    ProcessingFee DECIMAL(4,2),
    PaymentGateway VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE payment_status (
    StatusID INT AUTO_INCREMENT PRIMARY KEY,
    StatusName VARCHAR(50) NOT NULL UNIQUE,
    StatusDescription TEXT,
    IsSystemStatus BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE warehouses (
    WarehouseID INT AUTO_INCREMENT PRIMARY KEY,
    WarehouseName VARCHAR(100) NOT NULL,
    WarehouseLocation VARCHAR(255) NOT NULL,
    WarehouseCapacity INT,
    IsActive BOOLEAN DEFAULT TRUE,
    ContactPhone VARCHAR(20),
    ContactEmail VARCHAR(100),
    OperatingHours VARCHAR(100),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_warehouse_location (WarehouseLocation)
) ENGINE=InnoDB;

CREATE TABLE stores (
    StoreID INT AUTO_INCREMENT PRIMARY KEY,
    StoreName VARCHAR(100) NOT NULL,
    Location VARCHAR(255) NOT NULL,
    StorePhone VARCHAR(20),
    StoreEmail VARCHAR(100),
    ManagerName VARCHAR(100),
    OperatingHours VARCHAR(100),
    StoreSize INT,
    IsActive BOOLEAN DEFAULT TRUE,
    SupportsPickup BOOLEAN DEFAULT TRUE,
    RegionID INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_store_location (Location),
    INDEX idx_store_region (RegionID)
) ENGINE=InnoDB;

CREATE TABLE customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20),
    DateJoined DATE NOT NULL DEFAULT (CURRENT_DATE),
    DateOfBirth DATE,
    Gender VARCHAR(20),
    PreferredLanguage VARCHAR(10) DEFAULT 'en',
    MarketingPreferences JSON,
    LastLoginDate TIMESTAMP,
    IsActive BOOLEAN DEFAULT TRUE,
    IsFirstTimeBuyer BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_email (Email),
    INDEX idx_customer_name (LastName, FirstName),
    INDEX idx_customer_phone (Phone),
    INDEX idx_first_time_buyer (IsFirstTimeBuyer)
) ENGINE=InnoDB;

CREATE TABLE suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(100) NOT NULL,
    ContactPhone VARCHAR(20),
    Address VARCHAR(255) NOT NULL,
    TaxID VARCHAR(50),
    PaymentTerms VARCHAR(100),
    LeadTimeDays INT,
    MinimumOrderQuantity INT,
    PreferredCurrency CHAR(3) DEFAULT 'USD',
    IsActive BOOLEAN DEFAULT TRUE,
    SupplierRating DECIMAL(3,2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_supplier_email (ContactEmail),
    INDEX idx_supplier_name (SupplierName)
) ENGINE=InnoDB;

-- Dependent entity tables (dependent on tables above)

CREATE TABLE addresses (
    AddressID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    AddressLine1 VARCHAR(100) NOT NULL,
    AddressLine2 VARCHAR(100),
    City VARCHAR(100) NOT NULL,
    StateProvince VARCHAR(50) NOT NULL,
    PostalCode VARCHAR(20) NOT NULL,
    Country VARCHAR(50) NOT NULL DEFAULT 'USA',
    IsDefaultShipping BOOLEAN DEFAULT FALSE,
    IsDefaultBilling BOOLEAN DEFAULT FALSE,
    AddressType ENUM('HOME', 'BUSINESS', 'SHIPPING', 'BILLING') NOT NULL,
    IsVerified BOOLEAN DEFAULT FALSE,
    VerificationDate TIMESTAMP NULL,
    VerificationMethod VARCHAR(50),
    VerificationNotes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    INDEX idx_customer_address (CustomerID),
    INDEX idx_address_type (AddressType),
    INDEX idx_postal_code (PostalCode),
    INDEX idx_address_verified (IsVerified)
) ENGINE=InnoDB;

CREATE TABLE loyalty_accounts (
    LoyaltyAccountID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL UNIQUE,
    PointsBalance INT DEFAULT 0,
    TierLevel ENUM('Core', 'Enthusiast', 'Icon') DEFAULT 'Core',
    TierStartDate DATE,
    TierEndDate DATE,
    LifetimePoints INT DEFAULT 0,
    TierUpgradeEligibleDate DATE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    INDEX idx_tier_level (TierLevel)
) ENGINE=InnoDB;

CREATE TABLE products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    ProductDescription TEXT,
    Brand VARCHAR(50) NOT NULL DEFAULT 'GAP',
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,
    ProductLifecycleStatus ENUM('Draft', 'Active', 'Discontinued', 'Seasonal') DEFAULT 'Active',
    MSRP DECIMAL(10,2) NOT NULL,
    StandardCost DECIMAL(10,2) NOT NULL,
    Weight DECIMAL(6,2),
    Dimensions VARCHAR(50),
    SeasonYear INT,
    SeasonName VARCHAR(20),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CategoryID) REFERENCES categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES suppliers(SupplierID),
    INDEX idx_product_lifecycle (ProductLifecycleStatus),
    INDEX idx_product_name (ProductName),
    INDEX idx_product_brand (Brand),
    CONSTRAINT chk_product_prices CHECK (MSRP >= 0 AND StandardCost >= 0)
) ENGINE=InnoDB;

CREATE TABLE promotions (
    PromotionID INT AUTO_INCREMENT PRIMARY KEY,
    PromotionName VARCHAR(100) NOT NULL,
    PromotionCode VARCHAR(20) UNIQUE,
    Description TEXT,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NOT NULL,
    DiscountType ENUM('PERCENTAGE', 'FIXED_AMOUNT', 'BUY_X_GET_Y', 'BUNDLE') NOT NULL,
    DiscountValue DECIMAL(10,2) NOT NULL,
    MinimumPurchase DECIMAL(10,2),
    MaximumDiscount DECIMAL(10,2),
    UsageLimit INT,
    UsageCount INT DEFAULT 0,
    IsStackable BOOLEAN DEFAULT FALSE,
    IsActive BOOLEAN DEFAULT TRUE,
    IsFirstTimePurchaseOnly BOOLEAN DEFAULT FALSE,
    ApplicableProducts JSON,
    ExcludedProducts JSON,
    TargetCustomerSegment VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_promotion_dates CHECK (EndDate > StartDate),
    CONSTRAINT chk_discount_value CHECK (DiscountValue > 0),
    INDEX idx_promotion_dates (StartDate, EndDate),
    INDEX idx_promotion_code (PromotionCode),
    INDEX idx_promotion_active (IsActive),
    INDEX idx_first_time_purchase (IsFirstTimePurchaseOnly)
) ENGINE=InnoDB;

CREATE TABLE shopping_cart (
    CartID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    INDEX idx_customer_cart (CustomerID)
) ENGINE=InnoDB;

CREATE TABLE product_variants (
    VariantID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    SKU VARCHAR(50) NOT NULL UNIQUE,
    Color VARCHAR(50),
    Size VARCHAR(20),
    VariantPrice DECIMAL(10,2) NOT NULL,
    VariantImageURI VARCHAR(255),
    StockLevel INT DEFAULT 0,
    LowStockThreshold INT DEFAULT 10,
    Weight DECIMAL(6,2),
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES products(ProductID),
    INDEX idx_variant_sku (SKU),
    INDEX idx_variant_details (Color, Size),
    CONSTRAINT chk_variant_price CHECK (VariantPrice >= 0)
) ENGINE=InnoDB;

CREATE TABLE orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    OrderStatus ENUM('Pending', 'Processing', 'Ready for Pickup', 'Picked Up', 'Shipped', 'Delivered', 'Cancelled', 'Returned') NOT NULL DEFAULT 'Pending',
    ShippingAddressID INT NOT NULL,
    BillingAddressID INT NOT NULL,
    SubTotal DECIMAL(10,2) NOT NULL,
    TaxAmount DECIMAL(10,2) NOT NULL,
    ShippingAmount DECIMAL(10,2) NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    IsFirstTimePurchase BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    FOREIGN KEY (ShippingAddressID) REFERENCES addresses(AddressID),
    FOREIGN KEY (BillingAddressID) REFERENCES addresses(AddressID),
    INDEX idx_customer_order (CustomerID),
    INDEX idx_order_status (OrderStatus),
    INDEX idx_order_date (OrderDate),
    INDEX idx_first_purchase (IsFirstTimePurchase),
    CONSTRAINT chk_order_amounts CHECK (SubTotal >= 0 AND TaxAmount >= 0 AND ShippingAmount >= 0 AND TotalAmount >= 0)
) ENGINE=InnoDB;

-- Many-to-Many relationship tables and dependent tables

CREATE TABLE product_categories (
    ProductCategoryID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    CategoryID INT NOT NULL,
    IsPrimary BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES products(ProductID),
    FOREIGN KEY (CategoryID) REFERENCES categories(CategoryID),
    UNIQUE KEY uk_product_category (ProductID, CategoryID)
) ENGINE=InnoDB;

CREATE TABLE shopping_cart_items (
    CartItemID INT AUTO_INCREMENT PRIMARY KEY,
    CartID INT NOT NULL,
    ProductVariantID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CartID) REFERENCES shopping_cart(CartID),
    FOREIGN KEY (ProductVariantID) REFERENCES product_variants(VariantID),
    CONSTRAINT chk_cart_quantity CHECK (Quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE inventory_levels (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    SKU VARCHAR(50) NOT NULL,
    WarehouseID INT NULL,
    StoreID INT NULL,
    LocationType ENUM('Store', 'Warehouse') NOT NULL,
    QuantityOnHand INT NOT NULL DEFAULT 0,
    ReservedForPickup INT DEFAULT 0,
    PickupReservationExpiry TIMESTAMP NULL,
    ReorderPoint INT NOT NULL DEFAULT 10,
    LastStockCheckDate TIMESTAMP,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (WarehouseID) REFERENCES warehouses(WarehouseID),
    FOREIGN KEY (StoreID) REFERENCES stores(StoreID),
    FOREIGN KEY (SKU) REFERENCES product_variants(SKU),
    INDEX idx_inventory_sku (SKU),
    INDEX idx_inventory_location (LocationType, WarehouseID, StoreID),
    INDEX idx_inventory_quantity (QuantityOnHand),
    CONSTRAINT chk_location CHECK (
        (WarehouseID IS NULL AND StoreID IS NOT NULL AND LocationType = 'Store') OR
        (WarehouseID IS NOT NULL AND StoreID IS NULL AND LocationType = 'Warehouse')
    ),
    CONSTRAINT chk_quantity CHECK (QuantityOnHand >= 0 AND ReservedForPickup >= 0)
) ENGINE=InnoDB;

CREATE TABLE warehouse_stock_transfer (
    TransferID INT AUTO_INCREMENT PRIMARY KEY,
    FromWarehouseID INT NOT NULL,
    ToWarehouseID INT NOT NULL,
    SKU VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    TransferStatus ENUM('Pending', 'In Transit', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Pending',
    RequestedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CompletedDate TIMESTAMP NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (FromWarehouseID) REFERENCES warehouses(WarehouseID),
    FOREIGN KEY (ToWarehouseID) REFERENCES warehouses(WarehouseID),
    FOREIGN KEY (SKU) REFERENCES product_variants(SKU),
    INDEX idx_transfer_status (TransferStatus),
    INDEX idx_transfer_sku (SKU),
    CONSTRAINT chk_transfer_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_different_warehouses CHECK (FromWarehouseID != ToWarehouseID)
) ENGINE=InnoDB;

CREATE TABLE store_inventory_replenishment (
    ReplenishmentID INT AUTO_INCREMENT PRIMARY KEY,
    StoreID INT NOT NULL,
    WarehouseID INT NOT NULL,
    SKU VARCHAR(50) NOT NULL,
    RequestedQuantity INT NOT NULL,
    IsForPickupReserve BOOLEAN DEFAULT FALSE,
    ReplenishmentStatus ENUM('Requested', 'Processing', 'Shipped', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Requested',
    RequestedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CompletedDate TIMESTAMP NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (StoreID) REFERENCES stores(StoreID),
    FOREIGN KEY (WarehouseID) REFERENCES warehouses(WarehouseID),
    FOREIGN KEY (SKU) REFERENCES product_variants(SKU),
    INDEX idx_replenishment_status (ReplenishmentStatus),
    INDEX idx_replenishment_sku (SKU),
    CONSTRAINT chk_replenishment_quantity CHECK (RequestedQuantity > 0)
) ENGINE=InnoDB;

-- Order processing tables that depend on orders table

CREATE TABLE order_items (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductVariantID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    SubTotal DECIMAL(10,2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (ProductVariantID) REFERENCES product_variants(VariantID),
    INDEX idx_order_items (OrderID, ProductVariantID),
    CONSTRAINT chk_orderitem_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_orderitem_price CHECK (UnitPrice >= 0 AND SubTotal >= 0)
) ENGINE=InnoDB;

CREATE TABLE payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentMethodID INT NOT NULL,
    PaymentStatusID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    TransactionDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TransactionReference VARCHAR(100),
    PaymentAttempts INT DEFAULT 1,
    LastPaymentAttemptDate TIMESTAMP NULL,
    FailureReason VARCHAR(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (PaymentMethodID) REFERENCES payment_methods(PaymentMethodID),
    FOREIGN KEY (PaymentStatusID) REFERENCES payment_status(StatusID),
    INDEX idx_payment_order (OrderID),
    INDEX idx_payment_transaction (TransactionReference),
    INDEX idx_payment_attempts (PaymentAttempts),
    CONSTRAINT chk_payment_amount CHECK (Amount > 0)
) ENGINE=InnoDB;

CREATE TABLE shipments (
    ShipmentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ShipmentType ENUM('Standard Shipping', 'Express Shipping', 'Store Pickup') NOT NULL DEFAULT 'Standard Shipping',
    ShipmentStatus ENUM('Processing', 'Shipped', 'In Transit', 'Delivered', 'Ready for Pickup', 'Picked Up', 'Failed', 'Address Issue') NOT NULL DEFAULT 'Processing',
    TrackingNumber VARCHAR(100),
    ShippingCarrier VARCHAR(50),
    ShippedDate TIMESTAMP NULL,
    EstimatedDeliveryDate TIMESTAMP NULL,
    ActualDeliveryDate TIMESTAMP NULL,
    PickupDate TIMESTAMP NULL,
    PickupStoreID INT NULL,
    ShippingAddressVerified BOOLEAN DEFAULT FALSE,
    DeliveryAttempts INT DEFAULT 0,
    DeliveryNotes TEXT,
    LastAttemptDate TIMESTAMP NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (PickupStoreID) REFERENCES stores(StoreID),
    INDEX idx_shipment_order (OrderID),
    INDEX idx_shipment_tracking (TrackingNumber),
    INDEX idx_shipment_pickup (ShipmentType, PickupStoreID),
    INDEX idx_shipment_verified (ShippingAddressVerified),
    INDEX idx_delivery_attempts (DeliveryAttempts),
    CONSTRAINT chk_pickup_store CHECK (
        (ShipmentType = 'Store Pickup' AND PickupStoreID IS NOT NULL) OR
        (ShipmentType != 'Store Pickup')
    )
) ENGINE=InnoDB;

CREATE TABLE returns (
    ReturnID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ReturnStatus ENUM('Requested', 'Approved', 'Received', 'Processed', 'Refunded', 'Rejected') NOT NULL DEFAULT 'Requested',
    ReturnReason TEXT NOT NULL,
    ReturnDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    RefundAmount DECIMAL(10,2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    INDEX idx_return_order (OrderID),
    INDEX idx_return_status (ReturnStatus),
    CONSTRAINT chk_refund_amount CHECK (RefundAmount IS NULL OR RefundAmount >= 0)
) ENGINE=InnoDB;

CREATE TABLE shipment_items (
    ShipmentItemID INT AUTO_INCREMENT PRIMARY KEY,
    ShipmentID INT NOT NULL,
    OrderItemID INT NOT NULL,
    Quantity INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ShipmentID) REFERENCES shipments(ShipmentID),
    FOREIGN KEY (OrderItemID) REFERENCES order_items(OrderItemID),
    CONSTRAINT chk_shipitem_quantity CHECK (Quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE return_items (
    ReturnItemID INT AUTO_INCREMENT PRIMARY KEY,
    ReturnID INT NOT NULL,
    OrderItemID INT NOT NULL,
    Quantity INT NOT NULL,
    ReturnReason TEXT NOT NULL,
    ItemCondition VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ReturnID) REFERENCES returns(ReturnID),
    FOREIGN KEY (OrderItemID) REFERENCES order_items(OrderItemID),
    CONSTRAINT chk_returnitem_quantity CHECK (Quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE supplier_orders (
    SupplierOrderID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierID INT NOT NULL,
    OrderDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ExpectedDeliveryDate TIMESTAMP NULL,
    OrderStatus ENUM('Draft', 'Submitted', 'Confirmed', 'Shipped', 'Received', 'Cancelled') NOT NULL DEFAULT 'Draft',
    TotalAmount DECIMAL(10,2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (SupplierID) REFERENCES suppliers(SupplierID),
    INDEX idx_supplierorder_status (OrderStatus),
    CONSTRAINT chk_supplierorder_amount CHECK (TotalAmount >= 0)
) ENGINE=InnoDB;

CREATE TABLE supplier_order_items (
    SupplierOrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitCost DECIMAL(10,2) NOT NULL,
    TotalCost DECIMAL(10,2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (SupplierOrderID) REFERENCES supplier_orders(SupplierOrderID),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID),
    CONSTRAINT chk_supplieritem_quantity CHECK (Quantity > 0),
    CONSTRAINT chk_supplieritem_cost CHECK (UnitCost >= 0 AND TotalCost >= 0)
) ENGINE=InnoDB;

CREATE TABLE promotion_application (
    ApplicationID INT AUTO_INCREMENT PRIMARY KEY,
    PromotionID INT NOT NULL,
    OrderID INT NOT NULL,
    DiscountAmount DECIMAL(10,2) NOT NULL,
    IsEligible BOOLEAN DEFAULT TRUE,
    AppliedReason VARCHAR(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PromotionID) REFERENCES promotions(PromotionID),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    CONSTRAINT chk_promo_discount CHECK (DiscountAmount >= 0)
) ENGINE=InnoDB;

CREATE TABLE order_promotions (
    OrderPromotionID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    PromotionID INT NOT NULL,
    DiscountAmount DECIMAL(10,2) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (PromotionID) REFERENCES promotions(PromotionID),
    CONSTRAINT chk_orderpromo_discount CHECK (DiscountAmount >= 0)
) ENGINE=InnoDB;

-- Analytics tables

CREATE TABLE sales_analytics (
    AnalyticsID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    CustomerID INT NOT NULL,
    OrderTotal DECIMAL(10,2) NOT NULL,
    ShipmentType ENUM('Standard Shipping', 'Express Shipping', 'Store Pickup'),
    OrderDate TIMESTAMP NOT NULL,
    ProductCategories JSON,
    PromotionsApplied JSON,
    PaymentMethod VARCHAR(50),
    IsFirstTimePurchase BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    INDEX idx_analytics_date (OrderDate),
    INDEX idx_analytics_customer (CustomerID),
    INDEX idx_analytics_shipment (ShipmentType),
    INDEX idx_analytics_first_purchase (IsFirstTimePurchase)
) ENGINE=InnoDB;

CREATE TABLE order_tracking (
    TrackingID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    Status ENUM('Pending', 'Processing', 'Ready for Pickup', 'Picked Up', 'Shipped', 'Delivered', 'Cancelled', 'Returned') NOT NULL,
    StatusTimestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    INDEX idx_tracking_order (OrderID),
    INDEX idx_tracking_status (Status)
) ENGINE=InnoDB;

