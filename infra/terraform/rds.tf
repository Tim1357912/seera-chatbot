resource "random_password" "db_password" {
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = values(aws_subnet.private)[*].id

  tags = {
    Name = "${local.name_prefix}-db-subnets"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "${local.name_prefix}-postgres"
  engine                  = "postgres"
  engine_version          = var.postgres_engine_version != null && trimspace(var.postgres_engine_version) != "" ? trimspace(var.postgres_engine_version) : null
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = 100
  storage_type            = "gp3"
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db_password.result
  db_subnet_group_name    = aws_db_subnet_group.postgres.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 7
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = !var.db_deletion_protection

  tags = {
    Name = "${local.name_prefix}-postgres"
  }
}
