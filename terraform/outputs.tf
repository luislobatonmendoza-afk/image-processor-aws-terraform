output "environment" {
  description = "Entorno actualmente seleccionado"
  value       = local.environment
}

output "name_prefix" {
  description = "Prefijo utilizado para nombrar los recursos"
  value       = local.name_prefix
}

output "aws_region" {
  description = "Region donde se despliega la infraestructura"
  value       = var.aws_region
}