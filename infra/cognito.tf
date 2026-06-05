resource "aws_cognito_user_pool" "main" {
  name = "daily-personal-performance-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = true
  }

  schema {
    attribute_data_type = "String"
    name                = "name"
    required            = true
    mutable             = true
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email profile openid"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    name     = "name"
  }
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "daily-personal-performance-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Suporta apenas Google para simplificar
  supported_identity_providers = ["Google"]

  # Configurações OAuth
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = [var.cognito_redirect_uri]
  logout_urls                          = ["https://daily-personal-perfomance.filipe-deabreu.com"]

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  # Depende do Identity Provider estar criado antes de tentar associá-lo ao App Client
  depends_on = [
    aws_cognito_identity_provider.google
  ]
}
