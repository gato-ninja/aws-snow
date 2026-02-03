
# SNS Topic for S3 notifications
resource "aws_sns_topic" "s3_notifications" {
  name = "snowflake-s3-notifications"
}

# SNS Topic Policy Document
data "aws_iam_policy_document" "s3_notifications_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["SNS:Publish"]
    resources = [aws_sns_topic.s3_notifications.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.simple_bucket.arn]
    }
  }
}

# SNS Topic Policy to allow S3 to publish
resource "aws_sns_topic_policy" "s3_notifications_policy" {
  arn    = aws_sns_topic.s3_notifications.arn
  policy = data.aws_iam_policy_document.s3_notifications_policy.json
}

# SNS Subscription to Snowflake SQS queue
resource "aws_sns_topic_subscription" "snowflake_pipe_subscription" {
  topic_arn = aws_sns_topic.s3_notifications.arn
  protocol  = "sqs"
  endpoint  = snowflake_pipe.pipe.notification_channel
}
