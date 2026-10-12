SELECT * 
FROM database.default.bright_coffee_shop_analysis 
LIMIT 100;

-- 2. See only specific columns
SELECT transaction_date, store_location, product_category, product_detail, transaction_qty * unit_price AS revenue
FROM database.default.bright_coffee_shop_analysis
LIMIT 10;

-- 3. Filter: All Coffee sales only
SELECT * 
FROM database.default.bright_coffee_shop_analysis
WHERE product_category = 'Coffee'
LIMIT 10;

-- 4. Filter: Sales from Lower Manhattan in January 2023
SELECT * FROM database.default.bright_coffee_shop_analysis
WHERE store_location = 'Lower Manhattan'
AND transaction_date BETWEEN '2023-01-01' AND '2023-01-31'
LIMIT 10;

-- 5. Sort: Most expensive items first
SELECT product_detail, unit_price, product_category
FROM database.default.bright_coffee_shop_analysis
ORDER BY unit_price DESC
LIMIT 10;

-- 6. Distinct values: What store locations do we have?
SELECT DISTINCT store_location 
FROM database.default.bright_coffee_shop_analysis;

-- 7. Distinct values: What product categories?
SELECT DISTINCT product_category 
FROM database.default.bright_coffee_shop_analysis;

-- 8. How many transactions total?
SELECT COUNT(*) AS total_transactions 
FROM database.default.bright_coffee_shop_analysis;

-- 9. Total revenue overall
SELECT SUM(transaction_qty * unit_price) AS total_revenue 
FROM database.default.bright_coffee_shop_analysis;

-- 10. Total revenue per store location
SELECT 
  store_location,
  SUM(transaction_qty * unit_price) AS total_revenue,
  COUNT(*) AS num_transactions,
  SUM(transaction_qty) AS total_items_sold
FROM database.default.bright_coffee_shop_analysis
GROUP BY store_location
ORDER BY total_revenue DESC;

-- 11. Revenue per product category
SELECT
  product_category,
  SUM(transaction_qty * unit_price) AS total_revenue,
  AVG(unit_price) AS avg_price
FROM database.default.bright_coffee_shop_analysis
GROUP BY product_category
ORDER BY total_revenue DESC;

-- 12. Top 10 best selling products
SELECT
  product_detail,
  product_category,
  SUM(transaction_qty) AS total_qty_sold,
  SUM(transaction_qty * unit_price) AS total_revenue
FROM database.default.bright_coffee_shop_analysis
GROUP BY product_detail, product_category
ORDER BY total_qty_sold DESC
LIMIT 10;

-- 13. Sales by day
SELECT
  transaction_date,
  SUM(transaction_qty * unit_price) AS daily_revenue,
  COUNT(*) AS daily_transactions
FROM database.default.bright_coffee_shop_analysis
GROUP BY transaction_date
ORDER BY transaction_date;

-- 14. Sales by month (great for trends)
SELECT
  DATE_TRUNC('month', transaction_date) AS month,
  SUM(transaction_qty * unit_price) AS monthly_revenue,
  SUM(transaction_qty) AS items_sold
FROM database.default.bright_coffee_shop_analysis
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY month;

-- 15. What day of week is busiest?
SELECT
  DAYOFWEEK(transaction_date) AS day_number, -- 1=Sunday
  DATE_FORMAT(transaction_date, 'EEEE') AS day_name,
  COUNT(*) AS transactions,
  SUM(transaction_qty * unit_price) AS revenue
FROM database.default.bright_coffee_shop_analysis
GROUP BY DAYOFWEEK(transaction_date), DATE_FORMAT(transaction_date, 'EEEE')
ORDER BY transactions DESC;

-- 16. What hour of day is busiest?
SELECT
  HOUR(transaction_time) AS hour_of_day,
  COUNT(*) AS transactions,
  SUM(transaction_qty * unit_price) AS revenue
FROM database.default.bright_coffee_shop_analysis
GROUP BY HOUR(transaction_time)
ORDER BY hour_of_day;

-- 17. Only product types that sold more than 1000 items
SELECT
  product_type,
  SUM(transaction_qty) AS total_qty
FROM database.default.bright_coffee_shop_analysis
GROUP BY product_type
HAVING SUM(transaction_qty) > 1000
ORDER BY total_qty DESC;

-- 18. Stores with average transaction > $5
SELECT
  store_location,
  AVG(transaction_qty * unit_price) AS avg_transaction_value
FROM database.default.bright_coffee_shop_analysis
GROUP BY store_location
HAVING AVG(transaction_qty * unit_price) > 5
ORDER BY avg_transaction_value DESC;

-- 19. Create categories: Cheap, Medium, Expensive using CASE
SELECT
  product_detail,
  unit_price,
  CASE 
    WHEN unit_price < 3 THEN 'Cheap'
    WHEN unit_price BETWEEN 3 AND 4 THEN 'Medium'
    ELSE 'Expensive'
  END AS price_tier
FROM database.default.bright_coffee_shop_analysis
LIMIT 20;

-- 20. Revenue by price tier and store
SELECT
  store_location,
  CASE 
    WHEN unit_price < 3 THEN 'Cheap'
    WHEN unit_price BETWEEN 3 AND 4 THEN 'Medium'
    ELSE 'Expensive'
  END AS price_tier,
  SUM(transaction_qty * unit_price) AS total_revenue
FROM database.default.bright_coffee_shop_analysis
GROUP BY store_location, CASE WHEN unit_price < 3 THEN 'Cheap' WHEN unit_price BETWEEN 3 AND 4 THEN 'Medium' ELSE 'Expensive' END
ORDER BY store_location, total_revenue DESC;

-- 21. Morning vs Afternoon vs Evening sales
SELECT
  CASE
    WHEN HOUR(transaction_time) < 12 THEN 'Morning'
    WHEN HOUR(transaction_time) < 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS time_of_day,
  COUNT(*) AS transactions,
  SUM(transaction_qty * unit_price) AS revenue
FROM database.default.bright_coffee_shop_analysis
GROUP BY CASE WHEN HOUR(transaction_time) < 12 THEN 'Morning' WHEN HOUR(transaction_time) < 17 THEN 'Afternoon' ELSE 'Evening' END
ORDER BY revenue DESC;

-- =============================================
-- PART 6: WINDOW FUNCTIONS (Slightly Advanced but Useful)
-- =============================================

-- 22. Rank products by revenue within each category
SELECT
  product_category,
  product_detail,
  SUM(transaction_qty * unit_price) AS total_revenue,
  RANK() OVER (PARTITION BY product_category ORDER BY SUM(transaction_qty * unit_price) DESC) AS rank_in_category
FROM database.default.bright_coffee_shop_analysis
GROUP BY product_category, product_detail
ORDER BY product_category, rank_in_category;

-- 23. Running total revenue by date
SELECT
  transaction_date,
  SUM(transaction_qty * unit_price) AS daily_revenue,
  SUM(SUM(transaction_qty * unit_price)) OVER (ORDER BY transaction_date) AS running_total_revenue
FROM database.default.bright_coffee_shop_analysis
GROUP BY transaction_date
ORDER BY transaction_date;


-- 24. Check for nulls
SELECT
  COUNT(*) AS total_rows,
  SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_prices,
  SUM(CASE WHEN store_location IS NULL THEN 1 ELSE 0 END) AS null_locations
FROM database.default.bright_coffee_shop_analysis;

--25. Final Coding

SELECT
  transaction_id,
  transaction_date,
  transaction_time,
  transaction_time AS transaction_timestamp,
  transaction_qty,
  store_id,
  store_location,
  product_id,
  CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS unit_price,
  CAST(transaction_qty AS INT) * CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS revenue,
  product_category,
  product_type,
  product_detail,
  MONTH(TO_DATE(transaction_date, 'yyyy-MM-dd')) AS month_number,
  DATE_FORMAT(TO_DATE(transaction_date, 'yyyy-MM-dd'), 'MMMM') AS month_name
FROM database.default.bright_coffee_shop_analysis
WHERE TO_DATE(transaction_date, 'yyyy-MM-dd') BETWEEN '2023-01-01' AND '2023-06-30'
ORDER BY transaction_date ASC;
