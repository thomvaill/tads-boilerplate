# Required variables
variable "environment" {
  description = "The environment name. Used to name resources"
}

variable "swarm_vpc_cidr" {
  description = "Your Swarm VPC CIDR"
}

variable "swarm_vpc_subnets" {
  description = "Your Swarm VPC subnets. Ideally one per AZ"
}

# Optional variables
variable "ssh_pubkey_name" {
  description = "Desired name of AWS SSH key pair"
  default     = "tads"
}

variable "ssh_pubkey_path" {
  description = "Local path to your SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_cidr_blocks" {
  description = "Allowed CIDR blocks to SSH nodes from"
  default     = ["0.0.0.0/0"] # you should definitely secure this
}

variable "aws_nodes_instance_type" {
  description = "The AWS instance type of your Swarm nodes"
  default     = "t2.micro" # free tier
}

variable "swarm_nb_manager_nodes" {
  description = "Number of Docker Swarm manager nodes to create"
  default     = 3
}

variable "swarm_nb_worker_nodes" {
  description = "Number of Docker Swarm worker nodes to create"
  default     = 0
}
