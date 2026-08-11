# Módulo Infra

Módulo base para provisionamento de infraestrutura AWS.

## Recursos Criados

- VPC com DNS habilitado
- Internet Gateway
- Subnets públicas e privadas
- Route tables (pública e privada)
- NAT Gateway (apenas em produção)
- Security Group para EC2
- Instâncias EC2 com Ubuntu 20.04

## Uso Básico

module "infra" {
  source = "../../modules/infra"
  
  environment     = "dev"
  vpc_cidr        = "10.0.0.0/16"
  instance_type   = "t3.micro"
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}