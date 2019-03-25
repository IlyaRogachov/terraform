#-----------s3/main.tf

resource "random_id" "aws_bucket_id" {
  byte_length = 2
}

resource "aws_s3_bucket" "aws_bucket_name" {

  bucket = "${var.project_name}-${random_id.aws_bucket_id.dec}"
  acl = "private"
  force_destroy = true

  tags {
    Name = "aws_bucket_name"
  }

}