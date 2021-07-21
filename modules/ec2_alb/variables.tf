/**
 * # ec2_alb - variables.tf
 */

variable "region" {
  description = "The region we are building into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Build environment"
  type        = string
  default     = "Development"
}

variable "layer" {
  description = "Terraform layer"
  type        = string
  default     = "300compute"
}

variable "tg_name" {
  description = "Name of the Target Group"
  type        = string
  default     = "My-ELB-TG"
}

variable "vpc_id" {
  description = "VPC to place the target group"
  type        = string
}

variable "tg_port" {
  description = "Port to be used for the target group"
  type        = number
  default     = "80"
}

variable "tg_protocol" {
  description = "Protocol to be used for the target group"
  type        = string
  default     = "HTTP"
}

variable "elb_name" {
  description = "Name of the elastic loadbalancer"
  type        = string
  default     = "My-ELB"
}

variable "elb_subnets" {
  description = "Subnets for the elastic loadbalancer"
  type        = list(string)
}

variable "elb_securitygroups" {
  description = "Security groups for the elastic loadbalancer"
  type        = list(string)
}

variable "ip_type" {
  description = "IP type to be used"
  type        = string
  default     = "ipv4"
}

variable "elb_internal" {
  description = "Whether it is an internal loadbalancer or not"
  type        = bool
  default     = false
}

variable "elb_port" {
  description = "Port to be used for the Loadbalancer"
  type        = number
  default     = "80"
}

variable "elb_protocol" {
  description = "Protocol to be used for the Loadbalancer"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type for the TG"
  type        = string
  default     = "instance"
}