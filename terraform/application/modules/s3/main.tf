terraform {
  required_version = ">= 0.13"
}

locals {
  src-dir    = "../../lambda/${var.app_name}"
  build-file = "${local.src-dir}/${var.app_name}.zip"
}

resource "aws_s3_bucket" "terraform_deployment_bucket" {
  bucket = "${var.app_name}-deployments"
  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = false
  }

  force_destroy = true

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_object" "lambda_zip" {
  bucket = aws_s3_bucket.terraform_deployment_bucket.id
  key    = "v${var.app_version}/${var.app_name}.zip"
//  acl    = "private"
  source = "../../lambda/dadjoke-service/dadjoke-service.zip"
  etag = filebase64("../../lambda/dadjoke-service/dadjoke-service.zip")
}
