terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-states-bucket-filipe"
    key     = "website-daily-personal-performance/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}