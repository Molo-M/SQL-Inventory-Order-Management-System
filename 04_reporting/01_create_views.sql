-- =====================================================
-- Inventory and Order Management System
-- Phase 5: Views to simplify data access
-- =====================================================
-- The report scripts in this folder read from these views,
-- so each piece of logic (e.g. the tier thresholds) lives in one place.

USE InventoryOrderManagement;
GO

-- =====================================================
-- 1. View: Order Summary
-- =====================================================
-- One row per order: customer name, order date, total amount and number of items

CREATE OR ALTER VIEW dbo.vw_OrderSummary
AS
SELECT
    c.CustomerName,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount,
    od.TotalQuantity
FROM dbo.Orders AS o
INNER JOIN
(
    -- First group the "OrderDetails" table before joining it
    SELECT
        OrderID,
        SUM(Quantity) AS TotalQuantity
    FROM dbo.OrderDetails
    GROUP BY OrderID
) AS od
    ON o.OrderID = od.OrderID
INNER JOIN dbo.Customers AS c
    ON o.CustomerID = c.CustomerID;
GO

-- =====================================================
-- 2. View: Low Stock Products
-- =====================================================
-- Products whose stock is below their reorder level, and how many units
-- are needed to reach the reorder level

CREATE OR ALTER VIEW dbo.vw_LowStockProducts
AS
SELECT
    ProductID,
    ProductName,
    Category,
    Price,
    StockQuantity,
    ReorderLevel,
    (ReorderLevel - StockQuantity) AS QuantityNeeded
FROM dbo.Products
WHERE StockQuantity < ReorderLevel;
GO

-- =====================================================
-- 3. View: Customer Spending & Tier Level
-- =====================================================
-- Total spending per customer and their tier:
--   Gold   = 200 or more
--   Silver = 100 to 199.99
--   Bronze = below 100 (including customers with no orders)
-- Because the tier is calculated in a view, it updates automatically
-- every time a customer places an order.

CREATE OR ALTER VIEW dbo.vw_CustomerSpending
AS
SELECT
    c.CustomerID,
    c.CustomerName,
    COALESCE(SUM(o.TotalAmount), 0) AS TotalSpending,
    CASE
        WHEN COALESCE(SUM(o.TotalAmount), 0) >= 200
            THEN 'Gold'
        WHEN COALESCE(SUM(o.TotalAmount), 0) >= 100
            THEN 'Silver'
        ELSE 'Bronze'
    END AS CustomerTier
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
    ON c.CustomerID = o.CustomerID
    AND o.Status = N'Completed'   -- only completed orders count towards spending
GROUP BY
    c.CustomerID,
    c.CustomerName;
GO