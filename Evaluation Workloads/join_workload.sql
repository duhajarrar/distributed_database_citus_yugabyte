-- 3. Join between distributed tables
\set random_order_id random(1, 50000)
SELECT c.first_name, c.last_name, o.order_id, o.order_date, o.total_price
FROM customer c JOIN order_trans o ON c.customer_id = o.customer_id
WHERE o.order_id = :random_order_id;

-- 4. Join with reference table (product)
\set random_product_id random(1, 1000)
SELECT p.product_name, p.category, o.quantity, o.total_price
FROM order_trans o JOIN product p ON o.product_id = p.product_id
WHERE p.product_id = :random_product_id
LIMIT 10;

-- 5. Aggregation query on distributed data
\set random_city random(1, 100)
SELECT c.city, COUNT(o.order_id) as order_count, SUM(o.total_price) as total_sales
FROM customer c JOIN order_trans o ON c.customer_id = o.customer_id
WHERE c.city = 'City_' || :random_city
GROUP BY c.city;
