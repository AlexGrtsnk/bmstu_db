-- work 1
SELECT DISTINCT C1.passw, C1.fio
FROM Customers C1 JOIN Customers AS C2 ON C2.dateofregistration = C1.dateofregistration
WHERE C1.birthday > '1973-08-31'
AND C1.email like '%nas@tam.net1%' ORDER BY C1.passw, C1.fio

-- work 2
SELECT DISTINCT cust_cust_id, date_of_shipping
FROM orders
WHERE date_of_shipping BETWEEN '2017-04-27' AND '2018-01-25'

-- work 3
SELECT DISTINCT category
FROM products
WHERE nme LIKE '%product 1%'

-- work 4
SELECT order_id, cust_cust_id, man_man_id, source
FROM orders
WHERE cust_cust_id IN (SELECT userr_id
FROM customers
WHERE fio LIKE '%Ivan1%' ) AND man_man_id > 100

-- work 5
SELECT product_id, nme
FROM products
WHERE EXISTS (SELECT products.product_id
    FROM products LEFT OUTER JOIN orders
    ON products.product_id = orders.prod_prod_id
    WHERE orders.prod_prod_id = 2
)

-- work 6
SELECT product_id, nme, price
FROM products
WHERE price > ALL ( SELECT price
    FROM products
    WHERE category LIKE '%cat 1%' )

-- work 7
SELECT AVG(TotalPrice) AS "Actual AVG",
SUM(TotalPrice) / COUNT(order_id) AS "Calc AVG"
FROM ( SELECT order_id, SUM(price*qua*(0.01*cast(discount as int))) AS TotalPrice
FROM ( (orders join products p on p.product_id = orders.prod_prod_id join customers c on orders.cust_cust_id = c.userr_id))
GROUP BY order_id ) AS TotOrders

-- work 8
SELECT product_id, price,
    ( SELECT AVG(price)
    FROM products) AS AvgPrice,
    ( SELECT MIN(price)
    FROM products) AS MinPrice,
    nme FROM products
    WHERE category LIKE '%cat 1%'
    

SELECT product_id, price,
    ( SELECT AVG(order_status) -- работает
    FROM orders
    WHERE orders.prod_prod_id = products.product_id) AS AvgPrice,
    ( SELECT MIN(order_status)
    FROM orders
    WHERE orders.prod_prod_id = products.product_id ) AS MaxPrice,
    nme
    FROM products
    WHERE category LIKE '%cat 1%'

-- work 9
SELECT order_id, fio,
    CASE EXTRACT(YEAR from CAST (creation_time as date) )
        WHEN EXTRACT(YEAR from now()) THEN 'This Year'
        WHEN EXTRACT(YEAR from now()) - 1 THEN 'Last year'
    ELSE CAST(extract(year from now()) - extract(year from cast(creation_time as date)) AS varchar(5) ) || ' years ago'
    valid_to_dttm
        AS Kogda
FROM orders JOIN customers ON orders.cust_cust_id = customers.userr_id


-- work 10
SELECT nme,
    CASE
        WHEN price < 2000 THEN 'Inexpensive'
        WHEN price < 3000 THEN 'Fair'
        WHEN price < 5000 THEN 'Expensive' ELSE 'Very Expensive'
    valid_to_dttm AS PPrice
FROM products

-- work 11
SELECT prod_prod_id, COUNT(order_id) AS SQ,
    CAST(SUM(price*qua*(0.01*cast(discount as int)))AS money) AS SR
INTO BestSelling
FROM orders join products on orders.prod_prod_id = products.product_id join customers c on orders.cust_cust_id = c.userr_id
GROUP BY prod_prod_id

-- work 12
SELECT  'By units' AS  Criteria, nme as "Best Selling"
FROM products P JOIN ( SELECT prod_prod_id, SUM(qua) AS SQ
    FROM orders
    GROUP BY prod_prod_id
    ORDER BY SQ DESC ) AS OD ON OD.prod_prod_id = P.product_id
UNION
SELECT  'By revenue'  AS Criteria, nme as "Best Selling"
FROM products P JOIN ( SELECT prod_prod_id,
        CAST(SUM(price*qua*(0.01*cast(discount as int)))AS int) AS SR
    FROM orders join products on orders.prod_prod_id = products.product_id join customers c on orders.cust_cust_id = c.userr_id
    GROUP BY prod_prod_id
    ORDER BY SR DESC) AS OD ON OD.prod_prod_id = P.product_id




--work 13

SELECT  'By units' AS  Criteria, nme as "Best Selling"
FROM products P JOIN ( SELECT prod_prod_id, SUM(qua) AS SQ
    FROM orders
    GROUP BY prod_prod_id
    ORDER BY SQ DESC ) AS OD ON OD.prod_prod_id = P.product_id
UNION
SELECT  'By revenue'  AS Criteria, nme as "Best Selling"
FROM products P JOIN ( SELECT prod_prod_id,
        CAST(SUM(price*qua*(0.01*cast(discount as int)))AS int) AS SR
    FROM orders join products on orders.prod_prod_id = products.product_id join customers c on orders.cust_cust_id = c.userr_id
    GROUP BY prod_prod_id
    ORDER BY SR DESC) AS OD ON OD.prod_prod_id = P.product_id



-- work 14
SELECT product_id, price, nme,
    AVG(price) AS AvgPrice,
    MIN(price) AS MinPrice
FROM products
WHERE category LIKE '%cat 1%'
GROUP BY product_id, price, nme


--work 15
SELECT category, AVG(price) AS "Average Price"
FROM products P
GROUP BY category
HAVING AVG(price) > ( SELECT AVG(price) AS MPrice
FROM products)

--work 16
INSERT INTO products (product_id, articul, nme, category, weigth, dateofrelease, price)
VALUES (30, 100500, 'mobila', 'phone', 3, '2010-10-13',6000)


--work 17
INSERT INTO orders (order_id, date_of_shipping, addres, order_status, source) SELECT ( SELECT MAX(order_id)
FROM orders
WHERE cust_cust_id = 2 ), '2019-01-11', 'lol', 10, 0.1
FROM products
WHERE nme LIKE '%cat 1%'


-- wokr 18
UPDATE products
SET Price = price * 1.5
WHERE product_id = 29


--wokr 19
UPDATE products
SET price = ( SELECT AVG(order_status)
FROM orders inner join products p on p.product_id = orders.prod_prod_id
WHERE prod_prod_id = 6 ) WHERE product_id = 6

-- work 20
DELETE orders
WHERE cust_cust_id = 1


-- work 21
DELETE FROM products
WHERE product_id IN ( SELECT products.product_id
FROM products LEFT OUTER JOIN orders ON products.product_id = orders.prod_prod_id
WHERE orders.prod_prod_id = 15 AND products.category LIKE '%cat 1%')


-- work 22
WITH CTE (SupplierNo, NumberOfprods) AS ( SELECT product_id, price AS Total FROM products 
WHERE product_id IS NOT NULL
GROUP BY product_id )
SELECT AVG(NumberOfprods) AS "Среднее количество денег на продукт" FROM CTE




CREATE TABLE MyEmployees (
EmployeeID smallint NOT NULL,
FirstName varchar(30) NOT NULL,
LastName varchar(40) NOT NULL,
Title varchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY (EmployeeID)
)
-- Заполнение таблицы значениями.
INSERT INTO MyEmployees
VALUES (1, N'Иван', N'Петров', N'Главный исполнительный директор',16,NULL) ; -- Определение ОТВ
WITH RECURSIVE DirectReports (ManagerID, EmployeeID, Title, DeptID, Level) AS
(
-- Определение закрепленного элемента
SELECT e.ManagerID, e.EmployeeID, e.Title, e.DeptID, 0 AS Level FROM MyEmployees AS e
WHERE ManagerID IS NULL
UNION ALL
-- Определение рекурсивного элемента
SELECT e.ManagerID, e.EmployeeID, e.Title, e.DeptID, Level + 1 FROM MyEmployees AS e INNER JOIN DirectReports AS d
ON e.ManagerID = d.EmployeeID
      )
-- Инструкция, использующая ОТВ
SELECT ManagerID, EmployeeID, Title, DeptID, Level FROM DirectReports;


--work 23
with recursive testcte(ord_id, shipping, st)
as
(
    select o.order_id, o.date_of_shipping, 1 as st from orders as o where order_status = 1
    union all
    select o.order_id, o.date_of_shipping, st + 1 as st from orders as o inner join  testcte as t on o.order_id = t.ord_id
)
SELECT  ord_id, shipping, st FROM testcte;

-- work 24
SELECT P.product_id, P.price, P.nme
    AVG(P.price) OVER(PARTITION BY P.product_id, P.ProductName) AS AvgPrice,
    MIN(P.price) OVER(PARTITION BY P.product_id, P.ProductName) AS MinPrice,
    MAX(P.price) OVER(PARTITION BY P.product_id, P.ProductName) AS MaxPrice
FROM Products P



-- work 25
SELECT nam, ROW_NUMBER() OVER(ORDER BY kol) From tr




-- dopi
SELECT
  table1.var1,
  table2.var2,
  dates_table.*

FROM (SELECT
    result.valid_from_dttm,
    (MIN(w.valid_from_dttm) - INTERVAL '1' DAY)::date AS valid_to_dttm
  FROM

    (SELECT valid_from_dttm FROM table1
    UNION
    SELECT valid_from_dttm FROM table2
    ORDER BY valid_from_dttm) AS result,

    (SELECT valid_from_dttm FROM table1
     UNION
     SELECT valid_from_dttm FROM table2
    UNION
     SELECT (MAX(valid_to_dttm) + INTERVAL '1' DAY)::date FROM table2
    ORDER BY valid_from_dttm) AS w
  WHERE w.valid_from_dttm > result.valid_from_dttm
  GROUP BY result.valid_from_dttm) AS dates_table
  JOIN table1
    ON (table1.valid_from_dttm BETWEEN dates_table.valid_from_dttm AND dates_table.valid_to_dttm
    OR table1.valid_to_dttm BETWEEN dates_table.valid_from_dttm AND dates_table.valid_to_dttm
    OR (table1.valid_from_dttm < dates_table.valid_from_dttm
    AND table1.valid_to_dttm > dates_table.valid_to_dttm))
  JOIN table2
    ON (table2.valid_from_dttm BETWEEN dates_table.valid_from_dttm AND dates_table.valid_to_dttm
    OR table2.valid_to_dttm BETWEEN dates_table.valid_from_dttm AND dates_table.valid_to_dttm
    OR (table2.valid_from_dttm < dates_table.valid_from_dttm
    AND table2.valid_to_dttm > dates_table.valid_to_dttm))
ORDER BY valid_from_dttm, valid_to_dttm;