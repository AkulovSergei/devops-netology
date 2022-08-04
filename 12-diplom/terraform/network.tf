// Создаем частную сеть
resource "yandex_vpc_network" "default" {
  name = "net"
}

//Создаем частную внутреннюю подсеть
resource "yandex_vpc_subnet" "default" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.108.0/24"]
  route_table_id = yandex_vpc_route_table.route-table-nat.id
}

//Создаем частную внешнюю подсеть для NAT-instance
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

# Cloud DNS
resource "yandex_dns_zone" "default" {
  name        = "dns-zone"
  description = "Internal DNS zone"

  zone             = "akulovnetology.ru."
  public           = false
  private_networks = [yandex_vpc_network.default.id]
}

# Web Proxy Server
resource "yandex_dns_recordset" "proxy" {
  zone_id = yandex_dns_zone.default.id
  name    = "${var.proxy_dns_name}."
  type    = "A"
  ttl     = 600
  data    = ["${var.proxy_ip}"]
}

# MySQL DB
resource "yandex_dns_recordset" "db01" {
  zone_id = yandex_dns_zone.default.id
  name    = "${var.db01_dns_name}."
  type    = "A"
  ttl     = 600
  data    = ["${var.db01_ip}"]
}
resource "yandex_dns_recordset" "db02" {
  zone_id = yandex_dns_zone.default.id
  name    = "${var.db02_dns_name}."
  type    = "A"
  ttl     = 600
  data    = ["${var.db02_ip}"]
}

# Web APP
resource "yandex_dns_recordset" "app" {
  zone_id = yandex_dns_zone.default.id
  name    = "${var.wordpress_dns_name}."
  type    = "A"
  ttl     = 600
  data    = ["${var.wordpress_ip}"]
}

# CI/CD
resource "yandex_dns_recordset" "gitlab" {
  zone_id = yandex_dns_zone.default.id
  name    = "${var.gitlab_dns_name}."
  type    = "A"
  ttl     = 600
  data    = ["${var.gitlab_ip}"]
}
resource "yandex_dns_recordset" "runner" {
  zone_id = yandex_dns_zone.default.id
  name    = "${var.runner_dns_name}."
  type    = "A"
  ttl     = 600
  data    = ["${var.runner_ip}"]
}

# Monitoring
resource "yandex_dns_recordset" "monitoring" {
  zone_id = yandex_dns_zone.default.id
  name    = "${var.monitoring_dns_name}."
  type    = "A"
  ttl     = 600
  data    = ["${var.monitoring_ip}"]
}