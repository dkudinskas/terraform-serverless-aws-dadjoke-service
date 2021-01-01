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

resource "aws_lambda_function" "lambda_function" {
  function_name = var.app_name

  s3_bucket = "${var.app_name}-deployments"
  s3_key    = "v${var.app_version}/${var.app_name}.zip"

  handler = "main.handler"
  runtime = "nodejs10.x"

  role = aws_iam_role.lambda_iam_role.arn
}
