terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # שמירת ה-State בצורה מאובטחת ב-S3 בתוך us-east-1
  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}