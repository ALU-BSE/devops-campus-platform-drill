terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ── DRILL 1 ───────────────────────────────────────────────────────────────
  # Uncomment this block. This is what moves your state OFF your laptop and into
  # a locked, remote backend.
  #
  # It names no organization or workspace, because each of you has your own.
  # They come from TF_CLOUD_ORGANIZATION and TF_WORKSPACE (see drill 1).
  #
  # cloud {}
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
