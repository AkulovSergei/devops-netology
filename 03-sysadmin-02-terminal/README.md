## Домашнее задание к занятию "3.2. Работа в терминале, лекция 2"
##
## Вопрос 1. Какого типа команда cd?
**type cd** - получаем информацию о типе команды
Это встроенная команда Bash, она меняет текущую директорию только для оболочки, в которой выполняется. 
Поскольку команда является внутренней, она выполняется в том же процессе, что и оболочка, использует те же 
файловые дескрипторы, ту же область памяти. Поэтому команде cd гораздо рациональней быть внутренней, чем внешней.
## 
## Вопрос 2. Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l? 
Команда grep <some_string> <some_file> производит поиск <some_string> в stdin, в нашем примере - <some_file>, 
затем передает найденные строки в stdout, в нашем примере - через pipe передает их на stdin команды wc -l, 
которая подсчитывает количество строк в stdin и выводит результат в stdout, в нашем примере в окно терминала.
Команда grep **-c <some_string> <some_file>** делает тоже самое без использования pipe и дополнительных команд.
##
## Вопрос 3. Какой процесс с PID 1 является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?
Используя команду **pstree -p** видим - процесс **systemd(1)** является родителем для всех процессов.
##
## Вопрос 4. Как будет выглядеть команда, которая перенаправит вывод stderr ls на другую сессию терминала?
Выполняем команду из pts/0 и передаем результат в pts/1
**ls \netology 2>/dev/pts/1**
##
## Вопрос 5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.
**grep -c string* file.txt>file1.txt**. Данная команда посылает файл с именем file.txt на stdin команде grep. 
Команда grep производит подсчет всех строк начинающихся на слово string, и выводит результат этого подсчета, 
свой stdout в файл file1.txt.
##
## Вопрос 6. Получится ли находясь в графическом режиме, вывести данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?
**echo hello from netology>/dev/tty3**
Данная команда передаст введенное сообщение из графического терминала SHELL на эмулятор TTY, комбинация клавиш 
Ctrl+Alt+F3 откроет окно терминала, в котором можно будет прочитать переданный текст.
##
## Вопрос 7. Выполните команду bash 5>&1. К чему она приведет? Что будет, если вы выполните echo netology > /proc/$$/fd/5? Почему так происходит?
Команда **bash 5>&1** создаст для процесса bush новый файловый дескриптор с номером 5 и перенаправит его в stdout 
процесса bush(окно терминала SHELL) .
Команда **echo netology > /proc/$$/fd/5**: берет заданную строку (netology) из stdin; передает считанный из stdin 
текст в файловый дескриптор номер 5 процесса bash; дескриптор номер 5 перенаправляет переданный ему текст на 
stdout процесса bush (окно терминала SHELL); bush выводит в окно терминала пришедший на его stdout текст: netology
##
## Вопрос 8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty? Напоминаем: по умолчанию через pipe передается только stdout команды слева от | на stdin команды справа. 
**~$ pwd && dir netology 3>&1 2>&3 | wc -d**
- Команда pwd выведет в окно терминала полный путь текущей директории
- Команда dir netology попытается найти несуществующую директорию netology и выдаст ошибку на stderr
- 3>&1 создает новый дескриптор 3 и перенаправляет его в stdout
- 2>&3 перенаправляет stderr на дескриптор 3
- Команда wc получает на свой stdin строку ошибки переданную через дескриптор 3 на stdout предыдущей команды, 
- ключ -d подсчитывает количество слов в строке ошибки и выводит результат в окно терминала.
##
## Вопрос 9. Что выведет команда cat /proc/$$/environ? Как еще можно получить аналогичный по содержанию вывод?
**Environ** - переменная окружения конкретного запущенного процесса. В нашем случае данная команда выведет в окно 
терминала содержание переменной окружения процесса bash
Команды **env** и **printenv** выведут в окно терминала все имена и значения всех переменных окружения
##
## Вопрос 10. Используя man, опишите что доступно по адресам /proc/cmdline, /proc/exe
**/proc/cmdline** - храниться полная командная строка до работающего процесса, если процесс не является зомби-процессом.
**/proc/exe** - представляет собой символическую ссылку на исполняемый файл, который инициировал запуск процесса
##
## Вопрос 11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью /proc/cpuinfo
**cat /proc/cpuinfo | grep sse** - с помощью данной команды легко увидеть все поддерживаемые инструкции SSE. 
В моем случае, старшая версия SSE3
##
## Вопрос 12. При открытии нового окна терминала и vagrant ssh создается новая сессия и выделяется pty. Это можно подтвердить командой tty, которая упоминалась в лекции 3.2. Однако:
vagrant@netology1:~$ ssh localhost 'tty'

not a tty
## Почитайте, почему так происходит, и как изменить поведение.
Так происходит, потому что по умолчанию при подключении по ssh происходит запрос pty-сессии,  TTY не выделяется 
для удаленного сеанса. Это можно исправить указав ключ ssh -t тогда TTY запустится принудительно 
**~$ ssh -t localhost 'tty'**
##
## Вопрос 13. Использование reptyr
Предварительная подготовка: меняем разрешение командой: **echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope**
Запускаем еще один терминал (терминал2), узнаем его PID, командой echo $$. Запускаем в терминале2 какой-нибудь 
интерактивный процесс, например htop.
В первом терминале вводим команду: **sudo reptyr -T PID** и видим, что команда reptyr исправно работает!
##
## Вопрос 14. Узнайте что делает команда tee и почему в отличие от sudo echo команда с sudo tee будет работать.
Команда **tee** считывает информацию из потока stdin и записывает ее в stdout и указанный файл.
При выполнении команды **echo string | sudo tee /root/new_file** произойдет следующее: команда echo передаст значение 
string на stdin команды tee, запущенной с правами супер-пользователя; команда tee прочитает строку string на своем 
stdin и запишет ее в stdout (окно терминала) и в указанный файл /root/new_file. Поскольку команда tee запущена с 
правами супер-пользователя проблем с записью в директорию /root не возникнет.