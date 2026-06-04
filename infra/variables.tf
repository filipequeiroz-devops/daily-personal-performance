variable "google_client_id" {
  type        = string
  description = "Client ID do Google OAuth"
}

variable "google_client_secret" {
  type        = string
  description = "Client Secret do Google OAuth"
  sensitive   = true
}

variable "cognito_domain_prefix" {
  type        = string
  description = "Prefixo para o domínio da Hosted UI do Cognito (deve ser único globalmente)"
  default     = "daily-personal-perfomance-auth"
}

variable "cognito_redirect_uri" {
  type        = string
  description = "URI de redirecionamento (Callback) para o Cognito"
  default     = "https://daily-personal-perfomance.com.br"
}