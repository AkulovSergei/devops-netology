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

provider "yandex" {
  token     = var.IAM_TOKEN
  cloud_id  = "b1g3a9ad3ktf3ktngcjv"
  folder_id = "b1gnqelhsinht34q3fgh"
  zone      = "ru-central1-a"
}

// Создаем bucket для хранения tfstate
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
