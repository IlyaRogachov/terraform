variable "aws_region" {}
variable "aws_profile" {}
data "aws_availability_zones" "available" {}

#------- vpc
variable "vpc_cidr" {}

#------- subnets
variable "cidrs" {
  type = "map"
}

variable "accessip" {}
variable "domain_name" {}
variable "db_instance_class" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}

variable "elb_healthy_threshold" {}
variable "elb_interval" {}
variable "elb_timeout" {}
variable "elb_unhealthy_threashold" {}

variable "public_key_path" {}
variable "key_name" {}
variable "dev_ami" {}
variable "dev_instance_type" {}

variable "lc_instance_type" {}

variable "asg_max" {}
variable "asg_min" {}
variable "asg_grace" {}
variable "asg_hct" {}
variable "asg_cap" {}

variable "delegation_set" {}
