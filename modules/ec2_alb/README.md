# ec2_alb
Terraform ec2_alb module

This module allows you to create an application loadbalancer

By default the Linux instance created will be:
- An ALB for HTTP traffic
- A target group
- A listener on port 80


The following variables are required when calling the module:

Variable | Description | Value
-------- | ----------- | -----
"vpc_id" | VPC to place the target group | string
"elb_subnets" | Subnets for the elastic loadbalancer | list(string)
"elb_securitygroups" | Security groups for the elastic loadbalancer | list(string)


The following variables are not required when calling the module:

Variable | Description | Value | Default
-------- | ----------- | ----- | -------
"region" | The region we are building into | string | us-east-1
"environment" | Build environment | string | Development
"layer" | Terraform layer | string | 300compute
"tg_name" | Name of the Target Group | string | My-ELB-TG
"tg_port" | Port to be used for the target group | number | 80
"tg_protocol" | Protocol to be used for the target group | string | HTTP
"elb_name" | Name of the elastic loadbalancer | string | My-ELB
"ip_type" | IP type to be used | string | ipv4
"elb_internal" | Whether it is an internal loadbalancer or not | bool | false
"elb_port" | Port to be used for the Loadbalancer | number | "80
"elb_protocol" | Protocol to be used for the Loadbalancer | string | HTTP