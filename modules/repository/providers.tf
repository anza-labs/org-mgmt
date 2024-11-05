terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
    bitwarden = {
      source = "maxlaverse/bitwarden"
    }
  }
}

provider "github" {
  owner = "anza-labs"
}
