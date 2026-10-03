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

output "vpc_id" {
  description = "ID de la VPC principal"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs de las subredes publicas"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}