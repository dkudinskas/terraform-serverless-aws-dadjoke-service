terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "ncsc-state-bucket"
    key    = "global/s3/terraform.tfstate"
    region = "eu-west-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source = "./modules/s3"
  app_name = var.app_name
}

module "lambda" {
  source = "./modules/lambda"
  app_name = var.app_name
  app_version = var.app_version
  apigw_execution_arn = module.apigateway.apigw_execution_arn
}

module "apigateway" {
  source = "./modules/apigateway"
  app_name = var.app_name
  lambda_arn = module.lambda.lambda_arn
}

module "apigateway_lambda_integration" {
  source = "./modules/apigateway-lambda-integration"
  api_gateway_for_lambda_id = module.apigateway.apigw_id
  app_name = var.app_name
  environment = "test"
  lambda_arn = module.lambda.lambda_arn
  proxy_resource_id = module.apigateway.apigw_proxy_resource_id
  proxy_root_resource_id = module.apigateway.apigw_proxy_root_resource_id
}
