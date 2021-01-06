terraform {
  required_version = ">= 0.13"
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "${var.app_name}-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy_attachment" "attach-cloudwatch-policy" {
  name       = "allow-cloudwatch-logs-access"
  roles      = [aws_iam_role.lambda_iam_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "dynamodb-read-policy" {
  name        = "dynamodb-ro-logs-policy"
  description = "Only allow only scan and query, and logs access"
  policy      = data.aws_iam_policy_document.dynamodb_ro_logs.json
}

resource "aws_iam_policy_attachment" "attach-dynamodb-policy" {
  name       = "allow-dynamodb-readonly-access"
  roles      = [aws_iam_role.lambda_iam_role.name]
  policy_arn = aws_iam_policy.dynamodb-read-policy.arn
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.app_name

  s3_bucket = "${var.app_name}-deployments"
  s3_key    = "v${var.app_version}/${var.app_name}.zip"

  handler = "main.handler"
  runtime = "nodejs10.x"

  environment {
    variables = {
      DATABASE_NAME = "dadjokes-table"
    }
  }

  role = aws_iam_role.lambda_iam_role.arn
}
