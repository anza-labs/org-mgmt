module "org_mgmt" {
  source      = "./modules/repository"
  name        = "org-mgmt"
  description = "Management of org via OpenTofu and GitHub Actions"
  archived    = false
  topics      = ["hacktoberfest", "opentofu"]
}

module "scribe" {
  source      = "./modules/repository"
  name        = "scribe"
  description = "Tool for propagation of annotations in Kubernetes"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubernetes"]
  required_status_checks = [
    "DCO",
    "pr-title",
    "unit",
    "e2e",
    "lint",
    "hadolint",
  ]
}

module "manifests" {
  source      = "./modules/repository"
  name        = "manifests"
  description = "Application manifests for Flux managed clusters"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubernetes", "flux", "gitops"]
}

module "infra" {
  source      = "./modules/repository"
  description = "Infrastructure as a code"
  name        = "infra"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubernetes", "flux", "gitops"]
}

module "charts" {
  source       = "./modules/repository"
  name         = "charts"
  description  = "Helm Charts of tools developed or used by Anza Labs"
  archived     = false
  is_public    = true
  enable_pages = true
  topics       = ["hacktoberfest", "kubernetes", "helm"]
}
