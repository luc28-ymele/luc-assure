variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "luc-assure"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
}

variable "cluster_version" {
  description = "Version de Kubernetes pour le cluster EKS"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "ID du VPC dans lequel déployer EKS"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs des sous-réseaux privés où déployer les nœuds"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs des sous-réseaux publics (nécessaires pour le plan de contrôle EKS)"
  type        = list(string)
}

variable "node_instance_type" {
  description = "Type d'instance EC2 pour les nœuds worker"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Nombre de nœuds souhaité"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Nombre minimum de nœuds"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Nombre maximum de nœuds (pour l'autoscaling)"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}
