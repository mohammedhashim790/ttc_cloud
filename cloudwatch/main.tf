# Note: AWS CloudWatch Logs minimum retention period is 1 day.
# It is not possible to natively configure a 6-hour retention in CloudWatch via Terraform directly using the standard options.
# Here we configure it for 1 day, and add a custom tag to reflect the 6-hour requirement if you have an external cleanup script.

resource "aws_cloudwatch_log_group" "harvester_log" {
  name              = "/aws/lambda/ttc-harvester"
  retention_in_days = 1

  tags = {
    Retention = "6 hours"
    Service   = "TTC Watch"
  }
}

resource "aws_cloudwatch_log_group" "ingestor_log" {
  name              = "/aws/lambda/ttc-ingestor"
  retention_in_days = 1

  tags = {
    Retention = "6 hours"
    Service   = "TTC Watch"
  }
}

resource "aws_cloudwatch_log_group" "normaliser_log" {
  name              = "/aws/lambda/ttc-normaliser"
  retention_in_days = 1

  tags = {
    Retention = "6 hours"
    Service   = "TTC Watch"
  }
}

resource "aws_cloudwatch_log_group" "accumulator_log" {
  name              = "/aws/lambda/ttc-accumulator"
  retention_in_days = 1

  tags = {
    Retention = "6 hours"
    Service   = "TTC Watch"
  }
}
