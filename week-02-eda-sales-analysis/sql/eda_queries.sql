-- ------------------------------------------------------------
-- SCHEMA
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS sales_db;
USE sales_db;

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    OrderID         VARCHAR(50) PRIMARY KEY,
    `Date`          DATE,
    CustomerID      VARCHAR(50),
    Product         VARCHAR(100),
    Quantity        INT,
    UnitPrice       DECIMAL(10,2),
    ShippingAddress VARCHAR(255),
    PaymentMethod   VARCHAR(50),
    OrderStatus     VARCHAR(50),
    TrackingNumber  VARCHAR(50),
    ItemsInCart     INT,
    CouponCode      VARCHAR(50),
    ReferralSource  VARCHAR(50),
    TotalPrice      DECIMAL(10,2),
    INDEX idx_date (`Date`),
    INDEX idx_customer (CustomerID),
    INDEX idx_payment_status (PaymentMethod, OrderStatus)
);

-- Load your cleaned dataset into this table here
-- (e.g. via MySQL Workbench Table Data Import Wizard, or LOAD DATA INFILE)


-- ============================================================
-- WEEK 2 — EXPLORATORY DATA ANALYSIS (EDA)
-- ============================================================

-- 1. Basic statistics: count, mean, min, max for numeric fields
SELECT
    COUNT(*)          AS total_orders,
    AVG(Quantity)      AS avg_quantity,
    AVG(UnitPrice)     AS avg_unit_price,
    AVG(TotalPrice)    AS avg_total_price,
    MIN(TotalPrice)    AS min_total_price,
    MAX(TotalPrice)    AS max_total_price
FROM orders;

-- 2. Median TotalPrice (MySQL has no MEDIAN() function, so I derived it
--    via ROW_NUMBER over the ordered set)
SELECT AVG(TotalPrice) AS median_total_price
FROM (
    SELECT TotalPrice,
           ROW_NUMBER() OVER (ORDER BY TotalPrice) AS rn,
           COUNT(*) OVER ()                        AS cnt
    FROM orders
) t
WHERE rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2));

-- 3 & 4. Quartiles (Q1 / Q3) via NTILE, then IQR-based outlier detection
--    Combined into a single NTILE pass (computed once, reused for both bounds)
--    rather than three separate NTILE scans.
SELECT
    MAX(CASE WHEN q = 1 THEN TotalPrice END) INTO @q1,
    MAX(CASE WHEN q = 3 THEN TotalPrice END) INTO @q3
FROM (
    SELECT TotalPrice, NTILE(4) OVER (ORDER BY TotalPrice) AS q
    FROM orders
) x;

SET @iqr = @q3 - @q1;

-- Sanity check: view the computed bounds before trusting the outlier list
SELECT @q1 AS q1_boundary, @q3 AS q3_boundary, @iqr AS iqr;

SELECT *
FROM orders
WHERE TotalPrice < (@q1 - 1.5 * @iqr)
   OR TotalPrice > (@q3 + 1.5 * @iqr);

-- 5. Trend over time: monthly revenue and order volume
SELECT
    DATE_FORMAT(`Date`, '%Y-%m') AS month,
    COUNT(*)                     AS order_count,
    SUM(TotalPrice)              AS monthly_revenue
FROM orders
GROUP BY month
ORDER BY month;

-- 6. Correlation between Quantity and TotalPrice (Pearson's r, manual
--    formula since MySQL has no CORR() function).
SELECT
    (COUNT(*) * SUM(Quantity * TotalPrice) - SUM(Quantity) * SUM(TotalPrice)) /
    (SQRT(COUNT(*) * SUM(Quantity * Quantity) - POW(SUM(Quantity), 2)) *
     SQRT(COUNT(*) * SUM(TotalPrice * TotalPrice) - POW(SUM(TotalPrice), 2)))
    AS correlation_qty_totalprice
FROM orders;

-- 7. OrderStatus breakdown by payment method — is cancellation concentrated anywhere?
SELECT
    PaymentMethod,
    OrderStatus,
    COUNT(*) AS order_count
FROM orders
GROUP BY PaymentMethod, OrderStatus
ORDER BY PaymentMethod, order_count DESC;
