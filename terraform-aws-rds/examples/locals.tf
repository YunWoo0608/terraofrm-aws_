locals {
  prefix           = "test"
  env              = "test"
  team             = "devops"
  purpose          = "mysql"
  vpc_id           = aws_vpc.this.id
  database_subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}
