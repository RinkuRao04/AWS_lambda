# Create a Lambda Function URL with IAM role authorization
resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.lambda-visitorcounter.function_name
  authorization_type = "NONE"  # Set the authorization type to IAM role

  # Optionally, you can define a function URL policy here, but it's not necessary for IAM-based authorization.
}

# Output the Lambda Function URL
output "lambda_function_url" {
  value       = aws_lambda_function_url.lambda_url.function_url
  description = "The URL to invoke the Lambda function directly with IAM authorization"
}