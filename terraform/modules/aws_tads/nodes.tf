# A security group for Swarm nodes
resource "aws_security_group" "swarm_node" {
  name   = "tads-${var.environment}-swarm-node"
  vpc_id = "${aws_vpc.swarm.id}"

  # Docker Swarm ports from this security group only
  ingress {
    description = "Docker container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "Docker container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
  }
  ingress {
    description = "Docker overlay network"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }

  # SSH for Ansible
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_cidr_blocks}"
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# A security group for Swarm manager nodes only
resource "aws_security_group" "swarm_manager_node" {
  name   = "tads-${var.environment}-swarm-manager-node"
  vpc_id = "${aws_vpc.swarm.id}"

  # HTTP access from ELB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.swarm_elb.id}"]
  }

  # HTTPS access from ELB
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.swarm_elb.id}"]
  }

  # Docker Swarm manager only
  ingress {
    description     = "Docker Swarm management between managers"
    from_port       = 2377
    to_port         = 2377
    protocol        = "tcp"
    security_groups = ["${aws_security_group.swarm_node.id}"]
  }
}

# Key Pair for SSH
resource "aws_key_pair" "local" {
  key_name   = "${var.ssh_pubkey_name}-${var.environment}"
  public_key = "${file(var.ssh_pubkey_path)}"
}

## MANAGER NODES
# Spread placement group for Swarm manager nodes
resource "aws_placement_group" "swarm_manager_nodes" {
  name     = "tads-${var.environment}-swarm-manager-nodes"
  strategy = "spread"
}

# Launch Configuration for Swarm manager nodes
resource "aws_launch_configuration" "swarm_manager_node" {
  associate_public_ip_address = true
  image_id                    = "${data.aws_ami.latest-ubuntu.id}"
  instance_type               = "${var.aws_nodes_instance_type}"
  name_prefix                 = "tads-${var.environment}-swarm-manager-node"
  security_groups             = ["${aws_security_group.swarm_node.id}", "${aws_security_group.swarm_manager_node.id}"]
  key_name                    = "${aws_key_pair.local.id}"
  user_data                   = "${local.nodes_user_data}"

  lifecycle {
    create_before_destroy = true
  }
}

# Swarm manager nodes auto-scaling group
resource "aws_autoscaling_group" "swarm_manager_nodes" {
  desired_capacity     = "${var.swarm_nb_manager_nodes}"
  max_size             = "${var.swarm_nb_manager_nodes}"
  min_size             = "${var.swarm_nb_manager_nodes}"
  launch_configuration = "${aws_launch_configuration.swarm_manager_node.id}"
  name                 = "tads-${var.environment}-swarm-manager-nodes"
  vpc_zone_identifier  = "${aws_subnet.swarm_nodes.*.id}"
  placement_group      = "${aws_placement_group.swarm_manager_nodes.id}"
  load_balancers       = ["${aws_elb.swarm.id}"]

  tag {
    key                 = "Name"
    value               = "tads-${var.environment}-swarm-manager-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "tads-environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "tads-node-type"
    value               = "manager" # we use this tag to output instances IPs
    propagate_at_launch = true
  }
}

## WORKER NODES
# Spread placement group for Swarm worker nodes
resource "aws_placement_group" "swarm_worker_nodes" {
  name     = "tads-${var.environment}-swarm-worker-nodes"
  strategy = "spread"
}

# Launch Configuration for Swarm worker nodes
resource "aws_launch_configuration" "swarm_worker_node" {
  associate_public_ip_address = true
  image_id                    = "${data.aws_ami.latest-ubuntu.id}"
  instance_type               = "${var.aws_nodes_instance_type}"
  name_prefix                 = "tads-${var.environment}-swarm-worker-node"
  security_groups             = ["${aws_security_group.swarm_node.id}"]
  key_name                    = "${aws_key_pair.local.id}"
  user_data                   = "${local.nodes_user_data}"

  lifecycle {
    create_before_destroy = true
  }
}

# Swarm worker nodes auto-scaling group
resource "aws_autoscaling_group" "swarm_worker_nodes" {
  desired_capacity     = "${var.swarm_nb_worker_nodes}"
  max_size             = "${var.swarm_nb_worker_nodes}"
  min_size             = "${var.swarm_nb_worker_nodes}"
  launch_configuration = "${aws_launch_configuration.swarm_worker_node.id}"
  name                 = "tads-${var.environment}-swarm-worker-nodes"
  vpc_zone_identifier  = "${aws_subnet.swarm_nodes.*.id}"
  placement_group      = "${aws_placement_group.swarm_worker_nodes.id}"

  tag {
    key                 = "Name"
    value               = "tads-${var.environment}-swarm-worker-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "tads-environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "tads-node-type"
    value               = "worker" # we use this tag to output instances IPs
    propagate_at_launch = true
  }
}

# Bootstrap script for instances
locals {
  nodes_user_data = <<EOF
#!/bin/bash
set -e
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y python-pip
	EOF
}
