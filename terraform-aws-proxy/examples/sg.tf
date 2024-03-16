resource "aws_security_group" "asg" {
  name   = format("%s%s-%s-asg-sg", local.prefix, local.env, local.purpose)
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 3834
    to_port     = 3834
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet1.cidr_block, aws_subnet.subnet2.cidr_block]
  }
  egress {
    from_port   = 3834
    to_port     = 3834
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s%s-%s-asg-sg", local.prefix, local.env, local.purpose)
  }
}
