# AWS
variable "aws_region" {
  description = "Região AWS"
  type        = string
}

variable "aws_profile" {
  description = "Perfil AWS CLI"
  type        = string
  default     = "default"
}

# Projeto
variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

# Rede
variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
}

# Computação
variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
}

variable "instance_count" {
  description = "Número de instâncias"
  type        = number
  default     = 1
}

# Tags
variable "common_tags" {
  description = "Tags comuns"
  type        = map(string)
  default     = {}
}

variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
}

# ... variáveis existentes ...

# Auto Scaling
variable "min_size" {
  description = "Número mínimo de instâncias"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Número máximo de instâncias"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Número desejado de instâncias"
  type        = number
  default     = 1
}

variable "cpu_threshold" {
  description = "Threshold de CPU para alarme"
  type        = number
  default     = 70
}

# Adicionar no environments/dev/variables.tf

variable "db_username" {
  description = "Usuário do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}