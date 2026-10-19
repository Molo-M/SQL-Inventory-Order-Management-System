
-- =====================================================
-- Inventory and Order Management System
-- Phase 1: Sample Data to test order processing
-- =====================================================

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

-- 2. Prepare a record of products inserted by this script
DECLARE @NewProducts TABLE  -- this creates temporary table to store product IDs and stock quantity
(
    ProductID INT,
    StockQuantity INT
);

-- 3. Insert sample products
INSERT INTO dbo.Products
    (ProductName, Category, Price, StockQuantity, ReorderLevel)
-- output the inserted product ids and stock quantities into the temporary "@NewProducts" table.
OUTPUT
    inserted.ProductID,
    inserted.StockQuantity
INTO @NewProducts (ProductID, StockQuantity)
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

-- 4. Log the initial stock of newly inserted products
-- Zero-stock products are skipped because the log constraint
-- does not allow QuantityChanged = 0.

INSERT INTO dbo.InventoryLogs
    (ProductID, OrderID, QuantityChanged, ChangeType, Notes)
-- Select the "ProductID" and "StockQuantity" values in the table variable (@NewProducts)
-- and save them into the "InventoryLogs" table
SELECT
    ProductID,
    NULL,
    StockQuantity,
    N'InitialStock',
    N'Initial stock loaded during sample data setup'
FROM @NewProducts
WHERE StockQuantity > 0;
GO
