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
