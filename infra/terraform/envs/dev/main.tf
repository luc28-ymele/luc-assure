
# ---------------------------------------------------------------------------
# Modules VPC / EKS / RDS temporairement désactivés (commentés) suite à
# l'incident de facturation d'août 2026. À réactiver manuellement quand
# tu veux redéployer l'infrastructure complète du projet.
# ---------------------------------------------------------------------------

# module "vpc" {
#   source = "../../modules/vpc"
#
#   project_name = "luc-assure"
#   environment  = "dev"
#
#   vpc_cidr             = "10.0.0.0/16"
#   azs                  = ["ca-central-1a", "ca-central-1b"]
#   public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
#   private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
#
#   tags = {
#     Owner = "luc"
#   }
# }

# module "eks" {
#   source = "../../modules/eks"
#
#   project_name = "luc-assure"
#   environment  = "dev"
#
#   vpc_id              = module.vpc.vpc_id
#   private_subnet_ids  = module.vpc.private_subnet_ids
#   public_subnet_ids   = module.vpc.public_subnet_ids
#
#   cluster_version     = "1.31"
#   node_instance_type  = "t3.medium"
#   node_desired_size   = 2
#   node_min_size       = 1
#   node_max_size       = 3
#
#   tags = {
#     Owner = "luc"
#   }
# }

# module "rds" {
#   source = "../../modules/rds"
#
#   project_name = "luc-assure"
#   environment  = "dev"
#
#   vpc_id              = module.vpc.vpc_id
#   vpc_cidr            = "10.0.0.0/16"
#   private_subnet_ids  = module.vpc.private_subnet_ids
#
#   instance_class         = "db.t3.micro"
#   allocated_storage      = 20
#   multi_az               = false
#   backup_retention_days  = 1
#
#   tags = {
#     Owner = "luc"
#   }
# }

module "budget" {
  source = "../../modules/budget"

  project_name = "luc-assure"
  environment  = "dev"

  monthly_limit_usd            = 20
  alert_thresholds_percent     = [50, 80, 100]
  forecasted_threshold_percent = 100

  # ⚠️ Remplace par ta vraie adresse courriel avant de faire terraform apply
  notification_emails = ["lucymel95@gmail.com"]

  tags = {
    Owner = "luc"
  }
}

