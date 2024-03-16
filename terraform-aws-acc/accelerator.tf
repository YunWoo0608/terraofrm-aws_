resource "aws_globalaccelerator_accelerator" "this" {
  name = format("%s%s-%s", var.prefix, var.env, var.purpose)

  ip_address_type = var.ip_address_type
  enabled         = true

  dynamic "attributes" {
    for_each = local.flow_logs_enabled ? toset([true]) : toset([])

    content {
      flow_logs_enabled   = true
      flow_logs_s3_bucket = var.flow_logs_s3_bucket
      flow_logs_s3_prefix = var.flow_logs_s3_prefix
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}

resource "aws_globalaccelerator_listener" "this" {
  for_each = local.listeners

  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = try(each.value.client_affinity, null)
  protocol        = try(each.value.protocol, "TCP")

  dynamic "port_range" {
    for_each = try(each.value.port_ranges, [{
      from_port = 80
      to_port   = 80
    }])

    content {
      from_port = try(port_range.value.from_port, null)
      to_port   = try(port_range.value.to_port, null)
    }
  }
}

