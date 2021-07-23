/**
 * # 000base - main.tf
 */

terraform {
  required_version = "0.13.5"

  backend "s3" {
    bucket  = "curtis-terraform-interview-2021"
    key     = "terraform.000base.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  version    = "~> 3.3.0"
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

## ----------------------------------
## vpc module

module "vpc_basenetwork" {
  source = "github.com/CURRTIS1/Interview/modules/vpc_basenetwork"

  vpc_cidr             = var.vpc_cidr
  subnet_public_range  = var.subnet_public_range
  subnet_private_range = var.subnet_private_range
  vpc_name             = var.vpc_name
}