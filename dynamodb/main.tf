
resource "aws_dynamodb_table" "test_table" {
  name           = "ttc-trains-${var.env}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = var.env
  }
}



