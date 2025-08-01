-- benchmark_queries.sql
-- Use these queries to benchmark the performance of PostgreSQL and ClickHouse.

-- ##################
-- ## PostgreSQL
-- ##################
-- For PostgreSQL, we use EXPLAIN ANALYZE to get the execution time.

-- Query 1: Point Lookup
-- Fetches a single record by its primary key.
-- Expected: Faster on PostgreSQL due to its B-tree index.
EXPLAIN ANALYZE SELECT * FROM orders_row WHERE order_id = 'your-uuid-here';

-- Query 2: Aggregation
-- Calculates the total sales amount for each region.
-- Expected: Faster on ClickHouse because it only reads the 'region', 'price', and 'quantity' columns.
EXPLAIN ANALYZE SELECT region, SUM(price * quantity) AS total_sales FROM orders_row GROUP BY region;

-- Query 3: Filtering on a Range
-- Selects all orders within a specific one-month date range.
-- Expected: Faster on ClickHouse, as it can efficiently scan the 'order_date' column.
EXPLAIN ANALYZE SELECT COUNT(*) FROM orders_row WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Query 4: Analytical Query (Heavy Aggregation)
-- Finds customers who have placed more than 10 orders and counts them.
-- Expected: Significantly faster on ClickHouse. This is a classic analytical query that benefits greatly from columnar storage.
EXPLAIN ANALYZE
SELECT customer_id, COUNT(order_id) AS order_count
FROM orders_row
GROUP BY customer_id
HAVING COUNT(order_id) > 10;

-- Query 5: Full Scan Aggregation
-- Calculates the average price of all products sold.
-- Expected: Faster on ClickHouse because it only reads the 'price' column, avoiding I/O on other columns.
EXPLAIN ANALYZE SELECT AVG(price) FROM orders_row;


-- ##################
-- ## ClickHouse
-- ##################
-- For ClickHouse, we run the query and observe the 'Query took Xms' time in the ch-ui results.

-- Query 1: Point Lookup
-- Fetches a single record by its primary key.
-- Expected: Slower on ClickHouse because it has to "stitch together" the row from multiple column files.
-- Note: Replace 'your-uuid-here' with a valid UUID from your table.
SELECT * FROM orders_columnar WHERE order_id = 'your-uuid-here';

-- Query 2: Aggregation
-- Calculates the total sales amount for each region.
-- Expected: Faster on ClickHouse because it only reads the 'region', 'price', and 'quantity' columns.
SELECT region, sum(price * quantity) AS total_sales FROM orders_columnar GROUP BY region;

-- Query 3: Filtering on a Range
-- Selects all orders within a specific one-month date range.
-- Expected: Faster on ClickHouse, as it can efficiently scan the 'order_date' column.
SELECT count(*) FROM orders_columnar WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Query 4: Analytical Query (Heavy Aggregation)
-- Finds customers who have placed more than 10 orders and counts them.
-- Expected: Significantly faster on ClickHouse. This is a classic analytical query that benefits greatly from columnar storage.
SELECT customer_id, count(order_id) AS order_count
FROM orders_columnar
GROUP BY customer_id
HAVING count(order_id) > 10;

-- Query 5: Full Scan Aggregation
-- Calculates the average price of all products sold.
-- Expected: Faster on ClickHouse because it only reads the 'price' column, avoiding I/O on other columns.
SELECT avg(price) FROM orders_columnar;
