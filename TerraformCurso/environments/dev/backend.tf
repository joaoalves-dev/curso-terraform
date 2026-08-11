terraform {
  backend "s3" {
    bucket       = "meu-bucket-terraform-state-jp2024"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}