terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      version = ">= 5.44"
      source  = "hashicorp/aws"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
