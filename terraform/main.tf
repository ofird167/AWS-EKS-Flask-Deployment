terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # שמירת ה-State בצורה מאובטחת ב-S3 בתוך us-east-1
  backend "s3" {
    bucket         = "s3AWS-EKS-Flask-Deployment-state-bucket-ofir" # השם שייצרת בשלב 1
    key            = "s3AWS-EKS-Flask-Deployment/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}