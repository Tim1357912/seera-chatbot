resource "aws_secretsmanager_secret" "database_url" {
  name                    = "${local.name_prefix}/database-url"
  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-database-url"
  }
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id = aws_secretsmanager_secret.database_url.id
  secret_string = format(
    "postgresql+psycopg2://%s:%s@%s:%s/%s",
    var.db_username,
    random_password.db_password.result,
    aws_db_instance.postgres.address,
    aws_db_instance.postgres.port,
    var.db_name
  )
}
