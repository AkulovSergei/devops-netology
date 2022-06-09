terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

// Говорим Терраформу где искать образ для виртуальной машины
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}
data "yandex_compute_image" "centos" {
  family = "centos-7"
}
data "yandex_compute_image" "fedora" {
  family = "fedora-35"
}

// Создаем ресурсы, в зависимости от типа workspace
resource "yandex_compute_instance" "netology" {
  count = local.instance_count[terraform.workspace] // количество определяется типом workspace
  name = "${terraform.workspace}-${count.index}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = local.instance_type[terraform.workspace] // Тип ОС определяется типом workspace
      type = "network-hdd"
      size = 12
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_netology.id
    nat = true
  }

 /* metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }*/
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

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_netology.id
    nat = true
  }

 /*  metadata = {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }*/

  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }
}

// Создаем частную сеть
resource "yandex_vpc_network" "network_netology" {
  name = terraform.workspace
}

//Создаем частную подсеть
resource "yandex_vpc_subnet" "subnet_netology" {
  name           = terraform.workspace
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_netology.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

// Переменные определяющие количество установок instance в зависимости от типа workspace
locals {
  instance_count = {
    stage = 1
    prod = 2
  }
}

// Переменные определяющие версию ОС в зависимости от типа workspace
locals {
  instance_type = {
    stage = data.yandex_compute_image.ubuntu.id
    prod = data.yandex_compute_image.centos.id
  }
}

// Переменные для цикла for_each
locals {
  instance_count2 = toset([
    "fedora1",
    "fedora2",
  ])
}