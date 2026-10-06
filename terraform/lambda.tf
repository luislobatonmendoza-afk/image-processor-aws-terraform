data "archive_file" "upload_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/upload"
  output_path = "${path.module}/upload-lambda.zip"
}

data "archive_file" "crop_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/crop"
  output_path = "${path.module}/crop-lambda.zip"
}

resource "aws_lambda_function" "upload" {
  function_name = "${local.name_prefix}-upload"
  role          = aws_iam_role.upload_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"

  filename         = data.archive_file.upload_lambda.output_path
  source_code_hash = data.archive_file.upload_lambda.output_base64sha256

  memory_size = 256
  timeout     = 30

  architectures = ["x86_64"]

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.images.bucket
      UPLOAD_PREFIX = "uploads/"
    }
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_group_ids = [
      aws_security_group.upload_lambda.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.upload_basic_execution,
    aws_iam_role_policy_attachment.upload_vpc_access,
    aws_iam_role_policy.upload_s3
  ]

  tags = {
    Name = "${local.name_prefix}-upload"
  }
}

resource "aws_lambda_function" "crop" {
  function_name = "${local.name_prefix}-crop"
  role          = aws_iam_role.crop_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"

  filename         = data.archive_file.crop_lambda.output_path
  source_code_hash = data.archive_file.crop_lambda.output_base64sha256

  memory_size = 512
  timeout     = 60

  architectures = ["x86_64"]

  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.images.bucket
      PROCESSED_PREFIX = "processed/"
    }
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    security_group_ids = [
      aws_security_group.crop_lambda.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.crop_basic_execution,
    aws_iam_role_policy_attachment.crop_vpc_access,
    aws_iam_role_policy.crop_permissions
  ]

  tags = {
    Name = "${local.name_prefix}-crop"
  }
}

resource "aws_lambda_event_source_mapping" "sqs_to_crop" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.crop.arn

  batch_size = 5
  enabled    = true

  function_response_types = [
    "ReportBatchItemFailures"
  ]

  depends_on = [
    aws_iam_role_policy.crop_permissions
  ]
}