###
# Terraform production AWS example
##

# Do not hardcode credentials here
# Use environment variables or AWS CLI profile
provider "aws" {
  version = "~> 2.36"
  region  = "us-east-1"
}

module "tads" {
  source = "../../modules/aws_tads"

  environment = "production"

  swarm_vpc_cidr = "172.21.0.0/16"
  swarm_vpc_subnets = [
    "172.21.0.0/20",  # AZ a
    "172.21.16.0/20", # AZ b
    "172.21.32.0/20"  # AZ c
  ]
  swarm_nb_manager_nodes  = 3
  swarm_nb_worker_nodes   = 1
  aws_nodes_instance_type = "t2.micro" # free tier

  # @see other variables in modules/aws_tads/variables.tf
}
