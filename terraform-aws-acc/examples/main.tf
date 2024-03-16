module "global_accelerator" {
  source = "../"

  # tag
  env     = local.env
  team    = local.team
  purpose = local.purpose
  prefix  = local.prefix

  # global accelerator
  ip_address_type     = local.ip_address_type
  flow_logs_enabled   = local.flow_logs_enabled
  flow_logs_s3_prefix = local.s3_bucket_prefix
  flow_logs_s3_bucket = local.s3_bucket_id

  listeners = [
    {
      client_affinity = "NONE"
      protocol        = "TCP"
      port_ranges = [
        {
          from_port = 443
          to_port   = 443
        }
      ]
    }
  ]

  # endpoint group
  listener_arn = module.global_accelerator.listener_ids[0]

  config = {
    endpoint_region = "ap-northeast-2"
    endpoint_configuration = [
      {
        endpoint_lb_name = local.endpoint_lb_name
      }
    ]
  }
}
