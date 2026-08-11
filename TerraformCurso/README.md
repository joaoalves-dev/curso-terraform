# 🚀 Infraestrutura AWS com Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Free%20Tier-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

Projeto de **Infraestrutura como Código (IaC)** utilizando Terraform para provisionar recursos na AWS. Desenvolvido para fins de estudo e aplicação de boas práticas DevOps.

---

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)        → ## 💡 Sobre o Projeto
- [Arquitetura](#arquitetura)                 → ## 🏗️ Arquitetura
- [Estrutura do Projeto](#-estrutura-do-projeto) → ## 📁 Estrutura do Projeto
- [Recursos Provisionados](#-recursos-provisionados) → ## 🎯 Recursos Provisionados
- [Pré-requisitos](#-pré-requisitos)           → ## 🔧 Pré-requisitos
- [Autor](#-autor)                             → ## 👤 Autor

---

## 💡 Sobre o Projeto

Este projeto provisiona uma **infraestrutura completa na AWS** usando Terraform, com código modular e reutilizável para múltiplos ambientes.

### O que é criado:

- 🌐 **Rede**: VPC, Subnets públicas e privadas, Internet Gateway
- ⚖️ **Load Balancer**: Application Load Balancer (ALB)
- 📈 **Auto Scaling**: EC2 escalando automaticamente conforme demanda
- 🗄️ **Banco de Dados**: RDS MySQL 8.0 em subnet privada
- 📦 **Armazenamento**: S3 Bucket com versionamento
- 📊 **Monitoramento**: CloudWatch Alarms para CPU e Health Check
- 🔐 **Segurança**: Security Groups, Key Pair SSH

---

## 🏗️ Arquitetura

```text
                         ┌─────────────────────────────────────┐
                         │              AWS CLOUD               │
                         │                                      │
    👤 USUÁRIO ─────────▶│  ┌──────────────────────────────┐   │
                         │  │   Application Load Balancer   │   │
                         │  │          (ALB)                │   │
                         │  └──────────────┬───────────────┘   │
                         │                 │                    │
                         │  ┌──────────────┴───────────────┐   │
                         │  │     Auto Scaling Group        │   │
                         │  │   ┌──────────┐ ┌──────────┐  │   │
                         │  │   │  EC2     │ │  EC2     │  │   │
                         │  │   │  AZ1     │ │  AZ2     │  │   │
                         │  │   │  Nginx   │ │  Nginx   │  │   │
                         │  │   └────┬─────┘ └────┬─────┘  │   │
                         │  └─────────┼────────────┼────────┘   │
                         │            │            │             │
                         │  ┌─────────┴────────────┴────────┐   │
                         │  │       RDS MySQL (Privado)     │   │
                         │  └───────────────────────────────┘   │
                         │                                      │
                         │  ┌──────────┐  ┌─────────────────┐   │
                         │  │   S3     │  │   CloudWatch    │   │
                         │  │  Bucket  │  │    Alarms       │   │
                         │  └──────────┘  └─────────────────┘   │
                         └─────────────────────────────────────┘
```


### Fluxo da Aplicação:
1. Usuário acessa via internet
2. ALB distribui o tráfego entre as instâncias
3. Auto Scaling ajusta número de EC2 conforme CPU
4. EC2 processa com Nginx instalado automaticamente
5. RDS armazenado em subnet privada (sem acesso externo)
6. CloudWatch monitora e dispara alarmes

---

## 📁 Estrutura do Projeto

```
terraform-project/
│
├── modules/
│   └── infra/                      # Módulo reutilizável
│       ├── main.tf                 # Recursos AWS principais
│       ├── variables.tf            # Variáveis de entrada
│       └── outputs.tf              # Valores de saída
│
├── environments/
│   ├── dev/                        # Ambiente de desenvolvimento
│   │   ├── main.tf                 # Chamada do módulo
│   │   ├── providers.tf            # Provider AWS
│   │   ├── variables.tf            # Declaração de variáveis
│   │   ├── outputs.tf              # Outputs do ambiente
│   │   ├── backend.tf              # State remoto no S3
│   │   └── terraform.tfvars        # Valores (NÃO COMMITAR!)
│   │
│   ├── hom/                        # Ambiente de homologação
│   │   └── ...
│   │
│   └── prod/                       # Ambiente de produção
│       └── ...
│
├── .gitignore                      # Arquivos ignorados pelo Git
└── README.md                       # Documentação
```

---

## 🎯 Recursos Provisionados

### 🌐 Rede
- VPC com DNS habilitado e CIDR configurável
- 2 Subnets públicas (com acesso à internet)
- 2 Subnets privadas (isoladas)
- Internet Gateway para acesso externo
- NAT Gateway (apenas em produção)
- Route Tables públicas e privadas

### 💻 Computação
- Launch Template com Ubuntu 20.04
- Auto Scaling Group (1 a 3 instâncias)
- Application Load Balancer (ALB)
- Target Group com health check HTTP
- User Data: Nginx instalado automaticamente
- Key Pair para acesso SSH

### 🗄️ Banco de Dados
- RDS MySQL 8.0
- db.t3.micro (dev/hom) ou db.t3.small (prod)
- 20GB de storage
- Localizado em subnet privada
- Security Group dedicado (acesso só das EC2)

### 📦 Armazenamento
- S3 Bucket único por ambiente
- Versionamento habilitado (produção)
- Bloqueio total de acesso público
- Criptografia AES-256

### 📊 Monitoramento
- CloudWatch Alarm: CPU > 70% (scale up)
- CloudWatch Alarm: CPU < 23% (scale down)
- CloudWatch Alarm: Status Check Failed
- Auto Scaling Policies (aumenta/diminui)
- Schedules: desliga à noite em dev (22h-7h)

### 🔐 Segurança
- Security Groups para EC2, RDS e ALB
- SSH liberado apenas em dev e hom
- Senhas marcadas como sensitive
- S3 bloqueado publicamente

---

## 🔧 Pré-requisitos

| Ferramenta | Versão Mínima | Link |
|------------|---------------|------|
| **Terraform** | 1.5+ | [Download](https://www.terraform.io/downloads) |
| **AWS CLI** | 2.0+ | [Download](https://aws.amazon.com/cli/) |
| **Git** | 2.0+ | [Download](https://git-scm.com/) |
| **Conta AWS** | Free Tier | [Criar conta](https://aws.amazon.com/free/) |


## 👤 Autor
João Victor Alves

https://img.shields.io/badge/GitHub-joaoalves--dev-181717?style=for-the-badge&logo=github
