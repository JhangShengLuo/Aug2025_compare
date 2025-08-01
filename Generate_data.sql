-- data_generation/1_init_schema_and_data.sql

-- This script will:
-- 1. Define the table schema for the columnar store.
-- 2. Populate the table with 10 million rows of synthetic data.

-- Create the table for the columnar store (ClickHouse)
-- The MergeTree engine is the standard for ClickHouse.
CREATE TABLE IF NOT EXISTS orders_columnar (
    order_id UUID,
    customer_id Int32,
    order_date DateTime,
    product_id Int32,
    quantity Int32,
    price Decimal(10, 2),
    region String
) ENGINE = MergeTree()
ORDER BY order_date;

-- Generate and insert 10 million rows of data into the columnar table
INSERT INTO orders_columnar (order_id, customer_id, order_date, product_id, quantity, price, region)
SELECT
    generateUUIDv4(),
    rand() % 100000 + 1,
    now() - (rand() % 730) * 86400,
    rand() % 1000 + 1,
    rand() % 10 + 1,
    (rand() % 500 + 10) / 100.0,
    ['North', 'South', 'East', 'West', 'Central'][rand() % 5 + 1]
FROM numbers(10000000);

