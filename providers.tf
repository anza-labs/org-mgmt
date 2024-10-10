terraform {
  backend "pg" {
    schema_name = "tofu_remote_state_anza_labs"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.3.1"
    }
  }
}

provider "github" {
  owner = "anza-labs"
  token = var.gh_token
}
