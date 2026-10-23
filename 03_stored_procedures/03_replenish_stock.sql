-- =====================================================
-- Inventory and Order Management System
-- Phase 4: Stock Replenishment
-- =====================================================

USE InventoryOrderManagement;
GO

-- =====================================================
-- 1. Replenish ONE product by a chosen quantity
-- =====================================================
CREATE OR ALTER PROCEDURE dbo.ReplenishStock
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate the quantity before opening a transaction
    IF @Quantity <= 0
        THROW 50008, 'Replenishment quantity must be greater than zero.', 1;

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

-- =====================================================
-- 2. Find and replenish ALL low-stock products at once
-- =====================================================
-- Every product whose stock is below its reorder level is topped up
-- to (ReorderLevel x @TargetMultiplier). For example, with the default
-- multiplier of 2, a product with a reorder level of 10 is topped up to 20.
CREATE OR ALTER PROCEDURE dbo.ReplenishLowStock
    @TargetMultiplier INT = 2
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate the parameter before opening a transaction
    IF @TargetMultiplier < 1
        THROW 50009, 'The target multiplier must be at least 1.', 1;

    -- Temporary table to remember which products were replenished, and by how much
    DECLARE @Replenished TABLE
    (
        ProductID INT,
        QuantityAdded INT
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        -- a) Identify the low-stock products and how much each one needs.
        --    UPDLOCK, HOLDLOCK locks these rows so another order can't change
        --    their stock between this step and the update below.
        INSERT INTO @Replenished (ProductID, QuantityAdded)
        SELECT
            ProductID,
            (ReorderLevel * @TargetMultiplier) - StockQuantity
        FROM dbo.Products WITH (UPDLOCK, HOLDLOCK)
        WHERE StockQuantity < ReorderLevel;

        -- b) Increase the stock of those products
        UPDATE p
        SET StockQuantity = p.StockQuantity + r.QuantityAdded
        FROM dbo.Products AS p
        INNER JOIN @Replenished AS r
            ON p.ProductID = r.ProductID;

        -- c) Record each replenishment in the inventory log
        INSERT INTO dbo.InventoryLogs
            (ProductID, OrderID, QuantityChanged, ChangeType, Notes)
        SELECT
            ProductID,
            NULL,
            QuantityAdded,
            N'Replenishment',
            N'Low-stock product replenished automatically'
        FROM @Replenished;

        COMMIT TRANSACTION;

        -- d) Display what was replenished
        --    (if no product was low on stock, this returns no rows)
        SELECT
            p.ProductID,
            p.ProductName,
            r.QuantityAdded,
            p.StockQuantity AS NewStockQuantity,
            p.ReorderLevel
        FROM dbo.Products AS p
        INNER JOIN @Replenished AS r
            ON p.ProductID = r.ProductID
        ORDER BY p.ProductName;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO