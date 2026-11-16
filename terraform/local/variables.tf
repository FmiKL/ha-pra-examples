variable "project_name" {
  type    = string
  default = "seasonal-ha-pra"
}

variable "app_image" {
  type    = string
  default = "seasonal-ha-pra-app:local"
}

variable "lb_port" {
  type    = number
  default = 8081
}
