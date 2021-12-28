# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43" # ошибка была в этой строке, не хватало кавычек
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3
import socket
import time
import datetime
import json
import yaml
services = {'drive.google.com': '', 'mail.google.com': '', 'google.com': ''}
# Создаем словарь с сервисами и их ip-адресами
# Выгружаем данные в файлы json и yaml
json_ip = open('script_ip.json', 'w')
yaml_ip = open('script_ip.yaml', 'w')
i = 1
while i < 4:
 for host in services:
  services[host] = socket.gethostbyname(host)
  print(services[host], '-', host)
  dict1 = {host: services[host]}
  json.dump(dict1, json_ip)
  yaml_ip.write(yaml.dump(dict1, explicit_start=True, explicit_end=True))
  i += 1
json_ip.close()
yaml_ip.close()
# Запускаем цикл в котором будем проверять ip указанных сервисов
while True:
 print('Старт цикла проверки сервисов')
 i = 1
 while i < 4:
  for host in services:
   ip = socket.gethostbyname(host)
   # Если проверяемый сервис сменил ip - выводим ошибку, и перезаписываем jsom и yaml файлы
   if services[host] != ip:
    print('[ERROR]', host, 'IP mismatch:', services[host], ip)
    print(datetime.datetime.now())
    services[host] = ip
    json_ip = open('script_ip.json', 'w')
    yaml_ip = open('script_ip.yaml', 'w')
    i = 1
    while i < 4:
     for host in services:
      dict1 = {host: services[host]}
      json.dump(dict1, json_ip)
      yaml_ip.write(yaml.dump(dict1, explicit_start=True, explicit_end=True))
      i += 1
    json_ip.close()
    yaml_ip.close()
   # Если ip сервиса не изменился - выводим в консоль его имя и текущий ip
   else:
    print(host, '-', services[host])
  time.sleep(3)

```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 74.125.131.194
mail.google.com - 64.233.165.17
google.com - 173.194.221.101
drive.google.com - 74.125.131.194
[ERROR] mail.google.com IP mismatch: 64.233.165.17 64.233.165.19
2021-12-28 10:49:48.142215
google.com - 173.194.221.101
Старт цикла проверки сервисов
drive.google.com - 74.125.131.194
mail.google.com - 64.233.165.19
google.com - 173.194.221.101
drive.google.com - 74.125.131.194
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "74.125.131.194"}{"mail.google.com": "64.233.165.19"}{"google.com": "173.194.221.101"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
---
drive.google.com: 74.125.131.194
...
---
mail.google.com: 64.233.165.19
...
---
google.com: 173.194.221.101
...

```