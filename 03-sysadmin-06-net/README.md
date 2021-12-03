## Домашнее задание к занятию "3.6. Компьютерные сети, лекция 1"
##
## Вопрос 1. Работа c HTTP через телнет.
**~$ telnet stackoverflow.com 80**

Trying 151.101.193.69...

Connected to stackoverflow.com.

Escape character is '^]'.

GET /questions HTTP/1.0

HOST: stackoverflow.com


HTTP/1.1 301 Moved Permanently

cache-control: no-cache, no-store, must-revalidate

location: https://stackoverflow.com/questions

x-request-guid: 2b11c30f-1547-4785-ad02-4d6be67eb57d

feature-policy: microphone 'none'; speaker 'none'

content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com

Accept-Ranges: bytes

Date: Thu, 02 Dec 2021 18:22:30 GMT

Via: 1.1 varnish

Connection: close

X-Served-By: cache-bma1628-BMA

X-Cache: MISS

X-Cache-Hits: 0

X-Timer: S1638469351.789594,VS0,VE101

Vary: Fastly-SSL

X-DNS-Prefetch-Control: off

Set-Cookie: prov=b201a6b2-e83a-a9ac-1bfc-48e5a1d00923; domain=.stackoverflow.com; expires=Fri, 01-Jan-2055 00:00:00 GMT; path=/; HttpOnly

Сначала, мы подключаемся к сайту stackoverflow.com по 80 порту, с помощью **telnet**. Затем запрашиваем по протоколу HTTP страницу /questions. В ответ получаем сообщение, что запрашиваемый нами ресурс "переехал навсегда" и более не доступен. Теперь он доступен по другому протоколу и адресу - https://stackoverflow.com/questions
##
## Вопрос 2. Повторите задание 1 в браузере, используя консоль разработчика F12
откройте вкладку Network

отправьте запрос http://stackoverflow.com

найдите первый ответ HTTP сервера, откройте вкладку Headers

укажите в ответе полученный HTTP код.

**Request URL: http://stackoverflow.com/**

**Request Method: GET**

**Status Code: 307 Internal Redirect**

проверьте время загрузки страницы, какой запрос обрабатывался дольше всего?

**Request URL: https://stackoverflow.com/**

**Request Method: GET**

**Status Code: 200 **

приложите скриншот консоли браузера в ответ.
![alt text](03-sysadmin-06-net/screenshots/screen1.png)
##
## Вопрос 3. Какой IP адрес у вас в интернете?

**~$ wget -O - -q icanhazip.com**

193.93.135.14

Другие команды показывающие внешний IP:

**~$ wget -q -O - ifconfig.me/ip**

**~$ curl ifconfig.me/ip**
##
## Вопрос 4. Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой whois
**uadmin@ub1:~$ whois 193.93.135.14 | grep 'org-name'** Узнаем имя провайдера

org-name: Alians Telecom Ltd.

**uadmin@ub1:~$ whois 193.93.135.14 | grep 'origin'** Узнаем имя AS

origin: AS49897
 
##
## Вопрос 5. Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой traceroute
**~$ traceroute -An 8.8.8.8**

traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets

 1 172.19.11.185 [*] 5.112 ms 3.180 ms 3.569 ms

 2 10.9.4.2 [*] 4.534 ms 5.150 ms 5.888 ms

 3 5.59.132.70 [AS47626] 7.900 ms 8.822 ms 8.585 ms

 4 100.100.1.29 [*] 9.527 ms 100.100.1.189 [*] 9.803 ms 11.140 ms

 5 74.125.50.5 [AS15169] 31.252 ms 31.020 ms 33.952 ms

 6 * * *

 7 108.170.250.129 [AS15169] 30.006 ms 23.542 ms 172.253.69.166 [AS15169] 25.677 ms

 8 108.170.250.113 [AS15169] 26.391 ms 108.170.250.66 [AS15169] 28.016 ms 26.640 ms

 9 142.250.239.64 [AS15169] 38.280 ms * *

10 216.239.43.20 [AS15169] 41.376 ms 216.239.48.224 [AS15169] 45.839 ms 108.170.232.251 [AS15169] 44.457 ms

11 142.250.208.23 [AS15169] 48.778 ms 142.250.238.181 [AS15169] 43.982 ms 216.239.49.3 [AS15169] 45.907 ms

12 * * *

13 * * *

14 * * *

15 * * *

16 * * *

17 * * *

18 * * *

19 * * *

20 * * *

21 8.8.8.8 [AS15169] 46.686 ms 48.244 ms 46.824 ms

Отправленный пакет проходит через **следующие сети**: 172.19.0.0/16 (ISP-сеть), 10.9.0.0/16 (ISP-сеть), 5.59.128.0/19 (Timer LLC), 100.64.0.0/10(CGN-сеть), 74.125.0.0/16 (Google LLC), 108.170.192.0/18 (Google LLC), 142.250.0.0/15 (Google LLC), 216.239.32.0/19 (Google LLC), 8.8.8.8 (Google LLC)
Через следующие **автономные станции**: AS47626 (Timer LLC), AS15169 (Google LLC).
##
## Вопрос 6. Повторите задание 5 в утилите mtr. На каком участке наибольшая задержка - delay?
Запускаем команду ~$ mtr -r -c 5 8.8.8.8

                                     Loss% Snt Last    Avg    Best    Wrst   StDev

  9.|--  209.85.255.136   0.0%    5   38.3   38.8   38.0    39.4    0.6

 10.|-- 172.253.65.82     0.0%    5   41.1   44.1   41.1    48.2    2.8

 11.|-- 172.253.64.113   0.0%    5   38.9   40.6   38.6    46.8    3.5

 Колонки Last, Avg, Best, Wrst, StDev - отображают время задержки

 Last – время задержки последнего пакета;

 Avg – среднее время задержки; 

 Best – наименьшее время задержки;

 Wrst – наибольшее время задержки;

 StDev – стандартное отклонение времени задержки. 
##
## Вопрос 7. Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? воспользуйтесь утилитой dig
DNS сервера

**~$ dig google.com NS +noall +answer**

google.com. 70019 IN NS ns2.google.com.

google.com. 70019 IN NS ns1.google.com.

google.com. 70019 IN NS ns3.google.com.

google.com. 70019 IN NS ns4.google.com.


А записи

**~$ dig google.com +noall +answer**

google.com. 96 IN A 209.85.233.138

google.com. 96 IN A 209.85.233.102

google.com. 96 IN A 209.85.233.113

google.com. 96 IN A 209.85.233.101

google.com. 96 IN A 209.85.233.100

google.com. 96 IN A 209.85.233.139
 
##
## Вопрос 8. Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? воспользуйтесь утилитой dig
**~$ dig -x 209.85.233.113 +noall +answer**

113.233.85.209.in-addr.arpa. 6695 IN PTR lr-in-f113.1e100.net.

**~$ dig -x 209.85.233.138 +noall +answer**

138.233.85.209.in-addr.arpa. 71813 IN PTR lr-in-f138.1e100.net. 