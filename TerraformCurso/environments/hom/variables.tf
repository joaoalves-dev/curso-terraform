variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Profile do AWS CLI a ser usado (definido em ~/.aws/credentials)"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Nome do ambiente (dev, hom, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto, usado para nomear e taguear recursos"
  type        = string
  default     = "meu-projeto"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}
