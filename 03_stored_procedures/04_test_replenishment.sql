-- =====================================================
-- Inventory and Order Management System
-- Phase 4: Test stock replenishment
-- =====================================================
-- Run after 04_reporting/01_create_views.sql (this test uses dbo.vw_LowStockProducts)

USE InventoryOrderManagement;
GO

-- =====================================================
-- Test 1: Replenish ONE product manually (USB-C Hub)
-- =====================================================
DECLARE @ProductID INT =
(
    SELECT ProductID
    FROM dbo.Products
    WHERE ProductName = N'USB-C Hub'
);

-- Display the stock level before
SELECT ProductID, ProductName, StockQuantity, ReorderLevel
FROM dbo.Products
WHERE ProductID = @ProductID;

-- Add 10 units
EXEC dbo.ReplenishStock
    @ProductID = @ProductID,
    @Quantity = 10;

-- Check the inventory history for this product
SELECT
    ProductID,
    QuantityChanged,
    ChangeType,
    ChangeDate,
    Notes
FROM dbo.InventoryLogs
WHERE ProductID = @ProductID
ORDER BY InventoryLogID;
GO

-- =====================================================
-- Test 2: Identify and replenish ALL low-stock products
-- =====================================================

-- Before: products below their reorder level
SELECT *
FROM dbo.vw_LowStockProducts;

-- Replenish every low-stock product up to twice its reorder level
EXEC dbo.ReplenishLowStock
    @TargetMultiplier = 2;

-- After: this should return no rows
SELECT *
FROM dbo.vw_LowStockProducts;

-- The replenishments recorded in the inventory log
SELECT
    p.ProductName,
    l.QuantityChanged,
    l.ChangeType,
    l.ChangeDate,
    l.Notes
FROM dbo.InventoryLogs AS l
INNER JOIN dbo.Products AS p
    ON l.ProductID = p.ProductID
WHERE l.ChangeType = N'Replenishment'
ORDER BY l.InventoryLogID;
GO