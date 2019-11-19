# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "swarm_elb" {
  name   = "tads-${var.environment}-swarm-elb"
  vpc_id = "${aws_vpc.swarm.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The ELB (Classic)
# Layer 4, no SSL termination, since it is handled by Traefik
resource "aws_elb" "swarm" {
  name = "tads-${var.environment}-swarm"

  subnets         = "${aws_subnet.swarm_nodes.*.id}"
  security_groups = ["${aws_security_group.swarm_elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }
}
