#-----------ROOT/outputs.tf



#----- s3 outputs

output "s3_bucket_name" {
  value = "${module.s3.s3_bucket_name}"
}


#------- networking outputs
output "Public Subnets" {
  value = "${join(" , ", module.networking.public_subnets)}"
}

output "Subnet Ips" {
  value = "${join(",", module.networking.subnets_ips)}"
}

output "Public Security Group" {
  value = "${module.networking.public_security_group}"
}

#------- ec2 outputs
output "Server ID" {
  value = "${module.ecinstances.Server_id}"
}

output "Public Instance Ips" {
  value = "${module.ecinstances.Server_IP}"
}


