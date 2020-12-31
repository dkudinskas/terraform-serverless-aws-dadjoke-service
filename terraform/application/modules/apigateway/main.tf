terraform {
  required_version = ">= 0.13"
}


resource "aws_api_gateway_rest_api" "api_gateway_for_lambda" {
  name        = "${var.app_name}-api-gateway"
  description = "API gateway to invoke ${var.app_name} lambda"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_for_lambda.id
  resource_id   = aws_api_gateway_rest_api.api_gateway_for_lambda.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_for_lambda.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
//  uri                     = aws_lambda_function.lambda_application.invoke_arn
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_for_lambda.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_for_lambda.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_for_lambda.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_for_lambda.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}

//resource "aws_api_gateway_deployment" "api_gateway_deployment" {
//  depends_on = [
//    aws_api_gateway_integration.lambda,
//    aws_api_gateway_integration.lambda_root,
//  ]
//
//  rest_api_id = aws_api_gateway_rest_api.api_gateway_for_lambda.id
//  stage_name  = var.environment
//}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.app_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api_gateway_for_lambda.execution_arn}/*/*"
}
