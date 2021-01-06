terraform {
  required_version = ">= 0.13"

  backend "s3" {
    # Replace this with your bucket name! I cannot use variables here :/
    bucket = "dadjoke-service-state-bucket"
    key    = "global/s3/database.tfstate"
    # Replace this with your region! I cannot use variables here :/
    region = "eu-west-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name              = var.aws_ddb_table
  billing_mode      = "PAY_PER_REQUEST"
  hash_key          = "dadjoke_id"
  stream_enabled    = false
  global_secondary_index {
    name = "dadjoke-index"
    projection_type = "ALL"
    hash_key = "dadjoke"
  }

  attribute {
    name = "dadjoke_id"
    type = "S"
  }

  attribute {
    name = "dadjoke"
    type = "S"
  }
}

//resource "aws_lambda_event_source_mapping" "event_source_mapping" {
//  batch_size        = 1
//  event_source_arn  = aws_dynamodb_table.dynamodb_table.arn
//  enabled           = true
//  function_name     = var.app_name
//  starting_position = "TRIM_HORIZON"
//}
