output "budget_name" {
  description = "Nom du budget AWS créé"
  value       = aws_budgets_budget.monthly_cost.name
}

output "budget_id" {
  description = "ID du budget AWS créé"
  value       = aws_budgets_budget.monthly_cost.id
}
