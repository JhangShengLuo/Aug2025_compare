-- data_generation/1_init_schema_and_data.sql

-- This script will:
-- 1. Create the necessary extensions.
-- 2. Define the table schemas for both row and columnar stores.
-- 3. Populate the tables with 1 million rows of skewed synthetic data.

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the table for the row-oriented store (PostgreSQL)
-- This is a standard heap table.
CREATE TABLE IF NOT EXISTS orders_row (
    order_id UUID PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    product_id INT NOT NULL,
    quantity INT,
    price DECIMAL(10, 2),
    region TEXT
);

-- Create the table for the columnar store (Hydra)
-- The 'USING columnar' clause is specific to Hydra and creates a columnar table.
CREATE TABLE IF NOT EXISTS orders_columnar (
    order_id UUID,
    customer_id INT,
    order_date TIMESTAMP,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    region TEXT
) USING columnar;


-- Function to generate skewed customer IDs to simulate a real-world scenario
-- where 20% of customers account for 80% of orders.
CREATE OR REPLACE FUNCTION skewed_customer_id() RETURNS INT AS $$
BEGIN
    IF random() < 0.8 THEN
        -- 80% of the time, generate a customer_id from the top 20% of customers
        RETURN floor(random() * 20000 + 1)::INT;
    ELSE
        -- 20% of the time, generate a customer_id from the remaining 80% of customers
        RETURN floor(random() * 80000 + 20001)::INT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Generate and insert 1 million rows of data into the row-oriented table
-- This may take a few minutes to complete upon first container startup.
INSERT INTO orders_row (order_id, customer_id, order_date, product_id, quantity, price, region)
SELECT
    uuid_generate_v4(),
    skewed_customer_id(),
    NOW() - (random() * 365 * 2) * INTERVAL '1 day', -- Orders within the last 2 years
    floor(random() * 1000 + 1)::INT,
    floor(random() * 10 + 1)::INT,
    (random() * 500 + 10)::DECIMAL(10, 2),
    (ARRAY['North', 'South', 'East', 'West', 'Central'])[floor(random() * 5 + 1)]
FROM generate_series(1, 1000000);

-- Generate and insert 1 million rows of data into the columnar table
-- This will also run on the Hydra container.
INSERT INTO orders_columnar (order_id, customer_id, order_date, product_id, quantity, price, region)
SELECT
    uuid_generate_v4(),
    skewed_customer_id(),
    NOW() - (random() * 365 * 2) * INTERVAL '1 day',
    floor(random() * 1000 + 1)::INT,
    floor(random() * 10 + 1)::INT,
    (random() * 500 + 10)::DECIMAL(10, 2),
    (ARRAY['North', 'South', 'East', 'West', 'Central'])[floor(random() * 5 + 1)]
FROM generate_series(1, 1000000);

-- Create an index on the row-based table for fair point-lookup comparison
CREATE INDEX idx_orders_row_order_id ON orders_row(order_id);

-- Note: Columnar stores like Hydra typically do not benefit from traditional B-tree indexes
-- for analytical queries, as they scan columns directly. We omit it for the columnar table
-- to demonstrate the natural performance characteristics.

