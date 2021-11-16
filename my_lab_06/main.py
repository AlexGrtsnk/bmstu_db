#from tk import *

import psycopg2

from tasks import *


def main():
    # Подключаемся к БД.
    try:
        con = psycopg2.connect(
            database="mydb",
            #user="lis",
            password="",
            host="127.0.0.1",  # Адрес сервера базы данных.
            port="5432"		   # Номер порта.
        )
    except:
        print("Ошибка при подключении к БД")
        return

    print("База данных успешно открыта")
    info_txt = "\nУсловия задачи:\n\
    1. Выполнить скалярный запрос;\n\
    2. Выполнить запрос с несколькими соединениями(JOIN);\n\
    3. Выполнить запрос с ОТВ(CTE) и оконными функциями;\n\
    4. Выполнить запрос к метаданным;\n\
    5. Вызвать скалярную функцию(написанную в третьей лабораторной работе);\n\
    6. Вызвать многооператорную или табличную функцию(написанную в третьей лабораторной работе);\n\
    7. Вызвать хранимую процедуру(написанную в третьей лабораторной работе);\n\
    8. Вызвать системную функцию или процедуру;\n\
    9. Создать таблицу в базе данных, соответствующую тематике БД;\n\
    10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY. \n\
    11. Показать варики.\n\
    0. Конец \n"
    # Объект cursor используется для фактического
    # выполнения наших команд.
    cur = con.cursor()

    # Интерфейс.
    #window(cur, con)
    ch = 1
    print(info_txt)
    try:
        while(ch > 0 and ch < 12):
            ch = int(input("Что выбираете: "))
            if ch == 1:
                task1(cur, con)
            if ch == 2:
                task2(cur, con)
            if ch == 3:
                task3(cur, con)
            if ch == 4:
                task4(cur, con)
            if ch == 5:
                task5(cur, con)
            if ch == 6:
                task6(cur, con)
            if ch == 7:
                task7(cur, con)
            if ch == 8:
                task8(cur, con)
            if ch == 9:
                task9(cur, con)
            if ch == 10:
                task10(cur, con)
            if ch == 11:
                print(info_txt)
    except:
        cur.close()
        con.close()

    # Закрываем соединение с БД.
    cur.close()
    con.close()


if __name__ == "__main__":
    main()