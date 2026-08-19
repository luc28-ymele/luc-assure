variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "luc-assure"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs des sous-réseaux privés où déployer RDS"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR du VPC, pour autoriser le trafic entrant sur le port PostgreSQL"
  type        = string
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "lucassure"
}

variable "db_username" {
  description = "Nom d'utilisateur administrateur de la base"
  type        = string
  default     = "lucassure_admin"
}

variable "instance_class" {
  description = "Type d'instance RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Espace de stockage alloué en Go"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Activer le multi-AZ (haute disponibilité, coûte plus cher — désactivé en dev)"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Nombre de jours de rétention des sauvegardes automatiques"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}
