#-----------ROOT/variables.tf
variable "project_name" {}
variable "aws_region" {}

#--------Networking variables

variable "vpc_cidr" {}
variable "public_cidr" {
  type = "list"
}
variable "allowed_ip" {}


#-----------------ec2 variables
variable "key_name" {}
variable "public_key_path" {}
variable "server_instance_type" {}
variable "instance_count" {
  default = "1"
}