output "apigateway_url" {
  value = aws_api_gateway_rest_api.api_gateway.execution_arn
}

output "s3_website_url" {
  value = aws_s3_bucket.daily_personal_perfomance_website.website_endpoint
}