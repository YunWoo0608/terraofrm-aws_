resource "aws_security_group" "sg" {
  name   = format("%s%s-%s-agw-sg", local.prefix, local.env, local.purpose)
  vpc_id = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    description = "allow http"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    description = "allow https"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s%s-%s-agw-sg", local.prefix, local.env, local.purpose)
  }
}
