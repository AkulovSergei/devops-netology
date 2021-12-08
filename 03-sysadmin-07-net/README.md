## Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"
##
## Вопрос 1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?
Linux

**~$ ip -c -br link**

**~$ ifconfig -s**

Windows

**ipconfig /all**
##
## Вопрос 2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?
**Link Layer Discovery Protocol (LLDP)** — протокол канального уровня, позволяющий сетевому оборудованию оповещать оборудование, работающее в локальной сети, о своём существовании и передавать ему свои характеристики, а также получать от него аналогичные сведения. Сообщения LLDP инкапсулируются в Ethernet-кадр и передаются через все активные линки.

Для LLDP зарезервирован multicast MAC-адрес — 01:80:C2:00:00:0E. Это специальный зарезервированный MAC-адрес, который предполагает, что коммутаторы, получившие кадр с таким адресом получателя, не будут его передавать дальше.

В Linux для работы с протоколом LLDP существует пакет **lldpd**. Его необходимо установить и добавить в sysctl

**~$ sudo apt install lldpd**

**~$ sudo systemctl enable lldpd && systemctl start lldpd**

Следующие команды покажут нам соседей

**~$ lldpctl**

**~$ lldpcli**

[lldpcli] **$ show neighbors**
##
## Вопрос 3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.
Коммутатор L2 можно разделить на несколько виртуальных сетей с помощью технологии VLAN (Virtual Local Area Network). При этом, устройства объединенные в одну VLAN не будут "видеть" устройства из другой VLAN

**VLAN в Linux**

На одном физическом порту может совместно существовать несколько VLAN-сетей, которые настраиваются программными средствами Linux, а не конфигурацией физических интерфейсов (но настройка самих интерфейсов тоже требуется). С помощью VLAN можно разделить сетевые ресурсы для использования различных сервисов. Для этого можно использовать команду ip.

**~S lsmod | grep 8021q** Проверяем загружен ли необходимый модуль ядра

**~$ sudo ip link add link enp3s0 name enp3s0.10 type vlan id 10** Создаем новый VLAN интерфейс на имеющейся физической сетевой карте

**~$ sudo ip link set dev enp3s0.10 up** Включаем интерфейс

**~$ ip -c -d -br link show** Проверяем - новый интерфейс появился

**~$ sudo ip link set dev enp3s0.10 down**

**~$ sudo ip link delete enp3s0.10** Удаляем интерфейс
##
## Вопрос 4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.
**Linux bonding** — объединение сетевых интерфейсов в Linux

Объединение сетевых карт в Linux можно осуществить с помощью драйвера bonding, он предоставляет методы для агрегирования нескольких сетевых интерфейсов в один логический. Поведение связанных интерфейсов зависит от режима. В общем случае, объединенные интерфейсы могут работать в режиме горячего резерва (отказоустойчивости) или в режиме балансировки нагрузки.
Настройку bonding можно провести используя скрипты инициализации сети ( initscripts, sysconfig или interfaces ), либо вручную используя ifenslave и sysfs. 

**~$ sudo apt install ifenslave** Устанавливаем необходимый пакет

Пример настройки интерфейсов eth0 и eth1 в режиме active-backup в файле «/etc/network/interfaces»:

auto bond0

iface bond0 inet dhcp

   bond-slaves none

   bond-mode active-backup

   bond-miimon 100

auto eth0

   iface eth0 inet manual

   bond-master bond0

   bond-primary eth0 eth1

auto eth1

iface eth1 inet manual

   bond-master bond0

   bond-primary eth0 eth1
##
## Вопрос 5. Сколько IP адресов в сети с маской /29 ?
**~$ ipcalc 192.168.1.0/29** Получаем 6 IP адресов
## Сколько /29 подсетей можно получить из сети с маской /24.
**~$ ipcalc 192.168.0.1 255.255.255.0 255.255.255.248** Итого 32 подсети и 192 хоста
## Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.
**~$ ipcalc 10.10.10.1 255.255.255.0 255.255.255.248**

 1.

Network: 10.10.10.0/29 

HostMin: 10.10.10.1 

HostMax: 10.10.10.6 

Broadcast: 10.10.10.7 

Hosts/Net: 6 Class A, Private Internet

 2.

Network: 10.10.10.8/29 

HostMin: 10.10.10.9 

HostMax: 10.10.10.14 

Broadcast: 10.10.10.15 

Hosts/Net: 6 Class A, Private Internet
##
## Вопрос 6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.

Для выполнений данной задачи можно использовать сеть из диапазона CGN 100.64.0.0 — 100.127.255.255

**~$ ipcalc -b --split 50 100.64.0.0/10**

1. Requested size: 50 hosts

Netmask: 255.255.255.192 = 26 

Network: 100.64.0.0/26 

HostMin: 100.64.0.1 

HostMax: 100.64.0.62 

Broadcast: 100.64.0.63 

Hosts/Net: 62 Class A
##
## Вопрос 7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?
**~$ arp** Выводит на экран текущее содержание ARP таблицы

**~$ arp -d <address>** Удалить указанную запись из таблицы

**~$ sudo ip neigh flush all** Удалить все записи таблицы