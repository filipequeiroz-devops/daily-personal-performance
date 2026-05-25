data "archive_file" "daily-personal-perfomance-lambda-zip" {
  type        = "zip"
  source_dir  = "${path.module}/daily_personal_performance_handler/"
  output_path = "${path.module}/daily_personal_performance_payload/daily_personal_performance_handler.zip"
}

resource "aws_lambda_function" "daily_personal_performance" {
  function_name                  = "daily_personal_performance"
  filename                       = data.archive_file.daily-personal-perfomance-lambda-zip.output_path
  handler                        = "personal_performance.lambda_handler"
  memory_size                    = 128
  package_type                   = "Zip"
  region                         = "us-east-1"
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda_role.arn
  runtime                        = "python3.10"
  timeout                        = 3

  source_code_hash = data.archive_file.daily-personal-perfomance-lambda-zip.output_base64sha256

  ephemeral_storage {
    size = 512
  }

  logging_config {
    application_log_level = null
    log_format            = "Text"
    log_group             = "/aws/lambda/personal_performance"
    system_log_level      = null
  }

  tracing_config {
    mode = "PassThrough"
  }

  environment {

    variables = {
      DYNAMODB_TABLENAME = aws_dynamodb_table.daily_personal_performance.name
    }
  }
}