// Create revers proxy server for NGINX

resource "yandex_compute_instance" "proxy" {
  name = "proxy"
  zone        = "ru-central1-a"
  hostname = "${var.proxy_dns_name}"

  resources {
    core_fraction = var.core_fraction
    cores  = 2
    memory = 2
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
    ip_address = "${var.proxy_ip}"
    nat = true
    nat_ip_address = "${var.public_ip}"
  }

  metadata = {
    ssh-keys = "centos:${file("~/.ssh/id_rsa.pub")}"
  }

}