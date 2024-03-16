resource "aws_db_subnet_group" "this" {
  name        = local.sub_name
  description = local.description
  subnet_ids  = var.subnet_ids

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}
