# ============================================
# OUTPUTS DO AMBIENTE DEV
# ============================================

# ============================================
# REDE
# ============================================

output "vpc_id" {
  description = "ID da VPC"
  value       = module.infra.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.infra.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.infra.private_subnet_ids
}

# ============================================
# AUTO SCALING + EC2
# ============================================

output "autoscaling_group_name" {
  description = "Nome do Auto Scaling Group"
  value       = module.infra.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN do Auto Scaling Group"
  value       = module.infra.autoscaling_group_arn
}

output "launch_template_id" {
  description = "ID do Launch Template"
  value       = module.infra.launch_template_id
}

# ============================================
# LOAD BALANCER
# ============================================

output "alb_dns_name" {
  description = "DNS do Application Load Balancer"
  value       = module.infra.alb_dns_name
}

output "alb_arn" {
  description = "ARN do ALB"
  value       = module.infra.alb_arn
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = module.infra.target_group_arn
}

# ============================================
# BANCO DE DADOS (RDS)
# ============================================

output "rds_endpoint" {
  description = "Endpoint do RDS"
  value       = module.infra.rds_endpoint
}

output "rds_address" {
  description = "Endereço do RDS"
  value       = module.infra.rds_address
}

# ============================================
# ARMAZENAMENTO (S3)
# ============================================

output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = module.infra.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = module.infra.s3_bucket_arn
}

# ============================================
# CLOUDWATCH ALARMS
# ============================================

output "cpu_high_alarm_arn" {
  description = "ARN do alarme de CPU alta"
  value       = module.infra.cpu_high_alarm_arn
}

output "cpu_low_alarm_arn" {
  description = "ARN do alarme de CPU baixa"
  value       = module.infra.cpu_low_alarm_arn
}

# ============================================
# SECURITY GROUPS
# ============================================

output "ec2_security_group_id" {
  description = "ID do Security Group da EC2"
  value       = module.infra.ec2_security_group_id
}

output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = module.infra.alb_security_group_id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = module.infra.rds_security_group_id
}