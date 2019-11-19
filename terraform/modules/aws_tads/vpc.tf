# Create a VPC to launch our instances into
resource "aws_vpc" "swarm" {
  cidr_block = "${var.swarm_vpc_cidr}"
  tags = {
    Name = "tads-${var.environment}-swarm"
  }
}

# Create an Internet Gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "swarm" {
  vpc_id = "${aws_vpc.swarm.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.swarm.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.swarm.id}"
}

# Create subnets to launch our instances into
# These subnets are public so we can SSH into the instances with Ansible
resource "aws_subnet" "swarm_nodes" {
  count = "${length(var.swarm_vpc_subnets)}"

  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "${var.swarm_vpc_subnets[count.index]}"
  vpc_id                  = "${aws_vpc.swarm.id}"
  map_public_ip_on_launch = true
}
