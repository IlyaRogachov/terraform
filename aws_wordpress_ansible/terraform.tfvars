aws_profile = "testprofile"
aws_region = "eu-west-2"
vpc_cidr = "10.132.0.0/16"
cidrs = {
  public1 = "10.132.1.0/24"
  public2 = "10.132.2.0/24"
  private1 = "10.132.3.0/24"
  private2 =  "10.132.4.0/24"
  rds1 = "10.132.5.0/24"
  rds2 = "10.132.6.0/24"
  rds3 = "10.132.7.0/24"
}
#ip from 2ip.ru
accessip = "127.0.0.1/32"
domain_name = "rogachov"
db_instance_class = "db.t2.micro"
dbname = "rogachovdb"
dbuser = "rogachovuser"
dbpassword = "rogachovdb"
elb_healthy_threshold = "2"
elb_unhealthy_threashold = "2"
elb_timeout = "3"
elb_interval = "30"

dev_instance_type = "t2.micro"
dev_ami = "ami-b73b63a0"
public_key_path = "/root/.ssh/testkey.pub"
key_name = "testkey"

asg_max = "2"
asg_min = "1"
asg_grace = "300"
asg_hct = "EC2"
asg_cap = "2"
lc_instance_type = "t2.micro"

delegation_set = "N1HD42OPWFOUVY"