provider "aws" {

  region = "ap-northeast-2"
}

resource "random_string" "random" {
  length  = 10
  special = false
}

module "db" {
  source = "../"

  # tag
  env     = local.env
  team    = local.team
  purpose = local.purpose
  prefix  = local.prefix
  vpc_id  = aws_vpc.this.id

  identifier = format("%s%s-%s", local.prefix, local.env, local.purpose)

  engine               = "mysql"
  engine_version       = "5.7.33"
  family               = "mysql5.7" # DB parameter group
  major_engine_version = "5.0"      # DB option group
  instance_class       = "db.r5.large"

  storage_type          = "io1"
  allocated_storage     = 300
  max_allocated_storage = 1000
  iops                  = 3000

  apply_immediately = true

  db_name  = "secure"
  username = "treeroot"
  password = "Wemade!34"
  port     = 3306

  multi_az               = true
  subnet_ids             = local.database_subnets
  db_subnet_group_name   = format("%s%s-%s-subnetgroup", local.prefix, local.env, local.purpose)
  vpc_security_group_ids = [aws_security_group.this.id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general", "audit", "error", "slowquery"]

  backup_retention_period = 7
  skip_final_snapshot     = false
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  parameter_group_name                  = format("%s%s-%s-pg", local.prefix, local.env, local.purpose)

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
}
