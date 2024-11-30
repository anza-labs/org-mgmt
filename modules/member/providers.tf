# tflint-ignore: terraform_required_version
terraform {
  required_providers {
    # tflint-ignore: terraform_required_providers
    github = {
      source = "integrations/github"
    }
  }
}

provider "github" {
  owner = "anza-labs"
}
