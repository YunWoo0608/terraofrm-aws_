provider "aws" {
  region = "ap-northeast-2"
}

provider "random" {}

resource "random_string" "random" {
  length           = 10
  special          = true
  override_special = "/!@£$"
}

module "docdb_cluster" {
  source = "../"

  # tag
  env     = "test"
  team    = "test"
  purpose = "test"
  prefix  = "test"

  vpc_id         = aws_vpc.this.id
  subnet_ids     = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  instance_class = "db.r5.large"

  cluster_parameters = [
    {
      apply_method = "immediate"
      name         = "audit_logs"
      value        = "disabled"
    },
    {
      apply_method = "immediate"
      name         = "change_stream_log_retention_duration"
      value        = 10800
    },
    {
      apply_method = "immediate"
      name         = "profiler"
      value        = "enabled"
    },
    {
      apply_method = "immediate"
      name         = "profiler_sampling_rate"
      value        = 1.0
    },
    {
      apply_method = "immediate"
      name         = "profiler_threshold_ms"
      value        = 100
    },
    {
      apply_method = "pending-reboot"
      name         = "tls"
      value        = "disabled"
    },
    {
      apply_method = "immediate"
      name         = "ttl_monitor"
      value        = "enabled"
    },
  ]
  cluster_family = "docdb4.0"

  # cluster info 
  cluster_config = {
    cluster_size                    = 2
    master_username                 = "test"
    master_password                 = format("%s", random_string.random.result)
    db_port                         = 27017
    deletion_protection             = false
    apply_immediately               = false
    auto_minor_version_upgrade      = false
    allowed_security_groups         = [aws_security_group.this.id]
    allowed_cidrs                   = ["10.0.10.0/24", "10.0.20.0/24"]
    snapshot_identifier             = ""
    retention_period                = 300
    preferred_backup_window         = "07:00-09:00"
    preferred_maintenance_window    = "Mon:22:00-Mon:23:00"
    engine                          = "docdb"
    engine_version                  = "4.0.0"
    storage_encrypted               = true
    kms_key_id                      = ""
    skip_final_snapshot             = false
    enabled_cloudwatch_logs_exports = ["audit", "profiler"]
    deletion_protection             = true
  }
}
