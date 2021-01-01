terraform {
  required_version = ">= 0.13"
}
resource "aws_dynamodb_table" "dynamodb_table" {
  name              = var.app_name
  read_capacity     = 1
  write_capacity    = 1
  hash_key          = "dadjoke_id"
  stream_enabled    = false

  attribute {
    name = "dadjoke_id"
    type = "S"
  }

  attribute {
    name = "dadjoke"
    type = "S"
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 1
  event_source_arn  = aws_dynamodb_table.dynamodb_table.arn
  enabled           = true
  function_name     = var.app_name
  starting_position = "TRIM_HORIZON"
}
