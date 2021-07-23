/**
 * # 100security - main.tf
 */

terraform {
  required_version = "0.13.5"

  backend "s3" {
    bucket  = "curtis-terraform-interview-2021"
    key     = "terraform.100security.tfstate"
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

locals {
  tags = {
    environment = var.environment
    layer       = var.layer
    terraform   = "true"
  }
}

data "terraform_remote_state" "state_000base" {
  backend = "s3"
  config = {
    bucket = "curtis-terraform-interview-2021"
    key    = "terraform.000base.tfstate"
    region = "us-east-1"
  }
}

## ----------------------------------
## ECS Security group

resource "aws_security_group" "sg_ecs" {
  name        = "ECS Security Group"
  description = "ECS Security Group"
  vpc_id      = data.terraform_remote_state.state_000base.outputs.vpc_id
  ingress {
    description = "Port 80 from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags, {
      "Name" = "ECS Security Group"
    }
  )
}