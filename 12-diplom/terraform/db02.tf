// Create instance for MySQL-slave DB

resource "yandex_compute_instance" "db02" {
  name = "db02"
  zone        = "ru-central1-a"
  hostname = "${var.db02_dns_name}"

  resources {
    core_fraction = var.core_fraction
    cores  = 4
    memory = 4
  }
  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = "${var.centos_id}"
      type = "network-hdd"
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    ip_address = "${var.db02_ip}"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }
}