locals {
  lambda_func_name    = var.lambda_function_name
  lambda_zip_location = var.lambda_output_file_name
}

data "archive_file" "init" {
  type        = "zip"
  source_file = var.lambda_source_file_name
  output_path = local.lambda_zip_location
}

resource "aws_lambda_function" "test_lambda" {
  filename      = local.lambda_zip_location
  function_name = local.lambda_func_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler_name


  # need for redeployment and for cache busting
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "python3.7"

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}
