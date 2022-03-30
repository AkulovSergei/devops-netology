# Домашнее задание к занятию "6.3. MySQL"

---
## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
```
version: "3.9"
services:
  db:
    image: mysql:8
    container_name: mysql_1
    environment:
      MYSQL_ROOT_PASSWORD: "password1"
    volumes:
      - ./test_data:/backup
      - ./data:/var/lib/mysql
    ports:
      - "3306:3306"
    deploy:
      resources:
        limits:
          memory: 1000M
        reservations:
          memory: 1000M
```
Изучите бэкап БД и восстановитесь из него.
```
docker exec -it mysql_1 mysql -u root -p
mysql> CREATE DATABASE test_db;
mysql> use test_db
mysql> source /backup/test_dump.sql
```

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
```
mysql> \s
--------------
mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:		8
Current database:	test_db
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server version:		8.0.28 MySQL Community Server - GPL
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	utf8mb4
Db     characterset:	utf8mb4
Client characterset:	latin1
Conn.  characterset:	latin1
UNIX socket:		/var/run/mysqld/mysqld.sock
Binary data as:		Hexadecimal
Uptime:			5 min 57 sec

Threads: 2  Questions: 38  Slow queries: 0  Opens: 142  Flush tables: 3  Open tables: 60  Queries per second avg: 0.106
--------------

```
Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```
mysql> use test_db
mysql> SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

**Приведите в ответе** количество записей с `price` > 300.
```
mysql> SELECT * FROM orders WHERE price>300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```

---
## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"
```
CREATE USER 'test'@'%'
	IDENTIFIED WITH mysql_native_password BY 'test-pass' 
	WITH MAX_QUERIES_PER_HOUR 100
	PASSWORD EXPIRE INTERVAL 180 DAY 
	FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 24
	ATTRIBUTE '{"Surname":"Pretty", "Name":"James"}';
```
Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
```
GRANT SELECT ON test_db.* TO 'test'@'%';
```
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.
```
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
+------+------+----------------------------------------+
| USER | HOST | ATTRIBUTE                              |
+------+------+----------------------------------------+
| test | %    | {"Name": "James", "Surname": "Pretty"} |
+------+------+----------------------------------------+
1 row in set (0.00 sec)
```

---
## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.
```
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)
```
```
mysql> SELECT * FROM orders WHERE price > 120;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
```
```
mysql> SHOW PROFILES;
+----------+------------+----------------------------------------+
| Query_ID | Duration   | Query                                  |
+----------+------------+----------------------------------------+
|        1 | 0.00048000 | select * from orders where price > 120 |
+----------+------------+----------------------------------------+
1 row in set, 1 warning (0.00 sec)
```
```
mysql> SHOW PROFILE CPU FOR QUERY 1;
+--------------------------------+----------+----------+------------+
| Status                         | Duration | CPU_user | CPU_system |
+--------------------------------+----------+----------+------------+
| starting                       | 0.000110 | 0.000056 |   0.000052 |
| Executing hook on transaction  | 0.000010 | 0.000005 |   0.000004 |
| starting                       | 0.000014 | 0.000007 |   0.000007 |
| checking permissions           | 0.000012 | 0.000006 |   0.000006 |
| Opening tables                 | 0.000064 | 0.000033 |   0.000031 |
| init                           | 0.000010 | 0.000005 |   0.000005 |
| System lock                    | 0.000016 | 0.000009 |   0.000007 |
| optimizing                     | 0.000018 | 0.000009 |   0.000009 |
| statistics                     | 0.000029 | 0.000015 |   0.000014 |
| preparing                      | 0.000029 | 0.000014 |   0.000014 |
| executing                      | 0.000066 | 0.000035 |   0.000031 |
| end                            | 0.000011 | 0.000005 |   0.000005 |
| query end                      | 0.000008 | 0.000004 |   0.000004 |
| waiting for handler commit     | 0.000014 | 0.000007 |   0.000007 |
| closing tables                 | 0.000015 | 0.000008 |   0.000007 |
| freeing items                  | 0.000041 | 0.000021 |   0.000019 |
| cleaning up                    | 0.000017 | 0.000008 |   0.000008 |
+--------------------------------+----------+----------+------------+
17 rows in set, 1 warning (0.00 sec)
```
Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
```
mysql> SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES where TABLE_SCHEMA = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.00 sec)
```
Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
```
mysql> ALTER TABLE orders ENGINE MyISAM;
Query OK, 5 rows affected (0.03 sec)
Records: 5  Duplicates: 0  Warnings: 0
```
```
mysql> SHOW PROFILES;
+----------+------------+-----------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                   |
+----------+------------+-----------------------------------------------------------------------------------------+
|        8 | 0.00183100 | SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES where TABLE_SCHEMA = 'test_db' |
|       10 | 0.02999725 | ALTER TABLE orders ENGINE MyISAM                                                        |
+----------+------------+-----------------------------------------------------------------------------------------+
10 rows in set, 1 warning (0.00 sec)

```
- на `InnoDB`
```
mysql> ALTER TABLE orders ENGINE InnoDB;
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

```
```
mysql> SHOW PROFILES;
+----------+------------+-----------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                               |
+----------+------------+-----------------------------------------------------------------------------------------------------+
|       14 | 0.02593850 | ALTER TABLE orders ENGINE InnoDB                                                                    |
+----------+------------+-----------------------------------------------------------------------------------------------------+
14 rows in set, 1 warning (0.00 sec)

```

---
## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
```
[mysqld]
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DSYNC
```
- Нужна компрессия таблиц для экономии места на диске
```
[mysqld]
innodb_file_per_table = ON
```
- Размер буффера с незакомиченными транзакциями 1 Мб
```
[mysqld]
innodb_log_buffer_size = 1M
```
- Буффер кеширования 30% от ОЗУ
```
innodb_buffer_pool_size = 300M
```
- Размер файла логов операций 100 Мб
```
[mysqld]
innodb_log_file_size = 100M
```

Приведите в ответе измененный файл `my.cnf`.
```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DSYNC
innodb_file_per_table = ON
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 300M
innodb_log_file_size = 100M

!includedir /etc/mysql/conf.d/
```

