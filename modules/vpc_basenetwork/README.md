# vpc_basenetwork
Terraform vpc_basenetwork

This module allows you to create a VPC whilst only specifying a small number of inputs.


By default the VPC will create:
- A VPC in us-east-1 in two availability zones
- A private and public subnet per az
- An Internet Gateway
- A NAT Gateway per az
- Private route tables to the Nat gateway per az
- Public route tables to the Internet gateway per az
- An EC2 IAM role for SSM Managed Instance Core


The following variables are required when calling the module:

Variable | Description | Value
-------- | ----------- | -----
"vpc_name" | Name of VPC | string
"vpc_cidr" | VPC main CIDR | string
"subnet_public_range" | VPC Public CIDR range | list(string)
"subnet_private_range" | VPC Private CIDR range | list(string)


The following variables are not required when calling the module:

Variable | Description | Value | Default
-------- | ----------- | ----- | -------
"region" | The region we are building into | string | us-east-1
"environment" | Build environment | string | Development
"layer" | Terraform layer | string | 000Base
"availability_zones" | List of custom availability zones | list(string) | []
"az_count" | The number of Availability Zones to deploy in the VPC | number | 2
"public_subnets_per_az" | The number of public subnets to deploy per Availability Zone | number | 1
"private_subnets_per_az" | The number of private subnets to deploy per Availability Zone | number | 1
"default_tenancy" | The default tenancy of Instances within the VPC | string | default
"enable_dns_support" | Whether or not to enable DNS support in the VPC | bool | true
"enable_dns_hostnames" | Whether or not to enable DNS hostname support in the VPC | bool | true