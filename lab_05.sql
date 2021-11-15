-- work 1
SELECT row_to_json(o) result FROM orders o;
SELECT row_to_json(p) result FROM products p;
SELECT row_to_json(m) result FROM managers m;
SELECT row_to_json(c) result FROM customers c;


-- work 2
CREATE TABLE copy_orders
(
    order_id INT PRIMARY KEY,
    date_of_shipping DATE NOT NULL,
    addres VARCHAR(45) NOT NULL,
    order_status INT NOT NULL,
    creation_time TIMESTAMP NOT NULL,
    source VARCHAR(45),
    prod_prod_id INT,
    cust_cust_id INT,
    man_man_id INT,
    FOREIGN KEY (prod_prod_id)  REFERENCES products (product_id),
    FOREIGN KEY (cust_cust_id)  REFERENCES customers (userr_id),
    FOREIGN KEY (man_man_id)  REFERENCES managers (manager_id)

);

COPY
(
    SELECT row_to_json(u) result FROM users u
)
TO '/Users/alexey/Desktop/database/copy_orders.json';

CREATE TABLE IF NOT EXISTS orders_import(doc json);

copy orders_import from '/Users/alexey/Desktop/database/copy_orders.json';

select * from orders_import;

select * from orders_import, json_populate_record(null::copy_orders, doc);

insert into copy_orders
select order_id, date_of_shipping, addres, order_status, creation_time, source, prod_prod_id, cust_cust_id, man_man_id
from orders_import, json_populate_record(null::copy_orders, doc);


-- work 3
CREATE TABLE IF NOT EXISTS ord_status
(
    data json
);

insert into ord_status
select * from json_object('{st_id, status}', '{1, "Создан"}');
insert into ord_status
select * from json_object('{st_id, status}', '{2, "Оплачен"}');

--work 4

-- work 4.1
CREATE TABLE IF NOT EXISTS orders_id_date
(
    orders_id INT,
    date_of_shipping date
);

SELECT * FROM orders_import, json_populate_record(null::orders_id_date, doc);

SELECT orders_id, date_of_shipping
FROM orders_import, json_populate_record(null::orders_id_date, doc)
WHERE extract(year from date_of_shipping) > 2017;

SELECT * FROM orders_import;

SELECT doc->'order_id' AS id, doc->'date_of_shipping' AS dt
FROM orders_import;


-- work 4.2
CREATE TABLE adress_plus (doc jsonb);
INSERT INTO adress_plus VALUES ('{"id":1, "house": {"apartam_num": 1, "floor":1, "comment":"no ring"}}');
INSERT INTO adress_plus VALUES ('{"id":2, "house": {"apartam_num":11, "floor":3, "comment":"lift repair"}}');

SELECT * FROM adress_plus;

SELECT doc->'id' AS id, doc->'house'->'apartam_num' AS apartam_num
FROM adress_plus;


-- work 4.3
-- крч для себя что это есть ли доп адресс
CREATE OR REPLACE FUNCTION get_adr(u_id jsonb)
RETURNS VARCHAR AS '
    SELECT CASE
               WHEN count.cnt > 0
                   THEN ''true''
               ELSE ''false''
               END AS comment
    FROM (
             SELECT COUNT(doc -> ''id'') cnt
             FROM adress_plus
             WHERE doc -> ''id'' @> u_id
         ) AS count;
' LANGUAGE sql;

SELECT * FROM adress_plus;

SELECT get_adr('0');

-- work 4.4
SELECT doc || '{"id": 44}'::jsonb
FROM adress_plus;

UPDATE adress_plus
SET doc = doc || '{"id": 44}'::jsonb
WHERE (doc->'id')::INT = 4;

SELECT * FROM adress_plus;


-- work 4.5
CREATE TABLE IF NOT EXISTS users_info_plus(doc JSON);

INSERT INTO users_info_plus VALUES ('[{"user_id": 1, "family": 1},
  {"user_id": 2, "family": 1}, {"user_id": 3, "family": 0}]');

SELECT * FROM users_info_plus;

-- jsonb_array_elements - Разворачивает массив JSON в набор значений JSON.
SELECT jsonb_array_elements(doc::jsonb)
FROM users_info_plus;
