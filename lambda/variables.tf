variable "env" {
  description = "The environment for the AWS instance (e.g., dev, staging, prod)"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for the Lambda functions"
  type        = string
}
