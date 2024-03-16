resource "random_pet" "ws" {
  length = 2
}

resource "aws_cloudwatch_log_group" "ws" {
  name = random_pet.ws.id
}

resource "aws_api_gateway_account" "ws" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
module "api_gateway_ws" {
  source = "../"

  prefix  = local.prefix
  env     = local.env
  purpose = format("%s-ws", local.purpose)
  team    = local.team

  description = "API GateWay WebSocket"

  # flag create / or not
  # api gateway
  create_agw = true
  # domain_name
  required_domain_name = true
  # default_stage
  required_default_stage = true
  # api mapping ( required domain_name / default_stage )
  requried_default_stage_api_mapping = true
  required_routes_and_integrations   = true

  # agw config
  agw_config = {
    protocol_type              = "WEBSOCKET"
    api_version                = "test-1"
    route_selection_expression = "$request.body.protocol"
  }

  # domain config
  domain_name = format("%s%s-%s-ws.%s", local.prefix, local.env, local.purpose, local.root_domain)
  domain_name_config = {
    domain_name_certificate_arn = ""
    endpoint_type               = "REGIONAL"
    security_policy             = "TLS_1_2"
  }

  # stage config
  ## access_log
  stage_access_log_settings = {
    stage_access_log_destination_arn = aws_cloudwatch_log_group.ws.arn
    stage_access_log_format = jsonencode({
      context = {
        domainName              = "$context.domainName"
        integrationErrorMessage = "$context.integrationErrorMessage"
        protocol                = "$context.protocol"
        requestId               = "$context.requestId"
        requestTime             = "$context.requestTime"
        responseLength          = "$context.responseLength"
        routeKey                = "$context.routeKey"
        stage                   = "$context.stage"
        status                  = "$context.status"
        error = {
          message       = "$context.error.message"
          messageString = "$context.error.messageString"
          responseType  = "$context.error.responseType"
        }
        identity = {
          sourceIP = "$context.identity.sourceIp"
        }
        integration = {
          error             = "$context.integration.error"
          integrationStatus = "$context.integration.integrationStatus"
        }
      }
    })
  }

  ## default_route_settings
  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

  # integration
  integrations = {
    "info" = {
      operation_name         = "ConnectRoute"
      integration_uri        = local.target_url_info
      integration_type       = "HTTP_PROXY"
      integration_method     = "GET"
      route_key              = 131072
      throttling_burst_limit = 50
      throttling_rate_limit  = 100

    }
  }
}
