resource "aws_s3_bucket" "example_firelens_bucket" {
  bucket = local.firelens_bucket_name
  acl    = "private"

  tags = {
    Name = local.tag_name
  }
}
