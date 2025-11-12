# ECS Cluster
resource "aws_ecs_cluster" "wordpress_cluster" {
  name = "${var.owner}-wordpress-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-cluster"
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.owner}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-ecs-task-execution-role"
  }
}

# ECS Task Execution Role Policy Attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "wordpress" {
  family                   = "${var.owner}-wordpress"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "wordpress"
    image     = "wordpress:php8.0-apache"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]

    environment = [
      {
        name  = "WORDPRESS_DB_HOST"
        value = aws_db_instance.wordpress.endpoint
      },
      {
        name  = "WORDPRESS_DB_USER"
        value = var.db_username
      },
      {
        name  = "WORDPRESS_DB_PASSWORD"
        value = var.db_password
      },
      {
        name  = "WORDPRESS_DB_NAME"
        value = var.db_name
      }
    ]

    mountPoints = [
      {
        sourceVolume  = "wp-content"
        containerPath = "/var/www/html/wp-content"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.wordpress.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "wordpress"
      }
    }
  }])

  volume {
    name = "wp-content"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.wordpress.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-task"
  }
}

# ECS Service
resource "aws_ecs_service" "wordpress" {
  name            = "${var.owner}-wordpress-service"
  cluster         = aws_ecs_cluster.wordpress_cluster.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.wordpress.arn
    container_name   = "wordpress"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.wordpress,
    aws_efs_mount_target.private_a,
    aws_efs_mount_target.private_b
  ]

  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-wordpress-service"
  }
}
