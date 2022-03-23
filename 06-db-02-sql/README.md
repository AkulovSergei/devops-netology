# Домашнее задание к занятию "6.2. SQL"

---
## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.
```
version: "3.9"
services:
  postgres:
    image: postgres:12
    container_name: postgres_1
    environment:
      POSTGRES_USER: "user1"
      POSTGRES_PASSWORD: "password1"
      POSTGRES_DB: "user1"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./backup:/backup
      - .:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

---
## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
```
$ psql -h 127.0.0.1 -U user1
$ CREATE USER "test-admin-user" PASSWORD 'password2';
$ CREATE DATABASE test_db;
$ \q
```
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
```
$ psql -h 127.0.0.1 -U user1 test_db
$ CREATE TABLE orders(id serial PRIMARY KEY, Наименование text, Цена integer);
$ CREATE TABLE clients(id serial PRIMARY KEY, ФИО text, Страна text, Заказ text REFERENCES orders);
```
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
```
$ GRANT ALL PRIVILEGES ON TABLE orders, clients TO "test-admin-user";
```
- создайте пользователя test-simple-user
```
$ CREATE USER "test-simple-user" PASSWORD 'password3';
```
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
```
$ GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE orders, clients TO "test-simple-user";
```

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
```
test_db=# \l
                                  List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    |      Access privileges      
-----------+-------+----------+------------+------------+-----------------------------
 postgres  | user1 | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | user1 | UTF8     | en_US.utf8 | en_US.utf8 | =c/user1                   +
           |       |          |            |            | user1=CTc/user1
 template1 | user1 | UTF8     | en_US.utf8 | en_US.utf8 | =c/user1                   +
           |       |          |            |            | user1=CTc/user1
 test_db   | user1 | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/user1                  +
           |       |          |            |            | user1=CTc/user1            +
           |       |          |            |            | "test-admin-user"=CTc/user1
 user1     | user1 | UTF8     | en_US.utf8 | en_US.utf8 | 
(5 rows)
```
- описание таблиц (describe)
```
test_db=# \d orders
                            Table "public.orders"
 Column |  Type   | Collation | Nullable |              Default               
--------+---------+-----------+----------+------------------------------------
 id     | integer |           | not null | nextval('orders_id_seq'::regclass)
 name   | text    |           |          | 
 price  | integer |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_oder_fkey" FOREIGN KEY (oder) REFERENCES orders(id)

test_db=# \d clients
                             Table "public.clients"
 Column  |  Type   | Collation | Nullable |               Default               
---------+---------+-----------+----------+-------------------------------------
 id      | integer |           | not null | nextval('clients_id_seq'::regclass)
 surname | text    |           |          | 
 country | text    |           |          | 
 oder    | integer |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_oder_fkey" FOREIGN KEY (oder) REFERENCES orders(id)
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```
$ SELECT * FROM information_schema.table_privileges WHERE table_catalog='test_db';
```
- список пользователей с правами над таблицами test_db
```
test_db=# \dp orders
                                    Access privileges
 Schema |  Name  | Type  |        Access privileges        | Column privileges | Policies 
--------+--------+-------+---------------------------------+-------------------+----------
 public | orders | table | user1=arwdDxt/user1            +|                   | 
        |        |       | "test-simple-user"=arwd/user1  +|                   | 
        |        |       | "test-admin-user"=arwdDxt/user1 |                   | 
(1 row)

test_db=# \dp clients
                                     Access privileges
 Schema |  Name   | Type  |        Access privileges        | Column privileges | Policies 
--------+---------+-------+---------------------------------+-------------------+----------
 public | clients | table | user1=arwdDxt/user1            +|                   | 
        |         |       | "test-simple-user"=arwd/user1  +|                   | 
        |         |       | "test-admin-user"=arwdDxt/user1 |                   | 
(1 row)
```

---
## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

```
$ INSERT INTO orders (Наименование, Цена) VALUES ('Шоколад', 10), ('Принтер', 3000), ('Книга', 500), ('Монитор', 7000), ('Гитара', 4000);
```

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

```
$ INSERT INTO clients (ФИО, Страна) VALUES ('Иванов Иван Иванович', 'USA'), ('Петров Петр Петрович', 'Canada'), ('Иоганн Себастьян Бах', 'Japan'), ('Ронни Джеймс Дио', 'Russia'), ('Ritchie Blackmore', 'Russia');
```

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

```
test_db=# SELECT count(*) FROM orders;
 count 
-------
     5
(1 row)

test_db=# SELECT count(*) FROM clients;
 count 
-------
     5
(1 row)
```

---
## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
```
test_db=# UPDATE clients SET Заказ = 3 WHERE id = 1;
test_db=# UPDATE clients SET Заказ = 4 WHERE id = 2;
test_db=# UPDATE clients SET Заказ = 5 WHERE id = 3;
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
```
test_db=# SELECT * FROM clients WHERE Заказ is not null;
 id |         ФИО          | Страна | Заказ 
----+----------------------+--------+-------
  1 | Иванов Иван Иванович | USA    |     3
  2 | Петров Петр Петрович | Canada |     4
  3 | Иоганн Себастьян Бах | Japan  |     5
(3 rows)

```

---
## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
```
test_db=# EXPLAIN SELECT * FROM clients WHERE Заказ is not null;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..1.05 rows=5 width=72)
   Filter: ("Заказ" IS NOT NULL)
(2 rows)
```
Планировщик выбрал следующий план запроса:
1. Первый узел плана "Seq Scan" производит последовательное сканирование таблицы clients. Отображаются затраты (стоимость) сканирования. Единица измерения стоимости - извлечение одной страницы памяти с диска в последовательном порядке
2. К первому узлу плана применяется заданный нами фильтр ("Заказ" IS NOT NULL). Это означает, что узел плана "Filter" проверяет заданное условие для каждого просканированного им узла и выводит только те строки, которые удовлетворяют ему.

---
## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
```
$ docker exec -t postgres_1 pg_dump -U user1 test_db -f /backup/test_db.sql
```
Остановите контейнер с PostgreSQL (но не удаляйте volumes).
```
$ docker-compose stop
```
Поднимите новый пустой контейнер с PostgreSQL.
```
$ docker run -d --name postgres_2 -e POSTGRES_PASSWORD=postgres -it -p 5432:5432 -v $(pwd)backup:/backup postgres:12
```
Восстановите БД test_db в новом контейнере.
```
$ docker exec -i postgres_2 psql -U postgres -d postgres -f /backup/test_db.sql
```

