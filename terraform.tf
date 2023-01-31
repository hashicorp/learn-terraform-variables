terraform {

  cloud {
    organization = "hashicorp-training"
    workspaces {
      name = "learn-terraform-variables"
    }
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }
  }
  required_version = "~> 1.2.0"
}

