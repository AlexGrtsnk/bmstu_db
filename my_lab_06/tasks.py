def task1(cur, con = None):
    st = int(input("Введите статус: "))
    cur.execute(" \
        SELECT count(order_status) \
        FROM orders \
        WHERE order_status= 5 \
        GROUP BY order_status", (st,))
    row = cur.fetchone()
    print("Кол-во заказов в статусе"+str(st)+ "составляет: " + row[0])

def task2(cur, con = None):
    print("id людей, которые имеют статус заказа пять и скидку больше 50% \n")
    cur.execute("\
    SELECT userr_id \
    FROM orders \
    JOIN customers \
    ON orders.cust_cust_id = customers.userr_id where order_status = 5 and cast(discount as int) > 50;")

    rows = cur.fetchall()
    print(rows)
    #create_list_box(rows, "Задание 2")

def task3(cur, con = None):
    cur.execute("WITH CTE (SupplierNo, NumberOfprods) AS ( SELECT product_id, price AS Total FROM products \
WHERE product_id IS NOT NULL \
GROUP BY product_id ) \
SELECT AVG(NumberOfprods) FROM CTE")
    row = cur.fetchall()
    print("Средняя цена за продукт" + row[0])

def task4(cur, con):
    table_name = input("Введите название таблицы: ")

    try:
        cur.execute(f"SELECT * FROM {table_name}")
    except:
        # Откатываемся.
        con.rollback()
        print("Такой таблицы нет!")
        return
    rows = [(elem[0],) for elem in cur.description]
    print(rows)


def task5(cur, con = None):
    cur.execute("select * from work1('%cat 1%')")
    row = cur.fetchone()
    print(f"Минимальная цена из первой категории: {row[0]}")

def task7(cur, con=None):
    cur.execute("CALL work5(1, 2);")

    #row = cur.fetchone()
    print("Все отработало")

def task9(cur, con):
    cur.execute(" \
        CREATE TABLE IF NOT EXISTS couriers \
        ( \
            courier_id INT, \
            car_type INT, \
            login varchar, \
            password varchar, \
            salary int \
        ) ")
    con.commit()
    print("Таблица успешно создана!")

def task10(cur, con):
    names = ["id курьера",
    "тип машины(1 - легковая, B; 2 - грузовая, B; 3 - Грузовая C; 4 - Фура; 5 - фура двойной сцепки",
    "логин ЛК комании",
    "пароль ЛК комании",
    "зарплату"]
    param = list()

    i = 0
    for elem in names:
        elem = input(f"Введите {elem}: ")
        param.append(elem)
    try:
        courier_id = int(param[0].get())
        car_type = int(param[1].get())
        login = param[2].get()
        password = param[3].get()
        salary = int(param[4].get())
    except:
        print("Error")
        return
    print(courier_id, car_type, login, password, salary)

    cur.execute(
        "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='blacklist'")
    if not cur.fetchone():
        print("Ошибка, таблица не создана ")
        return
    try:
        cur.execute("INSERT INTO couriers VALUES(%s, %s, %s, %s, %s)",
                    (courier_id, car_type, login, password, salary))
    except:
        print("Ошибка запроса")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    con.commit()
    print("курьер успешно добавлен")



