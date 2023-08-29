terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    region = "ap-south-1"
}

provider "aws" {
    region = "ap-south-1a"
}


provider "aws" {
    region = "ap-south-1b"
}

provider "aws" {
    region = "ap-south-2b"
}
