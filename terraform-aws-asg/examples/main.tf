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

  # tag
  env     = "test"
  team    = "devops"
  purpose = "test"

  prefix = "test"

  launch_template = {
    key_name      = aws_key_pair.this.key_name
    image_id      = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    network_interfaces = [
      {
        delete_on_termination = false
        description           = "eth0"
        device_index          = 0
        security_groups       = [aws_security_group.this.id]
      },
    ]
    block_device_mappings = {
      root = {
        volume_size = 100
      }
    }
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = "2"
    }
  }

  # AutoScailing Group 
  autoscaling_group = {
    subnet_ids                = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
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

output "launch_template_name" {
  value = module.asg.launch_template_name
}

output "launch_template_id" {
  value = module.asg.launch_template_id
}

output "launch_template_version" {
  value = module.asg.launch_template_version
}

output "autoscaling_group_id" {
  value = module.asg.autoscaling_group_id
}

output "autoscaling_group_arn" {
  value = module.asg.autoscaling_group_arn
}
