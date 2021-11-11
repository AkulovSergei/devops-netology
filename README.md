# **Домашнее задание к занятию «2.4. Инструменты Git»**
#
# **1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea**
# Выполняем команду **$ git log aefea**, первый результат данной команды - нужный нам коммит
# commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
# Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
# Date:   Thu Jun 18 10:29:58 2020 -0400
# Update CHANGELOG.md
# Соответственно: **полный хэш - aefead2207ef7e2aa5dc81a34aedf0cad4c32545**
# **Комментарий коммита - Update CHANGELOG.md**
# _Эту же информацию можно получить командой **$ git show aefea**_
#
# **2. Какому тегу соответствует коммит 85024d3?**
# С помощью этой же команды находим коммит 85024d3
# **$ git log 85024d3**
# commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
# Author: tf-release-bot <terraform@hashicorp.com>
# Date:   Thu Mar 5 20:56:10 2020 +0000
# v0.12.23
# **Данный коммит соответствует тэгу v0.12.23**
# _Эту же информацию можно получить командами: **$ git show 85024d3** и 
# **$ git show --oneline -s 85024d3**_
#
# **3. Сколько родителей у коммита b8d720? Напишите их хеши.**
# Выполнив команду: $ git show b8d720
# commit b8d720f8340221f2146e4e4870bf2ee0bc48f2d5
# Merge: 56cd7859e 9ea88f22f
# **Видим, что данный коммит является мерж-коммитом, соответственно имеет двух предков**
# хэш первого предка - 56cd7859e, хэш второго - 9ea88f22f
# _Более подробную информацию о предках можно посмотреть с помощью команд:
# $ git show b8d720^ - первый предок
# $ git show b8d720^^ - второй предок_
#
# **4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24**
# Получаем требуемую информацию в сокращенном виде командой:
# **$ git log v0.12.23..v0.12.24 --oneline**
# **33ff1c03b** (tag: v0.12.24) v0.12.24
# **b14b74c49** [Website] vmc provider links
# **3f235065b** Update CHANGELOG.md
# **6ae64e247** registry: Fix panic when server is unreachable
# **5c619ca1b** website: Remove links to the getting started guide's old location
# **06275647e** Update CHANGELOG.md
# **d5f9411f5** command: Fix bug when using terraform login on Windows
# **4b6d06cc5** Update CHANGELOG.md
# **dd01a3507** Update CHANGELOG.md
# **225466bc3** Cleanup after v0.12.23 release
# _Эту же информацию можно получить с помощью команд:
# **$ git rev-list v0.12.23..v0.12.24 --oneline**
# **$ git show v0.12.23..v0.12.24 --oneline --no-patch**_
#
# **5. Найдите коммит в котором была создана функция func providerSource**
# Находим когда было создано определение искомой функции с помощью команды:
# $ git log -S 'func providerSource(' --oneline
# 8c928e835 main: Consult local directories as potential mirrors of providers
# Соответственно коммит **8c928e835** - искомый коммит
#
# **6. Найдите все коммиты в которых была изменена функция globalPluginDirs.**
# С помощью команды **$ git grep -p 'globalPluginDirs('** находим файл plugins.go
# С помощью команды **$ git log -L :globalPluginDirs:plugins.go --oneline** находим все коммиты
# в которых функция globalPluginDirs была изменена
# **78b122055** Remove config.go and update things using its aliases
# **52dbf9483** keep .terraform.d/plugins for discovery
# **41ab0aef7** Add missing OS_ARCH dir to global plugin paths
# **66ebff90c** move some more plugin search path logic to command
# **8364383c3** Push plugin discovery down into command package
#
# **7. Кто автор функции synchronizedWriters?**
# Находим коммиты в которых функция изменялась:
# **$ git log -S"func synchronizedWriters(" --pretty=format:"%h, %an, %ad, %s"**
# bdfea50cc, James Bardin, Mon Nov 30 18:02:04 2020 -0500, remove unused
# 5ac311e2a, Martin Atkins, Wed May 3 16:25:41 2017 -0700, main: synchronize writes to VT100-faker on Windows
# Автор первого коммита **Martin Atkins** - автор нашей функции
#