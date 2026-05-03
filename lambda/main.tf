
# --- Harvester ---
resource "null_resource" "pip_install_harvester" {
  triggers = {
    # Re-run if requirements.txt changes
    requirements = fileexists("${path.root}/functions/harvester/requirements.txt") ? filemd5("${path.root}/functions/harvester/requirements.txt") : "none"
  }

  provisioner "local-exec" {
    command = "if [ -f ${path.root}/functions/harvester/requirements.txt ]; then pip install -r ${path.root}/functions/harvester/requirements.txt -t ${path.root}/functions/harvester/package/; cp ${path.root}/functions/harvester/*.py ${path.root}/functions/harvester/package/; fi"
  }
}

data "archive_file" "harvester_zip" {
  depends_on  = [null_resource.pip_install_harvester]
  type        = "zip"
  source_dir  = fileexists("${path.root}/functions/harvester/requirements.txt") ? "${path.root}/functions/harvester/package" : "${path.root}/functions/harvester"
  output_path = "${path.root}/functions/output/harvester-${var.env}.zip"
}

resource "aws_lambda_function" "harvester" {
  filename         = data.archive_file.harvester_zip.output_path
  function_name    = "ttc-harvester-${var.env}"
  role             = var.lambda_role_arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.harvester_zip.output_base64sha256
}

# --- Ingestor ---
resource "null_resource" "pip_install_ingestor" {
  triggers = {
    requirements = fileexists("${path.root}/functions/ingestor/requirements.txt") ? filemd5("${path.root}/functions/ingestor/requirements.txt") : "none"
  }

  provisioner "local-exec" {
    command = "if [ -f ${path.root}/functions/ingestor/requirements.txt ]; then pip install -r ${path.root}/functions/ingestor/requirements.txt -t ${path.root}/functions/ingestor/package/; cp ${path.root}/functions/ingestor/*.py ${path.root}/functions/ingestor/package/; fi"
  }
}

data "archive_file" "ingestor_zip" {
  depends_on  = [null_resource.pip_install_ingestor]
  type        = "zip"
  source_dir  = fileexists("${path.root}/functions/ingestor/requirements.txt") ? "${path.root}/functions/ingestor/package" : "${path.root}/functions/ingestor"
  output_path = "${path.root}/functions/output/ingestor-${var.env}.zip"
}

resource "aws_lambda_function" "ingestor" {
  filename         = data.archive_file.ingestor_zip.output_path
  function_name    = "ttc-ingestor-${var.env}"
  role             = var.lambda_role_arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.ingestor_zip.output_base64sha256
}

# --- Normaliser ---
resource "null_resource" "pip_install_normaliser" {
  triggers = {
    requirements = fileexists("${path.root}/functions/normaliser/requirements.txt") ? filemd5("${path.root}/functions/normaliser/requirements.txt") : "none"
  }

  provisioner "local-exec" {
    command = "if [ -f ${path.root}/functions/normaliser/requirements.txt ]; then pip install -r ${path.root}/functions/normaliser/requirements.txt -t ${path.root}/functions/normaliser/package/; cp ${path.root}/functions/normaliser/*.py ${path.root}/functions/normaliser/package/; fi"
  }
}

data "archive_file" "normaliser_zip" {
  depends_on  = [null_resource.pip_install_normaliser]
  type        = "zip"
  source_dir  = fileexists("${path.root}/functions/normaliser/requirements.txt") ? "${path.root}/functions/normaliser/package" : "${path.root}/functions/normaliser"
  output_path = "${path.root}/functions/output/normaliser-${var.env}.zip"
}

resource "aws_lambda_function" "normaliser" {
  filename         = data.archive_file.normaliser_zip.output_path
  function_name    = "ttc-normaliser-${var.env}"
  role             = var.lambda_role_arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.normaliser_zip.output_base64sha256
}

# --- Accumulator ---
resource "null_resource" "pip_install_accumulator" {
  triggers = {
    requirements = fileexists("${path.root}/functions/accumulator/requirements.txt") ? filemd5("${path.root}/functions/accumulator/requirements.txt") : "none"
  }

  provisioner "local-exec" {
    command = "if [ -f ${path.root}/functions/accumulator/requirements.txt ]; then pip install -r ${path.root}/functions/accumulator/requirements.txt -t ${path.root}/functions/accumulator/package/; cp ${path.root}/functions/accumulator/*.py ${path.root}/functions/accumulator/package/; fi"
  }
}

data "archive_file" "accumulator_zip" {
  depends_on  = [null_resource.pip_install_accumulator]
  type        = "zip"
  source_dir  = fileexists("${path.root}/functions/accumulator/requirements.txt") ? "${path.root}/functions/accumulator/package" : "${path.root}/functions/accumulator"
  output_path = "${path.root}/functions/output/accumulator-${var.env}.zip"
}

resource "aws_lambda_function" "accumulator" {
  filename         = data.archive_file.accumulator_zip.output_path
  function_name    = "ttc-accumulator-${var.env}"
  role             = var.lambda_role_arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.accumulator_zip.output_base64sha256
}
