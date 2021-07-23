/**
 * # 100security - outputs.tf
 */

output "sg_ecs" {
  value       = aws_security_group.sg_ecs.id
  description = "The ID of the ECS Group"
}