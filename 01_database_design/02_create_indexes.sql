
-- =====================================================
-- Inventory and Order Management System
-- Phase 5: Indexes for performance
-- =====================================================
-- SQL Server automatically indexes primary keys, but NOT foreign keys.
-- These indexes speed up the joins and lookups that the procedures,
-- views and reports use, so they stay fast as the number of
-- customers, orders and products grows.

USE InventoryOrderManagement;
GO

-- Find all orders of a customer (order summary, customer spending tiers)
DROP INDEX IF EXISTS IX_Orders_CustomerID ON dbo.Orders;
CREATE INDEX IX_Orders_CustomerID
    ON dbo.Orders (CustomerID);
GO

-- Find all order lines of a product
-- (lookups by OrderID are already covered by the primary key (OrderID, ProductID))
DROP INDEX IF EXISTS IX_OrderDetails_ProductID ON dbo.OrderDetails;
CREATE INDEX IX_OrderDetails_ProductID
    ON dbo.OrderDetails (ProductID);
GO

-- Find the inventory history of a product, in date order (auditing)
DROP INDEX IF EXISTS IX_InventoryLogs_ProductID_ChangeDate ON dbo.InventoryLogs;
CREATE INDEX IX_InventoryLogs_ProductID_ChangeDate
    ON dbo.InventoryLogs (ProductID, ChangeDate);
GO

-- Find the stock changes caused by an order
DROP INDEX IF EXISTS IX_InventoryLogs_OrderID ON dbo.InventoryLogs;
CREATE INDEX IX_InventoryLogs_OrderID
    ON dbo.InventoryLogs (OrderID);
GO
