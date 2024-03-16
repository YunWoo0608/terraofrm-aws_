output "launch_template_name" {
  description = "The name of the launch configuration."
  value       = var.use_spinnaker ? null : aws_launch_template.this[0].name
}

output "launch_template_id" {
  description = "The ID of the launch configuration."
  value       = var.use_spinnaker ? null : aws_launch_template.this[0].id
}

output "launch_template_version" {
  description = "The ID of the launch configuration."
  value       = var.use_spinnaker ? null : aws_launch_template.this[0].latest_version
}

output "autoscaling_group_name" {
  description = "The Name of the AutoScalingGroup"
  value       = var.use_spinnaker ? null : aws_autoscaling_group.this[0].name
}

output "autoscaling_group_id" {
  description = "The ID of the AutoScalingGroup"
  value       = var.use_spinnaker ? null : aws_autoscaling_group.this[0].id
}

output "autoscaling_group_arn" {
  description = "The ARN of the AutoScalingGroup"
  value       = var.use_spinnaker ? null : aws_autoscaling_group.this[0].arn
}
