-- Use our desired warehouse
USE InventoryOrderManagement;
GO

-- Make the Query Report
SELECT c.CustomerName, od.OrderID, o.OrderDate, o.TotalAmount, od.TotalQuantity
FROM dbo.Orders o
INNER JOIN (
	-- First group the "OrderDetails" table before joining it
	SELECT OrderId, SUM(Quantity) AS TotalQuantity
	FROM dbo.OrderDetails
	GROUP BY OrderId
) AS od
 ON o.OrderId = od.OrderId
INNER JOIN dbo.Customers c
ON o.CustomerID = c.CustomerID
GO