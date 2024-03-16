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
  type        = string
  description = "The asg name"
}

variable "use_spinnaker" {
  type        = bool
  description = "Whether spinnaker is used or not"
  default     = false
}

variable "launch_template" {
  type        = any
  description = "LaunchTemplate configuration"
  default     = {}
}

variable "autoscaling_group" {
  type        = any
  description = "autoscaling group info"
  default     = {}
}
