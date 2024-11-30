# tflint-ignore: terraform_required_version
terraform {
  required_providers {
    # tflint-ignore: terraform_required_providers
    github = {
      source = "integrations/github"
    }

    # tflint-ignore: terraform_required_providers
    bitwarden = {
      source = "maxlaverse/bitwarden"
    }
  }
}

provider "github" {
  owner = "anza-labs"
}
