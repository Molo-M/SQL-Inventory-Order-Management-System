
USE InventoryOrderManagement;
GO

DECLARE @Items dbo.OrderItemType;

-- Order 2 Wireless Keyboards
INSERT INTO @Items (ProductID, Quantity)
SELECT ProductID, 2
FROM dbo.Products
WHERE ProductName = N'Wireless Keyboard';

-- Order 3 Wireless Mice
INSERT INTO @Items (ProductID, Quantity)
SELECT ProductID, 3
FROM dbo.Products
WHERE ProductName = N'Wireless Mouse';

-- Place the order for customer 1
EXEC dbo.PlaceOrder
    @CustomerID = 1,
    @Items = @Items;
GO
