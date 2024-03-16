terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

provider "random" {}

resource "random_string" "random" {
  length  = 4
  special = false
}

resource "aws_key_pair" "this" {
  key_name   = format("asg-module-%s-test-key", random_string.random.result)
  public_key = ""
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211129"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "asg" {
  source = "../"

  prefix = "test"

  # tag
  env     = local.env
  team    = local.team
  purpose = local.purpose

  use_spinnaker = false
  launch_template = {
    key_name      = "test"
    image_id      = data.aws_ami.ubuntu.id
    instance_type = "c5.large"
    network_interfaces = [
      {
        delete_on_termination = false
        description           = "eth0"
        device_index          = 0
        security_groups = [
          aws_security_group.asg.id,
        ]
      }
    ]
    block_device_mappings = {
      root = {
        volume_size = 50
      }
    }
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = "2"
    }
    user_data = base64encode(data.template_file.user_data.rendered)
  }

  # AutoScailing Group 
  autoscaling_group = {
    subnet_ids = [aws_subnet.subnet1.cidr_block, aws_subnet.subnet2.cidr_block]

    health_check_grace_period = 1
    force_delete              = false
    termination_policies      = []
    suspended_processes       = []
    placement_group           = ""
    health_check_type         = "EC2"
    min_size                  = 0
    max_size                  = 0
    desired_capacity          = 0
    wait_for_capacity_timeout = 0
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")
}

output "asg_arn" {
  value = module.asg.autoscaling_group_arn
}

output "asg_id" {
  value = module.asg.autoscaling_group_id
}

output "asg_sg_id" {
  value = aws_security_group.asg.id
}
