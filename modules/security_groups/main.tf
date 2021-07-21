/**
* 
* Module - security_groups
* 
* This module is used to create Security groups
* 
* 
* ## Usage
* 
* module "security_groups" {
*     source = "github.com/CURRTIS1/Interview/modules/security_groups"
* 
* }
* 
* 
*/


terraform {
  required_version = "0.13.5"
}

locals {
  tags = {
    environment = var.environment
    layer       = var.layer
    terraform   = "true"
  }
}



## ----------------------------------
## Default ALB to WEB Security Group

resource "aws_security_group" "sg_web" {
  name        = "WebServer Security Group"
  description = "WebServer Security Group"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Port 80 from the Application Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags, {
      "Name" = "WEB Security Group"
    }
  )
}

## ----------------------------------
## Default Internet to ALB Security Group

resource "aws_security_group" "sg_alb" {
  name        = "ALB Security Group"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id
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
      "Name" = "ALB Security Group"
    }
  )
}

## ----------------------------------
## Default Web to RDS Security Group

resource "aws_security_group" "sg_rds" {
  name        = "RDS Security Group"
  description = "RDS Security Group"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Port 3306 from the WebServer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web.id]
  }

  tags = merge(
    local.tags, {
      "Name" = "RDS Security Group"
    }
  )
}

## ----------------------------------
## Default SSH, RDP and HTTP from 0.0.0.0/0 for testing

resource "aws_security_group" "sg_testing" {
  name        = "SSH/RDP/HTTP test"
  description = "Security group for testing SSH/RDP/HTTP"
  vpc_id      = var.vpc_id
  dynamic "ingress" {
    for_each = var.test_ingress_rules
    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags, {
      "Name" = "Test Security Group for testing SSH/RDP/HTTP"
    }
  )
}