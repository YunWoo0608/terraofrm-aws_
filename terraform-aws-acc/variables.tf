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

variable "listeners" {
  type = list(object({
    client_affinity = string
    port_ranges = list(object({
      from_port = number
      to_port   = number
    }))
    protocol = string
  }))
  default = []
}

variable "flow_logs_enabled" {
  description = "Enable or disable flow logs for the Global Accelerator."
  type        = bool
  default     = false
}

variable "flow_logs_s3_bucket" {
  description = "The name of the S3 Bucket for the Accelerator Flow Logs. Required if `var.flow_logs_enabled` is set to `true`."
  type        = string
  default     = null
}

variable "flow_logs_s3_prefix" {
  description = "The Object Prefix within the S3 Bucket for the Accelerator Flow Logs. Required if `var.flow_logs_enabled` is set to `true`."
  type        = string
  default     = null
}

variable "ip_address_type" {
  description = "The address type to use for the Global Accelerator. At this moment, [only IPV4 is supported](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/globalaccelerator_accelerator#ip_address_type)."
  type        = string
  default     = "IPV4"
  validation {
    condition     = var.ip_address_type == "IPV4"
    error_message = "Only IPV4 is supported."
  }
}

variable "listener_arn" {
  type        = string
  description = "The ARN of the Global Accelerator Listener which this Endpoint Group will be associated with."
}

variable "config" {
  type        = any
  description = "Endpint-Group CONFIG"
}
