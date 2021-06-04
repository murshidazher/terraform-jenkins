data "archive_file" "init" {
  type        = "zip"
  source_file = "unused-eips.py"
  output_path = "unused-eips.zip"
}


resource "aws_lambda_function" "unused_eips" {
  filename      = data.archive_file.init.output_path
  function_name = "unused-eips-demo"
  role          = aws_iam_role.unused_eips_role.arn
  handler       = "unused-eips.lambda_handler"

  source_code_hash = filebase64sha256(data.archive_file.init.output_path)

  runtime = "python3.8"
  environment {
    variables = {
      SOURCE_EMAIL = "sourceemail@gmail.com", # need to verified in ses
      DEST_EMAIL   = "destemail@gmail.com"
    }
  }
}

# Trigger
# Schedule Lambda Function for every minute its easy to test but in real world this time should be increase else its not efficient
resource "aws_cloudwatch_event_rule" "unused_eips" {
  name                = "unused_eips"
  description         = "find unused eips"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "unused_eips" {
  rule      = aws_cloudwatch_event_rule.unused_eips.name
  target_id = "SendUnusedEIPs"
  arn       = aws_lambda_function.unused_eips.arn
}

# Allow cloudwatch to invoke lambda function

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unused_eips.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.unused_eips.arn
}
