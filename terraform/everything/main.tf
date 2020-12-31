terraform {
//  backend "s3" {
//    # Replace this with your bucket name!
//    bucket = "ncsc-state-bucket"
//    key    = "global/s3/terraform.tfstate"
//    region = "eu-west-1"
//  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

}

provider "aws" {
  region = var.aws_region
}


resource "aws_lambda_function" "dadjoke_lambda" {
  function_name = var.app_name

  # the deployments go here
  s3_bucket = var.app_name
  s3_key    = "${var.app_name}/v1.0.0/${var.app_name}.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "nodejs10.x"

  role = aws_iam_role.dadjoke_lambda_execution_role.arn
}

 # IAM role which dictates what other AWS services the Lambda function
 # may access.
resource "aws_iam_role" "dadjoke_lambda_execution_role" {
   name = "dadjoke_lambda_execution_role"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_api_gateway_rest_api" "dadjoke_apigateway" {
  name        = "dadjoke_apigateway"
  description = "REST API apigateway to serve a random dad joke"
}

resource "aws_api_gateway_resource" "dadjoke_apigateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.dadjoke_apigateway.id
  parent_id   = aws_api_gateway_rest_api.dadjoke_apigateway.root_resource_id
  path_part   = "dadjoke"
}

resource "aws_api_gateway_method" "dadjoke_apigateway_get_method" {
   rest_api_id   = aws_api_gateway_rest_api.dadjoke_apigateway.id
   resource_id   = aws_api_gateway_resource.dadjoke_apigateway_resource.id
   http_method   = "GET"
   authorization = "NONE"
}



resource "aws_api_gateway_integration" "dadjoke_apigateway_lambda_integration" {
   rest_api_id = aws_api_gateway_rest_api.dadjoke_apigateway.id
   resource_id = aws_api_gateway_method.dadjoke_apigateway_get_method.resource_id
   http_method = aws_api_gateway_method.dadjoke_apigateway_get_method.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.dadjoke_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    aws_api_gateway_integration.dadjoke_apigateway_lambda_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.dadjoke_apigateway.id
  stage_name  = "test"
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dadjoke_lambda.function_name
  principal     = "apigateway.amazonaws.com"

//  source_arn = "${aws_api_gateway_rest_api.dadjoke_apigateway.execution_arn}/*/*"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.dadjoke_apigateway.id}/*/${aws_api_gateway_method.dadjoke_apigateway_get_method.http_method}${aws_api_gateway_resource.dadjoke_apigateway_resource.path}"
}
