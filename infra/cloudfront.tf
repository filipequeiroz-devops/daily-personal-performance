# -------------------------------------------------------------------------
# 1. ORIGIN ACCESS CONTROL (OAC)
# Este bloco cria a identidade de segurança do CloudFront. 
# Ele substitui o antigo OAI e é a forma moderna de acessar o S3 de forma privada.
# -------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "daily_performance_oac" {
  name                              = "OAC-DailyPersonalPerformance"
  description                       = "Controle de acesso do CloudFront para o bucket S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -------------------------------------------------------------------------
# 2. DISTRIBUIÇÃO CLOUDFRONT
# -------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "daily_personal_performance_distribution" {

  origin {
    # Aponta para a URL regional do  bucket S3
    domain_name = aws_s3_bucket.daily_personal_perfomance_website.bucket_regional_domain_name
    origin_id   = "S3-daily-personal-performance-website"

    # Vinculando o OAC criado
    origin_access_control_id = aws_cloudfront_origin_access_control.daily_performance_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for Daily Personal Performance website"
  default_root_object = "index.html"

  # -----------------------------------------------------------------------
  # ALTERNATE DOMAIN
  # -----------------------------------------------------------------------
  aliases = ["daily-personal-perfomance.filipe-deabreu.com"]

  default_cache_behavior {
    target_origin_id = "S3-daily-personal-performance-website"

    # Força qualquer requisição HTTP a ser redirecionada para HTTPS
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      # Sem cache por ser site estático, e também para evitar que o CloudFront crie uma cache para cada combinação de cookies (o que pode explodir o custo)
      cookies {
        forward = "none"
      }
    }
  }

  # Limita os servidores para baratear o custo (EUA, Canadá e Europa)
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # -----------------------------------------------------------------------
  # CERTIFICADO SSL CUSTOMIZADO
  # -----------------------------------------------------------------------
  viewer_certificate {
    # ATENÇÃO: Substitua a linha abaixo pelo ARN real do seu certificado gerado no ACM (precisa estar na região us-east-1)
    acm_certificate_arn      = aws_acm_certificate_validation.daily_personal_performance_cert_validation_wait.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021" # Mesma política de segurança mostrada no seu print
  }
}

