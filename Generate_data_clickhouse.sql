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
    (rand() % 50000 + 1000) / 100.0,
    arrayElement(['North', 'South', 'East', 'West', 'Central'], (rand() % 5) + 1)
FROM numbers(1000000);
