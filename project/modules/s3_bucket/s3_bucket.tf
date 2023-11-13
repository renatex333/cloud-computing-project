resource "aws_s3_bucket" "main" {
  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "main" {
  bucket = aws_s3_bucket.main.id
  key    = "terraform-state"
  source = "terraform.tfstate"
  etag   = filemd5("terraform.tfstate")
}

