resource "aws_cloudwatch_log_group" "upload_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.upload.function_name}"
  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}-upload-logs"
  }
}

resource "aws_cloudwatch_log_group" "crop_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.crop.function_name}"
  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}-crop-logs"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${local.name_prefix}-http-api"
  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}-api-logs"
  }
}

resource "aws_sns_topic" "dlq_alerts" {
  name = "${local.name_prefix}-dlq-alerts"

  tags = {
    Name = "${local.name_prefix}-dlq-alerts"
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${local.name_prefix}-dlq-messages-alarm"
  alarm_description   = "Alerta cuando existen mensajes visibles en la DLQ"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.image_dlq.name
  }

  alarm_actions = [
    aws_sns_topic.dlq_alerts.arn
  ]

  tags = {
    Name = "${local.name_prefix}-dlq-messages-alarm"
  }
}