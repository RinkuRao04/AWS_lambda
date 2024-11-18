# Create a zip package containing both function.py and paramiko.zip
data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "function.py"           # Path to function.py
  output_path = "function.zip"          # Output zip file containing function.py
#   depends_on  = [data.archive_file.paramiko_layer]
}

# # Create a zip package for paramiko.zip (This will be used as a Lambda Layer)
# data "archive_file" "paramiko_layer" {
#   type        = "zip"
#   source_file = "paramiko.zip"          # Path to your paramiko.zip file
#   output_path = "paramiko-layer.zip"    # Output zip file for Lambda layer
# }

# Lambda Layer resource for paramiko
# Lambda Layer resource for paramiko
resource "aws_lambda_layer_version" "paramiko_layer" {
  layer_name        = "paramiko-layer"         # Name of the Lambda Layer
  compatible_runtimes = ["python3.12"]          # Compatible runtime for the layer
  filename          = "paramiko.zip"           # Directly reference your existing paramiko.zip file
}


# Lambda function resource that points to the generated zip file
resource "aws_lambda_function" "html_lambda" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = "myLambdaFunction-new"
  role             = aws_iam_role.lambda_role.arn
  handler          = "function.lambda_handler"
  runtime          = "python3.12"
  
  # Uncomment and set source_code_hash if you want to trigger updates on code changes
  # source_code_hash = data.archive_file.lambda_package.output_base64sha256
  
  timeout          = 30
  
  # Associate Lambda layer for paramiko
  layers           = [aws_lambda_layer_version.paramiko_layer.arn]
}

# IAM role to allow Lambda execution
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
