module "infra" {
  source = "../../modules/infra"
  
  environment   = "hom"
  project_name  = "curso-terraform"
  
  # VPC e redes
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b"]
  
  # Computação
  instance_type = "t3.micro"
  instance_count = 1
  
  # Tags
  common_tags = {
    Owner       = "DevOps"
    CostCenter  = "dev-001"
  }
}