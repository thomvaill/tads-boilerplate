output "elb_url" {
  value = "${module.tads.elb_url}"
}

output "manager_ips" {
  value = "${module.tads.manager_ips}"
}

output "worker_ips" {
  value = "${module.tads.worker_ips}"
}

output "ssh_user" {
  value = "${module.tads.ssh_user}"
}
