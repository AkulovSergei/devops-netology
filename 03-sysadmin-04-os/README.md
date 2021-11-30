##Домашнее задание к занятию "3.4. Операционные системы, лекция 2"
##
##Вопрос 1. Настройка node_exporter
$ sudo useradd -r -M -s /bin/false node_exporter Добавляем системного пользователя, от которого будет работать Node Exporter

$ sudo cp ~/node_exporter-1.3.0.linux-amd64  node_exporter /usr/local/bin Копируем скаченный файл node_exporter в bin

$ sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter Назначаем владельца

Создаем Systemd Unit

$ sudo nano /etc/systemd/system/node_exporter.service

[Unit]

Description=Node Exporter

Wants=network-online.target

After=network-online.target

[Service]

User=node_exporter

Group=node_exporter

Type=simple

ExecStart=/usr/local/bin/node_exporter $OPTIONS

EnvironmentFile=-/etc/systemd/system/node_exporter/node_exporter.conf

Restart=on-failure

[Install]

WantedBy=multi-user.target

Добавляем сервис в автозагрузку, запускаем его, проверяем статус

$ sudo systemctl daemon-reload

$ sudo systemctl enable --now node_exporter

$ sudo systemctl status node_exporter

Проверяем порт 9100

$ sudo ss -pnltu | grep 9100
##
##Вопрос 2. Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.
Открываем в браузере: http://localhost:9100/metrics

Метрики CPU

node_cpu_scaling_frequency_hertz Current scaled CPU thread frequency in hertz.

node_cpu_seconds_total Seconds the CPUs spent in each mode.

Метрики MEMORY

node_memory_Active_anon_bytes Memory information field Active_anon_bytes.

node_memory_Active_bytes Memory information field Active_bytes.

Метрики DISK

node_disk_discard_time_seconds_total This is the total number of seconds spent by all discards.

node_disk_io_now The number of I/Os currently in progress.

Метрики NETWORK

node_network_receive_bytes_total Network device statistic receive_bytes.

node_network_receive_drop_total Network device statistic receive_drop.
##
##Вопрос 3. Настройка Netdata
vagrant@vagrant:~$ sudo apt install -y netdata Устанавливаем netdata

vagrant@vagrant:~$ sudo vim /etc/netdata/netdata.conf Меняем IP с localhost на  0.0.0.0.

~$ vim ~/vagrant/Vagrantfile Делаем проброс порта Netdata на свой локальный компьютер

~/vagrant$ vagrant reload Перезагружаем VM

Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

cpu Total CPU utilization (all cores). Общая загрузка ЦП

load Current system load, i.e. the number of processes using CPU or waiting for system resources (usually CPU and disk). Текущая загрузка системы, например количество процессов использующих ЦП или ожидающих системных ресурсов.

disk Total Disk I/O, for all physical disks. Общая загрузка дисковой подсистемы.

ram System Random Access Memory Системная оперативная память

swap System swap memory usage. Использование системой swap-памяти (файла подкачки). Пространство в файле подкачки используется когда места в ОЗУ мало, неактивные страницы из ОЗУ перемещаются в SWAP.

network Total bandwidth of all physical network interfaces. Общая загрузка всех физических сетевых интерфейсов 

System processes. Running are the processes in the CPU. Системные процессы работающие с ЦП. 

Memory Detailed information about the memory management of the system. Детальная информация об использовании системной памяти.
##
##Вопрос 4. Можно ли по выводу dmesg понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?
dmesg Выводит буфер сообщений ядра в stdout.

~$ dmesg -H | grep virtualiz Данная команда покажет нам с чего загружена ОС

Booting paravirtualized kernel on bare hardware Загружена на простом железе

Booting paravirtualized kernel on KVM Загружена на KVM (ПО, обеспечивающее виртуализацию в среде LInux)
##
##Вопрос 5. Как настроен sysctl fs.nr_open на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (ulimit --help)?
sysctl fs.nr_open = 1048576 Общесистемное ограничение на максимальное количество открываемых файловых дескрипторов для всех процессов. По умолчанию, верхний придел  1048576 (1024*1024).

Следует иметь ввиду, что существуют еще "жесткие ограничения" и "мягкие ограничения", которые задаются для каждого отдельного процесса, значения этих ограничений можно посмотреть с помощью команд: ulimit -n (показывает текущие ограничения), ulimit -Sn (показывает мягкие ограничения), ulimit -Hn (показывает жесткие ограничения) по умолчанию максимальное доступное число открытых дескрипторов для процесса - 1024. 

Мягкое значение устанавливается после входа пользователя в систему, но процессу пользователей разрешено увеличивать ограничение до жесткого ограничения. Изменить заданные по умолчанию ограничения можно в этом файле /etc/security/limits.conf, указав требуемое значение nofile.
##
##Вопрос 6. Запустите любой долгоживущий процесс (не ls, который отработает мгновенно, а, например, sleep 1h) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через nsenter.
В терминале 1 выполняем следующие команды:

$ sudo -i 

~# unshare -f --pid --mount-proc /bin/bash Запускаем bash в новом отдельном PID-неймспейсе процессов

~# ps a Проверяем какой PID имеет наш процесс bash

PID TTY STAT TIME COMMAND

 1   pts/1 S     0:00  /bin/bash

~# sleep 1h Запускаем команду sleep в целевом bash 

В терминале 0 подключаемся к спящему bash

~$ ps a | grep sleep Ищем спящий процесс

11247 pts/1 S+ 0:00 sleep 1h

~$ sudo nsenter --target 11247 --pid --mount Подключаемся к спящему процессу

/# pstree -p Проверяем к чему мы подключились

bash(1)───sleep(13) Все в порядке, мы подключились к целевому процессу запущенному в другой оболочке в отдельном неймспейсе процессов.

Если теперь в Терминале 1 завершить команду sleep (ctrl+C), то в Терминале 0 процесс sleep исчезнет из дерева процессов.
##
##Вопрос 7. Найдите информацию о том, что такое :(){ :|:& };:. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04. Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. 
Команда :(){ :|:& };: запускает так называемую fork-бомбу, одну из разновидностей DDoS атак на Linux.

:() - определяет функцию с именем :, с пустыми аргументами.

{ - открывает функцию

:|: - запускает рекурсию, а именно - вызывает функцию : и отправляет результат через pipe на другой вызов этой же функции

& - отправляет вызов функции в background, поэтому child, порожденный fork-ом вызванной функции, продолжает работать и потреблять системные ресурсы

} - закрывает функцию

; - завершает определение функции

: - вызывает функцию :, которая порождает вышеописанную fork-бомбу

При запуске данной fork-бомбы в Ubuntu 20.04 начнут создаваться новые процессы, которые будут пожирать все процессорное время. Процессы будут открываться пока не достигнут ограничения заданного в max user processes, в моем случае ограничение - 23496. Значение данного ограничения можно изменить с помощью ulimit -u <max-PID>