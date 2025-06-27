-- 1. Simple point lookup (highly optimized in YugabyteDB)
\set random_customer_id random(1, 10000)
SELECT * FROM customer WHERE customer_id = :random_customer_id;

-- 2. Range query on distributed table
\set random_state random(1, 50)
SELECT * FROM customer WHERE customer_state = 'State_' || :random_state LIMIT 20;