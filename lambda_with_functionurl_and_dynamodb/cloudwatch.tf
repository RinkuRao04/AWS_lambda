# Define a CloudWatch Log Group to store logs for the Lambda function
resource "aws_cloudwatch_log_group" "lambda-visitorcounter" {
  name = "/aws/lambda/${aws_lambda_function.lambda-visitorcounter.function_name}"

  retention_in_days = 30
}
