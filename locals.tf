locals {
  availabilty_zone = "us-west-2a"
  region           = "us-west-2"
  tag_name         = "datadog-example"

  // Firelens
  firelens_bucket_name         = "example-firehose-logging-backup-bucket"
  firelens_log_container_image = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:latest"

  // Datadog
  datadog_logging_http_endpoint = "https://aws-kinesis-http-intake.logs.datadoghq.com/v1/input"
}
