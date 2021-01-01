output "lambda_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_name" {
  value = aws_lambda_function.lambda_function.function_name
}