terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
#  experiments = [provider_sensitive_attrs]
}

provider "aws" {
  region = "us-east-1" #var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  assume_role {
    role_arn = "arn:aws:iam::814517281194:role/terraform-sa" #var.terraform-role-arn
  }
}

terraform {
  backend "s3" {
    bucket = "kandasite-tf-state" #var.s3_terraform_bucket
    key = "kandasoft-dev.tfstate" #"${local.name_prefix}.tfstate"
    region = "us-east-1" #var.aws_region
    shared_credentials_file = "~/.aws/credentials"
    role_arn = "arn:aws:iam::814517281194:role/terraform-sa" #var.terraform-role-arn
  }
}
