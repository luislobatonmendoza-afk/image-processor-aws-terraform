# Image Processor AWS Terraform

Proyecto de infraestructura como código desarrollado con Terraform sobre AWS.

La arquitectura implementa un servicio de procesamiento de imágenes utilizando
API Gateway, AWS Lambda, Amazon S3, Amazon SQS, IAM, VPC Endpoints y CloudWatch.

## Arquitectura

El flujo principal es:

1. El cliente envía una imagen mediante `POST /upload`.
2. API Gateway invoca la función Lambda de carga.
3. La imagen original se almacena en Amazon S3 bajo el prefijo `uploads/`.
4. S3 genera una notificación hacia Amazon SQS.
5. La función Lambda de procesamiento consume los mensajes desde SQS.
6. La imagen es procesada y almacenada nuevamente en S3 bajo `processed/`.
7. CloudWatch registra logs y supervisa la Dead-Letter Queue.

## Entornos

La infraestructura utiliza Terraform Workspaces para separar tres entornos:

- DEV
- QA
- PROD

Los recursos utilizan un prefijo basado en el entorno seleccionado.

Ejemplos:

- `image-processor-dev-*`
- `image-processor-qa-*`
- `image-processor-prod-*`

## Requisitos

- Terraform >= 1.6
- AWS CLI
- Docker
- Git
- Cuenta AWS
- AWS IAM Identity Center configurado
- Perfil AWS CLI `terraform-admin`

## Configuración de AWS

Para iniciar sesión:

```bash
aws sso login --profile terraform-admin