variable "aws_region" {
  description = "Region de AWS donde se desplegara la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Perfil de AWS CLI utilizado por Terraform"
  type        = string
  default     = "terraform-admin"
}

variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
  default     = "image-processor"
}