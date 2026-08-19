locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# ---------------------------------------------------------------------------
# Groupe de sous-réseaux : dit à RDS dans quels subnets privés il peut
# déployer la base de données
# ---------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${local.name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name}-db-subnet-group"
  })
}

# ---------------------------------------------------------------------------
# Security Group : autorise UNIQUEMENT le trafic PostgreSQL (port 5432)
# venant de l'intérieur du VPC (les pods EKS) — jamais depuis Internet
# ---------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "${local.name}-rds-sg"
  description = "Autorise le trafic PostgreSQL depuis interieur du VPC uniquement"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL depuis le VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-rds-sg"
  })
}

# ---------------------------------------------------------------------------
# Instance RDS PostgreSQL
# ---------------------------------------------------------------------------
resource "aws_db_instance" "main" {
  identifier     = "${local.name}-postgres"
  engine         = "postgres"
  engine_version = "16.14"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az                  = var.multi_az
  backup_retention_period   = var.backup_retention_days
  backup_window              = "03:00-04:00"
  maintenance_window          = "sun:04:30-sun:05:30"

  # En dev : suppression facile pour éviter les frais si on oublie une ressource.
  # En prod, ceci serait `false` avec `deletion_protection = true`.
  skip_final_snapshot = true
  deletion_protection  = false

  tags = merge(local.common_tags, {
    Name = "${local.name}-postgres"
  })
}
