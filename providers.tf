terraform {
  required_version = ">= 1.8"

  backend "pg" {
    schema_name = "tofu_remote_state_anza_labs"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.7.5"
    }

    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.16.0"
    }
  }
}

provider "github" {
  owner = "anza-labs"
}

provider "bitwarden" {
  access_token = var.bws_access_token
  experimental {
    embedded_client = true
  }
}
