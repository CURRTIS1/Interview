/**
* 
* Module - ec2_alb
* 
* This module is used to create an Application Loadbalancer
* 
* 
* ## Usage
* 
* module "ec2_asg" {
*     source = "github.com/CURRTIS1/AWS-Onboarding/Terraform/modules/ec2_alb"
* 
*     alb_name = var.alb_name
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
## ELB Target Group

resource "aws_lb_target_group" "elb_target_group" {
  name     = var.tg_name
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  health_check {
    enabled  = true
    path     = "/"
    port     = var.tg_port
    interval = 30
  }

  tags = merge(
    local.tags, {
      "Name" = var.tg_name
    }
  )
}


## ----------------------------------
## ELB

resource "aws_lb" "myelb" {
  name               = var.elb_name
  load_balancer_type = "application"
  subnets            = var.elb_subnets
  security_groups    = var.elb_securitygroups
  ip_address_type    = var.ip_type
  internal           = var.elb_internal

  tags = merge(
    local.tags, {
      "Name" = var.elb_name
    }
  )
}


## ----------------------------------
## ELB Listener

resource "aws_lb_listener" "myelblistener" {
  load_balancer_arn = aws_lb.myelb.arn
  port              = var.elb_port
  protocol          = var.elb_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_target_group.arn
  }
}