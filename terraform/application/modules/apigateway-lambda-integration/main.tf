terraform {
  required_version = ">= 0.13"
}



resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = var.api_gateway_for_lambda_id
  resource_id = var.proxy_resource_id
  http_method = "ANY"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = var.api_gateway_for_lambda_id
  resource_id = var.proxy_root_resource_id
  http_method = "ANY"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}

resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = var.api_gateway_for_lambda_id
  stage_name  = var.environment
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.app_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_deployment.api_gateway_deployment.execution_arn}/*/*"
}
