/**
 * # 000base - terraform.tfvars
 */

region      = "eu-west-1"
environment = "dev"
layer       = "000base"

vpc_cidr = "172.16.0.0/16"

subnet_public_range = [
  "172.16.1.0/24",
  "172.16.2.0/24"
]

subnet_private_range = [
  "172.16.3.0/24",
  "172.16.4.0/24"
]

vpc_name = "VPC-Curtis-Interview"