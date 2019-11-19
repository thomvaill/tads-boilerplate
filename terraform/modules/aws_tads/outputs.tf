# ELB URL
output "elb_url" {
  value = "${aws_elb.swarm.dns_name}"
}

# Manager nodes IPs
# ASG does not output instances IP, so we have to retreive them with Tags
data "aws_instances" "swarm_manager_nodes" {
  filter {
    name   = "tag:tads-environment"
    values = ["${var.environment}"]
  }
  filter {
    name   = "tag:tads-node-type"
    values = ["manager"]
  }

  instance_state_names = ["pending", "running"]

  depends_on = [
    # AutoScalingGroup must be created, so its instances are created
    aws_autoscaling_group.swarm_manager_nodes
  ]
}
output "manager_ips" {
  value = "${data.aws_instances.swarm_manager_nodes.public_ips}"
}

# Worker nodes IPs
# ASG does not output instances IP, so we have to retreive them with Tags
data "aws_instances" "swarm_worker_nodes" {
  count = "${var.swarm_nb_worker_nodes == 0 ? 0 : 1}" # workaround if there is 0 worker

  filter {
    name   = "tag:tads-environment"
    values = ["${var.environment}"]
  }
  filter {
    name   = "tag:tads-node-type"
    values = ["worker"]
  }

  instance_state_names = ["pending", "running"]

  depends_on = [
    # AutoScalingGroup must be created, so its instances are created
    aws_autoscaling_group.swarm_worker_nodes
  ]
}
output "worker_ips" {
  value = "${var.swarm_nb_worker_nodes == 0 ? [] : data.aws_instances.swarm_worker_nodes[0].public_ips}"
}

# SSH user
output "ssh_user" {
  value = "ubuntu"
}
