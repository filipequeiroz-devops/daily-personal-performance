resource "aws_s3_bucket" "daily_personal_perfomance_website" {
  bucket = "daily-personal-perfomance-website"

}

resource "aws_s3_bucket_public_access_block" "daily_personal_perfomance_website" {
  bucket = aws_s3_bucket.daily_personal_perfomance_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_versioning" "daily_personal_perfomance_website" {
  bucket = aws_s3_bucket.daily_personal_perfomance_website.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "daily_personal_perfomance_website" {
  bucket = aws_s3_bucket.daily_personal_perfomance_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Permite que o CloudFront acesse os arquivos do bucket S3, mas bloqueia o acesso direto via URL do S3
resource "aws_s3_bucket_policy" "allow_cloudfront_oac" {
  # Referencia o ID do seu bucket S3 existente
  bucket = aws_s3_bucket.daily_personal_perfomance_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        # Libera o acesso a todos os arquivos dentro do bucket (/*)
        Resource = "${aws_s3_bucket.daily_personal_perfomance_website.arn}/*"
        Condition = {
          StringEquals = {
            # Amarra a permissão EXATAMENTE ao ARN da distribuição criada no passo 2
            "AWS:SourceArn" = aws_cloudfront_distribution.daily_personal_performance_distribution.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_object" "app_files" {
  for_each = fileset("${path.module}/../app", "**/*")

  bucket = aws_s3_bucket.daily_personal_perfomance_website.id
  key    = each.value
  source = "${path.module}/../app/${each.value}"

  etag = filemd5("${path.module}/../app/${each.value}")

  content_type = lookup(
    {
      "html" = "text/html",
      "css"  = "text/css",
      "js"   = "application/javascript",
      "png"  = "image/png",
      "jpg"  = "image/jpeg",
      "jpeg" = "image/jpeg",
      "svg"  = "image/svg+xml",
      "json" = "application/json"
    },
    element(split(".", each.value), length(split(".", each.value)) - 1),
    "binary/octet-stream"
  )
}