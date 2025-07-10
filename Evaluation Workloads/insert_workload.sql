-- 7. Write operation (INSERT)
\set new_customer_id random(10001, 20000)
-- \set client_num :client_id
-- \set new_customer_id (1000000 + :clientid * 10000 + random(1, 9999))
-- CREATE SEQUENCE customer_id_seq START WITH 1000000;
-- \set new_customer_id nextval('customer_id_seq')
INSERT INTO customer (
    customer_id, first_name, last_name, email, phone,
    address, city, customer_state, zip_code, registration_date
) VALUES (
    :new_customer_id,
    'First_' || :new_customer_id,
    'Last_' || :new_customer_id,
    'user_' || :new_customer_id || '@example.com',
    '555-' || (1000 + :new_customer_id % 9000),
    'Address_' || :new_customer_id,
    'City_' || (1 + :new_customer_id % 100),
    'State_' || (1 + :new_customer_id % 50),
    'ZIP_' || (10000 + :new_customer_id % 90000),
    CURRENT_DATE - (random() * 365)::int
);