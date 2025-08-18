# Quick-ecommerce-inventory-analytics-sql
PostgreSQL SQL scripts to explore, clean, and analyze the Zepto Inventory dataset—covering data quality checks, business queries (revenue, discounts, stock health), and ready-to-run setup with sample outputs.
# Zepto Inventory Analytics (PostgreSQL)

SQL-first exploration, cleaning, and business analysis for the **[Zepto Inventory Dataset](https://www.kaggle.com/datasets/palvinder2006/zepto-inventory-dataset/data)**.  
This repo provides a ready-to-run PostgreSQL script that:

- Creates a clean `zepto` table with appropriate types
- Performs data exploration (row counts, null checks, duplicates)
- Cleans records (zero prices, paise→rupees conversion)
- Answers key business questions (top discounts, revenue by category, stock health, best value per gram, etc.)

---

## Contents

├─ /sql
│ └─ zepto_inventory_analysis.sql # Full script: DDL + Exploration + Cleaning + Business queries
├─ /docs
└─ README.md

---

## Prerequisites

- **PostgreSQL 13+**
- Access to the Kaggle dataset CSV(s)

> If the dataset stores monetary amounts in paise, the script already converts to rupees.

---

## Quick Start

1. **Create a database (optional)**
   ```sql
2.Connect to the database
psql -d zepto_db
3.Run the master SQL script
Run the master SQL script
4.Load data from CSV
-- Example COPY command (edit file path & header accordingly)
COPY zepto(category, name, mrp, discountPercent, availableQuantity, dicountedsellingPrice, weightInGms, outofstock, quantity)
FROM '/absolute/path/to/your/zepto.csv'
DELIMITER ','
CSV HEADER;

Schema
DROP TABLE IF EXISTS zepto;
CREATE TABLE zepto(
  sku_id SERIAL PRIMARY KEY,
  category VARCHAR(120),
  name VARCHAR(150) NOT NULL,
  mrp NUMERIC(8,2),
  discountPercent NUMERIC(5,2),
  availableQuantity INTEGER,
  dicountedsellingPrice NUMERIC(8,2),
  weightInGms INTEGER,
  outofstock BOOLEAN,
  quantity INTEGER
);
Data Exploration
-- Count rows
SELECT COUNT(*) FROM zepto;

-- Sample
SELECT * FROM zepto LIMIT 10;

-- Null checks
SELECT *
FROM zepto
WHERE name IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR availableQuantity IS NULL
   OR dicountedsellingPrice IS NULL
   OR weightInGms IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- Distinct categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- In-stock vs out-of-stock
SELECT outofstock, COUNT(sku_id)
FROM zepto
GROUP BY outofstock;

-- Product names appearing multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

Data Cleaning
-- Products with MRP = 0
SELECT * FROM zepto WHERE mrp = 0;

-- Remove zero priced rows (business decision)
DELETE FROM zepto WHERE mrp = 0;

-- Convert paise to rupees (if dataset is in paise)
UPDATE zepto
SET mrp = mrp / 100.0,
    dicountedsellingPrice = dicountedsellingPrice / 100.0;

Business Queries
Q1. Top 10 best-value products by discount %
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

Q2. High MRP but Out of Stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outofstock = TRUE AND mrp > 300
ORDER BY mrp DESC;

Q3. Estimated Revenue per Category
SELECT category,
       SUM(dicountedsellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

Q4. MRP > 500 and Discount < 10%
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

Q5. Top 5 Categories with Highest Avg Discount
SELECT category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

Q6. Price per gram (for products ≥ 100g), best value first
SELECT DISTINCT name, weightInGms, dicountedsellingPrice,
       ROUND(dicountedsellingPrice::numeric / NULLIF(weightInGms, 0), 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

Q7. Weight Buckets (Low / Medium / Bulk)
SELECT DISTINCT name, weightInGms,
       CASE
         WHEN weightInGms < 1000  THEN 'Low'
         WHEN weightInGms < 5000  THEN 'Medium'
         ELSE 'Bulk'
       END AS weight_category
FROM zepto;

Q8. Total Inventory Weight per Category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;

Tips & Notes

Units: Ensure you know if prices are in paise or rupees before running the conversion step.

Duplicates: Consider using a deduplication strategy for name if the data has multiple SKUs per product (e.g., keep latest or highest stock).

Indexing: For larger datasets, add indexes to speed up analysis:

CREATE INDEX ON zepto (category);
CREATE INDEX ON zepto (outofstock);
CREATE INDEX ON zepto (discountPercent);
CREATE INDEX ON zepto (mrp);
   CREATE DATABASE zepto_db;
