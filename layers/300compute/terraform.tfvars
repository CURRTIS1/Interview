/**
 * # 300compute - terraform.tfvars
 */

region      = "eu-west-1"
environment = "dev"
layer       = "300container"
tg_name     = "my-tg"
elb_name    = "my-elb"
target_type = "ip"
tg_port = 80