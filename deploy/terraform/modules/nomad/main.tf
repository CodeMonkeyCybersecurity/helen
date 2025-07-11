# Nomad cluster module
locals {
  name_prefix = "nomad-${var.environment}"
}

# AMI data source for Nomad
data "aws_ami" "nomad" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["nomad-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data template for Nomad servers
data "template_file" "nomad_server_user_data" {
  template = file("${path.module}/templates/nomad-server-user-data.sh")

  vars = {
    environment       = var.environment
    consul_address    = var.consul_address
    vault_address     = var.vault_address
    nomad_datacenter  = var.nomad_datacenter
    server_count      = var.nomad_server_count
    encrypt_key       = var.nomad_encrypt_key
  }
}

# User data template for Nomad clients
data "template_file" "nomad_client_user_data" {
  template = file("${path.module}/templates/nomad-client-user-data.sh")

  vars = {
    environment       = var.environment
    consul_address    = var.consul_address
    vault_address     = var.vault_address
    nomad_datacenter  = var.nomad_datacenter
    encrypt_key       = var.nomad_encrypt_key
  }
}

# IAM role for Nomad servers
resource "aws_iam_role" "nomad_server" {
  name = "${local.name_prefix}-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM role for Nomad clients
resource "aws_iam_role" "nomad_client" {
  name = "${local.name_prefix}-client-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM policy for Nomad servers
resource "aws_iam_role_policy" "nomad_server" {
  name = "${local.name_prefix}-server-policy"
  role = aws_iam_role.nomad_server.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeRegions",
          "ec2:DescribeTags",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeAutoScalingInstances",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM policy for Nomad clients
resource "aws_iam_role_policy" "nomad_client" {
  name = "${local.name_prefix}-client-policy"
  role = aws_iam_role.nomad_client.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeRegions",
          "ec2:DescribeTags",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# Instance profiles
resource "aws_iam_instance_profile" "nomad_server" {
  name = "${local.name_prefix}-server-profile"
  role = aws_iam_role.nomad_server.name
}

resource "aws_iam_instance_profile" "nomad_client" {
  name = "${local.name_prefix}-client-profile"
  role = aws_iam_role.nomad_client.name
}

# Launch template for Nomad servers
resource "aws_launch_template" "nomad_server" {
  name_prefix   = "${local.name_prefix}-server-"
  image_id      = data.aws_ami.nomad.id
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = aws_iam_instance_profile.nomad_server.name
  }

  user_data = base64encode(data.template_file.nomad_server_user_data.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${local.name_prefix}-server"
      Role = "nomad-server"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Launch template for Nomad clients
resource "aws_launch_template" "nomad_client" {
  name_prefix   = "${local.name_prefix}-client-"
  image_id      = data.aws_ami.nomad.id
  instance_type = var.instance_type

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = aws_iam_instance_profile.nomad_client.name
  }

  user_data = base64encode(data.template_file.nomad_client_user_data.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${local.name_prefix}-client"
      Role = "nomad-client"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group for Nomad servers
resource "aws_autoscaling_group" "nomad_servers" {
  name                = "${local.name_prefix}-servers"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.nomad_servers.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.nomad_server_count
  max_size         = var.nomad_server_count
  desired_capacity = var.nomad_server_count

  launch_template {
    id      = aws_launch_template.nomad_server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-server"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Auto Scaling Group for Nomad clients
resource "aws_autoscaling_group" "nomad_clients" {
  name                = "${local.name_prefix}-clients"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.nomad_clients.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.nomad_client_count
  max_size         = var.nomad_client_count * 2
  desired_capacity = var.nomad_client_count

  launch_template {
    id      = aws_launch_template.nomad_client.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-client"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# Load balancer for Nomad servers
resource "aws_lb" "nomad_servers" {
  name               = "${local.name_prefix}-servers-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-servers-lb"
  })
}

# Target group for Nomad servers
resource "aws_lb_target_group" "nomad_servers" {
  name     = "${local.name_prefix}-servers-tg"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/v1/status/leader"
    matcher             = "200"
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-servers-tg"
  })
}

# Target group for Nomad clients
resource "aws_lb_target_group" "nomad_clients" {
  name     = "${local.name_prefix}-clients-tg"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/v1/status/leader"
    matcher             = "200"
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-clients-tg"
  })
}

# Load balancer listener
resource "aws_lb_listener" "nomad_servers" {
  load_balancer_arn = aws_lb.nomad_servers.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad_servers.arn
  }
}

# CloudWatch Log Group for Nomad
resource "aws_cloudwatch_log_group" "nomad" {
  name              = "/aws/nomad/${var.environment}"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-logs"
  })
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "nomad_client_scale_up" {
  name                   = "${local.name_prefix}-client-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.nomad_clients.name
}

resource "aws_autoscaling_policy" "nomad_client_scale_down" {
  name                   = "${local.name_prefix}-client-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.nomad_clients.name
}

# CloudWatch Alarms for scaling
resource "aws_cloudwatch_metric_alarm" "nomad_client_cpu_high" {
  alarm_name          = "${local.name_prefix}-client-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.nomad_client_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nomad_clients.name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "nomad_client_cpu_low" {
  alarm_name          = "${local.name_prefix}-client-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.nomad_client_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nomad_clients.name
  }

  tags = var.common_tags
}