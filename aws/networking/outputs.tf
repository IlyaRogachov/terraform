#-------------networking/outputs.tf
output "" {
  value = "${data.aws_availability_zones.available_names.names[1]}"
}

output "public_subnets" {
  value = "${aws_subnet.terraform_public_subnet.*.id}"
}

output "public_security_group" {
  value = "${aws_security_group.terraform_public_sg.id}"
}

output "subnets_ips" {
  value = "${aws_subnet.terraform_public_subnet.*.cidr_block}"
}