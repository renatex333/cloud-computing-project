terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  region               = "us-west-2"
  availability_zone_01 = "us-west-2a"
  availability_zone_02 = "us-west-2b"
  availability_zone_03 = "us-west-2c"
  availability_zone_04 = "us-west-2d"
}

# Configure the AWS Provider
provider "aws" {
  region = local.region
}

# Create a VPC from the module
locals {
  vpc_name       = "project-vpc"
  vpc_cidr_block = "10.20.0.0/16"
}
module "vpc" {
  source         = "./modules/vpc"
  vpc_name       = local.vpc_name
  vpc_cidr_block = local.vpc_cidr_block
}

# Create an internet gateway from the module
module "internet_gateway" {
  source   = "./modules/internet_gateway"
  igw_name = "project-igw"
  vpc_id   = module.vpc.vpc_id
}

# Create 2 public subnets and 1 private subnet from the module
locals {
  subnet_infos = {
    public_subnet_01 = {
      name              = "project-public-subnet-01"
      availability_zone = local.availability_zone_01
      cidr_block        = "10.20.1.0/24"
      map_public_ip     = true
    },
    public_subnet_02 = {
      name              = "project-public-subnet-02"
      availability_zone = local.availability_zone_02
      cidr_block        = "10.20.2.0/24"
      map_public_ip     = true
    },
    private_subnet_01 = {
      name              = "project-private-subnet-01"
      availability_zone = local.availability_zone_03
      cidr_block        = "10.20.3.0/24"
      map_public_ip     = false
    },
    private_subnet_02 = {
      name              = "project-private-subnet-02"
      availability_zone = local.availability_zone_04
      cidr_block        = "10.20.4.0/24"
      map_public_ip     = false
    }
  }
}

module "subnets" {
  source       = "./modules/subnets"
  vpc_id       = module.vpc.vpc_id
  subnet_infos = local.subnet_infos
}

# Create a route table for public subnets from the module
module "route_table" {
  source           = "./modules/route_table"
  vpc_id           = module.vpc.vpc_id
  igw_id           = module.internet_gateway.igw_id
  route_table_name = "project-route-table"
  cidr_block       = "0.0.0.0/0"
}

# Create route table associations for public subnets from the module
module "route_table_association" {
  source         = "./modules/subnet_route_table_association"
  route_table_id = module.route_table.route_table_id
  subnet_ids     = module.subnets.public_subnet_ids
}

# Create a security group for instances from the module
locals {
  http_rule = {
    port        = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  application_rule = {
    port        = 8000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ssh_rule = {
    port        = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  mysql_rule = {
    port        = 3306
    protocol    = "TCP"
    cidr_blocks = tolist([for subnet_info in local.subnet_infos : subnet_info.cidr_block])

  }
}
module "instances_security_group" {
  source              = "./modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "project-instances-security-group"
  port_protocol_cidr  = [local.http_rule, local.application_rule, local.ssh_rule, local.mysql_rule]
}

# Create a security group for load balancers from the module
module "load_balancers_security_group" {
  source              = "./modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "project-load-balancers-security-group"
  port_protocol_cidr  = [local.http_rule, local.application_rule]

}

# Create a security group for databases from the module
module "databases_security_group" {
  source              = "./modules/security_group"
  vpc_id              = module.vpc.vpc_id
  security_group_name = "project-databases-security-group"
  port_protocol_cidr  = [local.mysql_rule]
}

# Create a launch template from the module
locals {
  # Django by Bitnami (Linux Debian 11 - x86-64) 
  ami_id = "ami-071722fc5c4657325"
}

module "launch_template" {
  source               = "./modules/launch_template"
  launch_template_name = "project-launch-template"
  security_group_ids   = [module.instances_security_group.security_group_id]
  availability_zone    = local.availability_zone_01
  image_id             = local.ami_id
}

# Create a load balancer target group from the module
module "alb_target_group" {
  source                = "./modules/alb_target_group"
  alb_target_group_name = "project-alb-target-group"
  vpc_id                = module.vpc.vpc_id
}

# Create a load balancer from the module
module "alb" {
  source             = "./modules/application_load_balancer"
  alb_name           = "project-alb"
  subnet_ids         = module.subnets.public_subnet_ids
  security_group_ids = [module.load_balancers_security_group.security_group_id]
}

# Create a load balancer listener from the module
module "alb_listener" {
  source               = "./modules/alb_listener"
  alb_listener_name    = "project-alb-listener"
  alb_arn              = module.alb.alb_arn
  alb_target_group_arn = module.alb_target_group.alb_target_group_arn
}

# Create a placement group from the module
module "placement_group" {
  source               = "./modules/placement_group"
  placement_group_name = "project-placement-group"
}

# Create an auto scaling group from the module
module "auto_scaling_group" {
  source                  = "./modules/auto_scaling_group"
  auto_scaling_group_name = "project-auto-scaling-group"
  launch_template_id      = module.launch_template.launch_template_id
  target_group_arns       = [module.alb_target_group.alb_target_group_arn]
  placement_group_id      = module.placement_group.placement_group_id
  public_subnet_ids       = module.subnets.public_subnet_ids
}

# Create a relational database subnet group from the module
module "relational_database_subnet_group" {
  source               = "./modules/subnet_group"
  db_subnet_group_name = "project-db-subnet-group"
  private_subnet_ids   = module.subnets.private_subnet_ids
}

# Create a relational database from the module
module "relational_database" {
  source                   = "./modules/relational_database"
  db_name                  = "projectdb"
  db_allocated_storage     = 10
  db_max_allocated_storage = 50
  db_engine                = "mysql"
  db_engine_version        = "8.0"
  db_subnet_group_name     = module.relational_database_subnet_group.db_subnet_group_name
  db_security_group_ids    = [module.databases_security_group.security_group_id]
}

output "db_endpoint" {
  value = module.relational_database.db_endpoint
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
