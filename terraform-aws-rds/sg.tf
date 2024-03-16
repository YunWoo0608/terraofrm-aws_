resource "aws_security_group" "this" {
  name   = format("%s%s-%s-aware-sg", var.prefix, var.env, var.purpose)
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = var.port != null ? var.port : 3306
    to_port     = var.port != null ? var.port : 3306
    description = "allow mysql port from self"
  }

  dynamic "ingress" {
    for_each = var.allowed_cidrs != null ? [1] : []

    content {
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
      from_port   = var.port != null ? var.port : 3306
      to_port     = var.port != null ? var.port : 3306
      description = "allow mysql port from cidr"
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
