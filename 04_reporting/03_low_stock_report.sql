
-- =====================================================
-- Report: Products that need replenishment
-- =====================================================
-- Reads from the view dbo.vw_LowStockProducts (01_create_views.sql)
-- Most urgent products (largest shortfall) are listed first.

USE InventoryOrderManagement;
GO

SELECT
    ProductName,
    Category,
    StockQuantity,
    ReorderLevel,
    QuantityNeeded
FROM dbo.vw_LowStockProducts
ORDER BY QuantityNeeded DESC;
GO
