variable "env" {
  type        = string
  description = "Environment like prod, stg, dev, alpha"
}

variable "team" {
  type        = string
  description = "The team tag used to managed resources"
}

variable "purpose" {
  type        = string
  description = "The team tag used to managed resources"
}

variable "prefix" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "DocumentDB subnet ids"
}

variable "instance_class" {
  type        = string
  description = "DocumentDB instance type"
  default     = "db.r4.large"
}

variable "cluster_parameters" {
  type        = any
  description = "DocumentDB parameter groups information"
  default     = {}
}

variable "cluster_family" {
  type    = string
  default = "docdb4.0"
}

variable "cluster_config" {
  type        = any
  description = "DocumentDB Cluster Configuration Information"
}
