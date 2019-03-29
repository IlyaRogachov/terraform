provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#------ IAM -------
#S3 Access
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access_role.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_accesss_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
     "Effect": "Allow",
     "Action": "s3:*",
     "Resource": "*"
   }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
         "Action": "sts:AssumeRole",
         "Principal": {
             "Service": "ec2.amazonaws.com"
         },
           "Effect": "Allow",
           "Sid": ""
        }
       ]
}
EOF
}

#-------- VPC ----------

resource "aws_vpc" "terra_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "terra_vpc"
  }
}

resource "aws_internet_gateway" "terra_internet_gateway" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  tags {
    Name = "terra_intgateway"
  }
}

# Route tables
resource "aws_route_table" "terra_public_rt" {
  vpc_id = "${aws_vpc.terra_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_internet_gateway.id}"
  }

  tags {
    Name = "terra_public"
  }
}

resource "aws_default_route_table" "terra_private_rt" {
  default_route_table_id = "${aws_vpc.terra_vpc.default_route_table_id}"

  tags {
    Name = "terra_private"
  }
}

#------ Subnets -----

resource "aws_subnet" "terra_public1_subnet" {
  cidr_block              = "${var.cidrs["public1"]}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "terra_public1"
  }
}

resource "aws_subnet" "terra_public2_subnet" {
  cidr_block              = "${var.cidrs["public2"]}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "terra_public2"
  }
}

resource "aws_subnet" "terra_private1_subnet" {
  cidr_block              = "${var.cidrs["private1"]}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "terra_private1"
  }
}

resource "aws_subnet" "terra_private2_subnet" {
  cidr_block              = "${var.cidrs["private2"]}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "terra_private2"
  }
}

resource "aws_subnet" "terra_rds1_subnet" {
  cidr_block              = "${var.cidrs["rds1"]}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "terra_rds1"
  }
}

resource "aws_subnet" "terra_rds2_subnet" {
  cidr_block              = "${var.cidrs["rds2"]}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "terra_rds2"
  }
}

resource "aws_subnet" "terra_rds3_subnet" {
  cidr_block              = "${var.cidrs["rds3"]}"
  vpc_id                  = "${aws_vpc.terra_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "terra_rds3"
  }
}

#------- Association Subnets with Routes
#Rds made cidr to one group
resource "aws_db_subnet_group" "terra_rds_subnetgroup" {
  subnet_ids = ["${aws_subnet.terra_rds1_subnet.id}",
    "${aws_subnet.terra_rds2_subnet.id}",
    "${aws_subnet.terra_rds3_subnet.id}",
  ]

  tags {
    Name = "terra_rds_sng"
  }
}

#Subnet Associations

resource "aws_route_table_association" "terra_public1_assoc" {
  route_table_id = "${aws_route_table.terra_public_rt.id}"
  subnet_id      = "${aws_subnet.terra_public1_subnet.id}"
}

resource "aws_route_table_association" "terra_public2_assoc" {
  route_table_id = "${aws_route_table.terra_public_rt.id}"
  subnet_id      = "${aws_subnet.terra_public2_subnet.id}"
}

resource "aws_route_table_association" "terra_private1_assoc" {
  route_table_id = "${aws_default_route_table.terra_private_rt.id}"
  subnet_id      = "${aws_subnet.terra_private1_subnet.id}"
}

resource "aws_route_table_association" "terra_private2_assoc" {
  route_table_id = "${aws_default_route_table.terra_private_rt.id}"
  subnet_id      = "${aws_subnet.terra_private2_subnet.id}"
}
