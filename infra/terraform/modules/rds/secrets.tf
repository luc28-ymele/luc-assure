# ---------------------------------------------------------------------------
# Génère un mot de passe aléatoire fort pour la base de données.
# Ce mot de passe n'est JAMAIS écrit en clair dans le code ou le state Git —
# il est généré à la volée et stocké uniquement dans AWS Secrets Manager.
# ---------------------------------------------------------------------------
resource "random_password" "db_password" {
  length      = 24
  special     = true
  # Certains caractères spéciaux posent problème à RDS, on les exclut
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${local.name}-db-credentials"
  description = "Identifiants de connexion à la base de données PostgreSQL RDS"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    dbname   = var.db_name
    engine   = "postgres"
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
  })
}
