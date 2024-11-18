resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my-api-new"
  description = "My API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id  #parent_id is the ID of the parent resource for the new resource. In this case, parent_id is set to aws_api_gateway_rest_api.my_api.root_resource_id, which is the root resource of the API (i.e., the base path / of your API).
  path_part   = "mypath"
}


# Create the GET method for the resource
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "GET"  # Set method to GET
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.demo.id
  request_parameters = {
    "method.request.querystring.script" = true  # Allow query string parameter "script"
  }
}

# Lambda integration for the GET method
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id              = aws_api_gateway_rest_api.my_api.id
  resource_id              = aws_api_gateway_resource.root.id
  http_method              = aws_api_gateway_method.get_method.http_method
  integration_http_method  = "POST"  # Use POST for integration (common practice for AWS Lambda proxy integration)
  type                     = "AWS_PROXY"  # Use AWS proxy integration (recommended for Lambda)

  uri                      = aws_lambda_function.html_lambda.invoke_arn  # ARN of your Lambda function

  request_parameters = {
    "integration.request.querystring.script" = "method.request.querystring.script"  # Map query string parameter
  }
}

# Method response for GET method
resource "aws_api_gateway_method_response" "get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
}

# Integration response for Lambda integration
resource "aws_api_gateway_integration_response" "get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = aws_api_gateway_method_response.get_method_response.status_code

  # Optionally map the response from Lambda (depending on how your Lambda function is structured)
  response_templates = {
    "application/json" = "#set($inputRoot = $input.path('$'))\n{\n  \"message\": \"$inputRoot.message\"\n}"
  }

  depends_on = [
    aws_api_gateway_method.get_method,
    aws_api_gateway_integration.lambda_integration
  ]
}

# Deployment of the API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "dev"
}

resource "aws_api_gateway_authorizer" "demo" {
  name = "my_apig_authorizer2"
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  type = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.pool.arn]
}


