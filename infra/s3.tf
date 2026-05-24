resource "aws_s3_bucket" "daily_personal_perfomance_website" {
  bucket = "daily-personal-perfomance-website"

}

resource "aws_s3_bucket_public_access_block" "daily_personal_perfomance_website" {
  bucket = aws_s3_bucket.daily_personal_perfomance_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "daily_personal_perfomance_website" {
  bucket = aws_s3_bucket.daily_personal_perfomance_website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.daily_personal_perfomance_website.arn}/*"
      }
    ]
  })
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