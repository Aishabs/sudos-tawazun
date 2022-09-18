resource "aws_s3_bucket" "sudos-duihua-s3bucket" {
  bucket = "sudos-tawazun1-s3bucket"  #change name S3
  force_destroy = true

  tags = {
    Name = "sudos-duihua-s3bucket"
  }
}
