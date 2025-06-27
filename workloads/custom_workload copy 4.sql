-- 6. Complex query with multiple joins and filtering
\set random_category random(1, 10)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.product_name,
    p.category,
    o.order_date,
    o.total_price
FROM customer c
JOIN order_trans o ON c.customer_id = o.customer_id
JOIN product p ON o.product_id = p.product_id
WHERE p.category = 'Category_' || :random_category
AND o.order_date > CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.total_price DESC
LIMIT 15;

-- 8. Update operation on distributed table
\set update_customer_id random(1, 10000)
UPDATE customer SET phone = '555-' || (1000 + random() * 9000)::int
WHERE customer_id = :update_customer_id;

-- 9. Transaction with multiple operations
\set order_id_val random(50001, 100000)
\set customer_id_val random(1, 10000)
\set product_id_val random(1, 1000)
BEGIN;
    INSERT INTO order_trans (
        order_id, customer_id, product_id, order_date,
        quantity, unit_price, total_price,
        payment_method, shipping_address, status
    ) VALUES (
        :order_id_val,
        :customer_id_val,
        :product_id_val,
        CURRENT_TIMESTAMP,
        (1 + random() * 10)::int,
        (SELECT price FROM product WHERE product_id = :product_id_val),
        (SELECT price * (1 + random() * 10)::int FROM product WHERE product_id = :product_id_val),
        CASE WHEN random() < 0.5 THEN 'Credit Card' ELSE 'PayPal' END,
        (SELECT address FROM customer WHERE customer_id = :customer_id_val),
        'Processing'
    );
    
    UPDATE product SET stock_quantity = stock_quantity - (1 + random() * 10)::int
    WHERE product_id = :product_id_val;
COMMIT;

-- 10. Analytical query (scan)
SELECT 
    p.category,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_price) as total_revenue,
    AVG(o.total_price) as avg_order_value
FROM order_trans o
JOIN product p ON o.product_id = p.product_id
WHERE o.order_date > CURRENT_DATE - INTERVAL '90 days'
GROUP BY p.category
ORDER BY total_revenue DESC;