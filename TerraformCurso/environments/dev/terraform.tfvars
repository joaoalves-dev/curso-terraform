# ============================================
# CONFIGURAÇÕES AWS
# ============================================
aws_region    = "us-east-1"
aws_profile   = "default"
environment   = "dev"
project_name  = "curso-terraform"

# ============================================
# REDE (VPC e Subnets)
# ============================================
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

# ============================================
# COMPUTAÇÃO
# ============================================
instance_type  = "t3.micro"  # 
instance_count = 1            # Quantidade de instâncias

# ============================================
# TAGS (opcional mas recomendado)
# ============================================
common_tags = {
  Owner      = "Joao Victor Alves"
  CostCenter = "estudos"
  ManagedBy  = "terraform"
}

# SSH
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCv2DHIhO2QG+vizh6wP+6Cw/rOnwOTGB6Y4y0C2SMnJk8LUDgz9yntFuOux37XIfCAh+NeWFN+Bp9WlhFKJRqB86O7xJXD+ZgjD2pX5cG45WPXgV8onlsQjX1+Shk5WQD4icW3GAR40Vdk8wZ7TtfulzEFHMAqD2Qdm3P0sqblY0D/xOwbfi8ip4NecDFG4e5hFuJEVmsKEFv8l8t5v1oVjUnLqFYbmcqi3RFFHN0j7WbZXpIcGsedmfDJq0q9iDO5N8ASw6Cfif1RqnC23ZbpDZWlq/LzZ+0TyCAqW/IaeNkO7pBAYCROE7vElxYM/Oy9TyDqeKih1DYabI374rnL joaoalves@DESKTOP-12S4N6U"

# Auto Scaling
min_size     = 1
max_size     = 3
desired_size = 1
cpu_threshold = 70

# Banco de Dados
db_username = "admin"
db_password = "admin"