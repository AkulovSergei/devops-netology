variable "yandex_cloud_id" {
  default = "b1g3a9ad3ktf3ktngcjv"
}

variable "yandex_folder_id" {
  default = "b1gnqelhsinht34q3fgh"
}

variable "dom_name" {
  default = "akulovnetology.ru"
}

variable "centos_id" {
  default = "fd8qj9nrqnu79cu7389a"
}
// Задаем переменную в которой будет хрониться IAM_TOKEN переданный через переменную окружения
// export TF_VAR_IAM_TOKEN='IAM-token'
variable "IAM_TOKEN" {
  type = string
}
// Задаем переменную в которой будет хрониться ACCESS_KEY переданный через переменную окружения
// export TF_VAR_ACCESS_KEY='access_key'
variable "ACCESS_KEY" {
  type = string
}
// Задаем переменную в которой будет хрониться SECRET_KEY переданный через переменную окружения
// export TF_VAR_SECRET_KEY='secret_key'
variable "SECRET_KEY" {
  type = string
}

variable "core_fraction" {
  default = 20
}
variable "preemptible" {
  default = true
}

//Задаем переменные для хранения IP адресов
variable "public_ip" {
  default = "51.250.70.239"
}
variable "proxy_ip" {
  default = "192.168.108.11"
}
variable "proxy_dns_name" {
  default = "proxy.akulovnetology.ru"
}

variable "db01_ip" {
  default = "192.168.108.21"
}
variable "db01_dns_name" {
  default = "db01.akulovnetology.ru"
}

variable "db02_ip" {
  default = "192.168.108.22"
}
variable "db02_dns_name" {
  default = "db02.akulovnetology.ru"
}

variable "wordpress_ip" {
  default = "192.168.108.12"
}
variable "wordpress_dns_name" {
  default = "app.akulovnetology.ru"
}

variable "gitlab_ip" {
  default = "192.168.108.13"
}
variable "gitlab_dns_name" {
  default = "gitlab.akulovnetology.ru"
}

variable "runner_ip" {
  default = "192.168.108.14"
}
variable "runner_dns_name" {
  default = "runner.akulovnetology.ru"
}

variable "monitoring_ip" {
  default = "192.168.108.15"
}
variable "monitoring_dns_name" {
  default = "monitoring.akulovnetology.ru"
}
