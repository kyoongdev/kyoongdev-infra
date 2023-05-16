data "aws_s3_bucket" "tf_backend" {
  count  = terraform.workspace == "default" ? 1 : 0
  bucket = "kyoong-dev-tf"
}


locals {
  endpoints = {
    "endpoint-ssm" = {
      name = "ssm"
    },
    "logs" = {
      name = "logs"
    },
    "ecr-api" = {
      name = "ecr.api"
    },
    "ecr-dkr" = {
      name = "ecr.dkr"
    }
  }
}
