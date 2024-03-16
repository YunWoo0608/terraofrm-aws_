resource "aws_docdb_subnet_group" "this" {
  name = lower(format("%s%s-%s-sub", var.prefix, var.env, var.purpose))

  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.subnet_ids
  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-sub", var.prefix, var.env, var.purpose)
  })
}

resource "aws_docdb_cluster_parameter_group" "pg" {
  name = lower(format("%s%s-%s-pg", var.prefix, var.env, var.purpose))

  description = "DB cluster parameter group"
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = { for k, v in var.cluster_parameters : k => v }
    content {
      apply_method = lookup(parameter.value, "apply_method", "immediate")
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-pg", var.prefix, var.env, var.purpose)
  })
}

resource "aws_docdb_cluster_instance" "this" {
  count = lookup(var.cluster_config, "enabled", true) ? lookup(var.cluster_config, "cluster_size", 2) : 0

  identifier = "${aws_docdb_cluster.this.id}-${count.index + 1}"

  cluster_identifier         = join("", aws_docdb_cluster.this.*.id)
  apply_immediately          = lookup(var.cluster_config, "apply_immediately", false)
  instance_class             = var.instance_class
  engine                     = lookup(var.cluster_config, "engine", "docdb")
  auto_minor_version_upgrade = lookup(var.cluster_config, "auto_minor_version_upgrade", false)

  promotion_tier = count.index + 1

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier = lower(format("%s%s-%s", var.prefix, var.env, var.purpose))
  engine             = lookup(var.cluster_config, "engine", "docdb")
  engine_version     = lookup(var.cluster_config, "engine_version", "4.0.0")
  port               = lookup(var.cluster_config, "port", 27017)

  master_username = lookup(var.cluster_config, "master_username", null)
  master_password = lookup(var.cluster_config, "master_password", null)

  backup_retention_period      = lookup(var.cluster_config, "backup_retention_period", null)
  preferred_maintenance_window = lookup(var.cluster_config, "preferred_maintenance_window", null)

  preferred_backup_window = lookup(var.cluster_config, "preferred_backup_window", null)

  deletion_protection = lookup(var.cluster_config, "deletion_protection", true)
  apply_immediately   = lookup(var.cluster_config, "apply_immediately", false)
  storage_encrypted   = lookup(var.cluster_config, "storage_encrypted", false)
  kms_key_id          = lookup(var.cluster_config, "kms_key_id", null)

  snapshot_identifier       = lookup(var.cluster_config, "snapshot_identifier", null)
  skip_final_snapshot       = lookup(var.cluster_config, "skip_final_snapshot", true)
  final_snapshot_identifier = lower(format("%s%s-%s", var.prefix, var.env, var.purpose))

  vpc_security_group_ids = distinct(concat(
    [aws_security_group.this.id],
    lookup(var.cluster_config, "allowed_security_groups", []),
  ))
  db_subnet_group_name            = join("", aws_docdb_subnet_group.this.*.name)
  db_cluster_parameter_group_name = join("", aws_docdb_cluster_parameter_group.pg.*.name)
  enabled_cloudwatch_logs_exports = lookup(var.cluster_config, "enabled_cloudwatch_logs_exports", null)

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}


resource "aws_security_group" "this" {
  name   = format("%s%s-%s-sg", var.prefix, var.env, var.purpose)
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = lookup(var.cluster_config, "port", 27017)
    to_port     = lookup(var.cluster_config, "port", 27017)
    description = "allow docdb port from self"
  }

  dynamic "ingress" {
    for_each = lookup(var.cluster_config, "allowed_cidrs", null) != null ? [1] : []

    content {
      protocol    = "tcp"
      cidr_blocks = lookup(var.cluster_config, "allowed_cidrs", null)
      from_port   = lookup(var.cluster_config, "port", 27017)
      to_port     = lookup(var.cluster_config, "port", 27017)
      description = "allow docdb port from cidr"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}
