
USE InventoryOrderManagement;
GO

CREATE OR ALTER PROCEDURE dbo.ReplenishStock
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Increase stock for the selected product
        UPDATE dbo.Products
        SET StockQuantity = StockQuantity + @Quantity
        WHERE ProductID = @ProductID;

        -- Check that the product exists
        IF @@ROWCOUNT = 0
            THROW 50007, 'Product does not exist.', 1;

        -- Record the replenishment in the inventory log
        INSERT INTO dbo.InventoryLogs
            (ProductID, OrderID, QuantityChanged, ChangeType, Notes)
        VALUES
            (
                @ProductID,
                NULL,
                @Quantity,
                N'Replenishment',
                N'Stock replenished'
            );

        COMMIT TRANSACTION;

        -- Display the updated stock level
        SELECT ProductID, ProductName, StockQuantity
        FROM dbo.Products
        WHERE ProductID = @ProductID;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
