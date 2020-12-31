output "apigw_execution_arn" {
  value = aws_api_gateway_rest_api.api_gateway_for_lambda.execution_arn
}

output "apigw_id" {
  value = aws_api_gateway_rest_api.api_gateway_for_lambda.id
}

output "apigw_proxy_resource_id" {
  value = aws_api_gateway_method.proxy.resource_id
}

output "apigw_proxy_root_resource_id" {
  value = aws_api_gateway_method.proxy_root.resource_id
}