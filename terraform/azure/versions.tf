terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
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

provider "azurerm" {
  features {}
}
