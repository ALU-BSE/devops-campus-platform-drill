terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ── DRILL 1 ───────────────────────────────────────────────────────────────
  # Uncomment this block and replace the organization name with your team's
  # HCP Terraform org. This is what moves your state OFF your laptop and into
  # a shared, locked, remote backend.
  #
  # Leave the workspace name exactly as it is.
  #
  # cloud {
  #   organization = "alu-devops-CHANGE-ME"
  #
  #   workspaces {
  #     name = "campus-notifier-infra"
  #   }
  # }
  # ───────────────────────────────────────────────────────────────────────────
}

provider "aws" {
  # us-east-1 is pinned deliberately: it is free-tier eligible for t3.micro.
  # af-south-1 (Cape Town) is NOT free tier. Do not "helpfully" move this closer
  # to home — it will cost your team real money.
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
      Course    = "ALU-Advanced-DevOps"
    }
  }
}
