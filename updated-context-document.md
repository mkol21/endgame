# GAP Retail Database System - Project Context Document
*Updated: April 6, 2025*

## AI Assistant Instructions:
When helping with this project:
- Reference ALL files in the project folder to maintain consistency
- Suggest updates to any relevant files when necessary
- Understand how changes to one file might impact others
- Keep track of progress through the project phases
- Provide an updated version of this context document at the end of each session

## Project Description
This project involves developing a comprehensive retail database system for GAP, a global clothing and accessories retailer. The database supports all aspects of retail operations including inventory management, order processing, customer management, store operations, warehouse management, and analytics. This SQL-based system is designed to handle GAP's omnichannel retail environment (online, in-store, and pickup services).

## Database Schema Overview
The database follows a relational model with properly normalized tables and appropriate relationships. The schema is designed to support the complete retail lifecycle from inventory management to sales and returns processing. The system handles both B2C (direct to consumer) and internal operations (warehouse management, supplier orders).

## Current Progress
- ✅ Completed database schema design with all tables, relationships, and constraints (01schemav2.sql)
- ✅ Populated base independent tables in 02_p1v2.sql:
  * Payment methods
  * Payment statuses
  * Parent and child categories
  * Warehouses (50 locations)
  * Stores (20 locations across 5 regions)
- ✅ Populated suppliers table in 02_p2v2.sql (100 suppliers across various categories)
- ✅ Verified schema compatibility with all defined use cases (UC-001 through UC-007)
- ✅ Implemented unique constraints in data population scripts
- ✅ Ensured comprehensive coverage of different business domains

## Completed Tables
1. **Independent Entities**:
   - payment_methods
   - payment_status
   - categories
   - warehouses
   - stores
   - suppliers

## Next Steps
1. **[NEXT]** Populate dependent tables:
   - customers
   - addresses
   - loyalty_accounts
   - products
   - product_variants
2. Create data population scripts for:
   - shopping_cart
   - shopping_cart_items
   - inventory_levels
3. Generate transaction data:
   - orders
   - order_items
   - payments
   - shipments
4. Create operational data scripts:
   - returns
   - supplier_orders
   - warehouse transfers
5. Develop business query examples for common operations
6. Implement reporting and analytics features

## Technical Details

### Database Architecture
- MySQL InnoDB database with comprehensive schema
- Includes 30+ interconnected tables with proper foreign key relationships
- Designed for scalability with appropriate indexes and constraints
- Features timestamp tracking for record creation and updates

### Key Characteristics of Current Data Population
- Diverse and realistic data across multiple domains
- Global representation with international locations
- Comprehensive supplier ecosystem
- Realistic operating hours and contact information
- Varied store and warehouse sizes
- Multiple regional representations

### Common Strategies Used in Data Population
- Batch inserts with multiple rows per INSERT statement
- Transaction blocks for data integrity
- Temporarily disabling foreign key checks
- Clearing existing data before population to avoid conflicts
- Using realistic, varied data across different attributes

## Technology Stack
- MySQL/MariaDB with InnoDB engine
- SQL for all database operations and queries
- Potential integration with retail applications via standard connectors

## Project Timeline
- **Phase 1 (Completed)**: 
  * Database schema design 
  * Base table creation
  * Independent table population (payment methods, categories, warehouses, stores, suppliers)
- **Phase 2 (In Progress)**: Data population for dependent tables
- **Phase 3 (Upcoming)**: Implementation of complex queries and stored procedures
- **Phase 4 (Upcoming)**: Development of business reports and analytics
- **Phase 5 (Upcoming)**: Performance optimization and indexing strategies

## Project Files Organization
- **01schemav2.sql**: Comprehensive database schema definition
- **02_p1v2.sql**: Base independent tables population (payment methods, categories, warehouses, stores)
- **02_p2v2.sql**: Suppliers table population
- **GAP_Retail_System_Use_Cases.md**: Detailed use case documentation (UC-001 through UC-007)

## Notable Features Demonstrated in Current Implementation
- Comprehensive table design supporting multi-channel retail
- Global perspective with international warehouses and stores
- Flexible category hierarchy
- Detailed store and warehouse information
- Multiple payment method support
- Extensive supplier ecosystem

## Design Considerations Implemented
- Normalized structure with appropriate relationships
- Comprehensive foreign key constraints
- Timestamp tracking for audit purposes
- Status fields using ENUMs
- Unique constraints for data integrity

## Challenges Addressed
- Creating diverse, realistic data across multiple domains
- Maintaining referential integrity
- Ensuring data variety and representativeness
- Supporting complex retail business rules

## Key Resources
- Database Schema: 01schemav2.sql
- Base Data Population: 02_p1v2.sql
- Suppliers Population: 02_p2v2.sql
- Use Case Documentation: GAP_Retail_System_Use_Cases.md

## Glossary
- **SKU**: Stock Keeping Unit
- **MSRP**: Manufacturer's Suggested Retail Price
- **UC**: Use Case
- **POS**: Point of Sale system
- **WMS**: Warehouse Management System
- **B2C**: Business to Consumer

---

*This is a living document that reflects the current state of the GAP Retail Database project. It will be updated after each development session to maintain an accurate overview of progress and next steps.*