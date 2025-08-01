-- benchmark_queries.sql
-- Use these queries to benchmark the performance of PostgreSQL and ClickHouse.

-- ##################
-- ## PostgreSQL
-- ##################

-- Query 1: Point Lookup
-- Fetches a single record by its primary key.
EXPLAIN ANALYZE SELECT * FROM orders_row WHERE order_id = 'your-uuid-here';

-- Query 2: Aggregation
-- Calculates the total sales amount for each region.
EXPLAIN ANALYZE SELECT region, SUM(price * quantity) AS total_sales FROM orders_row GROUP BY region;

-- Query 3: Filtering on a Range
-- Selects all orders within a specific one-month date range.
EXPLAIN ANALYZE SELECT COUNT(*) FROM orders_row WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Query 4: Analytical Query (Heavy Aggregation)
-- Finds customers who have placed more than 10 orders and counts them.
EXPLAIN ANALYZE
SELECT customer_id, COUNT(order_id) AS order_count
FROM orders_row
GROUP BY customer_id
HAVING COUNT(order_id) > 10;

-- Query 5: Full Scan Aggregation
-- Calculates the average price of all products sold.
EXPLAIN ANALYZE SELECT AVG(price) FROM orders_row;


-- ##################
-- ## ClickHouse
-- ##################

-- Query 1: Point Lookup
-- Fetches a single record by its primary key.
-- Note: Replace 'your-uuid-here' with a valid UUID from your table.
SELECT * FROM orders_columnar WHERE order_id = 'your-uuid-here';

-- Query 2: Aggregation
-- Calculates the total sales amount for each region.
SELECT region, sum(price * quantity) AS total_sales FROM orders_columnar GROUP BY region;

-- Query 3: Filtering on a Range
-- Selects all orders within a specific one-month date range.
SELECT count(*) FROM orders_columnar WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Query 4: Analytical Query (Heavy Aggregation)
-- Finds customers who have placed more than 10 orders and counts them.
SELECT customer_id, count(order_id) AS order_count
FROM orders_columnar
GROUP BY customer_id
HAVING count(order_id) > 10;

-- Query 5: Full Scan Aggregation
-- Calculates the average price of all products sold.
SELECT avg(price) FROM orders_columnar;