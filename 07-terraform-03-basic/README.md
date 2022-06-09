# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 
```hcl
resource "yandex_storage_bucket" "netology" {
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  bucket = "akulov-netology"
  lifecycle {
    prevent_destroy = true
  }
  versioning {
    enabled = true
  }
}

// Настраиваем backend для хранения tfstate в баккете s3
terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "akulov-netology"
    region = "ru-central1"
    key = "workspaces/terraform.tfstate"
    access_key = "******"
    secret_key = "******"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
```

## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
2. Создайте два воркспейса `stage` и `prod`.
```hcl
$ terraform workspace new stage
$ terraform workspace new prod
```
3. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
```hcl
// Переменные определяющие версию ОС в зависимости от типа workspace
locals {
  instance_type = {
    stage = data.yandex_compute_image.ubuntu.id
    prod = data.yandex_compute_image.centos.id
  }
}
resource "yandex_compute_instance" "netology" {
  .............................
  boot_disk {
    initialize_params {
      image_id = local.instance_type[terraform.workspace] // Тип ОС определяется типом workspace
      type = "network-hdd"
      size = 12
    }
  }
  ...............................
}
```
4. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
```hcl
// Переменные определяющие количество установок instance в зависимости от типа workspace
locals {
  instance_count = {
    stage = 1
    prod = 2
  }
}

// Создаем ресурсы, в зависимости от типа workspace
resource "yandex_compute_instance" "netology" {
  count = local.instance_count[terraform.workspace] // количество определяется типом workspace
  name = "${terraform.workspace}-${count.index}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  ................
  ................
}
```
5. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
```hcl
// Переменные для цикла for_each
locals {
  instance_count2 = toset([
    "fedora1",
    "fedora2",
  ])
}

// Создаем несколько ресурсом с помощью цикла for_each
resource "yandex_compute_instance" "netology2" {
  for_each = local.instance_count2
  name = "${terraform.workspace}-${each.key}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.fedora.id
      type = "network-hdd"
      size = 12
    }
  }
  ..................
  ..................
}
```
6. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
```hcl
  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }
```
7. При желании поэкспериментируйте с другими параметрами и рессурсами.
---
В виде результата работы пришлите:
* Ссылка на репозиторий с исходной конфигурацией терраформа.  
 [terraform](./terraform/)

* Вывод команды `terraform workspace list`.
```
$ terraform workspace list
  default
* prod
  stage
```
* Вывод команды `terraform plan` для воркспейса `prod`.  
```
$ terraform plan
data.yandex_compute_image.ubuntu: Reading...
data.yandex_compute_image.centos: Reading...
data.yandex_compute_image.fedora: Reading...
data.yandex_compute_image.centos: Read complete after 3s [id=fd8ad4ie6nhfeln6bsof]
data.yandex_compute_image.ubuntu: Read complete after 3s [id=fd87tirk5i8vitv9uuo1]
data.yandex_compute_image.fedora: Read complete after 3s [id=fd8lmgo1jtoe74d3gf48]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.netology[0] will be created
  + resource "yandex_compute_instance" "netology" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + name                      = "prod-0"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8ad4ie6nhfeln6bsof"
              + name        = (known after apply)
              + size        = 12
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.netology[1] will be created
  + resource "yandex_compute_instance" "netology" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + name                      = "prod-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8ad4ie6nhfeln6bsof"
              + name        = (known after apply)
              + size        = 12
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.netology2["fedora1"] will be created
  + resource "yandex_compute_instance" "netology2" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + name                      = "prod-fedora1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8lmgo1jtoe74d3gf48"
              + name        = (known after apply)
              + size        = 12
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.netology2["fedora2"] will be created
  + resource "yandex_compute_instance" "netology2" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + name                      = "prod-fedora2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8lmgo1jtoe74d3gf48"
              + name        = (known after apply)
              + size        = 12
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_storage_bucket.netology will be created
  + resource "yandex_storage_bucket" "netology" {
      + access_key            = "******"
      + acl                   = "private"
      + bucket                = "akulov-netology"
      + bucket_domain_name    = (known after apply)
      + default_storage_class = (known after apply)
      + folder_id             = (known after apply)
      + force_destroy         = false
      + id                    = (known after apply)
      + secret_key            = (sensitive value)
      + website_domain        = (known after apply)
      + website_endpoint      = (known after apply)

      + anonymous_access_flags {
          + list = (known after apply)
          + read = (known after apply)
        }

      + versioning {
          + enabled = true
        }
    }

  # yandex_vpc_network.network_netology will be created
  + resource "yandex_vpc_network" "network_netology" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "prod"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet_netology will be created
  + resource "yandex_vpc_subnet" "subnet_netology" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "prod"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.128.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 7 to add, 0 to change, 0 to destroy.
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
