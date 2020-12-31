variable "app_name" {
  type    = string
}

variable "lambda_arn" {
  type = string
}

variable "environment" {
  type = string
}

variable api_gateway_for_lambda_id {
  type = string
}

variable "proxy_resource_id" {
  type = string
}

variable "proxy_root_resource_id" {
  type = string
}
