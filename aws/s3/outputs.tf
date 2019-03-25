#-----------s3/outputs.tf
output "s3_bucket_name" {
  value = "${aws_s3_bucket.aws_bucket_name.id}"
}