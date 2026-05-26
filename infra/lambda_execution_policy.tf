# 1. Cria a Role básica que permite à Lambda assumir essa identidade
resource "aws_iam_role" "lambda_role" {
  name = "daily-personal-performance-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Cria a Política de Execução (com permissão para o DynamoDB e CloudWatch Logs)
resource "aws_iam_policy" "lambda_policy" {
  name        = "daily-personal-performance-lambda-policy"
  description = "Permissoes para a Lambda salvar dados no DynamoDB e gerar logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permissão para o DynamoDB
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.daily_personal_performance.arn
      },
      # Permissão para criar logs no CloudWatch (Boa prática)
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 3. Une a Policy à Role criada
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}