resource "aws_dynamodb_table" "ttc-transit" {
  name         = "ttc-transit-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "line_number"
    type = "S"
  }

  attribute {
    name = "parent_station_id"
    type = "S"
  }

  attribute {
    name = "mode"
    type = "S"
  }

  global_secondary_index {
    name            = "line_number-parent_station_id-index"
    hash_key        = "line_number"
    range_key       = "parent_station_id"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "mode-index"
    hash_key        = "mode"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "parent_station_id-index"
    hash_key        = "parent_station_id"
    projection_type = "ALL"
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_dynamodb_table" "ttc-subway" {
  name         = "ttc-subway-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "mode"
    type = "S"
  }

  global_secondary_index {
    name            = "mode-index"
    hash_key        = "mode"
    projection_type = "ALL"
  }
  global_secondary_index {
    name            = "name-index"
    hash_key        = "name"
    projection_type = "ALL"
  }


  tags = {
    Environment = var.env
  }
}

resource "null_resource" "seed_stations" {
  depends_on = [aws_dynamodb_table.ttc-transit, aws_dynamodb_table.ttc-subway]

  triggers = {
    table_arn = join(",", [
      aws_dynamodb_table.ttc-transit.arn,
      aws_dynamodb_table.ttc-subway.arn
    ])
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/../functions/station_seed/main.py --table ${aws_dynamodb_table.ttc-transit.name} ${aws_dynamodb_table.ttc-subway.name}  --profile default; echo 'Done Updating Records'"
  }
}
