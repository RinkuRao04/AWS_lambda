resource "aws_api_gateway_rest_api_policy" "example_policy" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "*",
      "Condition": {
        "NotIpAddress": {
          "aws:SourceIp": "106.219.140.82"
        }
      }
    }
  ]
}
EOF
}
