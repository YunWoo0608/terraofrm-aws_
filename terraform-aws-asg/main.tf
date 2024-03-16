resource "aws_launch_template" "this" {
  count = var.use_spinnaker ? 0 : 1

  name = format("%s%s-%s", var.prefix, var.env, var.purpose)

  image_id               = lookup(var.launch_template, "image_id", null)
  instance_type          = lookup(var.launch_template, "instance_type", null)
  update_default_version = lookup(var.launch_template, "update_default_version", true)
  key_name               = lookup(var.launch_template, "key_name", true)
  user_data              = lookup(var.launch_template, "user_data", null)

  iam_instance_profile {
    name = lookup(var.launch_template, "iam_instance_profile", null)
  }

  dynamic "network_interfaces" {
    for_each = { for k, v in var.launch_template["network_interfaces"] : k => v }

    content {
      associate_carrier_ip_address = lookup(network_interfaces.value, "associate_carrier_ip_address", null)
      associate_public_ip_address  = lookup(network_interfaces.value, "associate_public_ip_address", false)
      delete_on_termination        = lookup(network_interfaces.value, "delete_on_termination", false)
      description                  = lookup(network_interfaces.value, "description", null)
      device_index                 = lookup(network_interfaces.value, "device_index", 0)
      ipv4_addresses               = lookup(network_interfaces.value, "ipv4_addresses", null) != null ? network_interfaces.value.ipv4_addresses : []
      ipv4_address_count           = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv6_addresses               = lookup(network_interfaces.value, "ipv6_addresses", null) != null ? network_interfaces.value.ipv6_addresses : []
      ipv6_address_count           = lookup(network_interfaces.value, "ipv6_address_count", null)
      network_interface_id         = lookup(network_interfaces.value, "network_interface_id", null)
      private_ip_address           = lookup(network_interfaces.value, "private_ip_address", null)
      security_groups              = lookup(network_interfaces.value, "security_groups", null) != null ? network_interfaces.value.security_groups : []
      subnet_id                    = lookup(network_interfaces.value, "subnet_id", null)
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.launch_template["block_device_mappings"] != null ? values(var.launch_template["block_device_mappings"]) : []

    content {
      device_name = lookup(block_device_mappings.value, "device_name", "/dev/xvda")

      ebs {
        delete_on_termination = lookup(block_device_mappings.value, "delete_on_termination", true)
        encrypted             = lookup(block_device_mappings.value, "encrypted", false)
        iops                  = lookup(block_device_mappings.value, "iops", null)
        kms_key_id            = lookup(block_device_mappings.value, "kms_key_id", null)
        snapshot_id           = lookup(block_device_mappings.value, "snapshot_id", null)
        volume_size           = lookup(block_device_mappings.value, "volume_size", "8")
        volume_type           = lookup(block_device_mappings.value, "volume_type", "gp3")
      }
    }
  }

  dynamic "metadata_options" {
    for_each = var.launch_template["metadata_options"] != null ? [var.launch_template["metadata_options"]] : []

    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "required")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", "2")
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag_specifications" {
    for_each = ["instance", "volume"]

    content {
      resource_type = tag_specifications.value

      tags = merge(local.default_tags, {
        Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
      })
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}

resource "aws_autoscaling_group" "this" {
  count = var.use_spinnaker ? 0 : 1

  name = format("%s%s-%s", var.prefix, var.env, var.purpose)

  vpc_zone_identifier = lookup(var.autoscaling_group, "subnet_ids", null)

  max_size         = lookup(var.autoscaling_group, "max_size", 1)
  min_size         = lookup(var.autoscaling_group, "min_size", 1)
  desired_capacity = lookup(var.autoscaling_group, "desired_capacity", 1)

  default_cooldown          = lookup(var.autoscaling_group, "default_cooldown", 60)
  health_check_grace_period = lookup(var.autoscaling_group, "health_check_grace_period", null)
  health_check_type         = lookup(var.autoscaling_group, "health_check_type", null)
  force_delete              = lookup(var.autoscaling_group, "force_delete", false)
  termination_policies      = lookup(var.autoscaling_group, "termination_policies", null)
  suspended_processes       = lookup(var.autoscaling_group, "suspended_processes", null)
  placement_group           = lookup(var.autoscaling_group, "placement_group", null)
  wait_for_capacity_timeout = lookup(var.autoscaling_group, "wait_for_capacity_timeout", null)
  service_linked_role_arn   = lookup(var.autoscaling_group, "service_linked_role_arn", null)

  launch_template {
    id      = aws_launch_template.this[0].id
    version = aws_launch_template.this[0].latest_version
  }
}
