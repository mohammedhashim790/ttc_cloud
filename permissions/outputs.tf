output "lambda_role_arn" {
  description = "The ARN of the IAM role created for Lambda execution"
  value       = aws_iam_role.lambda_exec.arn
}
