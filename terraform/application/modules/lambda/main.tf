terraform {
  required_version = ">= 0.13"
}

resource "aws_lambda_function" "lambda_application" {
  function_name = var.app_name

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "${var.app_name}-deployments"
  s3_key    = "${var.app_name}/v${var.app_version}/${var.app_name}.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "nodejs10.x"

  role = aws_iam_role.lambda_exec.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name               = "${var.app_name}-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy_attachment" "attach-cloudwatch-policy" {
  name       = "allow-cloudwatch-logs-access"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
