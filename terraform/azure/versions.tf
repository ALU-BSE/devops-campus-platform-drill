terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
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

provider "azurerm" {
  features {}
}
