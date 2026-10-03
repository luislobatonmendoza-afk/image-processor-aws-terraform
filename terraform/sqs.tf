resource "aws_sqs_queue" "image_dlq" {
  name                      = "${local.name_prefix}-image-dlq"
  message_retention_seconds = 1209600

  tags = {
    Name = "${local.name_prefix}-image-dlq"
  }
}

resource "aws_sqs_queue" "image_queue" {
  name                       = "${local.name_prefix}-image-queue"
  visibility_timeout_seconds = 360
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name = "${local.name_prefix}-image-queue"
  }
}

resource "aws_sqs_queue_policy" "allow_s3" {
  queue_url = aws_sqs_queue.image_queue.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowS3SendMessage"
        Effect = "Allow"

        Principal = {
          Service = "s3.amazonaws.com"
        }

        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.image_queue.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.images.arn
          }

          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}