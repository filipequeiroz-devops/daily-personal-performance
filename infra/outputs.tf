output "apigateway_url" {
  value = aws_apigatewayv2_api.daily-personal-performance-API.api_endpoint
}

output "s3_website_url" {
  value = aws_s3_bucket.daily_personal_perfomance_website.website_endpoint
}