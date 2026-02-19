terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # Bucket and Region will be passed via -backend-config in Jenkinsfile
    # key will be dynamic: s3/BUCKET_NAME.tfstate
  }
}

provider "aws" {
  region = var.region
}
