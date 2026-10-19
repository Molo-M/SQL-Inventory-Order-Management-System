USE InventoryOrderManagement;
GO

-- Display the stock level
SELECT ProductID, ProductName, StockQuantity
FROM dbo.Products
WHERE ProductID = 3;
GO

-- Begin the replenishment
EXEC dbo.ReplenishStock
    @ProductID = 3,
    @Quantity = 10;

-- Check the inventory history for this product
SELECT
    ProductID,
    QuantityChanged,
    ChangeType,
    ChangeDate,
    Notes
FROM dbo.InventoryLogs
WHERE ProductID = 3
ORDER BY InventoryLogID;
GO
