output "apigateway_url" {
  value = aws_apigatewayv2_api.daily-personal-performance-API.api_endpoint
}

output "s3_website_url" {
  value = aws_s3_bucket.daily_personal_perfomance_website.website_endpoint
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.main.id
}
