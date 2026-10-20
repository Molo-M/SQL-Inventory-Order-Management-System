
-- Use our desired warehouse
USE InventoryOrderManagement;
GO

-- Report customer spending and assign customer tiers
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
ORDER BY
    TotalSpending DESC;
GO