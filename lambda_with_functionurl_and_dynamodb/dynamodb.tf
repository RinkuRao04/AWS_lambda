resource "aws_dynamodb_table" "dynamo-visitorcounter" {
  name         = "db-visit-count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key  = "username"

  attribute {
    name = "username"
    type = "S"
  }
}
