#---------ec/main.tf

data "aws_ami" "server_ami" {
 # most_recent = true
  owners = ["310995868053"]

 # filter {
 #   name = "owner-alias"
  #  values = ["amazon"]
 # }

  filter {
    name = "name"
    values = ["kc2-master"]
  }
}

resource "aws_key_pair" "terraform_auth" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

#resource "aws_instance" "web" {
#  ami = "ami-0e55e373"
#  instance_type = "t1.micro"
#  tags {
#    Name = "eralabs"
#  }
#}

data "template_file" "user-init" {
  count = 2
  template = "${file("${path.module}/userdata.tpl")}"
  vars {
    firewall_subnets = "${element(var.subnet_ips, count.index)}"
  }
}

resource "aws_instance" "terraform_server" {
  count = "${var.instance_count}"
  ami = "${data.aws_ami.server_ami.id}"
  instance_type = "${var.instance_type}"
  tags {
    name = "terraform-server-${count.index + 1}"
  }
  key_name = "${aws_key_pair.terraform_auth.id}"
  security_groups = ["${var.security_group}"]
  subnet_id = "${element(var.subnets, count.index)}"
  user_data = "${data.template_file.user-init.*.rendered[count.index]}"
}