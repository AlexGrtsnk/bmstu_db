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

-- Создаем представление, т.к. таблицы не могут иметь INSTEAD OF triggers.
CREATE VIEW couriers_new AS
SELECT *
FROM couriers
WHERE courier_id < 15;

SELECT * FROM couriers_new;

-- Заменяем удаление на мягкое удаление.
CREATE OR REPLACE FUNCTION del_couriers_func()
RETURNS TRIGGER
AS $$
old_id = TD["old"]["courier_id"]
rv = plpy.execute(f" \
UPDATE couriers_new SET login = \'none\'  \
WHERE couriers_new.courier_id = {old_id}")

return TD["new"]
$$ LANGUAGE plpython3u;

CREATE TRIGGER del_user_trigger
-- INSTEAD OF - Сработает вместо указанной операции.
INSTEAD OF DELETE ON couriers_new
-- Триггер с пометкой FOR EACH ROW вызывается один раз для каждой строки,
-- изменяемой в процессе операции.
FOR EACH ROW
EXECUTE PROCEDURE del_couriers_func();

DELETE FROM couriers_new
WHERE login = 'gghvvccd';

SELECT * FROM couriers_new;


-- work 6

-- Тип содержит статус заказа и кол-во таких статусов.
CREATE TYPE status_count AS
(
	orders_status INT,
	count INT
);
drop function get_status_count;
CREATE OR REPLACE FUNCTION get_status_count(clr INT)
RETURNS status_count
AS
$$
plan = plpy.prepare("      \
SELECT order_status, COUNT(order_status) \
FROM orders                \
WHERE order_status = $1           \
GROUP BY order_status", ["INT"])

# return value
rv = plpy.execute(plan, [clr])

# nrows - возвращает кол-во строк, обработанных командой.
if (rv.nrows()):
    return (rv[0]["order_status"], rv[0]["count"])
$$ LANGUAGE plpython3u;

SELECT * FROM get_status_count(2);