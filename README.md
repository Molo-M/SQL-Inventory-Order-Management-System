# Inventory and Order Management System


## Project Overview: Problem Statement


You are tasked with designing and implementing a database-driven system to manage the inventory and orders for an e-commerce company. The system needs to handle product information, customer data, and order processing efficiently while ensuring that stock levels are properly updated when orders are placed. Additionally, the company wants to track all inventory changes and streamline processes related to stock replenishment.

---

## ERD Diagram

![erd diagram showing table relationships](erd_diagram.png)

---

## Tools and Technologies

The project was implemented using the following tools and technologies:

- **Microsoft SQL Server Express:** Used as the relational database management system to store and manage customers, products, orders, order details, and inventory logs.
- **SQL Server Management Studio (SSMS):** Used to create and manage the database, execute SQL scripts, implement stored procedures and views, and test the system's functionality.
- **Transact-SQL (T-SQL):** Used to define the database schema, enforce data integrity, process orders, calculate bulk discounts, update stock levels, record inventory changes, and generate reports.
- **Visual Studio Code (VS Code):** Used to organize and edit the SQL scripts and project documentation.
- **Git and GitHub:** Used for version control, tracking changes, and hosting the project repository.

---

## Project Structure

The repository is organized into folders to separate database design, sample data, stored procedures, and reporting scripts.

```text
SQL-Inventory-Order-Management/
│
├── 01_database_design/
│   └── 01_create_schema.sql
│
├── 02_sample_data/
│   └── 01_insert_sample_data.sql
│
├── 03_stored_procedures/
│   ├── 01_place_order.sql
│   ├── 02_test_place_order.sql
│   ├── 03_replenish_stock.sql
│   └── 04_test_replenishment.sql
│
├── 04_reporting/
│   ├── 01_order_summary.sql
│   ├── 02_low_stock_report.sql
│   ├── 03_customer_spending_tiers.sql
│   └── 04_create_views.sql
│
├── 05_triggers/
│   └── 01_log_initial_stock_trigger.sql
│
├── erd_diagram.png
└── README.md
```

### Folder and File Descriptions

**`01_database_design/`**

- `01_create_schema.sql`: Creates the database and defines the five tables, their relationships, and data integrity constraints.

**`02_sample_data/`**

- `01_insert_sample_data.sql`: Inserts sample customer, product, and initial inventory data for testing the system.

**`03_stored_procedures/`**

- `01_place_order.sql`: Defines the `PlaceOrder` stored procedure, which validates orders, calculates totals and bulk discounts, deducts stock, and records inventory changes.
- `02_test_place_order.sql`: Demonstrates and tests the order placement procedure.
- `03_replenish_stock.sql`: Defines the `ReplenishStock` stored procedure for increasing product stock and recording replenishment activity.
- `04_test_replenishment.sql`: Tests stock replenishment and verifies the resulting inventory changes.

**`04_reporting/`**

- `01_order_summary.sql`: Retrieves order summaries, including customer names, order dates, totals, and quantities ordered.
- `02_low_stock_report.sql`: Identifies products whose stock levels have fallen below their reorder levels.
- `03_customer_spending_tiers.sql`: Calculates customer spending and categorizes customers into Bronze, Silver, and Gold tiers.
- `04_create_views.sql`: Creates reusable views for order summaries and low-stock products.

**`05_triggers/`**

- `01_log_initial_stock_trigger.sql`: Updates the inventory log after adding product to the stock.

**Root files**

- `erd_diagram.png`: Entity Relationship Diagram (ERD) illustrating the database tables and their relationships.
- `README.md`: Documents the project objectives, technologies, database design, implementation, and deliverables.

## Project Objectives

### Phase 1: Database Design and Schema Implementation

1. **Create the necessary tables** — Design a database schema to track the following:

   - **Products:** Product ID, name, category, price, stock quantity, and reorder level
   - **Customers:** Customer ID, name, email, and phone number
   - **Orders:** Order ID, customer ID, order date, and total amount
   - **Order Details:** Products ordered, their quantities, and their prices
   - **Inventory Logs:** All changes made to inventory, including stock adjustments when orders are placed or products are replenished

2. **Enforce data integrity:**
   - Implement relationships between tables to maintain consistency (e.g., each order should be linked to a valid customer, and order details should correspond to valid products)

---

### Phase 2: Order Placement and Inventory Management

1. **Handle order placements efficiently:**
   - Design a way to process new orders from customers
   - When an order is placed, deduct the correct quantity from stock and calculate the total order amount
   - Update order details and track how much stock is being used per order
   - Ensure the system can handle multiple products in a single order

2. **Track inventory changes:**
   - Every time a stock level changes (due to an order or replenishment), record the change in an inventory log table
   - The log should store: when the change occurred, which product was affected, and how much the stock changed
   - Ensure a full history of inventory changes is retrievable for auditing purposes

---

### Phase 3: Monitoring and Reporting

1. **Create business insights and summaries:**
   - Display summaries of orders — including order date, total amount, and number of items — per customer
   - Generate reports identifying products that are low on stock and need replenishment (any product with stock below its reorder point should be flagged)

2. **Customer insights:**
   - Categorize customers based on total spending (e.g., Bronze, Silver, Gold tiers) and generate spending reports
   - Apply bulk discounts based on quantity ordered — if a customer orders in large quantities, apply appropriate discounts

---

### Phase 4: Stock Replenishment and Automation

1. **Implement stock replenishment:**
   - Design a mechanism to replenish stock for products that fall below the reorder point
   - Ensure the inventory log is updated to reflect all replenishment changes

2. **Automate processes:**
   - Automate stock level updates after an order is placed
   - Automate total amount calculation for each order
   - Automate customer tier categorization based on spending
   - Minimize manual work while ensuring accuracy in inventory tracking and order management

---

### Phase 5: Advanced Queries and Optimizations

1. **Create views to simplify data access:**
   - A view summarizing order information: customer name, order date, total amount, and number of items per order
   - A view displaying stock information: products that are low on stock and need to be reordered

2. **Optimize for performance:**
   - Optimize queries to ensure the system performs efficiently as the number of customers, orders, and products grows

---

## Project Deliverables

| Deliverable | Description |
|---|---|
| Database Schema | SQL scripts used to create tables, along with relationships and constraints |
| SQL Queries | Queries demonstrating order placement and stock updates, inventory tracking, and customer categorization based on spending |
| Views | SQL scripts for views summarizing order and product stock information |
| Replenishment System | Demonstration of how the system identifies low-stock products and replenishes them |
| Report Summaries | Sample queries showing how to retrieve order summaries and stock insights |