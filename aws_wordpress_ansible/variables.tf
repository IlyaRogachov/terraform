variable "aws_region" {}
variable "aws_profile" {}
data "aws_availability_zones" "available" {}

#------- vpc
variable "vpc_cidr" {}

#------- subnets
variable "cidrs" {
  type = "map"
}
