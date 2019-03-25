aws_region = "eu-west-2"
project_name = "terraform-aws-test"
vpc_cidr = "10.123.0.0/16"
public_cidr = [
  "10.123.1.0/24",
  "10.123.2.0/24"
]
allowed_ip = "0.0.0.0/0"
key_name = "terraform_key"
public_key_path = "./keys/terraform_rsa.pub"
server_instance_type = "t2.micro"
instance_count = "2"