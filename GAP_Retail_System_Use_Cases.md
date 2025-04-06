# GAP Retail Database System

# Use Case Documentation

**Version:** 1.0  
**Date Created:** 2025-04-06  
**Author:** mkol21  
**Last Updated:** 2025-04-06 07:15:10  

---

# Table of Contents

1. [UC-001: Order Processing with Store Pickup](#uc-001-order-processing-with-store-pickup)
2. [UC-002: Online Order with Home Delivery](#uc-002-online-order-with-home-delivery)
3. [UC-003: Product Return Processing](#uc-003-product-return-processing)
4. [UC-004: Inventory Management and Replenishment](#uc-004-inventory-management-and-replenishment)
5. [UC-005: Customer Loyalty Program Management](#uc-005-customer-loyalty-program-management)
6. [UC-006: Promotional Campaign Management](#uc-006-promotional-campaign-management)
7. [UC-007: Sales Analytics and Reporting](#uc-007-sales-analytics-and-reporting)

---

# UC-001: Order Processing with Store Pickup

**Use Case ID:** UC-001  
**Version:** 1.0  
**Date Created:** 2025-04-06  

## 1. Description

This use case describes the process of a customer placing an order through the GAP retail system and selecting store pickup as the delivery method. It covers the entire process flow from order creation through inventory verification, payment processing, and order fulfillment at the store location.

## 2. Actors

### 2.1 Primary Actor
- Customer

### 2.2 Secondary Actors
- Customer Service Representative
- Store Associate
- Store Manager
- Inventory System
- Payment Processing System

## 3. Preconditions

1. Customer has an active account in the system (exists in the `customers` table)
2. Customer has at least one address registered (exists in the `addresses` table)
3. Products are available in inventory (verified in `inventory_levels` table)
4. Store supports pickup option (verified by `SupportsPickup` in `stores` table)

## 4. Trigger

Customer initiates checkout process and selects "Store Pickup" as the delivery method

## 5. Main Flow

1. Customer adds products to shopping cart
   - System creates/updates record in `shopping_cart` table
   - System adds/updates items in `shopping_cart_items` table

2. Customer proceeds to checkout and selects "Store Pickup" option
   - Customer selects preferred store location from list of stores where `SupportsPickup = TRUE`
   - System verifies product availability at selected store using `inventory_levels` table

3. System checks inventory availability
   - If items are available at selected store:
     - System reserves the items by updating `ReservedForPickup` in `inventory_levels` table
     - System sets `PickupReservationExpiry` timestamp
   - If items are not available at selected store:
     - System initiates store replenishment request (see Alternative Flow 1)

4. Customer provides payment information
   - System creates a new record in `orders` table with `OrderStatus = 'Pending'`
   - System creates corresponding entries in `order_items` table
   - System sets `ShipmentType = 'Store Pickup'` in `shipments` table
   - System processes payment through the `payments` table

5. System confirms order
   - Updates `OrderStatus` to 'Processing' in `orders` table
   - Creates record in `shipments` table with `ShipmentType = 'Store Pickup'` and `ShipmentStatus = 'Processing'`
   - Associates the store ID with `PickupStoreID` in the shipment record
   - Creates entries in `shipment_items` table linking to `order_items`
   - Updates `orders`.`IsFirstTimePurchase` if applicable

6. Store prepares order for pickup
   - System updates `ShipmentStatus` to 'Ready for Pickup' in `shipments` table
   - System updates `OrderStatus` to 'Ready for Pickup' in `orders` table
   - System creates entry in `order_tracking` table
   - System notifies customer that order is ready for pickup

7. Customer arrives at store and presents order confirmation
   - Store associate locates order using order ID
   - Store associate verifies customer identity
   - Store associate marks order as picked up in system
   - System updates `ShipmentStatus` to 'Picked Up' in `shipments` table
   - System updates `OrderStatus` to 'Picked Up' in `orders` table
   - System records `PickupDate` in `shipments` table
   - System creates entry in `order_tracking` table
   - System updates `inventory_levels` table by decreasing `QuantityOnHand` and clearing `ReservedForPickup`

8. System processes loyalty points if applicable
   - If customer has loyalty account, system updates `PointsBalance` and `LifetimePoints` in `loyalty_accounts` table
   - System evaluates for potential tier upgrade based on updated points

9. System updates analytics
   - Creates record in `sales_analytics` table with `ShipmentType = 'Store Pickup'`

## 6. Alternative Flows

### 6.1 Alternative Flow 1: Store Replenishment Required
1a. If requested items are not available at selected store:
   - System checks warehouse inventory using `inventory_levels` table
   - If available in warehouse, system creates entry in `store_inventory_replenishment` table
   - System sets `IsForPickupReserve = TRUE` and `ReplenishmentStatus = 'Requested'`
   - System notifies customer of potential delay
   - Order remains in 'Processing' status until items are transferred to store
   - Process resumes at step 6 after items arrive at store

### 6.2 Alternative Flow 2: Payment Failure
4a. If payment processing fails:
   - System records failed attempt in `payments` table with appropriate `PaymentStatusID`
   - System increments `PaymentAttempts` counter
   - System releases reserved inventory by updating `inventory_levels` table
   - Customer is prompted to provide alternative payment method
   - If successful, main flow resumes at step 5
   - If unsuccessful after 3 attempts, order is canceled

### 6.3 Alternative Flow 3: Customer Doesn't Pick Up Order
7a. If customer doesn't pick up order within 7 days:
   - System sends reminder notification
   - If still not picked up after 3 days of reminder:
     - System updates `ShipmentStatus` to 'Cancelled' in `shipments` table
     - System updates `OrderStatus` to 'Cancelled' in `orders` table
     - System releases reserved inventory
     - If payment was processed, system initiates refund process
     - System creates appropriate entries in `order_tracking` table

## 7. Postconditions

1. Order is successfully fulfilled and marked as picked up
2. Inventory is accurately updated
3. Payment is successfully processed
4. Loyalty points are awarded if applicable
5. Analytics data is captured for reporting
6. Customer is able to initiate a return if needed

## 8. Business Rules

1. Inventory reservation expires after 24 hours if order is not confirmed
2. Store pickup orders must be picked up within 7 days
3. Customer must present valid ID matching the order information
4. Loyalty points are calculated as 1 point per $1 spent
5. First-time purchases receive double loyalty points
6. Orders marked as "Store Pickup" incur no shipping charges
7. Promotional discounts must be applied before order confirmation
8. Order status must follow proper sequence: Pending → Processing → Ready for Pickup → Picked Up
9. If any item in an order becomes unavailable, the entire order is held until replenishment

## 9. Technical Requirements

1. Integration with inventory management system for real-time stock verification
2. Integration with payment processing gateway
3. Secure customer identification verification process
4. Notification system for order status updates
5. Automatic inventory reservation timeout processing
6. Store-level inventory management system integration

## 10. Database Entities and Relationships

| Entity | Relationship | Description |
|--------|-------------|-------------|
| `customers` | Primary | Stores customer profile information |
| `shopping_cart` | 1:1 with customers | Contains active shopping cart for each customer |
| `shopping_cart_items` | M:1 with shopping_cart | Contains items in a customer's cart |
| `orders` | M:1 with customers | Stores order header information |
| `order_items` | M:1 with orders | Contains items within each order |
| `shipments` | M:1 with orders | Tracks shipment/pickup information |
| `shipment_items` | M:1 with shipments, 1:1 with order_items | Links shipments to order items |
| `payments` | M:1 with orders | Records payment transactions |
| `stores` | Referenced by shipments | Contains store location information |
| `inventory_levels` | M:1 with stores | Tracks inventory at store locations |
| `order_tracking` | M:1 with orders | Records status changes in order processing |
| `loyalty_accounts` | 1:1 with customers | Manages customer loyalty program |
| `store_inventory_replenishment` | M:1 with stores | Manages store inventory requests |

---

# UC-002: Online Order with Home Delivery

**Use Case ID:** UC-002  
**Version:** 1.0  
**Date Created:** 2025-04-06  

## 1. Description

This use case describes the process of a customer placing an online order through the GAP retail system and selecting home delivery. It covers the entire process flow from order creation through inventory verification, payment processing, shipment creation, and delivery tracking.

## 2. Actors

### 2.1 Primary Actor
- Customer

### 2.2 Secondary Actors
- Warehouse Staff
- Shipping Carrier
- Payment Processing System
- Inventory System
- Customer Service Representative

## 3. Preconditions

1. Customer has an active account in the system (exists in the `customers` table)
2. Customer has at least one shipping address registered (exists in the `addresses` table)
3. Products are available in inventory (verified in `inventory_levels` table)
4. Shipping carrier services are operational

## 4. Trigger

Customer initiates checkout process and selects "Home Delivery" as the delivery method

## 5. Main Flow

1. Customer adds products to shopping cart
   - System creates/updates record in `shopping_cart` table
   - System adds/updates items in `shopping_cart_items` table

2. Customer proceeds to checkout and selects "Home Delivery" option
   - Customer selects shipping address from list or enters a new address
   - If new address, system adds entry to `addresses` table
   - Customer selects shipping method (Standard or Express)
   - System calculates shipping cost based on items, destination, and shipping method

3. System checks warehouse inventory availability
   - System queries `inventory_levels` table with `LocationType = 'Warehouse'`
   - If items are available:
     - System reserves the inventory for the order
   - If items are not available:
     - System notifies customer of back-order status and estimated availability
     - Customer can choose to continue or modify order

4. Customer provides payment information
   - System creates a new record in `orders` table with `OrderStatus = 'Pending'`
   - System creates corresponding entries in `order_items` table
   - System calculates order total including tax and shipping
   - System processes payment through the `payments` table

5. System confirms order
   - Updates `OrderStatus` to 'Processing' in `orders` table
   - Creates record in `shipments` table with `ShipmentType` based on selected shipping method
   - Creates entries in `shipment_items` table linking to `order_items`
   - Updates `orders`.`IsFirstTimePurchase` if applicable

6. Warehouse processes order
   - Warehouse staff collects items
   - Items are packaged for shipment
   - System updates `ShipmentStatus` to 'Shipped' in `shipments` table
   - System updates `OrderStatus` to 'Shipped' in `orders` table
   - System records `ShippedDate` in `shipments` table
   - System creates entry in `order_tracking` table
   - System updates `inventory_levels` table by decreasing `QuantityOnHand`

7. Shipping carrier processes delivery
   - System assigns tracking number and shipping carrier information
   - System updates `TrackingNumber` and `ShippingCarrier` in `shipments` table
   - System calculates and updates `EstimatedDeliveryDate`
   - System notifies customer of shipment with tracking information

8. Delivery status is tracked
   - System receives updates from shipping carrier
   - System updates `ShipmentStatus` in `shipments` table
   - System creates entries in `order_tracking` table for significant status changes
   - System notifies customer of status changes

9. Order is delivered
   - System receives delivery confirmation from shipping carrier
   - System updates `ShipmentStatus` to 'Delivered' in `shipments` table
   - System updates `OrderStatus` to 'Delivered' in `orders` table
   - System records `ActualDeliveryDate` in `shipments` table
   - System creates entry in `order_tracking` table

10. System processes loyalty points if applicable
    - If customer has loyalty account, system updates `PointsBalance` and `LifetimePoints` in `loyalty_accounts` table
    - System evaluates for potential tier upgrade based on updated points

11. System updates analytics
    - Creates record in `sales_analytics` table with appropriate `ShipmentType`

## 6. Alternative Flows

### 6.1 Alternative Flow 1: Partial Inventory Availability
3a. If not all items are available in the warehouse:
   - System identifies which items are available and which are not
   - System offers customer options:
     - Wait for all items to become available
     - Proceed with available items only
     - Cancel order
   - If customer chooses to proceed with available items:
     - System updates order to include only available items
     - Main flow resumes at step 4

### 6.2 Alternative Flow 2: Payment Failure
4a. If payment processing fails:
   - System records failed attempt in `payments` table with appropriate `PaymentStatusID`
   - System increments `PaymentAttempts` counter
   - System releases reserved inventory
   - Customer is prompted to provide alternative payment method
   - If successful, main flow resumes at step 5
   - If unsuccessful after 3 attempts, order is canceled

### 6.3 Alternative Flow 3: Shipping Address Verification Failure
2a. If the shipping address cannot be verified:
   - System marks address as unverified (`IsVerified = FALSE` in `addresses` table)
   - System prompts customer to review and correct address
   - If address is corrected and verified, main flow resumes
   - If address cannot be verified after 3 attempts, customer is advised to contact customer service

### 6.4 Alternative Flow 4: Delivery Failure
9a. If delivery attempt fails:
   - System updates `ShipmentStatus` to reflect failed delivery
   - System increments `DeliveryAttempts` in `shipments` table
   - System records `LastAttemptDate`
   - System updates `DeliveryNotes` with carrier-provided information
   - If `DeliveryAttempts` < 3, shipping carrier schedules another attempt
   - If `DeliveryAttempts` = 3, package is returned to warehouse and customer is notified

## 7. Postconditions

1. Order is successfully delivered to customer's address
2. Inventory is accurately updated
3. Payment is successfully processed
4. Loyalty points are awarded if applicable
5. Analytics data is captured for reporting
6. Customer is able to initiate a return if needed

## 8. Business Rules

1. Standard shipping should be delivered within 3-5 business days
2. Express shipping should be delivered within 1-2 business days
3. Orders over $50 qualify for free standard shipping
4. International shipping requires address verification
5. Loyalty points are calculated as 1 point per $1 spent
6. First-time purchases receive double loyalty points
7. Shipping costs are calculated based on package weight, dimensions, and destination
8. Order status must follow proper sequence: Pending → Processing → Shipped → In Transit → Delivered
9. Automated shipping notifications must be sent at each major status change

## 9. Technical Requirements

1. Integration with inventory management system for real-time stock verification
2. Integration with payment processing gateway
3. Integration with address verification services
4. Integration with shipping carriers' APIs for tracking updates
5. Notification system for order status updates
6. Ability to handle partial shipments if needed

## 10. Database Entities and Relationships

| Entity | Relationship | Description |
|--------|-------------|-------------|
| `customers` | Primary | Stores customer profile information |
| `shopping_cart` | 1:1 with customers | Contains active shopping cart for each customer |
| `shopping_cart_items` | M:1 with shopping_cart | Contains items in a customer's cart |
| `addresses` | M:1 with customers | Stores customer shipping and billing addresses |
| `orders` | M:1 with customers | Stores order header information |
| `order_items` | M:1 with orders | Contains items within each order |
| `shipments` | M:1 with orders | Tracks shipment information |
| `shipment_items` | M:1 with shipments, 1:1 with order_items | Links shipments to order items |
| `payments` | M:1 with orders | Records payment transactions |
| `inventory_levels` | Ref. by product_variants | Tracks inventory at warehouse locations |
| `order_tracking` | M:1 with orders | Records status changes in order processing |
| `loyalty_accounts` | 1:1 with customers | Manages customer loyalty program |
| `warehouses` | Ref. by inventory_levels | Contains warehouse location information |

---

# UC-003: Product Return Processing

**Use Case ID:** UC-003  
**Version:** 1.0  
**Date Created:** 2025-04-06  

## 1. Description

This use case describes the process of a customer returning one or more products purchased from GAP, either by mail or at a physical store location. It covers the entire return process including return authorization, item inspection, refund processing, inventory updates, and analytics recording.

## 2. Actors

### 2.1 Primary Actor
- Customer

### 2.2 Secondary Actors
- Store Associate
- Customer Service Representative
- Returns Processing Staff
- Payment Processing System
- Inventory System

## 3. Preconditions

1. Customer has an active order in the system (exists in the `orders` table)
2. Order status is 'Delivered' or 'Picked Up'
3. Return is initiated within the return policy timeframe (typically 30 days)
4. Customer has proof of purchase (order number or receipt)

## 4. Trigger

Customer initiates a return request either online or in-store

## 5. Main Flow

### 5.1 Online Return Process

1. Customer logs into account and navigates to order history
   - System displays list of eligible orders for return from `orders` table

2. Customer selects order and items to return
   - Customer selects return reason for each item from predefined list
   - Customer indicates whether returning by mail or to store

3. System validates return eligibility
   - System checks return timeframe based on `OrderDate` or `ActualDeliveryDate`
   - System verifies item is returnable (not final sale)

4. System creates return authorization
   - System creates record in `returns` table with `ReturnStatus = 'Requested'`
   - System creates corresponding entries in `return_items` table
   - System generates return authorization number
   - If mail return, system provides shipping label
   - System notifies customer of return authorization

5. Customer ships items back or brings to store
   - If mail return, customer packs items and ships using provided label
   - If store return, customer brings items to store (continues with in-store flow)

6. Returns processing center receives returned items
   - Staff scans return authorization label
   - System updates `ReturnStatus` to 'Received' in `returns` table

7. Staff inspects returned items
   - Staff determines if items meet return policy requirements
   - Staff updates item condition in `return_items` table

8. System processes refund
   - System calculates refund amount based on original payment method, items returned, and condition
   - System updates `ReturnStatus` to 'Processed' in `returns` table
   - System creates refund transaction in `payments` table with negative amount
   - System updates `RefundAmount` in `returns` table

9. System updates inventory
   - If item condition allows for resale, system updates `QuantityOnHand` in `inventory_levels` table
   - If item cannot be resold, system records appropriately for accounting

10. System notifies customer
    - System sends confirmation of processed return and refund details

11. System updates analytics
    - System records return data for reporting and analysis

### 5.2 In-Store Return Process

1. Customer brings items to store with proof of purchase
   - Store associate looks up order in system using order number, customer email, or credit card

2. Store associate validates return eligibility
   - Associate verifies return is within timeframe based on `OrderDate` or `ActualDeliveryDate`
   - Associate verifies items are returnable (not final sale)

3. Store associate inspects items
   - Associate determines if items meet return policy requirements
   - Associate documents item condition

4. Store associate processes return in system
   - System creates record in `returns` table with `ReturnStatus = 'Requested'`
   - System creates corresponding entries in `return_items` table
   - System immediately updates `ReturnStatus` to 'Received' then 'Processed'

5. System processes refund
   - System calculates refund amount based on original payment method, items returned, and condition
   - If original payment was credit card and within 90 days, refund to same card
   - If original payment was cash or older than 90 days, refund as store credit
   - System creates refund transaction in `payments` table with negative amount
   - System updates `RefundAmount` in `returns` table

6. Store associate completes return transaction
   - Associate provides customer with return receipt
   - If applicable, associate processes store credit or gift card

7. System updates inventory
   - System updates `QuantityOnHand` in `inventory_levels` table
   - Items are made available for resale or marked for shipment to returns center

8. System updates analytics
   - System records return data for reporting and analysis

## 6. Alternative Flows

### 6.1 Alternative Flow 1: Return Denied
7a. If items do not meet return policy requirements:
   - Staff documents reason for denial
   - System updates `ReturnStatus` to 'Rejected' in `returns` table
   - System arranges for items to be returned to customer
   - System notifies customer of rejection reason
   - Use case ends

### 6.2 Alternative Flow 2: Partial Return Acceptance
7b. If some items meet return policy requirements and others do not:
   - Staff documents status for each item
   - System processes partial refund for acceptable items
   - System arranges for rejected items to be returned to customer
   - System notifies customer of partial return acceptance
   - Main flow continues from step 8 for accepted items only

### 6.3 Alternative Flow 3: Exchange Instead of Return
5c. If customer requests exchange instead of refund:
   - System creates return record as normal
   - System creates new order for exchange items
   - System links exchange order to return record
   - No payment processing needed if same value
   - If exchange value is greater, customer pays difference
   - If exchange value is less, system processes partial refund
   - Main flow continues from step 7

## 7. Postconditions

1. Return is successfully processed
2. Customer receives appropriate refund
3. Inventory is accurately updated
4. Analytics data is captured for reporting
5. If loyalty points were awarded for purchase, they are adjusted accordingly

## 8. Business Rules

1. Returns must be initiated within 30 days of purchase/delivery
2. Items must be in original condition with tags attached
3. Special promotional items may have different return policies
4. Refunds are processed to the original payment method when possible
5. Loyalty points awarded for the purchase are deducted upon return
6. Returns without receipt may be eligible for store credit only
7. Shipping costs are not refunded unless return is due to company error
8. Items purchased with promotional discounts are refunded at actual paid price
9. Return reason must be documented for analytics purposes

## 9. Technical Requirements

1. Integration with inventory management system
2. Integration with payment processing gateway for refunds
3. Barcode scanning capability for efficient processing
4. Notification system for return status updates
5. Reporting capability for return analytics

## 10. Database Entities and Relationships

| Entity | Relationship | Description |
|--------|-------------|-------------|
| `orders` | Referenced by returns | Stores the original order information |
| `order_items` | Referenced by return_items | Contains items from the original order |
| `returns` | M:1 with orders | Stores return header information |
| `return_items` | M:1 with returns, 1:1 with order_items | Contains items being returned |
| `payments` | M:1 with orders | Records original payment and refund transactions |
| `inventory_levels` | Updated upon return | Tracks inventory quantities |
| `customers` | Referenced by orders | Customer who made the purchase and return |
| `loyalty_accounts` | 1:1 with customers | For loyalty point adjustments |
| `sales_analytics` | For reporting | Captures return data for analytics |

---

# UC-004: Inventory Management and Replenishment

**Use Case ID:** UC-004  
**Version:** 1.0  
**Date Created:** 2025-04-06  

## 1. Description

This use case describes the processes for monitoring inventory levels across warehouses and stores, identifying items that need replenishment, creating purchase orders for suppliers, transferring inventory between locations, and updating inventory records when new stock arrives.

## 2. Actors

### 2.1 Primary Actor
- Inventory Manager

### 2.2 Secondary Actors
- Warehouse Staff
- Store Manager
- Store Associate
- Supplier
- Purchasing Department
- Logistics Department

## 3. Preconditions

1. Inventory records exist in the system (`inventory_levels` table)
2. Product information is defined in the system (`products` and `product_variants` tables)
3. Supplier information is defined in the system (`suppliers` table)
4. Store and warehouse locations are defined in the system (`stores` and `warehouses` tables)

## 4. Trigger

One of the following events occurs:
- Inventory level falls below reorder point
- Scheduled inventory review
- New product launch
- Seasonal inventory planning

## 5. Main Flow

### 5.1 Automated Inventory Monitoring

1. System regularly checks inventory levels
   - System queries `inventory_levels` table for all locations
   - System identifies items where `QuantityOnHand <= ReorderPoint`

2. System generates low stock alerts
   - Alerts are categorized by location type (warehouse or store)
   - Alerts are prioritized based on sales velocity and stock level

3. Inventory Manager reviews alerts
   - Manager assesses replenishment needs
   - Manager determines appropriate replenishment method (supplier order or inventory transfer)

### 5.2 Warehouse Replenishment from Supplier

1. Inventory Manager creates supplier order
   - System creates record in `supplier_orders` table with `OrderStatus = 'Draft'`
   - Manager selects products and quantities needed
   - System creates corresponding entries in `supplier_order_items` table
   - System calculates expected costs based on supplier contracts

2. Manager reviews and submits order
   - System updates `OrderStatus` to 'Submitted' in `supplier_orders` table
   - System calculates `ExpectedDeliveryDate` based on supplier `LeadTimeDays`
   - System sends purchase order to supplier

3. Supplier confirms order
   - System updates `OrderStatus` to 'Confirmed' in `supplier_orders` table
   - System notifies relevant warehouse staff of pending delivery

4. Warehouse receives shipment
   - Warehouse staff verifies received items against purchase order
   - Staff records any discrepancies
   - System updates `OrderStatus` to 'Received' in `supplier_orders` table

5. System updates inventory
   - System updates `QuantityOnHand` in `inventory_levels` table for warehouse location
   - System records stock receipt date and quantities

### 5.3 Store Replenishment from Warehouse

1. System identifies store replenishment needs
   - System identifies store locations where `QuantityOnHand <= ReorderPoint`
   - System checks warehouse inventory for availability

2. Inventory Manager creates replenishment order
   - System creates record in `store_inventory_replenishment` table with `ReplenishmentStatus = 'Requested'`
   - System calculates appropriate quantities based on sales history and space constraints
   - System assigns source warehouse based on proximity and availability

3. Warehouse prepares store shipment
   - Warehouse staff collects items for shipment
   - System updates `ReplenishmentStatus` to 'Processing' in `store_inventory_replenishment` table
   - Staff packages items for transit

4. Logistics handles shipping
   - Shipment is dispatched to store
   - System updates `ReplenishmentStatus` to 'Shipped' in `store_inventory_replenishment` table
   - System updates warehouse `inventory_levels` by decreasing `QuantityOnHand`

5. Store receives shipment
   - Store staff verifies received items against replenishment order
   - Staff records any discrepancies
   - System updates `ReplenishmentStatus` to 'Completed' in `store_inventory_replenishment` table

6. System updates store inventory
   - System updates `QuantityOnHand` in `inventory_levels` table for store location
   - System records receipt date and quantities

### 5.4 Inventory Transfer Between Warehouses

1. Inventory Manager identifies transfer need
   - Manager identifies warehouse with excess inventory
   - Manager identifies warehouse with shortage

2. Manager creates transfer order
   - System creates record in `warehouse_stock_transfer` table with `TransferStatus = 'Pending'`
   - Manager specifies source and destination warehouses
   - Manager selects products and quantities to transfer

3. Source warehouse prepares shipment
   - Warehouse staff collects items for transfer
   - System updates `TransferStatus` to 'In Transit' in `warehouse_stock_transfer` table
   - System updates source warehouse `inventory_levels` by decreasing `QuantityOnHand`

4. Destination warehouse receives shipment
   - Warehouse staff verifies received items against transfer order
   - Staff records any discrepancies
   - System updates `TransferStatus` to 'Completed' in `warehouse_stock_transfer` table

5. System updates destination inventory
   - System updates `QuantityOnHand` in `inventory_levels` table for destination warehouse
   - System records completion date

## 6. Alternative Flows

### 6.1 Alternative Flow 1: Supplier Order Discrepancies
4a. If received items don't match purchase order:
   - Warehouse staff documents discrepancies
   - System partially updates inventory for received items
   - Purchasing department contacts supplier about discrepancies
   - System keeps order open until resolved
   - If discrepancy is resolved with additional shipment, flow continues at step 4
   - If discrepancy is accepted, system updates order as complete with notes

### 6.2 Alternative Flow 2: Store Replenishment Prioritization
1a. If multiple stores have low inventory of the same items and warehouse stock is limited:
   - System prioritizes stores based on sales volume and strategic importance
   - System allocates available inventory accordingly
   - System schedules follow-up replenishment for remaining stores when new stock arrives
   - Main flow continues with modified quantities

### 6.3 Alternative Flow 3: Emergency Replenishment
1b. If store inventory reaches critical level (zero stock of fast-moving item):
   - System flags for emergency replenishment
   - System identifies nearest location (store or warehouse) with available stock
   - If nearby store has excess, system creates store-to-store transfer
   - Process expedited with highest priority
   - Main flow continues with expedited timeline

## 7. Postconditions

1. Inventory levels are appropriately maintained at all locations
2. Purchase orders are placed in a timely manner
3. Inventory transfers are completed accurately
4. Inventory records in system reflect physical inventory
5. Low stock situations are minimized

## 8. Business Rules

1. Reorder points are calculated based on sales velocity, lead time, and safety stock
2. Warehouse inventory levels must be maintained at 2x the aggregate store reorder points
3. Store replenishment prioritizes stores with higher sales volume
4. Seasonal inventory adjustments follow predefined merchandising calendar
5. New product launches require pre-allocation of inventory across locations
6. Fast-moving items have higher safety stock requirements
7. Clearance items are redistributed based on regional performance
8. Inventory accuracy must be maintained at >98%
9. Stock-takes must be performed monthly for high-value items
10. Supplier orders over $10,000 require additional approval

## 9. Technical Requirements

1. Real-time inventory tracking across all locations
2. Automated alerts for inventory below reorder points
3. Barcode/RFID scanning capability for accurate receiving
4. Integration with supplier systems for electronic ordering
5. Forecasting algorithms for intelligent reorder point calculation
6. Mobile access for warehouse and store staff
7. Reporting capability for inventory analysis

## 10. Database Entities and Relationships

| Entity | Relationship | Description |
|--------|-------------|-------------|
| `inventory_levels` | M:1 with product_variants | Tracks inventory quantities by location |
| `products` | 1:M with product_variants | Defines product information |
| `product_variants` | M:1 with products | Defines specific SKUs (size/color combinations) |
| `warehouses` | 1:M with inventory_levels | Defines warehouse locations |
| `stores` | 1:M with inventory_levels | Defines store locations |
| `suppliers` | 1:M with supplier_orders | Contains supplier information |
| `supplier_orders` | M:1 with suppliers | Stores purchase order header information |
| `supplier_order_items` | M:1 with supplier_orders | Contains items within each purchase order |
| `warehouse_stock_transfer` | References warehouses | Manages transfers between warehouses |
| `store_inventory_replenishment` | References stores and warehouses | Manages store replenishment orders |

---

# UC-005: Customer Loyalty Program Management

**Use Case ID:** UC-005  
**Version:** 1.0  
**Date Created:** 2025-04-06  

## 1. Description

This use case describes the processes for managing GAP's customer loyalty program, including customer enrollment, points accumulation, tier management, rewards redemption, and account management. The loyalty program has three tiers (Core, Enthusiast, and Icon) with increasing benefits based on customer spending and engagement.

## 2. Actors

### 2.1 Primary Actor
- Customer

### 2.2 Secondary Actors
- Customer Service Representative
- Store Associate
- Loyalty Program Administrator
- Marketing Department

## 3. Preconditions

1. Customer has an active account in the system (exists in the `customers` table)
2. Loyalty program rules and tiers are defined in the system

## 4. Trigger

One of the following events occurs:
- Customer requests to join loyalty program
- Customer makes a purchase
- Customer attempts to redeem rewards
- Scheduled tier evaluation period occurs
- Customer requests loyalty account information

## 5. Main Flow

### 5.1 Customer Enrollment

1. Customer requests to join loyalty program
   - Request can be made online, in-store, or via mobile app
   - If online/app, customer completes enrollment form
   - If in-store, associate collects necessary information

2. System validates customer information
   - System checks if customer already has an account in `customers` table
   - If new customer, system creates customer record
   - System verifies required customer information is complete

3. System creates loyalty account
   - System creates record in `loyalty_accounts` table
   - System sets `TierLevel = 'Core'` (entry level)
   - System sets `PointsBalance = 0`, `LifetimePoints = 0`
   - System sets `TierStartDate` to current date
   - System sets `TierEndDate` to one year from current date

4. System sends welcome communication
   - Welcome message includes program details, benefits, and account access information
   - Customer receives physical or digital loyalty card/identifier

### 5.2 Points Accumulation

1. Customer makes a purchase
   - Purchase is recorded in `orders` table
   - System calculates points based on purchase amount (`TotalAmount` in `orders` table)

2. System updates loyalty account
   - System increments `PointsBalance` in `loyalty_accounts` table
   - System increments `LifetimePoints` in `loyalty_accounts` table
   - If first purchase, points are doubled according to business rules
   - System records point transaction in loyalty activity log

3. System evaluates tier eligibility
   - System compares current `LifetimePoints` to tier thresholds
   - If threshold for next tier is met, system updates `TierLevel`
   - System updates `TierStartDate` to current date
   - System updates `TierEndDate` to one year from current date
   - System sends tier upgrade notification if applicable

### 5.3 Rewards Redemption

1. Customer requests to redeem points for rewards
   - Request can be made online, in-store, or via mobile app
   - System displays available rewards based on points balance
   - Customer selects desired reward

2. System validates redemption eligibility
   - System confirms `PointsBalance` is sufficient for selected reward
   - System checks any additional redemption requirements (e.g., tier level)

3. System processes redemption
   - System decrements `PointsBalance` by required amount
   - System generates reward (coupon code, gift card, merchandise credit, etc.)
   - System does not decrement `LifetimePoints`
   - System records redemption transaction in loyalty activity log

4. System delivers reward to customer
   - Digital rewards delivered via email/app
   - Physical rewards prepared for delivery or in-store pickup
   - System sends redemption confirmation

### 5.4 Tier Management and Renewal

1. System conducts scheduled tier evaluations
   - Evaluations occur monthly for all accounts
   - System identifies accounts approaching `TierEndDate`

2. System evaluates tier continuation eligibility
   - For accounts with `TierEndDate` within 30 days:
     - System checks if `LifetimePoints` in current year meets renewal threshold
     - If threshold met, system extends `TierEndDate` by one year
     - If threshold not met, system prepares for tier downgrade

3. System processes tier changes
   - For downgrades, system updates `TierLevel` to appropriate level
   - System updates `TierStartDate` to current date
   - System updates `TierEndDate` to one year from current date
   - System sends notification of tier change

### 5.5 Account Management

1. Customer requests account information
   - Request can be made online, in-store, or via customer service
   - System authenticates customer

2. System provides account information
   - Current points balance
   - Current tier level and benefits
   - Tier expiration date
   - Recent activity
   - Available rewards
   - Points needed for next tier

3. Customer requests specific account actions
   - Update contact information
   - Redeem points
   - Opt in/out of communications
   - Combine accounts (requires verification)
   - System processes requested actions

## 6. Alternative Flows

### 6.1 Alternative Flow 1: Point Adjustment
5.2a. If purchase is returned:
   - System calculates points to be deducted
   - System decrements `PointsBalance` in `loyalty_accounts` table
   - If return results in tier eligibility change, tier remains unchanged until next evaluation period
   - System records adjustment in loyalty activity log

### 6.2 Alternative Flow 2: Reward Unavailability
5.3a. If selected reward is unavailable:
   - System notifies customer of unavailability
   - System offers alternative rewards
   - Customer may select alternative or cancel redemption
   - If cancelled, points remain in account

### 6.3 Alternative Flow 3: Account Merger
5.5a. If customer has multiple accounts to be merged:
   - Customer service verifies ownership of all accounts
   - System combines `PointsBalance` and `LifetimePoints`
   - System uses most favorable `TierLevel` and `TierEndDate`
   - System deactivates redundant accounts
   - System records merger in loyalty activity log

## 7. Postconditions

1. Customer successfully participates in loyalty program
2. Points are accurately awarded, tracked, and redeemed
3. Customer tier level accurately reflects spending activity
4. Customer receives appropriate benefits based on tier level
5. Loyalty program data is available for marketing analytics

## 8. Business Rules

1. Points awarded at rate of 1 point per $1 spent
2. First-time purchases earn double points
3. Points expire after 24 months of inactivity
4. Tier levels have the following thresholds:
   - Core: 0-999 lifetime points
   - Enthusiast: 1,000-4,999 lifetime points
   - Icon: 5,000+ lifetime points
5. Tier status valid for one year from achievement date
6. Tier renewal requires earning 75% of threshold points during membership year
7. Returns result in deduction of points awarded for purchase
8. Promotional multipliers may temporarily increase points earned
9. Reward redemption requires minimum point balance
10. Customers can only belong to one tier at a time

## 9. Technical Requirements

1. Real-time points calculation and updating
2. Secure customer authentication for account access
3. Integration with order processing system
4. Automated tier evaluation processes
5. Customer communication system for notifications
6. Reporting capability for program performance analysis
7. Mobile app integration for account access

## 10. Database Entities and Relationships

| Entity | Relationship | Description |
|--------|-------------|-------------|
| `customers` | 1:1 with loyalty_accounts | Contains customer information |
| `loyalty_accounts` | 1:1 with customers | Stores loyalty program membership data |
| `orders` | M:1 with customers | Records purchases for points calculation |
| `loyalty_activity` | M:1 with loyalty_accounts | Tracks point transactions and redemptions |
| `loyalty_rewards` | Referenced during redemption | Defines available rewards and point requirements |
| `loyalty_tiers` | Referenced by loyalty_accounts | Defines tier levels, thresholds, and benefits |
| `promotions` | Referenced during point calculation | For promotional point multipliers |

---

# UC-006: Promotional Campaign Management

**Use Case ID:** UC-006  
**Version:** 1.0  
**Date Created:** 2025-04-06  

## 1. Description

This use case describes the processes for planning, creating, executing, and analyzing promotional campaigns in the GAP retail system. It covers various types of promotions including percentage discounts, fixed amount discounts, buy-one-get-one offers, and bundle promotions, as well as targeting specific customer segments.

## 2. Actors

### 2.1 Primary Actor
- Marketing Manager

### 2.2 Secondary Actors
- Merchandising Team
- Customer Segment Analyst
- Store Manager
- Customer
- E-commerce Team
- IT Support

## 3. Preconditions

1. Products are defined in the system (`products` and `product_variants` tables)
2. Customer segments are defined
3. User has appropriate permissions to create and manage promotions

## 4. Trigger

One of the following events occurs:
- Scheduled seasonal promotion planning
- Competitive response needed
- Excess inventory identified
- New product launch support needed
- Customer acquisition or retention campaign initiated

## 5. Main Flow

### 5.1 Promotion Planning

1. Marketing Manager initiates promotion planning
   - Manager identifies business objective (increase sales, clear inventory, promote new products, etc.)
   - Manager defines target time period for promotion
   - Manager identifies target customer segments if applicable

2. Marketing Manager defines promotion parameters
   - Promotion type (percentage discount, fixed amount, BOGO, bundle)
   - Discount value or promotion mechanics
   - Eligible products or categories
   - Minimum purchase requirements if applicable
   - Usage limits (per customer, total, etc.)
   - Stackability with other promotions

3. System validates promotion parameters
   - System checks for conflicts with existing promotions
   - System verifies technical feasibility
   - System estimates financial impact based on historical data

4. Marketing Manager finalizes promotion details
   - Promotion name and description
   - Promotion code (if applicable)
   - Creative assets and messaging
   - Terms and conditions

### 5.2 Promotion Creation

1. Marketing Manager creates promotion in system
   - System creates record in `promotions` table
   - Manager sets `PromotionName`, `Description`, `PromotionCode`
   - Manager sets `DiscountType`, `DiscountValue`
   - Manager sets `StartDate`, `EndDate`
   - Manager sets `MinimumPurchase`, `MaximumDiscount` if applicable
   - Manager sets `UsageLimit` if applicable
   - Manager sets `IsStackable` flag

2. Marketing Manager defines product applicability
   - If category-based, manager selects applicable categories
   - If product-based, manager selects specific products
   - If exclusions needed, manager defines excluded products
   - System stores product applicability in `ApplicableProducts` and `ExcludedProducts` fields in JSON format

3. Marketing Manager defines customer targeting
   - If promotion is for all customers, `TargetCustomerSegment` remains null
   - If promotion is targeted, manager selects appropriate segment
   - If first-time customer only, manager sets `IsFirstTimePurchaseOnly = TRUE`

4. System activates promotion
   - If immediate, system sets `IsActive = TRUE`
   - If scheduled, system schedules activation for `StartDate`
   - System generates unique promotion tracking identifiers

### 5.3 Promotion Execution

1. System applies promotion during checkout process
   - When customer proceeds to checkout, system identifies applicable promotions
   - System validates eligibility based on:
     - Cart contents match `ApplicableProducts`
     - Purchase amount meets `MinimumPurchase`
     - Customer status matches targeting criteria
     - Promotion is active (`IsActive = TRUE` and current date between `StartDate` and `EndDate`)

2. System calculates discount
   - Based on `DiscountType` and `DiscountValue`
   - Applied to eligible items only
   - Limited by `MaximumDiscount` if applicable
   - System shows discount in cart

3. Customer completes checkout
   - System finalizes discount application
   - System creates record in `promotion_application` table
   - System creates record in `order_promotions` table
   - System decrements remaining uses if `UsageLimit` is set
   - System updates `UsageCount` in `promotions` table

### 5.4 Promotion Monitoring and Analysis

1. Marketing Manager monitors promotion performance
   - System provides real-time metrics:
     - Usage count
     - Revenue impact
     - Average discount amount
     - Conversion rate
     - Customer acquisition rate

2. System tracks promotion effectiveness
   - System compares actual performance to forecasted performance
   - System identifies patterns in usage (product combinations, customer segments, etc.)
   - System alerts manager to unusual patterns or potential issues

3. Marketing Manager makes adjustments if needed
   - Extend or shorten duration
   - Modify discount parameters
   - Expand or restrict product applicability
   - Adjust customer targeting

4. System generates post-campaign analysis
   - Upon promotion completion, system provides comprehensive analysis
   - Metrics include revenue impact, margin impact, inventory movement, customer acquisition/retention
   - System provides recommendations for future promotions

## 6. Alternative Flows

### 6.1 Alternative Flow 1: Promotion Code Entry
5.3a. If promotion requires code entry:
   - Customer enters promotion code during checkout
   - System validates code against `PromotionCode` in `promotions` table
   - If valid, system applies promotion
   - If invalid, system notifies customer
   - Main flow continues at step 5.3.2

### 6.2 Alternative Flow 2: Promotion Performance Issues
5.4a. If promotion performance is significantly below expectations:
   - System alerts Marketing Manager
   - Manager evaluates possible causes
   - Manager may choose to:
     - Enhance promotion value
     - Expand eligible products
     - Increase marketing visibility
     - Terminate promotion early
   - System implements requested changes
   - Main flow continues with modified promotion parameters

### 6.3 Alternative Flow 3: Promotion Conflict Resolution
5.2a. If new promotion conflicts with existing promotion:
   - System identifies conflict (same products, overlapping dates, etc.)
   - System notifies Marketing Manager
   - Manager resolves by:
     - Adjusting dates to avoid overlap
     - Setting stackability rules
     - Modifying product applicability
     - Canceling or postponing one promotion
   - Main flow continues after conflict resolution

## 7. Postconditions

1. Promotion is successfully created and executed
2. Customers receive appropriate discounts
3. Promotion performance data is captured for analysis
4. Business objectives for promotion are measured
5. Learnings are applied to future promotion planning

## 8. Business Rules

1. Promotions must have a clear start and end date
2. Maximum discount percentage is 75% unless specially approved
3. Stackable promotions are limited to one category promotion and one product promotion
4. First-time purchase promotions cannot be combined with other promotional offers
5. Promotion codes must be unique within a 12-month period
6. Promotions targeting specific customer segments must be validated for compliance with privacy policies
7. Limited-quantity promotions must be monitored in real-time
8. Promotions affecting margin by more than 10% require executive approval
9. Promotional forecasts must be based on at least 6 months of historical data
10. Post-promotion analysis must be completed within 7 days of promotion end

## 9. Technical Requirements

1. Real-time promotion application during checkout
2. Dynamic eligibility evaluation based on complex rules
3. Integration with inventory management system
4. Integration with customer segmentation system
5. Analytical dashboard for monitoring performance
6. Forecasting capabilities for promotion planning
7. A/B testing capability for promotion optimization
8. Automated alerts for performance issues
9. API for integration with marketing automation platforms

## 10. Database Entities and Relationships

| Entity | Relationship | Description |
|--------|-------------|-------------|
| `promotions` | Primary | Stores promotion definitions and parameters |
| `promotion_application` | M:1 with promotions, M:1 with orders | Records when promotions are applied to orders |
| `order_promotions` | M:1 with orders, M:1 with promotions | Links orders to applied promotions |
| `products` | Referenced by promotions | Eligible products for promotions |
| `categories` | Referenced by promotions | Eligible categories for promotions |
| `customers` | Referenced for targeting | For customer-specific promotions |
| `orders` | Referenced by promotion_application | Orders to which promotions are applied |

---

# UC-007: Sales Analytics and Reporting

**Use Case ID:** UC-007  
**Version:** 1.0  
**Date Created:** 2025-04-06  

## 1. Description

This use case describes the processes for collecting, analyzing, and reporting on sales data across the GAP retail ecosystem. It covers standard reporting, custom analytics, dashboard visualization, and the export of data for further analysis. The system provides insights into sales performance by product, category, location, time period, customer segment, and promotion effectiveness.

## 2. Actors

### 2.1 Primary Actor
- Business Analyst

### 2.2 Secondary Actors
- Executive Management
- Store Manager
- Merchandising Team
- Marketing Team
- Finance Department
- IT Support

## 3. Preconditions

1. Sales data is captured in the system (`orders`, `order_items`, `payments` tables)
2. Product hierarchy is defined (`products`, `categories` tables)
3. Location hierarchy is defined (`stores`, `warehouses` tables)
4. User has appropriate permissions to access sales data

## 4. Trigger

One of the following events occurs:
- Scheduled reporting cycle (daily, weekly, monthly, quarterly)
- Ad-hoc analysis request
- Performance review meeting
- Strategic planning session
- Anomaly detection alert

## 5. Main Flow

### 5.1 Standard Reporting

1. Business Analyst accesses reporting system
   - Analyst selects report type from predefined templates
   - Analyst sets parameters (time period, product categories, locations, etc.)

2. System generates standard reports
   - Sales by product category
   - Sales by location
   - Sales by time period (hourly, daily, weekly, monthly)
   - Comparative sales (year-over-year, period-over-period)
   - Top-selling products
   - Sales by payment method
   - Returns analysis

3. System presents report data
   - Tabular data with appropriate totals and subtotals
   - Visual representations (charts, graphs)
   - Key performance indicators (KPIs) with trend indicators

4. Analyst reviews and distributes reports
   - Analyst adds commentary or insights
   - System distributes reports to stakeholders based on subscription settings
   - Reports are archived for future reference

### 5.2 Custom Analytics

1. Business Analyst defines custom analysis requirements
   - Analyst specifies dimensions and measures for analysis
   - Analyst defines filters and parameters
   - Analyst selects visualization preferences

2. System queries data sources
   - System accesses relevant tables using optimized queries
   - System integrates data from multiple sources (`sales_analytics`, `orders`, `inventory_levels`, etc.)
   - System performs required calculations

3. System generates custom analytics
   - Product affinity analysis (frequently purchased together)
   - Customer segmentation analysis
   - Price elasticity analysis
   - Promotion effectiveness
   - Inventory turn analysis
   - Channel performance comparison

4. Analyst refines and iterates
   - Analyst reviews initial results
   - Analyst adjusts parameters or adds dimensions as needed
   - System regenerates analysis with new parameters
   - Final results are saved for future reference

### 5.3 Dashboard Visualization

1. Business Analyst configures dashboard
   - Analyst selects relevant metrics and visualizations
   - Analyst arranges dashboard components
   - Analyst sets refresh frequency and alert thresholds

2. System populates dashboard with real-time or near-real-time data
   - Sales totals with comparison to targets
   - Inventory status
   - Customer traffic metrics
   - Return rates
   - Promotion performance
   - Staff performance metrics

3. System displays dashboard to stakeholders
   - Different dashboard views for different roles (executive, store, merchandising)
   - Interactive elements for drilling down into data
   - Automated highlighting of exceptions or anomalies

4. Stakeholders interact with dashboard
   - Filter by various dimensions
   - Drill down from summary to detail
   - Export specific views or data points
   - Set alerts for specific thresholds

### 5.4 Data Export and Advanced Analysis

1. Business Analyst requests data export
   - Analyst defines data set to be exported
   - Analyst selects export format (CSV, Excel, etc.)
   - Analyst specifies scheduling if recurring export

2. System prepares and validates data
   - System ensures data completeness
   - System applies appropriate transformations
   - System validates data against business rules

3. System exports data
   - Data is exported in requested format
   - System provides metadata and data dictionary
   - Export is delivered via secure method
   - System logs export for audit purposes

4. Analyst conducts advanced analysis
   - Data is imported into specialized tools (R, Python, SAS, etc.)
   - Advanced statistical analysis is performed
   - Predictive models are developed
   - Results are documented and shared

## 6. Alternative Flows

### 6.1 Alternative Flow 1: Data Quality Issue
5.2a. If system detects data quality issues during analysis:
   - System identifies specific records or dimensions with issues
   - System notifies Analyst of the issues
   - Analyst decides to:
     - Proceed with analysis excluding problematic data
     - Defer analysis until data is corrected
     - Apply correction or transformation rules
   - If proceeding, analysis continues with documented limitations
   - If deferring, system creates data quality incident ticket

### 6.2 Alternative Flow 2: Performance Anomaly Detection
5.3a. If dashboard detects significant performance anomaly:
   - System generates alert based on predefined thresholds
   - Alert is sent to appropriate stakeholders
   - System provides drill-down capability to analyze anomaly
   - Stakeholders can acknowledge alert and document response actions
   - System tracks resolution of anomaly

### 6.3 Alternative Flow 3: Scheduled Export Failure
5.4a. If scheduled data export fails:
   - System logs failure details
   - System attempts retry based on configuration
   - If retry fails, system notifies Analyst and IT Support
   - Manual intervention resolves issue
   - System reschedules export

## 7. Postconditions

1. Accurate and timely sales reports are generated
2. Stakeholders have access to relevant sales insights
3. Data-driven decisions are enabled
4. Performance trends are identified
5. Export data is available for specialized analysis
6. Data quality issues are identified and addressed

## 8. Business Rules

1. Sales data must be updated in near-real-time (within 15 minutes)
2. Historical data must be available for at least 3 years
3. Comparative analysis must account for calendar shifts (holidays, weekends)
4. All financial data must reconcile with general ledger
5. Data access must follow role-based security model
6. Personally identifiable information must be anonymized in exports
7. KPIs must be calculated using standardized definitions
8. Report distribution must comply with information security policies
9. Data anomalies exceeding 15% variance must trigger alerts
10. Standard reports must be available by 6:00 AM local time each day

9. Technical Requirements

1. High-performance data warehouse architecture
2. Real-time data integration pipelines
3. Interactive visualization capabilities
4. Role-based access control system
5. Export functionality supporting multiple formats
6. Automated anomaly detection
7. Scheduled report generation and distribution
8. Historical data archiving with fast retrieval
9. Mobile-friendly dashboard interface
10. API access for integration with external analytics tools

## 10. Database Entities and Relationships

| Entity | Relationship | Description |
|--------|-------------|-------------|
| `sales_analytics` | Integrates multiple tables | Denormalized table optimized for analytics |
| `orders` | Primary source | Contains order header information |
| `order_items` | M:1 with orders | Contains details of products sold |
| `products` | Referenced by order_items | Product information |
| `categories` | 1:M with products | Product categorization hierarchy |
| `stores` | Referenced by orders | Store location information |
| `customers` | Referenced by orders | Customer demographic information |
| `promotions` | Referenced by order_promotions | Promotion details |
| `order_promotions` | M:1 with orders | Links orders to applied promotions |
| `inventory_levels` | Referenced for analysis | Inventory position information |
| `returns` | M:1 with orders | Return information for analysis |
| `payments` | M:1 with orders | Payment method analysis |

---

# Document Information

**Document Generated By:** GitHub Copilot
**Current Date and Time (UTC):** 2025-04-06 07:19:46
**Current User's Login:** mkol21
**Document Version:** 1.0
**Last Updated:** 2025-04-06 07:19:46