# AWS Secrets Manager for application secrets
resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${var.project_name}-${var.environment}-secrets"
  description = "Application secrets for ${var.project_name}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-secrets"
    Environment = var.environment
    Application = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    database_url = "postgresql://localhost:5432/assignment"
    api_key      = "demo-api-key-12345"
    jwt_secret   = "demo-jwt-secret-67890"
  })
}