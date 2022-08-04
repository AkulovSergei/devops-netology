// Create instance for Gitlab-server

resource "yandex_compute_instance" "gitlab" {
  name = "gitlab"
  zone        = "ru-central1-a"
  hostname = "${var.gitlab_dns_name}"

  resources {
    core_fraction = var.core_fraction
    cores  = 4
    memory = 8
  }
  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-hdd"
      size = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    ip_address = "${var.gitlab_ip}"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}