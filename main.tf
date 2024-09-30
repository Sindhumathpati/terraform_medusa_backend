# AWS Provider
provider "aws" {
<<<<<<< HEAD
  region = "us-east-1" # Change as needed
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

=======
  region = "us-east-1"
}

# Create a VPC (You already have this)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
>>>>>>> bc90ef2eed9b66da1d6b66c23daed400d985ec21
  tags = {
    Name = "my-vpc"
  }
}

<<<<<<< HEAD
# Create a public subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true # Enable auto-assign public IP

=======
# Create a public subnet (You already have this)
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
>>>>>>> bc90ef2eed9b66da1d6b66c23daed400d985ec21
  tags = {
    Name = "my-subnet"
  }
}

<<<<<<< HEAD
# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

=======
# Create an Internet Gateway (You already have this)
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
>>>>>>> bc90ef2eed9b66da1d6b66c23daed400d985ec21
  tags = {
    Name = "my-internet-gateway"
  }
}

<<<<<<< HEAD
# Create a route table for the public subnet
=======
# Create a public route table (You already have this)
>>>>>>> bc90ef2eed9b66da1d6b66c23daed400d985ec21
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "my-public-route-table"
  }
}

<<<<<<< HEAD
# Associate the route table with the public subnet
=======
# Associate route table with the public subnet (You already have this)
>>>>>>> bc90ef2eed9b66da1d6b66c23daed400d985ec21
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

<<<<<<< HEAD
# Create a security group for the EC2 instance
resource "aws_security_group" "instance_sg" {
=======
# Security Group for ECS Tasks (Allow HTTP, HTTPS)
resource "aws_security_group" "ecs_sg" {
>>>>>>> bc90ef2eed9b66da1d6b66c23daed400d985ec21
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic
  }

<<<<<<< HEAD
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-instance-sg"
  }
}

# Create an EC2 instance
resource "aws_instance" "medusa" {
  ami           = "ami-0e86e20dae9224db8" # Update with a suitable AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  security_groups = [aws_security_group.instance_sg.id]
=======
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
>>>>>>> bc90ef2eed9b66da1d6b66c23daed400d985ec21

  key_name      = "awsmedusa"

  tags = {
    Name = "medusa-ecs-sg"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-ecs-cluster"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecsTaskExecutionRole" {
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

# Attach ECS Task Execution Role policies
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition (using Fargate)
resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "medusa-task"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 512 MB

  container_definitions = jsonencode([
    {
      name      = "medusa"
      image     = "<AWS_ACCOUNT_ID>.dkr.ecr.<region>.amazonaws.com/medusa-app:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# ECS Service for Fargate Spot
resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets         = [aws_subnet.main.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  # Use Fargate Spot by enabling Capacity Provider Strategy
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 0
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.medusa_tg.arn
    container_name   = "medusa"
    container_port   = 80
  }
}

# Create an ALB for external access to the ECS Fargate service
resource "aws_lb" "medusa_lb" {
  name               = "medusa-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.main.id]

  enable_deletion_protection = false
}

# Target Group for the ALB
resource "aws_lb_target_group" "medusa_tg" {
  name     = "medusa-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Listener for the ALB
resource "aws_lb_listener" "medusa_lb_listener" {
  load_balancer_arn = aws_lb.medusa_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.medusa_tg.arn
  }
}  