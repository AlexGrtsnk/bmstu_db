from execute_task import *


def task1(cur, con = None):
    root_1 = Tk()

    root_1.title('Задание 1')
    root_1.geometry("300x200")
    root_1.configure(bg="lavender")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="  статус заказа:", bg="lavender").place(
        x=75, y=50)
    st = Entry(root_1)
    st.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=cur, arg2=st: execute_task1(arg1, arg2),  bg="thistle3")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task2(cur, con = None):
    # Сколько человек имеют скидку больше 50% и имеют статус заказа 5
    cur.execute("\
    SELECT count(*) \
    FROM orders \
    JOIN customers \
    ON orders.cust_cust_id = customers.userr_id where order_status = 5 and cast(discount as int) > 5;")

    row = cur.fetchall()
    #print(rows)
    mb.showinfo(title="Результат",
                message=f"Кол-во человек имеют скидку больше 50% и имеют статус заказа 5: {row[0]}")
    #create_list_box(rows, "Задание 2")


def task3(cur, con = None):
    cur.execute("WITH CTE (SupplierNo, NumberOfprods) AS ( SELECT product_id, price AS Total FROM products \
WHERE product_id IS NOT NULL \
GROUP BY product_id ) \
SELECT AVG(NumberOfprods) FROM CTE")
    row = cur.fetchall()
    mb.showinfo(title="Результат",
                message=f"средняя цена за продукт: {row[0]}")



def task4(cur, con):

    root_1 = Tk()

    root_1.title('Задание 4')
    root_1.geometry("300x200")
    root_1.configure(bg="lavender")
    root_1.resizable(width=False, height=False)

    Label(root_1, text="Введите название таблицы:", bg="lavender").place(
        x=65, y=50)
    name = Entry(root_1)
    name.place(x=75, y=85, width=150)

    b = Button(root_1, text="Выполнить",
               command=lambda arg1=cur, arg2=name: execute_task4(arg1, arg2, con),  bg="thistle3")
    b.place(x=75, y=120, width=150)

    root_1.mainloop()


def task5(cur, con = None):
    cur.execute("select * from work1('%cat 1%')")

    row = cur.fetchone()
    mb.showinfo(title="Результат",
                message=f"Минимальная цена из первой категории: {row[0]}")


def task6(cur, con = None): #WORK
    root = Tk()

    root.title('Задание 1')
    root.geometry("300x200")
    root.configure(bg="lavender")
    root.resizable(width=False, height=False)

    Label(root, text="  Введите id:", bg="lavender").place(
        x=75, y=50)
    user_id = Entry(root)
    user_id.place(x=75, y=85, width=150)

    b = Button(root, text="Выполнить",
               command=lambda arg1=cur, arg2=user_id: execute_task6(arg1, arg2),  bg="thistle3")
    b.place(x=75, y=120, width=150)

    root.mainloop()


def task7(cur, con=None):
    cur.execute("CALL work5(1, 2);")

    #row = cur.fetchone()
    mb.showinfo(title="Результат",
                message=f"Все отработало")


def task8(cur, con = None): #WORK
    # Информация:
    # https://postgrespro.ru/docs/postgrespro/10/functions-info
    cur.execute(
        "SELECT current_database(), current_user;")
    current_database, current_user = cur.fetchone()
    mb.showinfo(title="Информация",
                message=f"Имя текущей базы данных:\n{current_database}\nИмя пользователя:\n{current_user}")


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

    mb.showinfo(title="Информация",
                message="Таблица успешно создана!")


def task10(cur, con):
    root = Tk()

    root.title('Задание 10')
    root.geometry("400x300")
    root.configure(bg="lavender")
    root.resizable(width=False, height=False)

    names = ["id курьера",
             "тип машины(1 - легковая, B; 2 - грузовая, B; 3 - Грузовая C; 4 - Фура; 5 - фура двойной сцепки",
             "логин ЛК комании",
             "пароль ЛК комании",
             "зарплату"]

    param = list()

    i = 0
    for elem in names:
        Label(root, text=f"Введите {elem}:",
              bg="lavender").place(x=70, y=i + 25)
        elem = Entry(root)
        i += 50
        elem.place(x=115, y=i, width=150)
        param.append(elem)

    b = Button(root, text="Выполнить",
               command=lambda: execute_task10(cur, param, con),  bg="thistle3")
    b.place(x=115, y=200, width=150)

    root.mainloop()