# -----------------------------------------------------------------------------
# Terraform configuration for deploying a simple time service on AWS using ECS Fargate.
#
# This configuration includes:
# - AWS provider setup with region from variable.
# - VPC creation using the terraform-aws-modules/vpc/aws module with public and private subnets.
# - ECS Cluster definition.
# - IAM Role and policy attachment for ECS task execution.
# - ECS Task Definition for a containerized time service application.
# - CloudWatch Log Group for ECS container logs.
# - Application Load Balancer (ALB) with security group and listener.
# - Target Group for routing traffic to ECS tasks.
# - Security Groups for ALB and ECS service.
# - ECS Service definition with Fargate launch type, private subnet networking, and ALB integration.
#
# Resources:
# - VPC with NAT Gateway, DNS support, and two availability zones.
# - ECS Cluster and Service for running the containerized application.
# - IAM Role for ECS task execution with required policies.
# - CloudWatch Log Group for application logs.
# - Application Load Balancer and Target Group for HTTP traffic on port 80 (ALB) and 5000 (ECS tasks).
# - Security Groups to control traffic between ALB and ECS tasks.
#
# Usage:
# - Ensure AWS credentials and region variable are set.
# - Deploy with `terraform init` and `terraform apply`.
# - The ALB will route HTTP requests to the ECS service running the time service container.
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "simple-time-service-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "simple-time-service-cluster"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "simple-time-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "simple-time-service"
      image     = "nikitashirbhate/simple-time-service:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/simple-time-service"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/simple-time-service"
  retention_in_days = 7
}

resource "aws_lb" "alb" {
  name               = "simple-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "tg" {
  name         = "simple-tg"
  port         = 5000
  protocol     = "HTTP"
  vpc_id       = module.vpc.vpc_id
  target_type  = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow ALB to communicate with ECS tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "service" {
  name            = "simple-time-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "simple-time-service"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.listener]
}
