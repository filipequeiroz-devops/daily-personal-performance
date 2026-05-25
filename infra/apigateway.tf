#aqui eu vou importar tanto a api gateway quanto a integração com a lambda, e também irei importar as rotas
resource "aws_apigatewayv2_api" "daily-personal-performance-API" {

  description                = "Created by AWS Lambda"
  ip_address_type            = "ipv4"
  name                       = "daily-personal-performance-API"
  protocol_type              = "HTTP"
  region                     = "us-east-1"
  route_selection_expression = "$request.method $request.path"

  cors_configuration {
    allow_credentials = false
    allow_headers = [
      "authorization",
      "content-type",
    ]
    allow_methods = [
      "GET",
      "OPTIONS",
      "POST",
      "PUT",
      "DELETE",
    ]
    allow_origins = [
      "*",
    ]
    expose_headers = []
    max_age        = 0
  }
}

#============ INTEGRAÇÕES  LAMBDA ============
resource "aws_apigatewayv2_integration" "daily-personal-performance-integration" {
  api_id                 = aws_apigatewayv2_api.daily-personal-performance-API.id
  integration_uri        = aws_lambda_function.daily-personal-performance.invoke_arn
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_type       = "AWS_PROXY"
  payload_format_version = "2.0"
  region                 = "us-east-1"
  timeout_milliseconds   = 30000
}


#============ ROTAS DEPOIMENTOS============
resource "aws_apigatewayv2_route" "route_depoimentos_post" {
  api_id    = aws_apigatewayv2_api.daily-personal-performance-API.id
  route_key = "POST /perfomance"
  target    = "integrations/${aws_apigatewayv2_integration.daily-personal-performance-integration.id}"
}

resource "aws_apigatewayv2_route" "route_depoimentos_get" {
  api_id    = aws_apigatewayv2_api.daily-personal-performance-API.id
  route_key = "GET /depoimentos"
  target    = "integrations/${aws_apigatewayv2_integration.daily-personal-performance-integration.id}"
}


resource "aws_apigatewayv2_route" "route_depoimentos_put" {
  api_id    = aws_apigatewayv2_api.daily-personal-performance-API.id
  route_key = "PUT /depoimentos"
  target    = "integrations/${aws_apigatewayv2_integration.daily-personal-performance-integration.id}"
}


resource "aws_apigatewayv2_route" "route_depoimentos_delete" {
  api_id    = aws_apigatewayv2_api.daily-personal-performance-API.id
  route_key = "DELETE /depoimentos"
  target    = "integrations/${aws_apigatewayv2_integration.daily-personal-performance-integration.id}"
}


#============ STAGES ============

#Criando stage Production
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.daily-personal-performance-API.id
  name        = "production"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily-personal-performance.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.daily-personal-performance-API.execution_arn}/production/*"
}
