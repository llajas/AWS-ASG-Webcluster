terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "staging_webserver" {
  source = "../../../../modules/services/web-server-app"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "S3-BUCKET-HERE"
    key            = "global/s3/webserver/staging/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "DYNAMODB_TABLE_HERE"
    encrypt        = true
  }
}