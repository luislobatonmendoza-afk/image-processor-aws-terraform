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

output "s3_bucket_name" {
  description = "Nombre del bucket de imagenes"
  value       = aws_s3_bucket.images.bucket
}

output "sqs_queue_url" {
  description = "URL de la cola principal"
  value       = aws_sqs_queue.image_queue.url
}

output "sqs_dlq_url" {
  description = "URL de la Dead-Letter Queue"
  value       = aws_sqs_queue.image_dlq.url
}

output "s3_vpc_endpoint_id" {
  description = "ID del VPC Endpoint de S3"
  value       = aws_vpc_endpoint.s3.id
}

output "sqs_vpc_endpoint_id" {
  description = "ID del VPC Endpoint de SQS"
  value       = aws_vpc_endpoint.sqs.id
}

output "upload_lambda_name" {
  description = "Nombre de la Lambda de carga"
  value       = aws_lambda_function.upload.function_name
}

output "crop_lambda_name" {
  description = "Nombre de la Lambda de procesamiento"
  value       = aws_lambda_function.crop.function_name
}