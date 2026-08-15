terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket         = "luc-assure-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "luc-assure-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"

  default_tags {
    tags = {
      Project     = "luc-assure"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}
