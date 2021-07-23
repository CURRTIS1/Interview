/**
 * # 300compute - variables.tf
 */

variable "region" {
  description = "The region we are building into."
  type        = string
}

variable "environment" {
  description = "Build environment"
  type        = string
}

variable "layer" {
  description = "Terraform layer"
  type        = string
}

variable "tg_name" {
  description = "Target group name"
  type        = string
}

variable "elb_name" {
  description = "Loadbalancer name"
  type        = string
}

variable "target_type" {
  description = "Target type for the TG"
  type        = string
  default     = "instance"
}

variable "tg_port" {
  description = "port for the TG"
  type        = number
  default     = 80
}