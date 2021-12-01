## Домашнее задание к занятию "3.5. Файловые системы"
##
## Вопрос 1. Узнайте о sparse (разряженных) файлах.
Разряженные файлы - специальные файлы, которые позволяют эффективно использовать свободное дисковое пространство носителя: занимать его только в случае фактической необходимости, когда в файл будет добавлена реальная информация. Т.е. у разряженного файла есть логический (максимально возможный) объем, но на деле полезной информацией занята только его часть, остальная часть (пустая информация) заполнена нулями и хранится в блоке метаданных ФС.

Команда **truncate -s<size> <file-name>** - создает разряженный файл заданного объема в Линукс.
##
## Вопрос 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

При создании нового файла в Линукс для него создается индексный дескриптор inode, запись в таблице, каждый элемент которой хранит информацию об отдельном файле. Индексные дескрипторы это те объекты, на которые указывают элементы каталога. При создании жесткой ссылки на существующий файл создается новый элемент каталога, но не новый индексный дескриптор.

Атрибуты объектов файловой системы, такие как: идентификатор владельца объекта и права доступа привязаны к inode этого объекта и являются общими для всех жестких ссылок на этот объект. **Следовательно, файлы являющиеся жесткой ссылкой на один объект не могут иметь разные права доступа и владельца**
##
## Вопрос 3. Создаем новую VM из предложенной конфигурации.

NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT

sda 8:0 0 64G 0 disk 

├─sda1 8:1 0 512M 0 part /boot/efi

├─sda2 8:2 0 1K 0 part 

└─sda5 8:5 0 63.5G 0 part 

  ├─vgvagrant-root 253:0 0 62.6G 0 lvm /

  └─vgvagrant-swap_1 253:1 0 980M 0 lvm [SWAP]

sdb 8:16 0 2.5G 0 disk 

sdc 8:32 0 2.5G 0 disk 
 
##
## Вопрос 4. Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

**~$ sudo fdisk /dev/sdb**

Welcome to fdisk (util-linux 2.34).

Changes will remain in memory only, until you decide to write them.

Be careful before using the write command.
 

Device does not contain a recognized partition table.

Created a new DOS disklabel with disk identifier 0xcac1800a.
 

Command (m for help): n

Partition type

   p primary (0 primary, 0 extended, 4 free)

   e extended (container for logical partitions)

Select (default p): 
 

Using default response p.

Partition number (1-4, default 1): 

First sector (2048-5242879, default 2048): 

Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

 

Created a new partition 1 of type 'Linux' and of size 2 GiB.
 

Command (m for help): n

Partition type

   p primary (1 primary, 0 extended, 3 free)

   e extended (container for logical partitions)

Select (default p): 

 

Using default response p.

Partition number (2-4, default 2): 

First sector (4196352-5242879, default 4196352): 

Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): 

 

Created a new partition 2 of type 'Linux' and of size 511 MiB.

 

Command (m for help): w

The partition table has been altered.

Calling ioctl() to re-read partition table.

Syncing disks.
 
##
## Вопрос 5. Используя sfdisk, перенесите данную таблицу разделов на второй диск.

**root@vagrant:~# sfdisk -d /dev/sdb | sfdisk /dev/sdc**
 
##
## Вопрос 6. Соберите mdadm RAID1 на паре разделов 2 Гб.

**root@vagrant:~# mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1**
##
## Вопрос 7. Соберите mdadm RAID0 на второй паре маленьких разделов.

**root@vagrant:~# mdadm --create --verbose /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2**
##
## Вопрос 8. Создайте 2 независимых PV на получившихся md-устройствах.

**root@vagrant:~# pvcreate /dev/md0 /dev/md1**
##
## Вопрос 9. Создайте общую volume-group на этих двух PV.

**root@vagrant:~# vgcreate volume_group1 /dev/md0 /dev/md1**
##
## Вопрос 10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

**root@vagrant:~# lvcreate -L 100M -n logical-vol1 volume_group1 /dev/md1**
##
## Вопрос 11. Создайте mkfs.ext4 ФС на получившемся LV.

**root@vagrant:~# mkfs.ext4 /dev/volume_group1/logical_vol1**
 
##
## Вопрос 12. Смонтируйте этот раздел в любую директорию, например, /tmp/new.

**root@vagrant:~# mkdir /tmp/new**

**root@vagrant:~# mount /dev/volume_group1/logical_vol1 /tmp/new**
 
##
## Вопрос 13. Поместите туда тестовый файл,

**root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz**
 
##
## Вопрос 14. Прикрепите вывод lsblk.

**root@vagrant:~# lsblk**

NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT

sda 8:0 0 64G 0 disk  

├─sda1 8:1 0 512M 0 part /boot/efi

├─sda2 8:2 0 1K 0 part  

└─sda5 8:5 0 63.5G 0 part  

  ├─vgvagrant-root 253:0 0 62.6G 0 lvm /

  └─vgvagrant-swap_1 253:1 0 980M 0 lvm [SWAP]

sdb 8:16 0 2.5G 0 disk  

├─sdb1 8:17 0 2G 0 part  

│ └─md0 9:0 0 2G 0 raid1 

└─sdb2 8:18 0 511M 0 part  

  └─md1 9:1 0 1018M 0 raid0 

    └─volume_group1-logical_vol1

                               253:2 0 100M 0 lvm /tmp/new

sdc 8:32 0 2.5G 0 disk  

├─sdc1 8:33 0 2G 0 part  

│ └─md0 9:0 0 2G 0 raid1 

└─sdc2 8:34 0 511M 0 part  

  └─md1 9:1 0 1018M 0 raid0 

    └─volume_group1-logical_vol1

                               253:2 0 100M 0 lvm /tmp/new

 
##
## Вопрос 15. Протестируйте целостность файла:

**root@vagrant:~# gzip -t /tmp/new/test.gz**

**root@vagrant:~# echo $?**

**0**
 
##
## Вопрос 16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

**root@vagrant:~# pvmove /dev/md1 /dev/md0**

  /dev/md1: Moved: 16.00%

  /dev/md1: Moved: 100.00%

**root@vagrant:~# lsblk**

NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT

sda 8:0 0 64G 0 disk  

├─sda1 8:1 0 512M 0 part /boot/efi

├─sda2 8:2 0 1K 0 part  

└─sda5 8:5 0 63.5G 0 part  

  ├─vgvagrant-root 253:0 0 62.6G 0 lvm /

  └─vgvagrant-swap_1 253:1 0 980M 0 lvm [SWAP]

sdb 8:16 0 2.5G 0 disk  

├─sdb1 8:17 0 2G 0 part  

│ └─md0 9:0 0 2G 0 raid1 

│ └─volume_group1-logical_vol1

│ 253:2 0 100M 0 lvm /tmp/new

└─sdb2 8:18 0 511M 0 part  

  └─md1 9:1 0 1018M 0 raid0 

sdc 8:32 0 2.5G 0 disk  

├─sdc1 8:33 0 2G 0 part  

│ └─md0 9:0 0 2G 0 raid1 

│ └─volume_group1-logical_vol1

│ 253:2 0 100M 0 lvm /tmp/new

└─sdc2 8:34 0 511M 0 part  

  └─md1 9:1 0 1018M 0 raid0 
##
## Вопрос 17. Сделайте --fail на устройство в вашем RAID1 md.

**root@vagrant:~# mdadm /dev/md0 --fail /dev/sdc1**

**mdadm: set /dev/sdc1 faulty in /dev/md0**

**md0 : active raid1 sdc1[1](F) sdb1[0]**
##
## Вопрос 18. Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии.

**root@vagrant:~# dmesg | grep md0**

[ 4843.533856] md/raid1:md0: not clean -- starting background reconstruction

[ 4843.533859] md/raid1:md0: active with 2 out of 2 mirrors

[ 4843.533884] md0: detected capacity change from 0 to 2144337920

[ 4843.534620] md: resync of RAID array md0

[ 4854.307532] md: md0: resync done.

[14058.362353] md/raid1:md0: Disk failure on sdc1, disabling device.

               md/raid1:md0: Operation continuing on 1 devices.
 
##
## Вопрос 19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

**root@vagrant:~# gzip -t /tmp/new/test.gz**

**root@vagrant:~# echo $?**

**0**