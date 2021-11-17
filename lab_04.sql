-- work 1
-- 1) Определяемую пользователем скалярную функцию CLR.
-- Получить название продукта по id.
CREATE OR REPLACE FUNCTION get_prod_name(prod_id INT)
RETURNS VARCHAR
AS $$
res = plpy.execute(f" \
    SELECT nme \
    FROM products  \
    WHERE product_id = {prod_id};")
if res:
    return res[0]['nme']
$$ LANGUAGE plpython3u;

select * from get_prod_name(5);


-- work 2

-- передается id продукта, получаем количество заказов, в котором данный продукт
select * from orders o inner join products p on p.product_id = o.prod_prod_id  where o.prod_prod_id = 7;

CREATE OR REPLACE FUNCTION count_prods(prod_id INT)
RETURNS INT
AS $$
res = plpy.execute(f" \
    select count(*) from orders o inner join products p on p.product_id = o.prod_prod_id  where o.prod_prod_id = {prod_id};")

return res[0]["count"]
$$ LANGUAGE plpython3u;

SELECT * FROM count_prods(7);


-- work 3

-- 3) Определяемую пользователем табличную функцию CLR.
-- Возвращает id заказа, фио заказчика и его адресс, где фио совпадает с данным.
CREATE OR REPLACE FUNCTION count_st_ord(cls VARCHAR)
RETURNS TABLE
(
    call_id INT,
    addres VARCHAR,
    fio VARCHAR
)
AS $$
# return value
rv = plpy.execute(f" \
SELECT order_id as call_id, addres, fio\
FROM orders o inner join customers c on o.cust_cust_id = c.userr_id")
res = []
for elem in rv:
    if elem["fio"] == cls:
        res.append(elem)
return res
$$ LANGUAGE plpython3u;

SELECT * FROM count_st_ord('Ivan10');

-- work 4
-- добавляет купрьера
CREATE OR REPLACE PROCEDURE add_courier
(
    courier_id INT,
    car_type INT,
    login varchar,
    password varchar,
    salary INT
) AS $$
# Чтобы юзать так, нужно подругому назвать входные параметры.
# plpy.execute(f"INSERT INTO users VALUES({id}, \'{nick name}\', \'{sex}\', {number_of_hours}, {id_device});")

# Функция plpy.prepare подготавливает план выполнения для запроса.
# Передается строка запроса и список типов параметров.
plan = plpy.prepare("INSERT INTO couriers VALUES($1, $2, $3, $4, $5)", ["INT", "INT", "varchar","varchar", "INT"])
rv = plpy.execute(plan, [courier_id, car_type, login, password, salary])
$$ LANGUAGE plpython3u;

CALL add_courier(1, 5, 'vbcnsbds', 'password', 150000);


-- work 5