# Variáveis básicas de identificação
variable "environment" {
  description = "Nome do ambiente (dev, hom, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "hom", "prod"], var.environment)
    error_message = "Environment deve ser dev, hom ou prod."
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "curso-terraform"
}

# Variáveis de rede
variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para subnets públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDRs para subnets privadas"
  type        = list(string)
}

variable "availability_zones" {
  description = "Lista de AZs para usar"
  type        = list(string)
}

# Variáveis de computação
variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
}

variable "instance_count" {
  description = "Número de instâncias"
  type        = number
  default     = 1
}

# Tags comuns
variable "common_tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default     = {}
}

variable "ssh_public_key" {
  description = "Chave SSH pública para acesso às instâncias"
  type        = string
  sensitive   = false  # Chave pública pode ser visível
}
# ============================================
# VARIÁVEIS AUTO SCALING
# ============================================

variable "min_size" {
  description = "Número mínimo de instâncias no Auto Scaling"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Número máximo de instâncias no Auto Scaling"
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Número desejado de instâncias"
  type        = number
  default     = 1
}

variable "cpu_threshold" {
  description = "Threshold de CPU para alarme (%)"
  type        = number
  default     = 70
}

# Variáveis RDS
variable "db_username" {
  description = "Usuário do banco de dados"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  default     = "changeme123"  # Mude em produção!
  sensitive   = true
}