terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket               = "kyoong-dev-tf"
    key                  = "terraform.tfstate"
    region               = "ap-northeast-2"
    workspace_key_prefix = "temp"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}


module "vpc_list" {
  source = "./infra"
  env    = terraform.workspace
}

