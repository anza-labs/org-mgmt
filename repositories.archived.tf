module "scribe" {
  source      = "./modules/repository"
  name        = "scribe"
  description = "Tool for propagation of annotations in Kubernetes"
  archived    = true
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

  secrets = [
    { name = "PAT", secret_id = local.PAT },
  ]
}

module "image-builder" {
  source       = "./modules/repository"
  name         = "image-builder"
  description  = "Tool for building linuxkit images in Kubernetes"
  archived     = true
  is_public    = true
  topics       = ["hacktoberfest", "kubernetes", "linuxkit"]
  enable_pages = true
  homepage_url = "anza-labs.github.io/image-builder"

  required_status_checks = [
    "DCO",
    "pr-title",
    "unit",
    # "e2e", e2e are not working for image builder in CI due to limited memory, fix needed
    "lint",
    "hadolint",
  ]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
  ]
}
