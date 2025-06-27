-- CREATE SEQUENCE order_id_seq START WITH 200001 INCREMENT BY 1;
\set order_id_val random(50001, 150000)
\set customer_id_val random(1, 10000)
\set product_id_val random(1, 1000)

SELECT * FROM product WHERE product_id = :product_id_val;
INSERT INTO order_trans (
    order_id, customer_id, product_id, order_date, quantity, unit_price, total_price, payment_method, shipping_address, status
) VALUES (
    nextval('order_id_seq'),
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

