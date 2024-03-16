provider "aws" {
  region = "ap-northeast-2"
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_cloudwatch_log_group" "http" {
  name = random_pet.this.id
}

module "api_gateway_http" {
  source = "../"

  prefix  = local.prefix
  env     = local.env
  purpose = local.purpose
  team    = local.team

  description = "API GateWay HTTP"

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
  required_vpc_link = true

  # agw config
  agw_config = {
    protocol_type = "HTTP"
    api_version   = "test-1"
  }

  cors_configuration = {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # domain config
  domain_name = format("%s%s-%s.%s", local.prefix, local.env, local.purpose, local.root_domain)
  domain_name_config = {
    domain_name_certificate_arn = ""
    endpoint_type               = "REGIONAL"
    security_policy             = "TLS_1_2"
  }

  # stage config
  ## access_log
  stage_access_log_settings = {
    stage_access_log_destination_arn = aws_cloudwatch_log_group.http.arn
    stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"
  }

  ## default_route_settings
  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }

  # integration
  integrations = {
    "POST /test/v1/auth/agreement" = {
      connection_type = "VPC_LINK"
      vpc_link = "vpc-link"
      integration_type       = "HTTP_PROXY"
      integration_uri        = local.target_url_info
      integration_method     = "GET"
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000

      request_parameters = jsonencode({
        "integration.request.path" = "/test/v1/auth/agreement"
      })
    }

  vpc_links = {
    vpc-link = {
      name               = format("%s%s-%s-vpc", local.prefix, local.env, local.purpose)
      security_group_ids = [aws_security_group.sg.id]
      subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnets
    }
  }
}



