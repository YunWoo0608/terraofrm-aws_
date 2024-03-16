locals {
  default_tags = {
    env        = var.env
    team       = var.team
    purpose    = var.purpose
    managed_by = "terraform"
  }

  flow_logs_enabled = var.flow_logs_enabled

  listeners = { for index, listener in var.listeners : format("listener-%v", index) => listener }

  endpoint_configurations = try(length(var.config.endpoint_configuration), 0) > 0 ? var.config.endpoint_configuration : []
  lb_names                = compact([for configuration in local.endpoint_configurations : try(configuration.endpoint_lb_name, null)])
}

data "aws_lb" "lb" {
  for_each = toset(local.lb_names)

  name = each.value
}

