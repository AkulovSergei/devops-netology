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
