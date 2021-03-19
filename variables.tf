locals {
  common_tags = {
    created_by = "terraform"
    app = var.application
    env = var.environment
  }
  name_prefix = "${var.application}-${var.environment}"
}

variable "database" {
  type = object({
    name = string
    user = string
    password = string
  })
  description = "The RDS mysql database configuration"
  default = {
    name = "default"
    user = "admin"
    password = "password"
  }
  sensitive = true
}

variable "vpc_cidr_block" {
  type = object({
    vpc_cidr = string
    subnet_1_cidr = string
    subnet_2_cidr = string
  })
  description = "The RDS mysql database configuration"
  default = {
    vpc_cidr = "10.2.0.0/26"
    subnet_1_cidr = "10.2.0.0/27"
    subnet_2_cidr = "10.2.0.32/27"
  }
}

variable "application" {
  type = string
  description = "The application name. This is using in tags"
  default = "kandasoft"
}

variable "environment" {
  type = string
  description = "The environment name. This is using in tags and resourse names"
  default = "dev"
}

variable "aws_region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}

variable "https-certs" {
  type = object({
    generate = bool
    cert = string
    key = string
  })
  description = "HTTPS certificate settings"
  default = {
    generate = true
    cert = "certs/cert.pem"
    key = "certs/key.pem"
  }
}

variable "ssh-key-pair" {
  type = object({
    generate = bool
    public_key = string
  })
  description = "SSH key settings"
  default = {
    generate = true
    public_key = "ssh-rsa.public.key"
  }
}
