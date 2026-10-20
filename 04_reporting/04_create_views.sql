
-- Use our desired warehouse
USE InventoryOrderManagement;
GO

-- =====================================================
-- 1. View: Order Summary
-- =====================================================

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

CREATE OR ALTER VIEW dbo.vw_LowStockProducts
AS
-- Report to check for products that are below their reorder level
SELECT 
    ProductName, 
    Category, 
    Price, 
    StockQuantity, 
    ReorderLevel, 
    (ReorderLevel - StockQuantity) AS QuantityNeeded
FROM dbo.Products
WHERE StockQuantity < ReorderLevel
GO

-- =====================================================
-- 3. View: Customer Spending & Tier Level
-- =====================================================

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
GROUP BY
    c.CustomerID,
    c.CustomerName
GO