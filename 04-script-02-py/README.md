# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | При использовании синтаксиса предложенного в скрипте переменная с не будет определена, следовательно не будет иметь никакого значения. Потому что, мы пытаемся выполнить арифметическую операцию сложение для целочисленной и строковой переменных, а такое делать нельзя  |
| Как получить для переменной `c` значение 12?  | Для этого необходимо во время операции сложения преобразовать  переменную a в строковую c = str(a) + b |
| Как получить для переменной `c` значение 3?  | Для этого необходимо во время операции сложения преобразовать  переменную b в целочисленную c = a + int(b) |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3
import os
bash_command = ["cd ~/git/home", "git status"]
result_os = os.popen (' && '.join(bash_command)).read()
for result in result_os.split('\n'):
  if result.find('изменено') != -1:
    prepare_result = result.replace('\tизменено:      ', 'Modif file ~/git/home/')
    print(prepare_result)
  if result.find('новый файл') != -1:
    prepare_result = result.replace('\tновый файл:    ', 'New file ~/git/home/')
    print(prepare_result)
exit
```

### Вывод скрипта при запуске при тестировании:
```
New file ~/git/home/newdir/test5
New file ~/git/home/test3
New file ~/git/home/test4
Modif file ~/git/home/scr1
Modif file ~/git/home/test3
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3
import argparse
import os
#Добавляем возможность ввода git-директории через аргумент скрипта
parser = argparse.ArgumentParser(description='Need Path to repository')
parser.add_argument('git_dir', type=str, help='Dir with git-rep')
args = parser.parse_args()
#Проверяем существует ли введенная пользователем директория
if os.path.exists(args.git_dir):
 bash_command = ["cd "+args.git_dir, "git status 2>&1"]
 result_os = os.popen (' && '.join(bash_command)).read()
 for result in result_os.split('\n'):
  #Проверяем существует ли репозиторий в введенной директории
  if result.find('fatal') != -1:
    print('\033[31mThere is no git-rep in specified directory  \033[31m')
    print('\033[30m'+args.git_dir+'\033[30m')
  #Проверяем репозиторий на наличие измененных файлов
  if result.find('изменено') != -1:
    prepare_result = result.replace('\tизменено:      ', '\033[32mModified file in git-dir  \033[32m'+'\033[30m'+args.git_dir+'/\033[30m')
    print(prepare_result)
  #Проверяем репозиторий на наличие новых файлов
  if result.find('новый файл') != -1:
    prepare_result = result.replace('\tновый файл:    ', '\033[34mNew file in git-dir  \033[34m'+'\033[30m'+args.git_dir+'/\033[30m')
    print(prepare_result)
#Если предложенная директория не существует сообщаем об этом
else:
 print('\033[31mThe specified directory does not exist   \033[31m')
 print('\033[30m'+args.git_dir+'\033[30m')
```

### Вывод скрипта при запуске при тестировании:
```
uadmin@ub1:~$ ./script2.py ~/git/home
New file in git-dir  /home/uadmin/git/home/newdir/test5
New file in git-dir  /home/uadmin/git/home/test3
New file in git-dir  /home/uadmin/git/home/test4
Modified file in git-dir  /home/uadmin/git/home/scr1
Modified file in git-dir  /home/uadmin/git/home/test3

uadmin@ub1:~$ ./script2.py ~/git/home1
There is no git-rep in specified directory  
/home/uadmin/git/home1

uadmin@ub1:~$ ./script2.py ~/git/home2
The specified directory does not exist   
/home/uadmin/git/home2

```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3
import socket
import time
import datetime
services=('drive.google.com', 'mail.google.com', 'google.com')
good_ip={1:' ', 2:' ', 3:' '}
while (1==1):
 #Создаем массив с "хорошими" айпишниками
 i=1
 while i<4:
  for service in services:
   service_ip = socket.gethostbyname(service)
   good_ip[i] = service_ip
   i+=1
 #Запускаем проверку ip-адресов
 i=1
 while (i<4):
  for service in services:
   service_ip = socket.gethostbyname(service)
   print('\033[30m', service, '-', service_ip)
   # Если сервис сменил ip - выдаем ошибку, выходим из цикла 
   # проверки, по-новой заполняем массих "хороших" ip, продолжаем проверку
   if service_ip != good_ip[i]:
    print('\033[31m[ERROR]', service, 'IP mismatch:', good_ip[i], '\033[34m', service_ip)
    print(datetime.datetime.now())
    break
   i+=1
  break
 time.sleep(3)

```

### Вывод скрипта при запуске при тестировании:
```
 drive.google.com - 74.125.131.194
 mail.google.com - 64.233.165.18
[ERROR] mail.google.com IP mismatch: 64.233.165.19 64.233.165.18
2021-12-17 12:53:21.445855
 drive.google.com - 74.125.131.194
 mail.google.com - 64.233.165.18
 google.com - 173.194.221.139
 drive.google.com - 74.125.131.194
 mail.google.com - 64.233.165.18
 google.com - 173.194.221.139
```
