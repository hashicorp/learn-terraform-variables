# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {

  /* Uncomment this block to use Terraform Cloud for this tutorial
  cloud {
      organization = "organization-name"
      workspaces {
        name = "learn-terraform-variables"
      }
  }
  */
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42.0"
    }
  }
  required_version = "~> 1.2"
}
