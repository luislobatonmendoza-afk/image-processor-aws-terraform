resource "aws_security_group" "upload_lambda" {
  name        = "${local.name_prefix}-sg-upload-lambda"
  description = "Security group para upload Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "HTTPS hacia servicios AWS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg-upload-lambda"
  }
}

resource "aws_security_group" "crop_lambda" {
  name        = "${local.name_prefix}-sg-crop-lambda"
  description = "Security group para crop Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "HTTPS hacia servicios AWS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg-crop-lambda"
  }
}

resource "aws_security_group" "sqs_endpoint" {
  name        = "${local.name_prefix}-sg-vpce-sqs"
  description = "Acceso HTTPS al endpoint privado de SQS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTPS desde upload Lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.upload_lambda.id]
  }

  ingress {
    description     = "HTTPS desde crop Lambda"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.crop_lambda.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-sg-vpce-sqs"
  }
}