DROP DATABASE IF EXISTS mydb;
CREATE DATABASE mydb;
--mysql -u root -p mydb < base.sql 
USE mydb;

CREATE TABLE customers
(
    userr_id INT PRIMARY KEY,
    fio VARCHAR(134) NOT NULL,
    birthday DATE NOT NULL,
    email VARCHAR(134) NOT NULL,
    passw VARCHAR(45) NOT NULL,
    dateofregistration DATE NOT NULL,
    contact_phone VARCHAR(11) NOT NULL UNIQUE,
    discount VARCHAR(45) NOT NULL
);

CREATE TABLE products
(
    product_id INT PRIMARY KEY,
    articul INT NOT NULL UNIQUE,
    nme VARCHAR(33) NOT NULL,
    category VARCHAR(66) NOT NULL,
    weigth SMALLINT NOT NULL,
    dateofrelease DATE NOT NULL,
    price INT NOT NULL
);

CREATE TABLE managers
(
    manager_id INT PRIMARY KEY,
    fio VARCHAR(134) NOT NULL,
    email VARCHAR(134) NOT NULL UNIQUE,
    passw VARCHAR(45) NOT NULL,
    acces_card INT NOT NULL UNIQUE,
    contact_phone VARCHAR(11) NOT NULL UNIQUE
);

CREATE TABLE orders
(
    order_id INT PRIMARY KEY,
    date_of_shipping DATE NOT NULL,
    addres VARCHAR(45) NOT NULL,
    order_status INT NOT NULL,
    creation_time TIMESTAMP NOT NULL UNIQUE,
    source VARCHAR(45),
    --prod_prod_id INT,
    --cust_cust_id INT,
    --man_man_id INT,
    FOREIGN KEY (prod_prod_id)  REFERENCES products (product_id),
    FOREIGN KEY (cust_cust_id)  REFERENCES customers (userr_id),
    FOREIGN KEY (man_man_id)  REFERENCES managers (manager_id)
    
);