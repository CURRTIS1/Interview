# security_groups
Terraform security_groups module

This module allows you to create a Security groups within your VPC


By default the Security groups created will be:
- ALB to WEB Security Group
- Internet to ALB Security Group
- Web to RDS Security Group
- SSH, RDP and HTTP from 0.0.0.0/0 for testing


The following variables are required when calling the module:

Variable | Description | Value
-------- | ----------- | -----
"vpc_id" | ID of VPC | string


The following variables are not required when calling the module:

Variable | Description | Value | Default
-------- | ----------- | ----- | -------
"region" | The region we are building into | string | us-east-1
"environment" | Build environment | string | Development
"layer" | Terraform layer | string | 100Security