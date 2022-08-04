# Ansible roles and ansible playbook for creating servises for diplom-work.

Данный [ansible-playbook](./playbook.yml) производит установку и настройку всех необходимых сервисов согласно дипломному заданию.

## Краткое описание созданных ролей, в порядке их примения:

Роли для реверс-прокси сервера NGINX:
- роль [nginx](./roles/nginx/). Устанавливает  NGINX сервер и конфигурирует его для использования в качестве реверс-прокси сервера.
- роль [certbot](./roles/certbot/). Уставливает ПО для получения сертификатов letsencrypt, генерирует запрос на сертификаты, помещает полученные сертификаты в указанное место хранения.
- роль [nginx-https-config](./roles/nginx-https-config/). Перенастраивает конфиги nginx для использования протокола HTTPS

Роли для MySQL сервера:
- роль [mysql-master](./roles/mysql-master/). Устанавливает MySQL, конфигурирует на работу в качестве master, создает необходимую БД, создает необходимых пользователей.
- роль [mysql-slave](./roles/mysql-slave/). Устанавливает MySQL, конфигурирует на работу в качестве slave.

Роль для сервера приложений на WORDPRESS
- роль [wordpress](./roles/wordpress/). Устанавливает apache сервер, устанавливает wordpress, конфигурирует apach для отображения веб-сайта wordpress, конфигурирует wordpress для использования БД созданной на MySQL сервере.

Роли для Gitlab-CE и Gitlab-runner
- роль [gitlab-ce](./roles/gitlab-ce/). Устанавливает Gitlab сервер, конфигурирует его для использования заданного root-пароля, генерирует токен для регистрации раннера.
- роль [gitlab-runner](./roles/gitlab-runner/). Устанавливает и регистрирует gitlab-runner.

Роли для создания системы мониторинга
- роль [node-exporter](./roles/node-exporter/). Устанвливает и настраивает Node Exporter, устанавливается на каждую ВМ, используется для сбора метрик.
- роль [prometheus](./roles/prometheus/). Устанавливает и настраиваит Prometheus для получения метрик от Node Exporter-ов со всех ВМ, конфигурирует правила alert-rules.
- роль [alertmanager](./roles/alertmanager/). Устанавливает и настраивает Alertmanager для генерации алертов при определенных условиях.
- роль [grafana](./roles/grafana/). Устанавливает и настраивает Grafana на получение данных из Prometheus, создает dashboard с метриками Node Exporters со всех серверов.