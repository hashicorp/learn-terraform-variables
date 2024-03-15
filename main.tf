# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  cidr = var.vpc_cidr_block

  azs = data.aws_availability_zones.available.names
  # private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)


  # public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)

  enable_nat_gateway = true
  enable_vpn_gateway = var.enable_vpn_gateway

  # tags = {
  #   project     = "project-alpha",
  #   environment = "dev"
  # }

  tags = var.resource_tags
}

module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "4.17.0"

  # name        = "web-sg-project-alpha-dev"
  name        = "web-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  description = "Security group for web-servers with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks

  # tags = {
  #   project     = "project-alpha",
  #   environment = "dev"
  # }

  tags = var.resource_tags

}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "4.17.0"

  name        = "lb-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  # tags = {
  #   project     = "project-alpha",
  #   environment = "dev"
  # }

  tags = var.resource_tags

}

resource "random_string" "lb_id" {
  length  = 3
  special = false
}

module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "4.0.1"

  # Ensure load balancer name is unique
  # name = "lb-${random_string.lb_id.result}-project-alpha-dev"
  name = "lab-${random_string.lb_id.result}-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"

  internal = false

  security_groups = [module.lb_security_group.security_group_id]
  subnets         = module.vpc.public_subnets

  number_of_instances = length(module.ec2_instances.instance_ids)
  instances           = module.ec2_instances.instance_ids

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }

  # tags = {
  #   project     = "project-alpha",
  #   environment = "dev"
  # }

  tags = var.resource_tags

}

module "ec2_instances" {
  source = "./modules/aws-instance"

  depends_on = [module.vpc]

  instance_count = var.instance_count
  # instance_type      = "t2.micro"
  instance_type = var.ec2_instance_type

  subnet_ids         = module.vpc.private_subnets[*]
  security_group_ids = [module.app_security_group.security_group_id]

  # tags = {
  #   project     = "project-alpha",
  #   environment = "dev"
  # }

  tags = var.resource_tags

}
