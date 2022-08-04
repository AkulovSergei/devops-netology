// Create instance for monitoring of created infrastructure 

resource "yandex_compute_instance" "monitoring" {
  name = "monitoring"
  zone        = "ru-central1-a"
  hostname = "${var.monitoring_dns_name}"

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
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-hdd"
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    ip_address = "${var.monitoring_ip}"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}