
-- =====================================================
-- Report: Customer spending and tiers
-- =====================================================
-- Reads from the view dbo.vw_CustomerSpending (01_create_views.sql)

USE InventoryOrderManagement;
GO

-- 1. Spending and tier of each customer
SELECT
    CustomerID,
    CustomerName,
    TotalSpending,
    CustomerTier
FROM dbo.vw_CustomerSpending
ORDER BY TotalSpending DESC;
GO

-- 2. Number of customers and total spending in each tier
SELECT
    CustomerTier,
    COUNT(*) AS NumberOfCustomers,
    SUM(TotalSpending) AS TierSpending
FROM dbo.vw_CustomerSpending
GROUP BY CustomerTier
ORDER BY TierSpending DESC;
GO
