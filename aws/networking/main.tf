#------------------networking/main.tf
data "aws_availability_zones" "available_names" {}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    Name = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "terraform_internet_gateway" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  tags {
    Name = "terraform_gateway"
  }
}

resource "aws_route_table" "terraform_public_route" {
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terraform_internet_gateway.id}"
  }
}

resource "aws_default_route_table" "terraform_private_route" {
  default_route_table_id = "${aws_vpc.terraform_vpc.default_route_table_id}"

  tags {
    Name = "terraform-private"
  }
}

resource "aws_subnet" "terraform_public_subnet" {
  count = 2
  cidr_block = "${var.public_cidrs[count.index]}"
  vpc_id = "${aws_vpc.terraform_vpc.id}"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available_names.names[count.index]}"

  tags {
    Name = "terraform-public-${count.index + 1}"
  }
}

resource "aws_route_table_association" "terraform_public_associations" {
  count = "${aws_subnet.terraform_public_subnet.count}"
  route_table_id = "${aws_route_table.terraform_public_route.id}"
  subnet_id = "${aws_subnet.terraform_public_subnet.*.id[count.index]}"
}

resource "aws_security_group" "terraform_public_sg" {
  name = "terraform-public-sg"
  description = "Used for the public instances"
  vpc_id = "${aws_vpc.terraform_vpc.id}"

  #SSH
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${var.allowed_ip}"]
  }

  #HTTP
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["${var.allowed_ip}"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}