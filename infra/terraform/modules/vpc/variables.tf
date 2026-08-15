variable "project_name" {
  description = "Nom du projet, utilisé pour préfixer les ressources"
  type        = string
  default     = "luc-assure"
}

variable "environment" {
  description = "Environnement de déploiement (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "Bloc CIDR principal du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Liste des zones de disponibilité à utiliser"
  type        = list(string)
  default     = ["ca-central-1a", "ca-central-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR des sous-réseaux publics (un par AZ)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR des sous-réseaux privés (un par AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "tags" {
  description = "Tags communs appliqués à toutes les ressources"
  type        = map(string)
  default     = {}
}
