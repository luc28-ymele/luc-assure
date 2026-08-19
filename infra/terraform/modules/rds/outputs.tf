output "db_instance_endpoint" {
  description = "Endpoint de connexion à la base de données"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Adresse (hostname) de la base de données"
  value       = aws_db_instance.main.address
}

output "secret_arn" {
  description = "ARN du secret Secrets Manager contenant les identifiants"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "security_group_id" {
  description = "ID du security group de la base de données"
  value       = aws_security_group.rds.id
}
