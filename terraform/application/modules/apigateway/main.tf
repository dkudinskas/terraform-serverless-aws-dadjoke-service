terraform {
  required_version = ">= 0.13"
}

resource "aws_api_gateway_rest_api" "apigw" {
  name        = "${var.app_name}-api-gateway"
  description = "API gateway to invoke ${var.app_name} lambda"
}

resource "aws_api_gateway_resource" "apigw_resource" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
  path_part   = "dadjoke"
}

resource "aws_api_gateway_method" "apigw_method" {
   rest_api_id   = aws_api_gateway_rest_api.apigw.id
   resource_id   = aws_api_gateway_resource.apigw_resource.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "apigw_integration" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_method.apigw_method.resource_id
  http_method = aws_api_gateway_method.apigw_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn
}

resource "aws_api_gateway_deployment" "apigw_deployment" {
  depends_on = [
    aws_api_gateway_integration.apigw_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.apigw.id
  stage_name  = "api"
}


resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.apigw.id}/*/${aws_api_gateway_method.apigw_method.http_method}${aws_api_gateway_resource.apigw_resource.path}"
}
