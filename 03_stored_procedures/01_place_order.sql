USE InventoryOrderManagement;
GO

-- =====================================================
-- 1. Create a type for passing multiple products into an order
-- =====================================================

-- Note: A table type allows me to pass a whole table of rows into a procedure as one parameter, called a
-- "table-valued parameter"

-- A table type can't be changed while a procedure uses it, so drop the procedure
-- first, then the type, and create both again. This also makes the script re-runnable.
DROP PROCEDURE IF EXISTS dbo.PlaceOrder;
DROP TYPE IF EXISTS dbo.OrderItemType;
GO

CREATE TYPE dbo.OrderItemType AS TABLE
(
    ProductID INT NOT NULL PRIMARY KEY,  -- primary key: the same product can't be listed twice in one order
    Quantity INT NOT NULL
);
GO

-- =====================================================
-- 2. Create the order placement procedure
-- =====================================================
CREATE OR ALTER PROCEDURE dbo.PlaceOrder
    @CustomerID INT,
    @Items dbo.OrderItemType READONLY,
    @BulkDiscountThreshold INT = 5,    -- minimum number of items a customer must buy to get a discount (default 5)
    @BulkDiscountRate DECIMAL(5,4) = 0.10 -- Discount (default 10%)
AS
BEGIN
    -- Turn off output messages (inserting the order, inserting order details, updating stock, writing logs)
    SET NOCOUNT ON;

    DECLARE @OrderID INT;
    DECLARE @SubtotalAmount DECIMAL(12,2);  -- Total amount before discount
    DECLARE @DiscountAmount DECIMAL(12,2); -- Discount amount
    DECLARE @TotalAmount DECIMAL(12,2);  -- Total amount after discount
    DECLARE @TotalQuantity INT;    -- Total quantity of goods ordered by customer

    -- Validate the request (parameters) before opening a transaction.
    IF NOT EXISTS (SELECT 1 FROM @Items)
        THROW 50001, 'An order must contain at least one item.', 1;

    IF @BulkDiscountThreshold < 1
        THROW 50002, 'The discount threshold must be at least 1.', 1;

    IF @BulkDiscountRate < 0 OR @BulkDiscountRate > 1
        THROW 50003, 'The discount rate must be between 0 and 1.', 1;

    -- Begin the transaction
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Validate that all products exist
        IF EXISTS
        (
            SELECT 1
            FROM @Items AS i
            LEFT JOIN dbo.Products AS p
                ON p.ProductID = i.ProductID
            WHERE p.ProductID IS NULL
        )
            THROW 50004, 'One or more products do not exist.', 1;

        -- Validate that all quantities are positive
        IF EXISTS
        (
            SELECT 1
            FROM @Items
            WHERE Quantity <= 0
        )
            THROW 50005, 'Quantity must be greater than zero.', 1;

        -- Check that sufficient stock is available
        IF EXISTS
        (
            SELECT 1
            FROM dbo.Products AS p
            INNER JOIN @Items AS i
                ON p.ProductID = i.ProductID
            WHERE p.StockQuantity < i.Quantity
        )
            THROW 50006, 'Insufficient stock for one or more products.', 1;

        -- a) Calculate the order total
        SELECT @SubtotalAmount = SUM(p.Price * i.Quantity),
                @TotalQuantity = SUM(i.Quantity)
        FROM dbo.Products AS p
        INNER JOIN @Items AS i
            ON p.ProductID = i.ProductID;

        -- b) Then find discount
        IF @TotalQuantity >= @BulkDiscountThreshold
            SET @DiscountAmount = ROUND(@BulkDiscountRate * @SubtotalAmount, 2);
        ELSE
            SET @DiscountAmount = 0;
        -- Final amount after applying discount
        SET @TotalAmount = @SubtotalAmount - @DiscountAmount;


        -- c) Create the order
        INSERT INTO dbo.Orders
            (CustomerID, SubtotalAmount, DiscountAmount,
             TotalAmount, Status)
        VALUES
            (@CustomerID, @SubtotalAmount, @DiscountAmount,
             @TotalAmount, N'Completed');

        -- d) What OrderID did SQL Server just give the order I inserted above?
        SET @OrderID = SCOPE_IDENTITY();

        -- e) Save the products and quantities ordered
        INSERT INTO dbo.OrderDetails
            (OrderID, ProductID, Quantity, UnitPrice)
        SELECT
            @OrderID, p.ProductID, i.Quantity, p.Price
        FROM dbo.Products AS p
        INNER JOIN @Items AS i
            ON p.ProductID = i.ProductID;

        -- f) Deduct stock from each product
        UPDATE p
        SET StockQuantity = StockQuantity - i.Quantity
        FROM dbo.Products AS p
        INNER JOIN @Items AS i
            ON p.ProductID = i.ProductID;

        -- g) Record the stock changes
        INSERT INTO dbo.InventoryLogs
            (ProductID, OrderID, QuantityChanged, ChangeType, Notes)
        SELECT
            ProductID,
            @OrderID,
            -Quantity,
            N'Order',
            N'Stock deducted for order'
        FROM @Items;

        COMMIT TRANSACTION;

        -- h) Display the completed operation
        SELECT *
        FROM dbo.Orders
        WHERE OrderID = @OrderID;

    END TRY
    BEGIN CATCH
        -- IF there is an ongoing transaction (greater than 0 means Yes) after an error occured:
        IF @@TRANCOUNT > 0
            -- Rollback everything (nothing is saved)
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO