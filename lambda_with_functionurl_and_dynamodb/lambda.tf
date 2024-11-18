# Archive the Python file into a ZIP
data "archive_file" "zip-python" {
  type        = "zip"
  source_file = "function.py"  # Local file path
  output_path = "function.zip"  # Output ZIP file path
}

# Configure Lambda to use the local ZIP file
resource "aws_lambda_function" "lambda-visitorcounter" {
  function_name = "lambda-function-for-dynamodb"

  # Use the local ZIP file for the Lambda function
  filename         = data.archive_file.zip-python.output_path
  source_code_hash = data.archive_file.zip-python.output_base64sha256

  runtime = "python3.9"
  handler = "function.lambda_handler"
  environment {
    variables = {
      DYNAMODB_TABLE = "db-visit-count"  # The name of your DynamoDB table
    }
  }
  vpc_config {
    subnet_ids         = [aws_subnet.subnet_private.id]
    security_group_ids = [aws_default_security_group.default_security_group.id]
  }
  # Role that grants the function permission to access AWS services and resources
  role = aws_iam_role.lambda_exec.arn

}


# IAM Role that allows Lambda to access resources in your AWS account

