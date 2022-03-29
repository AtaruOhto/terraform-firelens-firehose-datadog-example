# ECS Task Role
resource "aws_iam_role" "ecs_task" {
  name               = "example_ecs_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = local.tag_name
  }
}

# ECS Task Role Assume
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS Task Role IAM Policy
resource "aws_iam_role_policy" "ecs_task" {
  name   = "example_ecs_task_role_policy"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_access.json

}

# ECS Task Role IAM Policy JSON
data "aws_iam_policy_document" "ecs_task_access" {
  version = "2012-10-17"

  statement {
    sid = "CloudWatchLogsAccess"

    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "FirehoseAccess"
    effect = "Allow"
    actions = [
      "firehose:PutRecordBatch"
    ]
    resources = [aws_kinesis_firehose_delivery_stream.example.arn]
  }

}

// ECS Task Execution Role
resource "aws_iam_role" "ecs_task_exec" {
  name               = "example_ecs_task_exec_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_assume.json

  tags = {
    Name = local.tag_name
  }
}

data "aws_iam_policy_document" "ecs_task_exec_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}

