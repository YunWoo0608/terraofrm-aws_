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
  description = "The instance name"
}

variable "description" {
  type        = string
  description = "Description"
}

variable "protocol_type" {
  type        = string
  description = "HTTP/WEBSOCKET"
  default     = "HTTP"
}

variable "cors_configuration" {
  type    = any
  default = {}
}

variable "agw_config" {
  type    = any
  default = null
}

variable "create_agw" {
  type    = bool
  default = false
}

variable "required_domain_name" {
  type    = bool
  default = false
}

variable "required_default_stage" {
  type    = bool
  default = false
}

variable "requried_default_stage_api_mapping" {
  type    = bool
  default = false
}

variable "required_routes_and_integrations" {
  type    = bool
  default = false
}

variable "default_route_settings" {
  type    = any
  default = {}
}

variable "domain_name_config" {
  type    = any
  default = {}
}

variable "domain_name" {
  type = string
}

variable "integrations" {
  type    = any
  default = {}
}

variable "stage_access_log_settings" {
  type    = any
  default = {}
}

variable "required_vpc_link" {
  type = string
}
variable "vpc_links" {
  type    = any
  default = {}
}
