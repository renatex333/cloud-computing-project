terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC from the module
module "vpc" {
  source   = "./modules/vpc"
  vpc_name = "project-vpc"
}

# Create 2 public subnets and 1 private subnet from the module
locals {
  subnet_infos = {
    public_subnet_01 = {
      name              = "project-public-subnet-01"
      availability_zone = "us-east-1a"
      cidr_block        = "10.20.1.0/24"
      map_public_ip     = true
    },
    public_subnet_02 = {
      name              = "project-public-subnet-02"
      availability_zone = "us-east-1b"
      cidr_block        = "10.20.2.0/24"
      map_public_ip     = true
    },
    private_subnet_01 = {
      name              = "project-private-subnet-01"
      availability_zone = "us-east-1a"
      cidr_block        = "10.20.3.0/24"
      map_public_ip     = false
    }
  }
}

module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
  subnet_infos = local.subnet_infos
}

# Create a security group for instances from the module
module "instances_security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  security_group_name = "project-instances-security-group"
  security_group_ingress_cidr_blocks = ["0.0.0.0/0"]
}

# Create a security group for load balancers from the module
module "load_balancers_security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  security_group_name = "project-load-balancers-security-group"
  security_group_ingress_cidr_blocks = ["0.0.0.0/0"]
}

# Create a security group for databases from the module
module "databases_security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  security_group_name = "project-databases-security-group"
  security_group_ingress_cidr_blocks = tolist([for subnet_info in local.subnet_infos : subnet_info.cidr_block])
}
