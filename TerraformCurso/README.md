# 🚀 Infraestrutura AWS com Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Free%20Tier-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

Projeto de **Infraestrutura como Código (IaC)** utilizando Terraform para provisionar recursos na AWS.

## 📋 Índice

- [Sobre](#-sobre)
- [Arquitetura](#-arquitetura)
- [Estrutura](#-estrutura)
- [Recursos](#-recursos)
- [Pré-requisitos](#-pré-requisitos)
- [Como Usar](#-como-usar)
- [Custos](#-custos)
- [Comandos Úteis](#-comandos-úteis)

## 💡 Sobre

Este projeto provisiona uma infraestrutura completa na AWS usando Terraform:

- 🌐 VPC, Subnets, Internet Gateway
- ⚖️ Application Load Balancer
- 📈 Auto Scaling Group
- 🗄️ RDS MySQL
- 📦 S3 Bucket
- 📊 CloudWatch Alarms

## 🏗️ Arquitetura

Usuário → ALB → Auto Scaling (EC2 + Nginx) → RDS (MySQL)
                    ↓
              S3 + CloudWatch

## 📁 Estrutura
terraform-project/
├── modules/infra/ # Módulo reutilizável
│ ├── main.tf
│ ├── variables.tf
│ └── outputs.tf
├── environments/
│ ├── dev/ # Desenvolvimento
│ ├── hom/ # Homologação
│ └── prod/ # Produção
├── .gitignore
└── README.md


## 🎯 Recursos

| Categoria | Recursos |
|-----------|----------|
| 🌐 Rede | VPC, 2 subnets públicas, 2 privadas, IGW, NAT |
| 💻 Computação | Launch Template, ASG, ALB |
| 🗄️ Banco | RDS MySQL 8.0 em subnet privada |
| 📦 Storage | S3 com versionamento |
| 📊 Monitor | CloudWatch Alarms (CPU, Health) |

## 🔧 Pré-requisitos

- Terraform 1.5+
- AWS CLI configurado
- Conta AWS (Free Tier)

```bash
terraform version
aws --version

🚀 Como Usar
# 1. Clone
git clone https://github.com/seu-usuario/terraform-project.git
cd terraform-project/environments/dev

# 2. Configure
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com seus valores

# 3. Execute
terraform init
terraform plan
terraform apply

# 4. Acesse
terraform output alb_dns_name

💰 Custos
Com conta nova (12 meses grátis): TOTAL = R$ 0,00

Recurso	Free Tier
EC2 t3.micro	750h/mês
RDS db.t3.micro	750h/mês
ALB	750h/mês
S3	5GB

📝 Comandos Úteis
bash
terraform fmt -recursive    # Formatar
terraform validate          # Validar
terraform state list        # Ver recursos
terraform output            # Ver outputs
terraform destroy           # Destruir tudo

👤 Autor
João Victor Alves
GitHub: https://github.com/joaoalves-dev/