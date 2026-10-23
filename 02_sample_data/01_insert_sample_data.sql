-- =====================================================
-- Inventory and Order Management System
-- Phase 1: Sample Data to test order processing
-- =====================================================
-- The initial stock of each product is logged automatically by the
-- trigger dbo.trg_LogInitialProductStock (01_database_design/03_log_initial_stock_trigger.sql),
-- so this script only needs to insert the customers and products.

USE InventoryOrderManagement;
GO

-- 1. Insert sample customers
INSERT INTO dbo.Customers
    (CustomerName, Email, Phone)
-- Select temporary table known as "source" to temporarily hold the inserted values
SELECT
    source.CustomerName,
    source.Email,
    source.Phone
FROM
(
    VALUES
        (N'Alex Morgan', N'alex.morgan@example.com', N'+250780000001'),
        (N'Grace Uwimana', N'grace.uwimana@example.com', N'+250780000002'),
        (N'David Smith', N'david.smith@example.com', N'+250780000003'),
        (N'Chantal Mukamana', N'chantal.mukamana@example.com', N'+250780000004'),
        (N'Jean Pierre', N'jean.pierre@example.com', N'+250780000005')
) AS source(CustomerName, Email, Phone)
-- Compare the inserted values with values in "Customers" table.
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Customers AS existing
    WHERE existing.Email = source.Email
);
GO

-- 2. Insert sample products
INSERT INTO dbo.Products
    (ProductName, Category, Price, StockQuantity, ReorderLevel)
-- Created temporary "source" table to store inserted data
SELECT
    source.ProductName,
    source.Category,
    source.Price,
    source.StockQuantity,
    source.ReorderLevel
FROM
(
    VALUES
        (N'Wireless Keyboard', N'Accessories', 50.00, 12, 10),
        (N'Wireless Mouse', N'Accessories', 20.00, 20, 10),
        (N'USB-C Hub', N'Accessories', 35.00, 8, 10),
        (N'Monitor 24 Inch', N'Monitors', 180.00, 15, 5),
        (N'Mechanical Keyboard', N'Accessories', 95.00, 4, 5),
        (N'Laptop Stand', N'Office Equipment', 40.00, 25, 10),
        (N'Webcam HD', N'Electronics', 65.00, 3, 5),
        (N'Headphones', N'Audio', 75.00, 0, 10)
) AS source(ProductName, Category, Price, StockQuantity, ReorderLevel)
-- Compare temporary "source" values with "Products" table values
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Products AS existing
    WHERE existing.ProductName = source.ProductName
      AND existing.Category = source.Category
);
GO

-- 3. Check that the trigger logged the initial stock
SELECT
    p.ProductName,
    l.QuantityChanged,
    l.ChangeType,
    l.Notes
FROM dbo.InventoryLogs AS l
INNER JOIN dbo.Products AS p
    ON l.ProductID = p.ProductID
ORDER BY l.InventoryLogID;
GO