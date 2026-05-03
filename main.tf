terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
  profile = "default" // TODO CHANGE THIS TO DEDICATED AWS PROFILE NAME
}

module "dynamodb" {
  source = "./dynamodb"
  env = var.env
}


module "permissions" {
  source = "./permissions"
  env    = var.env
}

module "lambda" {
  source          = "./lambda"
  env             = var.env
  lambda_role_arn = module.permissions.lambda_role_arn
}

module "cloudwatch" {
  source = "./cloudwatch"
  env = var.env
}
