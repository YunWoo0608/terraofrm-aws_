output "db_instance_id" {
  description = "The RDS instance ID"
  value       = try(aws_db_instance.this.id, "")
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = try(aws_db_instance.this.resource_id, "")
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = try(aws_db_instance.this.status, "")
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = try(aws_db_instance.this.endpoint, "")
}

output "db_sg_id" {
  description = "The RDS instance SG (Aware)"
  value       = try(aws_security_group.this.id, "")
}
output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = try(aws_db_instance.this.arn, "")
}

