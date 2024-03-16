# API Gateway
resource "aws_apigatewayv2_api" "this" {
  count = var.create_agw ? 1 : 0

  name        = format("%s%s-%s", var.prefix, var.env, var.purpose)
  description = var.description

  protocol_type = lookup(var.agw_config, "protocol_type", "HTTP")
  version       = lookup(var.agw_config, "api_version", "1")
  body          = lookup(var.agw_config, "body", null)

  route_selection_expression   = lookup(var.agw_config, "route_selection_expression", null)
  api_key_selection_expression = lookup(var.agw_config, "api_key_selection_expression", null)
  disable_execute_api_endpoint = lookup(var.agw_config, "disable_execute_api_endpoint", null)

  dynamic "cors_configuration" {
    for_each = var.agw_config["protocol_type"] == "HTTP" && length(keys(var.cors_configuration)) > 0 ? [var.cors_configuration] : []

    content {
      allow_credentials = try(cors_configuration.value.allow_credentials, null)
      allow_headers     = try(cors_configuration.value.allow_headers, null)
      allow_methods     = try(cors_configuration.value.allow_methods, null)
      allow_origins     = try(cors_configuration.value.allow_origins, null)
      expose_headers    = try(cors_configuration.value.expose_headers, null)
      max_age           = try(cors_configuration.value.max_age, null)
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}

# Domain Name
resource "aws_apigatewayv2_domain_name" "this" {
  count = var.required_domain_name ? 1 : 0

  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn                        = lookup(var.domain_name_config, "domain_name_certificate_arn", null)
    ownership_verification_certificate_arn = lookup(var.domain_name_config, "domain_name_ownership_verification_certificate_arn", null)
    endpoint_type                          = lookup(var.domain_name_config, "endpoint_type", "REGIONAL")
    security_policy                        = lookup(var.domain_name_config, "security_policy", "TLS_1_2")
  }

  tags = merge(local.default_tags, {
    Name = var.domain_name
  })
}

resource "aws_apigatewayv2_stage" "default" {
  count = var.create_agw && var.required_default_stage ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  name        = "deploy"
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = var.stage_access_log_settings != null ? [true] : []

    content {
      destination_arn = lookup(var.stage_access_log_settings, "stage_access_log_destination_arn", null)
      format          = lookup(var.stage_access_log_settings, "stage_access_log_format", null)
    }
  }

  dynamic "default_route_settings" {
    for_each = length(keys(var.default_route_settings)) == 0 ? [] : [var.default_route_settings]

    content {
      data_trace_enabled       = try(default_route_settings.value.data_trace_enabled, false)
      detailed_metrics_enabled = try(default_route_settings.value.detailed_metrics_enabled, false)
      logging_level            = try(default_route_settings.value.logging_level, null)
      throttling_burst_limit   = try(default_route_settings.value.throttling_burst_limit, null)
      throttling_rate_limit    = try(default_route_settings.value.throttling_rate_limit, null)
    }
  }


  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-stage", var.prefix, var.env, var.purpose)
  })

  # Bug in terraform-aws-provider with perpetual diff
  #lifecycle {
  #  ignore_changes = [deployment_id]
  #}
}

# Default API mapping
resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.create_agw && var.required_domain_name && var.required_default_stage && var.requried_default_stage_api_mapping ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  domain_name = aws_apigatewayv2_domain_name.this[0].id
  stage       = aws_apigatewayv2_stage.default[0].id
}

# Routes and integrations
resource "aws_apigatewayv2_route" "this" {
  for_each = var.create_agw && var.required_routes_and_integrations ? var.integrations : {}

  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = each.key

  api_key_required                    = try(each.value.api_key_required, null)
  authorization_scopes                = try(split(",", each.value.authorization_scopes), null)
  authorization_type                  = try(each.value.authorization_type, "NONE")
  authorizer_id                       = try(each.value.authorizer_id, null)
  model_selection_expression          = try(each.value.model_selection_expression, null)
  operation_name                      = try(each.value.operation_name, null)
  route_response_selection_expression = try(each.value.route_response_selection_expression, null)
  target                              = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"

  # Have been added to the docs. But is WEBSOCKET only(not yet supported)
  # request_models  = try(each.value.request_models, null)
}

resource "aws_apigatewayv2_integration" "this" {
  for_each = var.create_agw && var.required_routes_and_integrations ? var.integrations : {}

  api_id      = aws_apigatewayv2_api.this[0].id
  description = try(each.value.description, null)

  integration_type    = try(each.value.integration_type, "AWS_PROXY")
  integration_subtype = try(each.value.integration_subtype, null)
  integration_method  = try(each.value.integration_method, try(each.value.integration_subtype, null) == null ? "POST" : null)
  integration_uri     = lookup(each.value, "integration_uri", null)

  connection_type = try(each.value.connection_type, "INTERNET")
  connection_id   = try(aws_apigatewayv2_vpc_link.this[each.value["vpc_link"]].id, try(each.value.connection_id, null))


  payload_format_version    = try(each.value.payload_format_version, null)
  timeout_milliseconds      = try(each.value.timeout_milliseconds, null)
  passthrough_behavior      = try(each.value.passthrough_behavior, null)
  content_handling_strategy = try(each.value.content_handling_strategy, null)
  credentials_arn           = lookup(each.value, "credentials_arn", null)
  request_parameters        = try(jsondecode(each.value["request_parameters"]), each.value["request_parameters"], null)

  dynamic "tls_config" {
    for_each = flatten([try(jsondecode(each.value["tls_config"]), each.value["tls_config"], [])])

    content {
      server_name_to_verify = tls_config.value["server_name_to_verify"]
    }
  }

  dynamic "response_parameters" {
    for_each = flatten([try(jsondecode(each.value["response_parameters"]), each.value["response_parameters"], [])])

    content {
      status_code = response_parameters.value["status_code"]
      mappings    = response_parameters.value["mappings"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# VPC Link (Private API)
resource "aws_apigatewayv2_vpc_link" "this" {
  for_each = var.create_agw && var.required_vpc_link ? var.vpc_links : {}

  name               = try(each.value.name, each.key)
  security_group_ids = each.value["security_group_ids"]
  subnet_ids         = each.value["subnet_ids"]

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-vpc-link-http", var.prefix, var.env, var.purpose)
  })
}
