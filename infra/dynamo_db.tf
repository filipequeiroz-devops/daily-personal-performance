resource "aws_dynamodb_table" "daily_personal_performance" {
  name         = "DailyPersonalPerformance"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "data"

  attribute {
    name = "data"
    type = "S"
  }

}