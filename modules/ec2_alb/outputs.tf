/**
 * # ec2_alb - outputs.tf
 */

output "elb_target_group" {
  value       = aws_lb_target_group.elb_target_group.id
  description = "Id of the Target Group"
}