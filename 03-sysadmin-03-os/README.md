## Домашнее задание к занятию "3.3. Операционные системы, лекция 1"
## Вопрос 1. Какой системный вызов делает команда cd? 
Первый системный вызов который делает команда cd - это **stat**, с помощью которого происходит проверка, существует ли 
указанная директория /tmp. В нашем случае, такая директория существует, поэтому **stat** возвращает значение **0**; далее 
запускается следующий системный вызов **chdir** который изменяет текущий каталог на указанный /tmp, при этом **chdir** 
возвращает значение **0**.
##
## Вопрос 2. Попробуйте использовать команду file на объекты разных типов на файловой системе. Используя strace выясните, где находится база данных file на основании которой она делает свои догадки ?
Команда **file** использует базу данных хранящуюся в файлах **magic** и **magic.mgc**. При помощи **strace** с ключом **-e** и 
указанием системного вызова **openat** можно увидеть как происходит поиск данных файлов в нескольких директориях, в итоге нужные
файлы находятся: **/etc/magic, /usr/share/misc/magic.mgc**
##
## Вопрос 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof). Основываясь на  знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).
**~$ vim file1** В терминале 1 с помощью vim открываем file1, вносим в него произвольные изменения и сохраняем, не закрывая vim (:w)
В терминале 2:

**~$ sudo rm .file1.swp** Удаляем файл в который пишет файловый дескриптор vim

**~$ ps -a | grep vim** Находим PID процесса, открывшего файл

**~$ lsof -p 4723 | grep file1** Проверяем, что дескриптор указывает на удаленный файл.

**vim 4723 uadmin 3u REG 8,5 12288 398529 /home/uadmin/.file1.swp (deleted)**

**~$ echo ' ' > /proc/4723/fd/3** Затираем дескриптор 3 

**~$ lsof -p 4723 | grep file1** Проверяем наш дескриптор

**vim 4723 uadmin 3u REG 8,5 1 398529 /home/uadmin/.file1.swp (deleted)** Дескриптор успешно очистился
##
## Вопрос 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
Процесс при завершении освобождает все используемые ресурсы, кроме PID и становится зомби-процессом. Фактически **зомби-процесс** - 
это **пустая запись в таблице процессов**, хранящая код завершения для родительского процесса. Следовательно з**омби не занимают 
никаких ресурсов в ОС кроме записей в таблице процессов**, размер которой все же ограничен.
## 
## Вопрос 5. Использование пакета bpfcc-tools для Ubuntu 20.04.  На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? 
**vagrant@vagrant:~$ sudo opensnoop-bpfcc**

PID COMM FD ERR PATH

760 vminfo 5 0 /var/run/utmp

542 dbus-daemon -1 2 /usr/local/share/dbus-1/system-services

542 dbus-daemon 18 0 /usr/share/dbus-1/system-services

542 dbus-daemon -1 2 /lib/dbus-1/system-services

542 dbus-daemon 18 0 /var/lib/snapd/dbus-1/system-services/

368 systemd-udevd 14 0 /sys/fs/cgroup/unified/system.slice/systemd-udevd.service/cgroup.procs

368 systemd-udevd 14 0 /sys/fs/cgroup/unified/system.slice/systemd-udevd.service/cgroup.threads

760 vminfo 5 0 /var/run/utmp

542 dbus-daemon -1 2 /usr/local/share/dbus-1/system-services

542 dbus-daemon 18 0 /usr/share/dbus-1/system-services

542 dbus-daemon -1 2 /lib/dbus-1/system-services

542 dbus-daemon 18 0 /var/lib/snapd/dbus-1/system-services/

760 vminfo 5 0 /var/run/utmp 
##
## Вопрос 6. Какой системный вызов использует uname -a? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в /proc, где можно узнать версию ядра и релиз ОС.
Команда **uname -a** использует одноименный системные вызов **uname()**, подробная информация есть на 2 странице мануала **UNAME(2)**.
Открываем мануал командой  **man 2 uname** и находим требуемую цитату:

Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}
##
## Вопрос 7. Чем отличается последовательность команд через ; и через && в bash?
**cmd1 && cmd2** - команда cmd2  будет выполнена в случае успешного выполнения cmd1

**cmd1 ; cmd2** - команда cmd2 выполнится в любом случае после выполнения cmd1

Назначение  **set -e** следующее: если команда после своего выполнение возвращает значение отличное от 0 происходит
немедленный выход из bash, соответственно все последующие команды выполняться не будут.

**~$ set -e ; test -d /netology ; echo hi** - команда test выдаст значение отличное от 0 и оболочка закроется

**~$ set -e ; test -d /netology && echo hi** - команда test выдаст значение отличное от 0, но оболочка не закроется, потому что
**set -e не применяется при использовании операторов && и ||**, данные операторы запускают проверку exit-кода.
Следовательно set -e не влияет на команды после которых стоит оператор &&
##
## Вопрос 8. Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?
**-e** Выход если команда возвращает значение отличное от нуля

**-u** Рассматривает неустановленные (не заданные) переменные как ошибки

**-x** Режим отладки. Перед выполнением команды печатает её со всеми уже развернутыми подстановками и вычислениями.

**-o pipefail** Возвращает значение последней команды из pipeline, которая завершила свое выполнение со значением отличным от 0.

Если все команды pipeline отработали положительно (вернули 0), то pipefail возвращает 0

_Данный режим можно применять для детального логирования в скриптах._
##
##Вопрос 9. Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе?
Статусы процессов будут выводиться по разному при использовании разных спецификаторов вывода: **s, stat, state**. При использовании
ключа **stat** будут выводиться **дополнительные символы** в статусах процессов

**ps -d -o stat** Показывает статусы всех запущенных процессов

**S (S, SN, Sl, Sl+, S<, S+)** - спящие процессы, ожидающие завершения

**I (I, I<)** - бездействующие (спящие) процессы ядра

**R (R, R+)** - выполняющиеся, либо готовые к выполнению процессы