# Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Terraform."


## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта. 
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы 
не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.
```
export TF_VAR_IAM_TOKEN=`IAM-token`
```

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер 
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс 
   1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
   Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
   `Example Usage`, но желательно, указать большее количество параметров.
   2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 

```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = var.IAM_TOKEN
  cloud_id  = "b1g3a9ad3ktf3ktngcjv"
  folder_id = "b1gnqelhsinht34q3fgh"
  zone      = "ru-central1-a"
}

// Задаем переменную в которой будет хрониться IAM_TOKEN переданный через переменную окружения
variable "IAM_TOKEN" {
  type = string
  description = "Use export TF_VAR_IAM_TOKEN = your-iam-token in shell"
}

// Говорим Терраформу где искать образ для виртуальной машины
data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

// Создаем виртуальную машину из публичного образа ubuntu
resource "yandex_compute_instance" "netology" {
  name        = "netology-vm1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      type = "network-hdd"
      size = 9
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_netology.id
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

// Создаем частную сеть
resource "yandex_vpc_network" "network_netology" {
  name = "net_netology"
}

//Создаем частную подсеть
resource "yandex_vpc_subnet" "subnet_netology" {
  name           = "sub_netology"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_netology.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

// Выводим в output внешний ip-адрес созданной виртуальной машины
output "external_ip_addr" {
  value = yandex_compute_instance.netology.network_interface.0.nat_ip_address
}
```

В качестве результата задания предоставьте:
1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?

Terraform

1. Ссылку на репозиторий с исходной конфигурацией терраформа.  
 [terraform](./terraform/)
---

