locals {
  PAT                = "a288b2ae-a336-4425-9b07-b1f100cd05ec"
  GPG_KEYRING_BASE64 = "568fd648-901a-4161-85e4-b1c500b3cb94"
  GPG_PASSPHRASE     = "ffb60bb8-8422-4d3b-95a1-b20700fb5232"
  PG_CONN_STR        = "b7d22a8b-8185-4d62-8bf6-b1d400b87552"
  LINODE_TOKEN       = "1c579b93-ac50-47a9-85e1-b1c500b40dd5"
  OCI_FINGERPRINT    = "fdc9cf76-3eed-4173-9e66-b1d400b74aaf"
  OCI_PEM_PRV        = "8c29761d-9f79-44f1-97a1-b1d400b70984"
  OCI_PEM_PUB        = "52c24fe2-2dba-45bb-be55-b1d400d3d7a8"
  OCI_TENANCY_OCID   = "f65d2583-7fe2-4ead-a4fa-b1d400b72191"
  OCI_USER_OCID      = "be76a461-2f01-49b8-a106-b1d400b735f4"
}

module "org_mgmt" {
  source      = "./modules/repository"
  name        = "org-mgmt"
  description = "Management of org via OpenTofu and GitHub Actions"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "opentofu"]

  labels = [
    { name = "area/dependency", color = "0052cc", description = "Issues or PRs related to dependency changes." },
    { name = "do-not-merge", color = "e11d21", description = "Indicates that a PR should not merge." },
    { name = "kind/membership", color = "c7def8", description = "Categorizes issue or PR as related to a new feature." },
    { name = "kind/security", color = "e11d21", description = "Categorizes issue or PR as related to a security." },
    { name = "kind/support", color = "c7def8", description = "Categorizes issue or PR as support-related." },
  ]

  required_status_checks = [
    "DCO",
    "pr-title",
    "tofu-fmt",
    "tflint",
    "shell-linter",
  ]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
    { name = "PG_CONN_STR", secret_id = local.PG_CONN_STR },
  ]
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

  secrets = [
    { name = "PAT", secret_id = local.PAT },
  ]
}

module "manifests" {
  source      = "./modules/repository"
  name        = "manifests"
  description = "Application manifests for Flux managed clusters"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubernetes", "flux", "gitops"]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
  ]
}

module "infra" {
  source      = "./modules/repository"
  description = "Infrastructure as a code"
  name        = "infra"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubernetes", "flux", "gitops"]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
    { name = "LINODE_TOKEN", secret_id = local.LINODE_TOKEN },
    { name = "PG_CONN_STR", secret_id = local.PG_CONN_STR },
    { name = "OCI_FINGERPRINT", secret_id = local.OCI_FINGERPRINT },
    { name = "OCI_PEM_PRV", secret_id = local.OCI_PEM_PRV },
    { name = "OCI_PEM_PUB", secret_id = local.OCI_PEM_PUB },
    { name = "OCI_TENANCY_OCID", secret_id = local.OCI_TENANCY_OCID },
    { name = "OCI_USER_OCID", secret_id = local.OCI_USER_OCID },
  ]
}

module "charts" {
  source       = "./modules/repository"
  name         = "charts"
  description  = "Helm Charts of tools developed or used by Anza Labs"
  archived     = false
  is_public    = true
  enable_pages = true
  topics       = ["hacktoberfest", "kubernetes", "helm"]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
    { name = "GPG_KEYRING_BASE64", secret_id = local.GPG_KEYRING_BASE64 },
    { name = "GPG_PASSPHRASE", secret_id = local.GPG_PASSPHRASE },
  ]
}
