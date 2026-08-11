module "infra" {
  source = "../../modules/infra"
  
  # Identificação
  environment  = var.environment
  project_name = var.project_name
  
  # Rede
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
  
  # Computação
  instance_type  = var.instance_type
  instance_count = var.instance_count

  # SSH
  ssh_public_key = var.ssh_public_key
  
  # Auto Scaling
  min_size      = var.min_size
  max_size      = var.max_size
  desired_size  = var.desired_size
  cpu_threshold = var.cpu_threshold
  
  # Banco de Dados (RDS)
  db_username = var.db_username
  db_password = var.db_password
  
  # Tags
  common_tags = var.common_tags
}