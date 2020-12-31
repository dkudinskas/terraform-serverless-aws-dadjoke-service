output "lambda_arn" {
  value = aws_lambda_function.lambda_application.arn
//  value = aws_api_gateway_deployment.api_gateway_for_lambda.invoke_url
}