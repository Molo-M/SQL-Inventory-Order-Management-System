
-- =====================================================
-- Inventory and Order Management System
-- Run every script in the correct order
-- =====================================================
-- HOW TO USE (in SSMS):
--   1. Turn on SQLCMD Mode: Query menu > SQLCMD Mode
--   2. Change ProjectPath below to the folder where this repository is saved
--   3. Execute (F5)
--
-- WARNING: 01_create_schema.sql drops and re-creates all tables,
-- so any existing data in InventoryOrderManagement is deleted.

:setvar ProjectPath "C:\path\to\SQL-Inventory-Order-Management"

-- Stop at the first error instead of running the rest on a broken setup
:on error exit

-- 1. Database design
:r $(ProjectPath)\01_database_design\01_create_schema.sql
:r $(ProjectPath)\01_database_design\02_create_indexes.sql
:r $(ProjectPath)\01_database_design\03_log_initial_stock_trigger.sql

-- 2. Sample data (the trigger logs the initial stock)
:r $(ProjectPath)\02_sample_data\01_insert_sample_data.sql

-- 3. Stored procedures and views
:r $(ProjectPath)\03_stored_procedures\01_place_order.sql
:r $(ProjectPath)\03_stored_procedures\03_replenish_stock.sql
:r $(ProjectPath)\04_reporting\01_create_views.sql

-- 4. Place a sample order (with bulk discount)
:r $(ProjectPath)\03_stored_procedures\02_test_place_order.sql

-- 5. Reports after the order
:r $(ProjectPath)\04_reporting\02_order_summary.sql
:r $(ProjectPath)\04_reporting\03_low_stock_report.sql
:r $(ProjectPath)\04_reporting\04_customer_spending_tiers.sql

-- 6. Replenish stock (one product, then all low-stock products)
:r $(ProjectPath)\03_stored_procedures\04_test_replenishment.sql

-- 7. Full inventory history and audit check
:r $(ProjectPath)\04_reporting\05_inventory_history.sql
