locals {
  default_tags = {
    env        = var.env
    team       = var.team
    purpose    = var.purpose
    managed_by = "terraform"
  }
  pg_name                   = format("%s%s-%s-pg", var.prefix, var.env, var.purpose)
  sub_name                  = format("%s%s-%s-subnetgroup", var.prefix, var.env, var.purpose)
  description               = format("%s%s-%s-pg", var.prefix, var.env, var.purpose)
  engine                    = var.engine
  engine_version            = var.engine_version
  final_snapshot_identifier = format("%s%s-%s-finalsnapshot", var.prefix, var.env, var.purpose)
}
