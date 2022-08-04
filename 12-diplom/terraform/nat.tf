locals {
  nat_instance_image_id  = "fd82fnsvr0bgt1fid7cl" # An image ID for a NAT instance. See https://cloud.yandex.ru/marketplace/products/yc/nat-instance-ubuntu-18-04-lts for details.
  cidr_internet          = "0.0.0.0/0"            # All IPv4 addresses.
}

// Create Nat instance
resource "yandex_compute_instance" "nat-instance-vm" {
  description = "NAT instance VM"
  name        = "nat-instance-vm"
  platform_id = "standard-v3" # Intel Ice Lake
  zone        = "ru-central1-b"

  resources {
    cores  = 2 # vCPU
    memory = 2 # GB
  }
  
  boot_disk {
    initialize_params {
      image_id = local.nat_instance_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

// Create rout-table
resource "yandex_vpc_route_table" "route-table-nat" {
  description = "Route table for Data Proc cluster subnet" # All requests can be forwarded to the NAT instance IP address.
  name        = "route-table-nat"

  depends_on = [
    yandex_compute_instance.nat-instance-vm
  ]

  network_id = yandex_vpc_network.default.id

  static_route {
    destination_prefix = local.cidr_internet
    next_hop_address   = yandex_compute_instance.nat-instance-vm.network_interface.0.ip_address
  }
}