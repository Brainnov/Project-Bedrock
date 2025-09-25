terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "project-bedrock-bucket" {
  bucket = "project-bedrock-tfstate"
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "My bucket"
  }
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name         = "terraform-eks-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
