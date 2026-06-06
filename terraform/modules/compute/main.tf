variable "project_name"    { default = "starttech" }
variable "vpc_id"          {}
variable "public_subnet_1" {}
variable "public_subnet_2" {}
variable "private_subnet_1" {}
variable "private_subnet_2" {}
variable "alb_sg_id"       {}
variable "backend_sg_id"   {}
variable "redis_sg_id"     {}
variable "ami_id"          { default = "ami-00403f401ee6a4b98" }
variable "instance_type"   { default = "t3.micro" }
variable "mongo_uri"       { sensitive = true }
variable "jwt_secret"      { sensitive = true }
variable "ecr_image_uri"   { default = "" }

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ALB
resource "aws_lb" "backend" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.public_subnet_1, var.public_subnet_2]
  tags               = { Name = "${var.project_name}-alb" }
}

resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
  tags = { Name = "${var.project_name}-tg" }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# Launch Template
resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project_name}-backend-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [var.backend_sg_id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io awscli
    systemctl start docker
    systemctl enable docker

    # Install CloudWatch Agent
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    dpkg -i amazon-cloudwatch-agent.deb

    # Set environment variables
    cat > /etc/app.env <<ENVEOF
    MONGO_URI=${var.mongo_uri}
    JWT_SECRET_KEY=${var.jwt_secret}
    PORT=8080
    ENABLE_CACHE=false
    DB_NAME=much_todo_db
    LOG_LEVEL=INFO
    LOG_FORMAT=json
    ENVEOF

    # Pull and run the backend container
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${var.ecr_image_uri}
    docker pull ${var.ecr_image_uri} || echo "Using latest available image"
    docker run -d \
      --env-file /etc/app.env \
      -p 8080:8080 \
      --restart always \
      --name muchtodo-backend \
      ${var.ecr_image_uri}
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-backend" }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "backend" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = [var.private_subnet_1, var.private_subnet_2]
  target_group_arns   = [aws_lb_target_group.backend.arn]
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend-asg"
    propagate_at_launch = true
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

# ElastiCache Redis
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-redis-subnet"
  subnet_ids = [var.private_subnet_1, var.private_subnet_2]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [var.redis_sg_id]
  tags                 = { Name = "${var.project_name}-redis" }
}

output "alb_dns_name"         { value = aws_lb.backend.dns_name }
output "alb_arn"              { value = aws_lb.backend.arn }
output "asg_name"             { value = aws_autoscaling_group.backend.name }
output "redis_endpoint"       { value = aws_elasticache_cluster.redis.cache_nodes[0].address }
output "target_group_arn"     { value = aws_lb_target_group.backend.arn }