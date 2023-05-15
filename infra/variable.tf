variable "env" {
  type    = string
  default = "default"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "namespace" {
  type    = string
  default = "kyopongdev"
}

variable "az" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}


variable "app_port" {
  type    = number
  default = 8000
}