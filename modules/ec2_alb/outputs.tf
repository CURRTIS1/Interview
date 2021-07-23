/**
 * # ec2_alb - outputs.tf
 */

output "elb_target_group" {
  value       = aws_lb_target_group.elb_target_group.id
  description = "Id of the Target Group"
}

output "elb" {
  value       = aws_lb.myelb.id
  description = "Id of the ALB"
}

output "elb_dns" {
  value       = aws_lb.myelb.dns_name
  description = "DNS of the ALB"
}