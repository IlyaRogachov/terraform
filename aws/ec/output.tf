#-----------ec/output.tf
#Output the IP Address of the Container
output "Server_id" {
  value = "${join(",",aws_instance.terraform_server.*.id ) }"
}

output "Server_IP" {
  value = "${join(",", aws_instance.terraform_server.*.public_ip)}"
}