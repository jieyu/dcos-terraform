provider "aws" {
  # Change your default region here
  region = "us-east-1"
}

module "dcos" {
  source  = "../../modules/aws/dcos"
  version = "~> 0.1"

  cluster_name        = "dcos-terraform-test"
  ssh_public_key_file = "./ssh-key.pub"
  admin_ips           = ["0.0.0.0/0"]

  num_masters        = "1"
  num_private_agents = "1"
  num_public_agents  = "0"

  dcos_version = "1.12.1"

  dcos_instance_os    = "centos_7.5"
  bootstrap_instance_type = "t2.medium"
  masters_instance_type  = "t2.medium"
  private_agents_instance_type = "t2.medium"
  public_agents_instance_type = "t2.medium"

  providers = {
    aws = "aws"
  }

  # dcos_variant              = "ee"
  # dcos_license_key_contents = "${file("./license.txt")}"
  dcos_variant = "open"

  dcos_install_mode = "${var.dcos_install_mode}"
}

variable "dcos_install_mode" {
  description = "specifies which type of command to execute. Options: install or upgrade"
  default     = "install"
}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}
