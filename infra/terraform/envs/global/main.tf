# ---------------------------------------------------------------------------
# Ressources GLOBALES au compte AWS : elles vivent en permanence et ne sont
# JAMAIS détruites par scripts/end-of-session.sh (qui ne cible que envs/dev).
#
# Le budget est un garde-fou : il doit survivre à l'infrastructure qu'il
# surveille. Il couvre tout le compte, toutes régions confondues.
#
# Utilisation (une seule fois, puis seulement en cas de changement) :
#   cd infra/terraform/envs/global
#   terraform init
#   terraform apply
# ---------------------------------------------------------------------------

module "budget" {
  source = "../../modules/budget"

  project_name = "luc-assure"
  environment  = "global"

  monthly_limit_usd            = 5
  alert_thresholds_percent     = [50, 80, 100]
  forecasted_threshold_percent = 100

  notification_emails = ["lucymel95@gmail.com"]

  tags = {
    Owner = "luc"
  }
}

output "budget_name" {
  description = "Nom du budget AWS permanent"
  value       = module.budget.budget_name
}
