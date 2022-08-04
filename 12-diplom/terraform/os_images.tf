// Говорим Терраформу где искать образ для виртуальной машины
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}
data "yandex_compute_image" "centos" {
  family = "centos-7"
}
