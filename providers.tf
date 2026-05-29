# ============================================================
#  providers.tf
#  Tells Terraform which cloud to use (AWS)
#  AND where to store the state file (S3)
# ============================================================

terraform {
  required_version = ">= 1.0"

  # Remote state configuration
  # Instead of storing state on your laptop,
  # it lives in S3 — safe, shared, never lost
  backend "s3" {
    bucket         = "john-terraform-state-2026"
    key            = "secure-cicd/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "john-terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}