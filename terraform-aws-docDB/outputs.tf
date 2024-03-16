output "docdb_cluster_id" {
  value       = aws_docdb_cluster.this.id
  description = "DocumentDB cluster identifier"
}

output "docdb_cluster_arn" {
  value       = aws_docdb_cluster.this.arn
  description = "DocumentDB cluster arn"
}

output "docdb_cluster_endpoint" {
  value       = aws_docdb_cluster.this.endpoint
  description = "DocumentDB cluster endpoint"
}

output "docdb_cluster_reader_endpoint" {
  value       = aws_docdb_cluster.this.reader_endpoint
  description = "DocumentDB cluster reader endpoint"
}

output "docdb_cluster_members" {
  value       = aws_docdb_cluster.this.cluster_members
  description = "DocumentDB cluster member lists"
}

output "docdb_subnet_group_id" {
  value       = aws_docdb_subnet_group.this.id
  description = "DocumentDB subnet group id"
}

output "docdb_subent_group_arn" {
  value       = aws_docdb_subnet_group.this.arn
  description = "DocumentDB subnet group arn"
}

output "docdb_parameter_group_id" {
  value       = aws_docdb_cluster_parameter_group.pg.id
  description = "DocumentDB parameter group id"
}

output "docdb_parameter_group_arn" {
  value       = aws_docdb_cluster_parameter_group.pg.arn
  description = "DocumentDB parameter group arn"
}

output "docdb_sg_id" {
  value       = aws_security_group.this.id
  description = "Security Group Id to allow traffic"
}
