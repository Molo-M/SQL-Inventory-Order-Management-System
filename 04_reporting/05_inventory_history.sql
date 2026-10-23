
-- =====================================================
-- Report: Inventory history (audit trail)
-- =====================================================

USE InventoryOrderManagement;
GO

-- 1. Full history of every stock change, oldest first
SELECT
    l.InventoryLogID,
    l.ChangeDate,
    p.ProductName,
    l.ChangeType,
    l.QuantityChanged,
    l.OrderID,     -- filled in for changes caused by an order
    l.Notes
FROM dbo.InventoryLogs AS l
INNER JOIN dbo.Products AS p
    ON l.ProductID = p.ProductID
ORDER BY
    l.ChangeDate,
    l.InventoryLogID;
GO

-- 2. Audit check: the current stock of each product should equal
--    the sum of all its logged changes. "Mismatch" means stock was
--    changed somewhere without being logged.
SELECT
    p.ProductName,
    p.StockQuantity AS CurrentStock,
    COALESCE(SUM(l.QuantityChanged), 0) AS LoggedStock,
    CASE
        WHEN p.StockQuantity = COALESCE(SUM(l.QuantityChanged), 0)
            THEN 'OK'
        ELSE 'Mismatch'
    END AS AuditResult
FROM dbo.Products AS p
LEFT JOIN dbo.InventoryLogs AS l
    ON p.ProductID = l.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.StockQuantity
ORDER BY p.ProductName;
GO
