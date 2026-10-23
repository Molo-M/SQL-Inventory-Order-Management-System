
-- =====================================================
-- Report: Order summary per customer
-- =====================================================
-- Reads from the view dbo.vw_OrderSummary (01_create_views.sql)

USE InventoryOrderManagement;
GO

SELECT
    CustomerName,
    OrderID,
    OrderDate,
    TotalAmount,
    TotalQuantity
FROM dbo.vw_OrderSummary
ORDER BY
    CustomerName,
    OrderDate;
GO
