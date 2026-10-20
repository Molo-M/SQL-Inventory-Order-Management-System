-- Use our desired warehouse
USE InventoryOrderManagement;
GO

-- Report to check for products that are below their reorder level
SELECT ProductName, Category, Price, StockQuantity, ReorderLevel, (ReorderLevel - StockQuantity) AS QuantityNeeded
FROM dbo.Products
WHERE StockQuantity < ReorderLevel
GO