-- Generate IDs
\set customer_id_val random(1, 10000)
\set product_id_val random(1, 1000)
-- Browse products
SELECT * FROM product ORDER BY price ASC LIMIT 10;

-- INSERT via SELECT to comply with Citus
INSERT INTO order_trans (order_id, customer_id, product_id, order_date,quantity, unit_price, total_price, payment_method,shipping_address,status)
SELECT
    nextval('order_id_seq'), :customer_id_val, :product_id_val, now(),1, p.price, p.price, 'Credit Card', '123 Discount Ave', 'Pending'
FROM product p
WHERE p.product_id = :product_id_val;