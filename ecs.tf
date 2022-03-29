# ECS Security Group
module "nginx_sg" {
  source      = "./modules"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.example.id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

# ECS Cluster
resource "aws_ecs_cluster" "example" {
  name = "example_ecs_cluster"

  tags = {
    Name = local.tag_name
  }
}

# ECS Task Defintion
resource "aws_ecs_task_definition" "example" {
  family                   = "example"
  task_role_arn            = aws_iam_role.ecs_task.arn
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  tags = {
    Name = local.tag_name
  }

  // https://docs.aws.amazon.com/en_us/AmazonECS/latest/userguide/using_firelens.html#firelens-using-fluentbit
  container_definitions = <<EOF
  [
    {
      "name": "example_nginx",
      "image": "nginx:latest",
      "essential": true,
      "postMappings": [{
        "protocol": "tcp",
        "containerPort": 80
      }],
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "firehose",
          "region": "${local.region}",
          "delivery_stream": "${aws_kinesis_firehose_delivery_stream.example.name}"
        }
      }      
    },
    {
      "name" : "example_log_router",
      "image": "${local.firelens_log_container_image}",
      "essential": true,
      "firelensConfiguration": {
        "type": "fluentbit"
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.example.name}",
          "awslogs-region": "${local.region}",
          "awslogs-stream-prefix": "firelens"
        }
      }
    }   
  ]
  EOF
}

# ECS Service
resource "aws_ecs_service" "example" {
  name             = "example_ecs_service"
  cluster          = aws_ecs_cluster.example.arn
  task_definition  = aws_ecs_task_definition.example.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.3.0"
  tags = {
    Name = local.tag_name
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = [module.nginx_sg.security_group_id]

    subnets = [
      aws_subnet.public.id
    ]
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}
