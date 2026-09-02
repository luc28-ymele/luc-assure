variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "luc-assure"
}

variable "environment" {
  description = "Environnement (dev, staging, prod) - utilisé pour le nom du budget"
  type        = string
}

variable "monthly_limit_usd" {
  description = "Plafond mensuel de dépenses AWS en USD au-delà duquel on considère un dépassement"
  type        = number
  default     = 20
}

variable "alert_thresholds_percent" {
  description = "Liste des pourcentages du budget auxquels déclencher une alerte"
  type        = list(number)
  default     = [50, 80, 100]
}

variable "forecasted_threshold_percent" {
  description = "Pourcentage du budget pour l'alerte basée sur la dépense PRÉVISIONNELLE"
  type        = number
  default     = 100
}

variable "notification_emails" {
  description = "Liste des adresses courriel à notifier lors d'un dépassement de seuil"
  type        = list(string)
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}
