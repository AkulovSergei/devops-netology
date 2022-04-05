# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
```
version: "3.9"
services:
  postgres:
    image: postgres:13
    container_name: postgres_1
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "password1"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./backup:/backup
      - ./test_data:/test_data
      - .:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

Подключитесь к БД PostgreSQL используя `psql`.
```
# docker exec -it postgres_1 psql -U postgres
```
Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
```
\l[+]   [PATTERN]      list databases

```
- подключения к БД
```
\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database (currently "postgres")
```
- вывода списка таблиц
```
\dt[S+] [PATTERN]      list tables
```
- вывода описания содержимого таблиц
```
\d[S+]                 list tables, views, and sequences
```
- выхода из psql
```
\q                     quit psql
```

---

## Задача 2

Используя `psql` создайте БД `test_database`.
```
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
```
Изучите бэкап БД

Восстановите бэкап БД в `test_database`.
```
docker exec -it postgres_1 bash
# psql -U postgres -d test_database -f /test_data/test_dump.sql
```
Перейдите в управляющую консоль `psql` внутри контейнера.
```
# docker exec -it postgres_1 psql -U postgres
```
Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```
postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".
```
```
test_database=# ANALYZE VERBOSE;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
INFO:  analyzing "pg_catalog.pg_type"
INFO:  "pg_type": scanned 10 of 10 pages, containing 414 live rows and 0 dead rows; 414 rows in sample, 414 estimated total rows
INFO:  analyzing "pg_catalog.pg_foreign_table"
.....
INFO:  "sql_sizing": scanned 1 of 1 pages, containing 23 live rows and 0 dead rows; 23 rows in sample, 23 estimated total rows
INFO:  analyzing "information_schema.sql_features"
INFO:  "sql_features": scanned 8 of 8 pages, containing 712 live rows and 0 dead rows; 712 rows in sample, 712 estimated total rows
ANALYZE
```
Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```
test_database=# SELECT avg_width, attname FROM pg_stats WHERE avg_width = (SELECT MAX(avg_width) FROM pg_stats WHERE tablename='orders');
 avg_width | attname 
-----------+---------
        16 | title
(1 row)
```

---
## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.
```
BEGIN;
ALTER TABLE orders RENAME TO orders_old;
CREATE TABLE orders (LIKE orders_old INCLUDING ALL);
ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;
CREATE TABLE orders_1 (CHECK (price > 499)) INHERITS (orders);
CREATE TABLE orders_2 (CHECK (price <= 499)) INHERITS (orders);
CREATE RULE orders_1_insert AS ON INSERT TO orders WHERE (price > 499) DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);
CREATE RULE orders_2_insert AS ON INSERT TO orders WHERE (price <= 499) DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
INSERT INTO orders SELECT * FROM orders_old;
DROP TABLE orders_old CASCADE;
COMMIT;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Да можно было бы, ниже приведен коректный синтаксис создания секционированной таблицы.
```
BEGIN;
CREATE TABLE orders (
  id serial NOT NULL PRIMARY KEY,
  title character varying(80) NOT NULL,
  price integer DEFAULT 0
);
CREATE TABLE orders_1 (CHECK (price > 499)) INHERITS (orders);
CREATE TABLE orders_2 (CHECK (price <= 499)) INHERITS (orders);
CREATE RULE orders_1_insert AS ON INSERT TO orders WHERE (price > 499) DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);
CREATE RULE orders_2_insert AS ON INSERT TO orders WHERE (price <= 499) DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
COMMIT;
```

---
## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.
```
pg_dump -U postgres test_database > /backup/test_database_backup.sql
```
Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```
ALTER TABLE public.orders
    ADD CONSTRAINT title_unique UNIQUE (title);
```
---
