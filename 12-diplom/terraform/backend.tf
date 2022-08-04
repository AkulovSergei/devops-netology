// Создаем bucket для хранения tfstate
resource "yandex_storage_bucket" "netology" {
  bucket = "akulov-netology"
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
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
    key = "diplom/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}