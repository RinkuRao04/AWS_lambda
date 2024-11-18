resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

# Attach a basic Lambda execution policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach DynamoDB full access policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_dynamoroles" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
#   version = "2012-10-17"
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "iam_role" {
#   assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
#   name               = "${var.project}-iam-role-lambda-trigger"
# }
# resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
#   role       = aws_iam_role.iam_role.name  # Use the ARN of the role, not the name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_policy" {
  role       = aws_iam_role.lambda_exec.name  # The IAM role for Lambda
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
