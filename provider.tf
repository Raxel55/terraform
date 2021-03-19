terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
  assume_role {
    role_arn = "arn:aws:iam::814517281194:role/terraform-sa"
  }
}

terraform {
  backend "s3" {
    bucket = "kandasite-tf-state"
    key = "kandasoft-dev.tfstate" #"${local.name_prefix}.tfstate"
    region = "us-east-1" #var.aws_region
    shared_credentials_file = "~/.aws/credentials"
    role_arn = "arn:aws:iam::814517281194:role/terraform-sa"
  }
}
