locals {
  prefix     = "test"
  env        = "test"
  team       = "devops"
  purpose    = "accelerator"
  managed_by = "terraform"

  # global accelerator
  ip_address_type   = "IPV4"
  flow_logs_enabled = false
  s3_bucket_prefix  = null
  s3_bucket_id      = null

  endpoint_lb_name = "lb-name"
}
