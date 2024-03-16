resource "random_string" "random" {
  length  = 4
  special = false
}

module "vpc" {
  source = "../"

  prefix  = format("test-%s", random_string.random.result)
  env     = local.prefix
  team    = local.team
  purpose = local.purpose

  cidr_block          = "10.111.0.0/16"
  azs                 = ["ap-northeast-2a", "ap-northeast-2c"]
  single_nat_gateway  = false
  enable_nat_private  = true
  enable_nat_database = false

  subnet_cidrs = {
    public   = ["10.111.0.0/24", "10.111.1.0/24"]
    private  = ["10.111.2.0/24", "10.111.3.0/24"]
    database = ["10.111.4.0/24", "10.111.5.0/24"]
  }
}
