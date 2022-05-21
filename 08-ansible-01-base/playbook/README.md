# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?
`/playbook/group_vars/all/examp.yml`

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?
`ansible-playbook site.yml -i ~/ansible/playbook/inventory/test.ymls`

3. Какой командой можно зашифровать файл?
`ansible-vault encrypt <file-name>`

4. Какой командой можно расшифровать файл?
`ansible-vault decrypt <file-name>`

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?
`ansible-vault view <file-name>`

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?
` ansible-playbook site.yml -i ~/ansible/playbook/inventory/prod.yml --ask-vault-password`

7. Как называется модуль подключения к host на windows?
```
ansible-doc --type connection --list | grep Microsoft

psrp                           Run tasks over Microsoft PowerShell Remoting...
winrm                          Run tasks over Microsoft's WinRM 
```

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh
` ansible-doc --type connection --list | grep ssh`

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?
```
ansible-doc --type connection ssh

- remote_user
        User name with which to login to the remote server, normally set by the remote_user keyword.

```