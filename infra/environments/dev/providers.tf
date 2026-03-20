terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "laptopai-tf-state-qwerttt"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "laptopai-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}