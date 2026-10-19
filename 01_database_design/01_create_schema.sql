
-- =====================================================
-- Inventory and Order Management System
-- Phase 1: Database Schema
-- Database: SQL Server Express
-- =====================================================

-- 1. Create the database if it does not exist
IF DB_ID(N'InventoryOrderManagement') IS NULL
BEGIN
    CREATE DATABASE InventoryOrderManagement;
END;
GO

-- Enter database
USE InventoryOrderManagement;
GO

-- 2. Create Customers table --------------------------------------------------------------------------------
CREATE TABLE dbo.Customers
(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Phone NVARCHAR(30) NULL
);
GO

-- 3. Create table: Products --------------------------------------------------------------------------------
CREATE TABLE dbo.Products
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(150) NOT NULL,
    Category NVARCHAR(100) NOT NULL,
    Price DECIMAL(12,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    ReorderLevel INT NOT NULL DEFAULT 10,  -- Quantity amount below which there is an alert of low stock: e.g below 10 apples create alert

    CONSTRAINT CK_Products_Price
        CHECK (Price >= 0),

    CONSTRAINT CK_Products_StockQuantity
        CHECK (StockQuantity >= 0),

    CONSTRAINT CK_Products_ReorderLevel
        CHECK (ReorderLevel >= 0)
);
GO

-- 4. Orders --------------------------------------------------------------------------------
CREATE TABLE dbo.Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME2(0) NOT NULL
        DEFAULT SYSUTCDATETIME(),
    SubtotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0,   -- Normal product amount: e.g $1000 
    DiscountAmount DECIMAL(12,2) NOT NULL DEFAULT 0,    -- Discount product amount: e.g $200 
    TotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0,       -- Amount after discount: e.g $1000 - $200 = $800
    Status NVARCHAR(20) NOT NULL DEFAULT N'Pending',

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),

    CONSTRAINT CK_Orders_Amounts
        CHECK (
            SubtotalAmount >= 0
            AND DiscountAmount >= 0
            AND DiscountAmount <= SubtotalAmount
            AND TotalAmount >= 0
        ),

    CONSTRAINT CK_Orders_Total
        CHECK (TotalAmount = SubtotalAmount - DiscountAmount),

    CONSTRAINT CK_Orders_Status
        CHECK (
            Status IN (N'Pending', N'Completed', N'Cancelled')
        )
);
GO

-- 5. OrderDetails --------------------------------------------------------------------------------
CREATE TABLE dbo.OrderDetails
(
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,

    CONSTRAINT PK_OrderDetails
        PRIMARY KEY (OrderID, ProductID),

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders(OrderID),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES dbo.Products(ProductID),

    CONSTRAINT CK_OrderDetails_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CK_OrderDetails_UnitPrice
        CHECK (UnitPrice >= 0)
);
GO

-- 6. InventoryLogs --------------------------------------------------------------------------------
CREATE TABLE dbo.InventoryLogs
(
    InventoryLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    OrderID INT NULL,
    QuantityChanged INT NOT NULL,
    ChangeType NVARCHAR(20) NOT NULL,  --Order, Replenishment, Cancellation, etc.
    ChangeDate DATETIME2(0) NOT NULL
        DEFAULT SYSUTCDATETIME(),
    Notes NVARCHAR(255) NULL,

    CONSTRAINT FK_InventoryLogs_Products
        FOREIGN KEY (ProductID)
        REFERENCES dbo.Products(ProductID),

    CONSTRAINT FK_InventoryLogs_Orders
        FOREIGN KEY (OrderID)
        REFERENCES dbo.Orders(OrderID),

    CONSTRAINT CK_InventoryLogs_QuantityChanged
        CHECK (QuantityChanged <> 0),

    CONSTRAINT CK_InventoryLogs_ChangeType
        CHECK (
            ChangeType IN (
                N'InitialStock',
                N'Order',
                N'Replenishment',
                N'Adjustment',
                N'Cancellation'
            )
        ),

    CONSTRAINT CK_InventoryLogs_OrderReference
        CHECK (
            (
                ChangeType IN (N'Order', N'Cancellation')
                AND OrderID IS NOT NULL
            )
            OR
            (
                ChangeType NOT IN (N'Order', N'Cancellation')
                AND OrderID IS NULL
            )
        )
);
GO
