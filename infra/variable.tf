variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "container_port" {
  type    = number
  default = 8000
}

variable "host_port" {
  type    = number
  default = 8000
}

variable "app_name" {
  type    = string
  default = "ecs-fargate-app"
}

variable "digest" {
  type    = string
  default = "sha256:9a60440ff8082ae8194d16a7016d51e5bfbdefdfe4d085440281c27259951ad3"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "repository_url" {
  type    = string
  default = "766738930863.dkr.ecr.ap-northeast-2.amazonaws.com/roof"
}

variable "env" {
  type    = string
  default = "default"
}

variable "cidr" {
  type    = string
  default = "172.16.0.0/16"
}

variable "namespace" {
  type    = string
  default = "kyopongdev"
}

variable "az" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "template_path" {
  type    = string
  default = "infra/ecs.config.tpl"
}


variable "scaling_max_capacity" {
  type    = number
  default = 3
}

variable "scaling_min_capacity" {
  type    = number
  default = 1
}

variable "database_name" {
  type    = string
  default = "roof"
}

variable "rds_name" {
  type    = string
  default = "roof-test"
}

variable "rds_username" {
  type    = string
  default = "admin"
}

variable "rds_password" {
  type    = string
  default = "wemacu123qwe"
}