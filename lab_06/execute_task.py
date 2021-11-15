from tkinter import *
from tkinter import messagebox as mb


def create_list_box(rows, title, count=15):
    root = Tk()

    root.title(title)
    root.resizable(width=False, height=False)

    size = (count + 3) * len(rows[0]) + 1

    list_box = Listbox(root, width=size, height=22,
                       font="monospace 10", bg="lavender", highlightcolor='lavender', selectbackground='#59405c', fg="#59405c")

    list_box.insert(END, "█" * size)

    for row in rows:
        string = (("█ {:^" + str(count) + "} ") * len(row)).format(*row) + '█'
        list_box.insert(END, string)

    list_box.insert(END, "█" * size)

    list_box.grid(row=0, column=0)

    root.configure(bg="lavender")

    root.mainloop()


def execute_task1(cur, st):
    try:
        st = int(st.get())
    except:
        mb.showerror(title="Ошибка", message="Введите число!")
        return

    cur.execute(" \
        SELECT count(order_status) \
        FROM orders \
        WHERE order_status= 5 \
        GROUP BY order_status", (st,))

    row = cur.fetchone()

    mb.showinfo(title="Результат",
                message=f"Кол-во заказов в статусе {st} составляет: {row[0]}")


def execute_task4(cur, table_name, con):
    table_name = table_name.get()

    try:
        cur.execute(f"SELECT * FROM {table_name}")
    except:
        # Откатываемся.
        con.rollback()
        mb.showerror(title="Ошибка", message="Такой таблицы нет!")
        return

    rows = [(elem[0],) for elem in cur.description]
    print(rows)
    create_list_box(rows, "Задание 4", 17)


def execute_task6(cur, user_id): # Доделать
    user_id = user_id.get()
    print(user_id)
    try:
        user_id = int(user_id)
    except:
        mb.showerror(title="Ошибка", message="Введите число!")
        return
    # походу из третьей надо бы переделать ворк2 и ворк3, тка как вроде бы мой 2 это 3 ыыы
    # get_user - Подставляемая табличная функция.
    # Возвращает пользователя по id.
    cur.execute("SELECT * FROM work3(%s)", (user_id,))

    rows = cur.fetchone()

    create_list_box((rows,), "Задание 6", 17)


def execute_task7(cur, param, con):
    try:
        device_id = int(param[0].get())
        company = param[1].get()
        year_of_issue = int(param[2].get())
        color = param[3].get()
        price = int(param[4].get())
    except:
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    if year_of_issue < 2000 or year_of_issue > 2120 or price < 0 or price > 100000:
        mb.showerror(title="Ошибка", message="Неподходящие значения!")
        return

    print(device_id, company, year_of_issue, color, price)

    # Выполняем запрос.
    try:
        cur.execute("CALL insert_device(%s, %s, %s, %s, %s);",
                    (device_id, company, year_of_issue, color, price))
    except:
        mb.showerror(title="Ошибка", message="Некорректный запрос!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    # Т.е. посылаем команду в бд.
    # Метод commit() помогает нам применить изменения,
    # которые мы внесли в базу данных,
    # и эти изменения не могут быть отменены,
    # если commit() выполнится успешно.
    con.commit()

    mb.showinfo(title="Информация!", message="Девайс добавлен!")


def execute_task10(cur, param, con):
    try:
        courier_id = int(param[0].get())
        car_type = int(param[1].get())
        login = param[2].get()
        password = param[3].get()
        salary = int(param[4].get())
    except:
        mb.showerror(title="Ошибка", message="Некорректные параметры!")
        return

    print(courier_id, car_type, login, password, salary)

    cur.execute(
        "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='blacklist'")

    if not cur.fetchone():
        mb.showerror(title="Ошибка", message="Таблица не создана!")
        return

    try:
        cur.execute("INSERT INTO couriers VALUES(%s, %s, %s, %s, %s)",
                    (courier_id, car_type, login, password, salary))
    except:
        mb.showerror(title="Ошибка!", message="Ошибка запроса!")
        # Откатываемся.
        con.rollback()
        return

    # Фиксируем изменения.
    con.commit()

    mb.showinfo(title="Информация!", message="Курьер добавлен")