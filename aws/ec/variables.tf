#--------ec/variables.tf
variable "key_name" {
  default = "terraform_key"
}
variable "public_key_path" {}

variable "subnet_ips" {
  type = "list"
}
variable "instance_count" {}
variable "instance_type" {}
variable "security_group" {}
variable "subnets" {
  type = "list"
}