terraform {
  required_version = ">= 1.8"

  backend "pg" {
    schema_name = "tofu_remote_state_anza_labs"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.12.1"
    }

    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.17.6"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }
  }
}

provider "github" {
  owner = "anza-labs"
}

provider "bitwarden" {
  access_token          = var.bws_access_token
  client_implementation = "embedded"
}
