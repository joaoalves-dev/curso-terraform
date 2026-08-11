# Recursos do módulo. Esse código é compartilhado por todos os ambientes
# (dev, hom, prod) — o que muda entre eles são as variáveis passadas.
#
# Exemplo (descomente e ajuste conforme necessário):

# Tags locais que combinam ambiente e tags comuns
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  default_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  )
}

# ============================================
# REDE (VPC e Subnets)
# ============================================

# VPC principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

# Subnets públicas
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-public-${count.index + 1}"
      Type = "public"
    }
  )
}

# Subnets privadas
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-private-${count.index + 1}"
      Type = "private"
    }
  )
}

# Elastic IP para NAT Gateway
resource "aws_eip" "nat" {
  count = var.environment == "prod" ? 1 : 0
  
  domain = "vpc"

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-nat-eip"
    }
  )
}

# NAT Gateway (apenas em produção)
resource "aws_nat_gateway" "main" {
  count         = var.environment == "prod" ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-nat"
    }
  )
}

# Route table pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-public-rt"
    }
  )
}

# Route table privada (com NAT se prod, sem NAT se dev/hom)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.environment == "prod" ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-private-rt"
    }
  )
}

# Associações de route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ============================================
# COMPUTAÇÃO (EC2)
# ============================================

# Security Group para EC2
resource "aws_security_group" "ec2" {
  name        = "${local.name_prefix}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  # SSH (apenas em dev/hom)
  dynamic "ingress" {
    for_each = var.environment != "prod" ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # Em prod, isso seria restrito
    }
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Saída total
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.name_prefix}-ec2-sg"
    }
  )
}

# Buscar AMI mais recente do Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# ============================================
# KEY PAIR (se ainda não tiver)
# ============================================

resource "aws_key_pair" "main" {
  count      = var.ssh_public_key != "" ? 1 : 0
  key_name   = "${local.name_prefix}-key"
  public_key = var.ssh_public_key

  tags = local.default_tags
}

# ============================================
# LAUNCH TEMPLATE (Substitui a EC2 direta)
# ============================================

resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.ssh_public_key != "" ? aws_key_pair.main[0].key_name : null

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>${var.project_name} - ${var.environment}</h1>" > /var/www/html/index.html
    echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
    echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
  EOF
  )

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.environment == "prod" ? 50 : 20
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.default_tags,
      {
        Name = "${local.name_prefix}-web"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_caller_identity" "current" {}
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}" 
  
  tags = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.environment == "prod" ? "Enabled" : "Suspended"
  }
}

# Security Group para RDS
resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306  # MySQL
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]  # Só EC2 acessa
  }

  tags = local.default_tags
}

# Subnet Group para RDS
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet"
  subnet_ids = aws_subnet.private[*].id

  tags = local.default_tags
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${local.name_prefix}-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.environment == "prod" ? "db.t3.small" : "db.t3.micro"
  
  allocated_storage = 20
  storage_encrypted = var.environment == "prod" ? true : false
  
  db_name  = "${var.project_name}db"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = "${local.name_prefix}-final-snapshot"

  tags = local.default_tags
}

# Security Group para ALB
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

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

  tags = local.default_tags
}

# ALB
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = local.default_tags
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${local.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }

  tags = local.default_tags
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# ============================================
# AUTO SCALING GROUP
# ============================================

resource "aws_autoscaling_group" "web" {
  name                = "${local.name_prefix}-asg"
  vpc_zone_identifier = aws_subnet.public[*].id
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_size
  
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns = [aws_lb_target_group.main.arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ============================================
# SCHEDULES DO AUTO SCALING (FORA DO ASG)
# ============================================

# Desligar à noite (apenas dev)
resource "aws_autoscaling_schedule" "night_shutdown" {
  count                  = var.environment == "dev" ? 1 : 0
  scheduled_action_name  = "${local.name_prefix}-night-shutdown"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 22 * * *"   # 22:00 UTC
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# Ligar de manhã (apenas dev)
resource "aws_autoscaling_schedule" "morning_start" {
  count                  = var.environment == "dev" ? 1 : 0
  scheduled_action_name  = "${local.name_prefix}-morning-start"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_size
  recurrence             = "0 7 * * *"    # 07:00 UTC
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# ============================================
# POLÍTICAS DE ESCALA
# ============================================

# Política para AUMENTAR instâncias
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${local.name_prefix}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300  # 5 minutos entre escalas
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# Política para DIMINUIR instâncias
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${local.name_prefix}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

# ============================================
# CLOUDWATCH ALARMS
# ============================================

# Alarme de CPU ALTA (sobe instâncias)
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "Alarme quando CPU > ${var.cpu_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

# Alarme de CPU BAIXA (desce instâncias)
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${local.name_prefix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.cpu_threshold / 3  # 1/3 do threshold (ex: 23%)
  alarm_description   = "Alarme quando CPU < ${var.cpu_threshold / 3}%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

# Alarme de Status Check (instância com problema)
resource "aws_cloudwatch_metric_alarm" "status_check" {
  alarm_name          = "${local.name_prefix}-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alarme quando instância falha em status check"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

# Tópico SNS para notificações (opcional)
resource "aws_sns_topic" "alarms" {
  count = var.environment == "prod" ? 1 : 0
  name  = "${local.name_prefix}-alarms"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high_notification" {
  count               = var.environment == "prod" ? 1 : 0
  alarm_name          = "${local.name_prefix}-cpu-high-notification"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Notificação crítica: CPU > 90%"
  alarm_actions       = [aws_sns_topic.alarms[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "ALB Requests"
        }
      }
    ]
  })
}

# Guardar senha do RDS com segurança
resource "aws_secretsmanager_secret" "rds" {
  name = "${local.name_prefix}-rds-secret"
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.main.address
    port     = 3306
  })
}