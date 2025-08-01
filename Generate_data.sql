-- data_generation/1_init_schema_and_data.sql

-- This script will:
-- 1. Create the necessary extensions for PostgreSQL.
-- 2. Define the table schemas for both row and columnar stores.
-- 3. Populate the tables with 1 million rows of synthetic data.

-- ##################
-- ## PostgreSQL
-- ##################

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the table for the row-oriented store (PostgreSQL)
CREATE TABLE IF NOT EXISTS orders_row (
    order_id UUID PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    product_id INT NOT NULL,
    quantity INT,
    price DECIMAL(10, 2),
    region TEXT
);

-- Generate and insert 1 million rows of data into the row-oriented table
INSERT INTO orders_row (order_id, customer_id, order_date, product_id, quantity, price, region)
SELECT
    uuid_generate_v4(),
    floor(random() * 100000 + 1)::INT,
    NOW() - (random() * 365 * 2) * INTERVAL '1 day', -- Orders within the last 2 years
    floor(random() * 1000 + 1)::INT,
    floor(random() * 10 + 1)::INT,
    (random() * 500 + 10)::DECIMAL(10, 2),
    (ARRAY['North', 'South', 'East', 'West', 'Central'])[floor(random() * 5 + 1)]
FROM generate_series(1, 1000000);

-- Create an index on the row-based table for fair point-lookup comparison
CREATE INDEX idx_orders_row_order_id ON orders_row(order_id);


-- ##################
-- ## ClickHouse
-- ##################

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

-- Generate and insert 1 million rows of data into the columnar table
INSERT INTO orders_columnar (order_id, customer_id, order_date, product_id, quantity, price, region)
SELECT
    generateUUIDv4(),
    rand() % 100000 + 1,
    now() - (rand() % 730) * 86400,
    rand() % 1000 + 1,
    rand() % 10 + 1,
    (rand() % 500 + 10) / 100.0,
    ['North', 'South', 'East', 'West', 'Central'][rand() % 5 + 1]
FROM numbers(1000000);