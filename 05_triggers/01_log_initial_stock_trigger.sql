
USE InventoryOrderManagement;
GO

-- Automatically log the initial stock of newly inserted products
CREATE OR ALTER TRIGGER dbo.trg_LogInitialProductStock
ON dbo.Products
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.InventoryLogs
        (ProductID, OrderID, QuantityChanged, ChangeType, Notes)
    SELECT
        ProductID,
        NULL,
        StockQuantity,
        N'InitialStock',
        N'Initial stock recorded when product was added'
    FROM inserted
    WHERE StockQuantity > 0;
END;
GO
