terraform {
  backend "s3" {}
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "dev-ecs-cluster"
}

resource "aws_launch_configuration" "ecs_instance" {
  name          = "ecs-instance2"
  image_id      = "ami-0ba0650e6cd15c2b4"
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  security_groups      = ["sg-01be005baa9ef1494"]
}


resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["subnet-06bc80554f02d8614", "subnet-0d62abcf68a067b35", "subnet-00395acff911333e0"]
  launch_configuration = aws_launch_configuration.ecs_instance.id

  tag {
    key                 = "Name"
    value               = "ecs-instance"
    propagate_at_launch = true
  }
}

data "aws_ecr_repository" "my_repository" {
  name = "andrestest12"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-task-family-ec2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "my-container-ec2"
      image = "${data.aws_ecr_repository.my_repository.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service-2"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets          = ["subnet-06bc80554f02d8614", "subnet-0d62abcf68a067b35", "subnet-00395acff911333e0"]
    security_groups  = ["sg-01be005baa9ef1494"]
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_pull_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_instance_sg" {
  name        = "ecs-instance-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-0ee46c443a427c1ad"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
