terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "random-dadjoke-service-state-bucket"
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
  app_version = var.app_version
}

module "lambda" {
  source = "./modules/lambda"
  app_name = var.app_name
  app_version = var.app_version
  depends_on = [ module.s3 ]
}

module "apigateway" {
  source = "./modules/apigateway"
  app_name = var.app_name
  aws_account_id = var.aws_account_id
  aws_region = var.aws_region
  lambda_function_arn = module.lambda.lambda_arn
  lambda_function_name = module.lambda.lambda_name

  depends_on = [ module.lambda ]
}
