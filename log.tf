// The Datadog API KEY must be registered in the SSM parameter store of the AWS CLI in advance.
data "aws_ssm_parameter" "datadog_apikey" {
  name = "/datadog_apikey"
}

// Firehose
resource "aws_iam_role" "firehose" {
  name               = "example_firehose_role_name"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
}

data "aws_iam_policy_document" "firehose_assume" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "firehose" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose_custom.arn
}

resource "aws_iam_policy" "firehose_custom" {
  name        = "firehose-role-policy"
  description = "Firehose Role Policy"
  policy      = data.aws_iam_policy_document.firehose_access.json
}

data "aws_iam_policy_document" "firehose_access" {
  version = "2012-10-17"

  statement {
    sid = "S3Access"

    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultiartUploads",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.example_firelens_bucket.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.example_firelens_bucket.bucket}/*",
    ]
  }

  statement {
    sid       = "CloudWatchLogsAccess"
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_group.example.arn]
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name = "example_cloudwatch_log_group"
}

resource "aws_kinesis_firehose_delivery_stream" "example" {
  name        = "example_firehose_delivery_stream"
  destination = "http_endpoint"

  s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = aws_s3_bucket.example_firelens_bucket.arn
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = aws_cloudwatch_log_group.example.name
      log_stream_name = "example_firehose_crowdwatch_groups"
    }
  }

  http_endpoint_configuration {
    url                = local.datadog_logging_http_endpoint
    name               = "example_firehose_datadog_config"
    access_key         = data.aws_ssm_parameter.datadog_apikey.value
    buffering_size     = 15
    buffering_interval = 600
    role_arn           = aws_iam_role.firehose.arn
    s3_backup_mode     = "AllData" // -  (Optional) Defines how documents should be delivered to Amazon S3. Valid values are FailedDataOnly and AllData. Default value is FailedDataOnly.

    request_configuration {
      content_encoding = "GZIP"

      common_attributes {
        name  = "Name"
        value = "Example"
      }
    }
  }
}
