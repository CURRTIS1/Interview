/**
 * # vpc_basenetwork - variables.tf
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
  default     = "000Base"
}

variable "vpc_cidr" {
  description = "VPC main CIDR"
  type        = string
}

variable "subnet_public_range" {
  description = "VPC Public CIDR range"
  type        = list(string)
}

variable "subnet_private_range" {
  description = "VPC Private CIDR range"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of custom availability zones"
  type        = list(string)
  default     = []
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "az_count" {
  description = "The number of Availability Zones to deploy in the VPC"
  type        = number
  default     = 2
}

variable "public_subnets_per_az" {
  description = "The number of public subnets to deploy per Availability Zone"
  type        = number
  default     = 1
}

variable "private_subnets_per_az" {
  description = "The number of private subnets to deploy per Availability Zone"
  type        = number
  default     = 1
}

variable "default_tenancy" {
  description = "The default tenancy of Instances within the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_support" {
  description = "Whether or not to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether or not to enable DNS hostname support in the VPC"
  type        = bool
  default     = true
}