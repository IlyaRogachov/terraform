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

#Swcurity group

resource "aws_security_group" "terra_dev_sg" {
  name        = "terra_dev_sg"
  description = "For access to dev instance"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  #SSH
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["${var.accessip}"]
  }

  #HTTP
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["${var.accessip}"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Public security group

resource "aws_security_group" "terra_public_sg" {
  name        = "terra_public_sg"
  description = "Public group for elastic lb"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  #HTTP

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Private SG

resource "aws_security_group" "terra_private_sg" {
  name        = "terra_private_sg"
  description = "Private security group from cidr for private instances"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#RDS sg
resource "aws_security_group" "terra_rds_sg" {
  name        = "terra_rds_sg"
  description = "Used for database instances"
  vpc_id      = "${aws_vpc.terra_vpc.id}"

  ingress {
    from_port = 0
    protocol  = "tcp"
    to_port   = 0

    security_groups = ["${aws_security_group.terra_dev_sg.id}",
      "${aws_security_group.terra_public_sg.id}",
      "${aws_security_group.terra_private_sg.id}",
    ]
  }
}

#VPC endpoint for S3

resource "aws_vpc_endpoint" "terra_private_s3_endpoint" {
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_id       = "${aws_vpc.terra_vpc.id}"

  route_table_ids = ["${aws_vpc.terra_vpc.main_route_table_id}",
    "${aws_route_table.terra_public_rt.id}",
  ]

  policy = <<POLICY
  {
    "Statement": [
          {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
          }
    ]
  }
POLICY
}

#----------------- S3 code bucket ------------------
resource "random_id" "terra_code_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket        = "${var.domain_name}-${random_id.terra_code_bucket.dec}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "Code bucket"
  }
}

#-------------- RDS ---------------
resource "aws_db_instance" "terra_db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.6.27"
  instance_class         = "${var.db_instance_class}"
  name                   = "${var.dbname}"
  username               = "${var.dbuser}"
  password               = "${var.dbpassword}"
  db_subnet_group_name   = "${aws_db_subnet_group.terra_rds_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.terra_rds_sg.id}"]
  skip_final_snapshot    = true
}

#------ ELB elastic load balancer -------
resource "aws_elb" "terra_elb" {
  name = "${var.domain_name}-elb"

  subnets = ["${aws_subnet.terra_public1_subnet.id}",
    "${aws_subnet.terra_public2_subnet.id}",
  ]

  security_groups = ["${aws_security_group.terra_public_sg.id}"]

  "listener" {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = "${var.elb_healthy_threshold}"
    interval            = "${var.elb_interval}"
    target              = "TCP:80"
    timeout             = "${var.elb_timeout}"
    unhealthy_threshold = "${var.elb_unhealthy_threashold}"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "terra_${var.domain_name}-elb"
  }
}

#-------- DEV SERVER FOR ANSIBLE FOR EXAMPLE -------

#key pare
resource "aws_key_pair" "terra_auth" {
  public_key = "${var.public_key_path}"
  key_name   = "${var.key_name}"
}

#dev server
resource "aws_instance" "terra_dev" {
  ami           = "${var.dev_ami}"
  instance_type = "${var.dev_instance_type}"

  tags {
    Name = "terra_dev"
  }

  key_name               = "${aws_key_pair.terra_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.terra_dev_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id              = "${aws_subnet.terra_public1_subnet.id}"

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts
[dev]
${aws_instance.terra_dev.public_ip}
[dev:vars]
s3code=${aws_s3_bucket.code.bucket}
domain=${var.domain_name}
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 instance-state-status-ok --instance-ids ${aws_instance.terra_dev.id} --profile testprofile  && ansible-playbook -i aws_hosts wordpress.yaml"
  }
}

#------ Golden AMI for create instances in auto scaling group -----

# random ami id

resource "random_id" "golden_ami" {
  byte_length = 3
}

# AMI from

resource "aws_ami_from_instance" "terra_golden" {
  name               = "terra-${random_id.golden_ami.b64}"
  source_instance_id = "${aws_instance.terra_dev.id}"

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF>> userdata
#!/bin/bash
/usr/bin/aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/
/bin/touch /var/spool/cron/root
sudo /bin/echo '*/5 * * * * aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/' >> /var/spool/cron/root
EOF
EOT
  }
}

#------- launch configuration -------

resource "aws_launch_configuration" "terra_lc" {
  name_prefix          = "terra_lc-"
  image_id             = "${aws_ami_from_instance.terra_golden.id}"
  instance_type        = "${var.lc_instance_type}"
  security_groups      = ["${aws_security_group.terra_private_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access_profile.id}"
  key_name             = "${aws_key_pair.terra_auth.id}"
  user_data            = "${file("userdata")}"

  lifecycle {
    create_before_destroy = true
  }
}

#------- ASG (auto scaling group) ------

resource "aws_autoscaling_group" "terra_asg" {
  name                      = "asg-${aws_launch_configuration.terra_lc.id}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  health_check_grace_period = "${var.asg_grace}"
  health_check_type         = "${var.asg_hct}"
  desired_capacity          = "${var.asg_cap}"
  force_delete              = true
  load_balancers            = ["${aws_elb.terra_elb.id}"]

  vpc_zone_identifier = ["${aws_subnet.terra_private1_subnet.id}",
    "${aws_subnet.terra_private2_subnet.id}",
  ]

  launch_configuration = "${aws_launch_configuration.terra_lc.name}"

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "terra_asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------- ROUTE 53 ------------

#Primary Zone

resource "aws_route53_zone" "primary" {
  name              = "${var.domain_name}.com"
  delegation_set_id = "${var.delegation_set}"
}

resource "aws_route53_record" "www" {
  name    = "www.${var.domain_name}.com"
  type    = "A"
  zone_id = "${aws_route53_zone.primary.id}"

  alias {
    evaluate_target_health = false
    name                   = "${aws_elb.terra_elb.dns_name}"
    zone_id                = "${aws_elb.terra_elb.zone_id}"
  }
}

#DEV

resource "aws_route53_record" "dev" {
  name    = "dev.${var.domain_name}.com"
  type    = "A"
  ttl     = "300"
  zone_id = "${aws_route53_zone.primary.zone_id}"
  records = ["${aws_instance.terra_dev.public_ip}"]
}

#Private zone

resource "aws_route53_zone" "secondary" {
  name = "${var.domain_name}.com"

  vpc {
    vpc_id = "${aws_vpc.terra_vpc.id}"
  }
}

#DB

resource "aws_route53_record" "db" {
  name    = "db.${var.domain_name}.com"
  type    = "CNAME"
  ttl     = "300"
  zone_id = "${aws_route53_zone.secondary.zone_id}"
  records = ["${aws_db_instance.terra_db.address}"]
}
