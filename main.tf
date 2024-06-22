provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}

module "vpc" {
  source = "./modules/vpc"
}

module "subnet" {
  source = "./modules/subnet"
  vpc_id = module.vpc.fis_vpc_id
}

module "security_group" {
  source     = "./modules/security_group"
  fis_vpc_id = module.vpc.fis_vpc_id
}

module "network_interface" {
  source           = "./modules/network_interface"
  subnet_id        = module.subnet.subnet_id
  web_server_sg_id = module.security_group.web_server_sg_id
}

module "ec2_instances" {
  source                    = "./modules/ec2_instances"
  aeis_network_interface_id = module.network_interface.aeis_network_interface_id
  aeis_network_interface_private_ips = module.network_interface.aeis_network_interface_private_ips
  depends_on = [ module.network_interface ]
}

module "ecr" {
  source = "./modules/ecr"
}

output "public_ip" {
  value = module.ec2_instances.public_aeis_ip
  description = "Public IP of the EC2 instance"
}

output "private_ip" {
  value = module.ec2_instances.private_aeis_ip
  description = "Private IP of the EC2 instance"
}

output "url_ecr_repository_aeis" {
  value = module.ecr.url_ecr_repository_aeis
  description = "URL of the ECR repository"
}

# Deber: que todo tenga un nombre
