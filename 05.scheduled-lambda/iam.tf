resource "aws_iam_policy" "unused_eips" {
  name        = "unused_eips_for_lambda"
  path        = "/"
  description = "Policy for unused eips"

  policy = file("./iam/lambda-policy.json")
}

# IAM Role for lambda
resource "aws_iam_role" "unused_eips_role" {
  name = "unused_eips_role"

  assume_role_policy = file("./iam/lambda-assume-policy.json")
}

# Attach role and policy
resource "aws_iam_role_policy_attachment" "unused_eips_attach" {
  role       = aws_iam_role.unused_eips_role.name
  policy_arn = aws_iam_policy.unused_eips.arn
}
