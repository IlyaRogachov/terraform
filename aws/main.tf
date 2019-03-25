#-------ROOT/main.tf

provider "aws" {
#  access_key = "${var.aws_key}"
#  secret_key = "${var.aws_id}"
   shared_credentials_file = "~/.aws/credentials"
   region     = "${var.aws_region}"
   profile    = "kops-london"
}

module "s3" {
   source = "./s3"
   project_name = "${var.project_name}"
}

module "networking" {
   source = "./networking"
   vpc_cidr = "${var.vpc_cidr}"
   public_cidrs = "${var.public_cidr}"
   allowed_ip = "${var.allowed_ip}"
}

module "ecinstances" {
   source = "./ec"
   instance_count = "${var.instance_count}"
   key_name = "${var.key_name}"
   public_key_path = "${var.public_key_path}"
   instance_type = "${var.server_instance_type}"
   subnets = "${module.networking.public_subnets}"
   security_group = "${module.networking.public_security_group}"
   subnet_ips = "${module.networking.subnets_ips}"
}