# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
```
docker build -t akulovsergei/elastic:7 .
```

- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины
```
docker run --rm -d -p 9200:9200 --name elastic akulovsergei/elastic:7
```
В ответе приведите:

- текст Dockerfile манифеста
```
FROM centos:7
ENV PATH=/usr/lib:$PATH

RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
RUN echo "[elasticsearch]" >>/etc/yum.repos.d/elasticsearch.repo &&\
    echo "name=Elasticsearch repository for 7.x packages" >>/etc/yum.repos.d/elasticsearch.repo &&\
    echo "baseurl=https://artifacts.elastic.co/packages/7.x/yum">>/etc/yum.repos.d/elasticsearch.repo &&\
    echo "gpgcheck=1">>/etc/yum.repos.d/elasticsearch.repo &&\
    echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch">>/etc/yum.repos.d/elasticsearch.repo &&\
    echo "enabled=0">>/etc/yum.repos.d/elasticsearch.repo &&\
    echo "autorefresh=1">>/etc/yum.repos.d/elasticsearch.repo &&\
    echo "type=rpm-md">>/etc/yum.repos.d/elasticsearch.repo 

RUN yum install -y --enablerepo=elasticsearch elasticsearch 
    
ADD elasticsearch.yml /etc/elasticsearch/
RUN mkdir /usr/share/elasticsearch/snapshots &&\
    chown elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots
RUN mkdir /var/lib/logs \
    && chown elasticsearch:elasticsearch /var/lib/logs \
    && mkdir /var/lib/data \
    && chown elasticsearch:elasticsearch /var/lib/data
    
USER elasticsearch
CMD ["/usr/sbin/init"]
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
```

- ссылку на образ в репозитории dockerhub
https://hub.docker.com/r/akulovsergei/elastic/tags

- ответ `elasticsearch` на запрос пути `/` в json виде
```
curl -X GET 172.17.0.2:9200
{
  "name" : "40c7d5b902c2",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "-VEQLNGeReSJnzrPdJ3kGw",
  "version" : {
    "number" : "7.17.2",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "de7261de50d90919ae53b0eff9413fd7e5307301",
    "build_date" : "2022-03-28T15:12:21.446567561Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

---
## Задача 2

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```
curl -X PUT 172.17.0.2:9200/ind-1 -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }
}'
curl -X PUT 172.17.0.2:9200/ind-2 -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 2,
      "number_of_replicas": 1
    }
  }
}'
curl -X PUT 172.17.0.2:9200/ind-3 -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 4,
      "number_of_replicas": 2
    }
  }
}'
```
Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```
curl -X GET 172.17.0.2:9200/_cat/indices?v
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases grkeO43eRpSZTu42t5mJ5w   1   0         40            0     37.9mb         37.9mb
green  open   ind-1            hHjsV8NrQdGLaplMyW5D6g   1   0          0            0       226b           226b
yellow open   ind-3            khjRKJAHQY6PuEQ0YqGTPQ   4   2          0            0       904b           904b
yellow open   ind-2            12j1iw3kRLyuwfX2sZig2Q   2   1          0            0       452b           452b

```
Получите состояние кластера `elasticsearch`, используя API.
```
# Запрашиваем состояние кластера
curl -X GET 172.17.0.2:9200/_cluster/health?pretty
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

```
# Запрашиваем состояние отдельных индексов
curl -X GET 172.17.0.2:9200/_cluster/health/ind-1?pretty
{
  "cluster_name" : "netology_test",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

curl -X GET 172.17.0.2:9200/_cluster/health/ind-2?pretty
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}

curl -X GET 172.17.0.2:9200/_cluster/health/ind-3?pretty
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Состояние yellow для отдельного индекса говорит о том, что у него доступны не все реплики. Однако, primary_shard находится в рабочем состоянии и может корректно отвечать на любые запросы.

Удалите все индексы.
```
curl -X DELETE 172.17.0.2:9200/ind-1
curl -X DELETE 172.17.0.2:9200/ind-2
curl -X DELETE 172.17.0.2:9200/ind-3

```

---
## Задача 3

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.
```
curl -X PUT 172.17.0.2:9200/_snapshot/netology_backup?verify=false -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/snapshots"
  }
}'

{"acknowledged":true}

```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```
# API создание индекса test
curl -X PUT 172.17.0.2:9200/test -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }
}'

# Список индексов
curl -X GET 172.17.0.2:9200/_cat/indices?v
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases grkeO43eRpSZTu42t5mJ5w   1   0         40            0     37.9mb         37.9mb
green  open   test             LpWIDTRMSmupII8gaIKaSQ   1   0          0            0       226b           226b

```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.
```
curl -X PUT 172.17.0.2:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
{"snapshot":{"snapshot":"elasticsearch","uuid":"vbYGxVE2SD6EQ43ivJ6ODw","repository":"netology_backup","version_id":7170299,"version":"7.17.2","indices":[".ds-.logs-deprecation.elasticsearch-default-2022.04.13-000001",".geoip_databases",".ds-ilm-history-5-2022.04.13-000001","test"],"data_streams":["ilm-history-5",".logs-deprecation.elasticsearch-default"],"include_global_state":true,"state":"SUCCESS","start_time":"2022-04-13T20:02:06.698Z","start_time_in_millis":1649880126698,"end_time":"2022-04-13T20:02:07.700Z","end_time_in_millis":1649880127700,"duration_in_millis":1002,"failures":[],"shards":{"total":4,"failed":0,"successful":4},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}
```

**Приведите в ответе** список файлов в директории со `snapshot`ами.
```
bash-4.2$ pwd && ls -la
/usr/share/elasticsearch/snapshots
total 60
drwxr-xr-x 1 elasticsearch elasticsearch  4096 Apr 13 20:02 .
drwxr-xr-x 1 root          root           4096 Apr 13 11:41 ..
-rw-r--r-- 1 elasticsearch elasticsearch  1425 Apr 13 20:02 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Apr 13 20:02 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch  4096 Apr 13 20:02 indices
-rw-r--r-- 1 elasticsearch elasticsearch 29292 Apr 13 20:02 meta-vbYGxVE2SD6EQ43ivJ6ODw.dat
-rw-r--r-- 1 elasticsearch elasticsearch   712 Apr 13 20:02 snap-vbYGxVE2SD6EQ43ivJ6ODw.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
```
# API удаления индекса test
curl -X DELETE 172.17.0.2:9200/test

# API создание индекса test-2
curl -X PUT 172.17.0.2:9200/test-2 -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    }
  }
}'

# Список индексов
curl -X GET 172.17.0.2:9200/_cat/indices?v
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2           mXz1K1lUQ6WBjIj2DP60VA   1   0          0            0       226b           226b
green  open   .geoip_databases grkeO43eRpSZTu42t5mJ5w   1   0         40            0     37.9mb         37.9mb

```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```
# API восстановления кластера
curl -X POST 172.17.0.2:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'
{
  "indices": "test",
  "include_global_state": true
}'

# Список индексов
curl -X GET 172.17.0.2:9200/_cat/indices?v
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases CLkQV2ugQGyMgT_EwqIcqw   1   0         40            0     37.9mb         37.9mb
green  open   test-2           mXz1K1lUQ6WBjIj2DP60VA   1   0          0            0       226b           226b
green  open   test             wqaiEGJ8RRCVywPaJSC6jQ   1   0          0            0       226b           226b

```
---