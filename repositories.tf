locals {
  BITWARDEN_TOKEN    = "0a3da8e6-41e3-4c40-9883-b23c00af72ee"
  GPG_KEYRING_BASE64 = "568fd648-901a-4161-85e4-b1c500b3cb94"
  GPG_PASSPHRASE     = "ffb60bb8-8422-4d3b-95a1-b20700fb5232"
  LINODE_TOKEN       = "1c579b93-ac50-47a9-85e1-b1c500b40dd5"
  OCI_FINGERPRINT    = "fdc9cf76-3eed-4173-9e66-b1d400b74aaf"
  OCI_PEM_PRV        = "8c29761d-9f79-44f1-97a1-b1d400b70984"
  OCI_TENANCY_OCID   = "f65d2583-7fe2-4ead-a4fa-b1d400b72191"
  OCI_USER_OCID      = "be76a461-2f01-49b8-a106-b1d400b735f4"
  PAT                = "a288b2ae-a336-4425-9b07-b1f100cd05ec"
  PG_CONN_STR        = "b7d22a8b-8185-4d62-8bf6-b1d400b87552"
  SSH_PUB_KEY        = "b2b149a9-1a9c-4a45-b3c6-b1d400b48405"
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
    { name = "BITWARDEN_TOKEN", secret_id = local.BITWARDEN_TOKEN },
    { name = "LINODE_TOKEN", secret_id = local.LINODE_TOKEN },
    { name = "OCI_FINGERPRINT", secret_id = local.OCI_FINGERPRINT },
    { name = "OCI_PEM_PRV", secret_id = local.OCI_PEM_PRV },
    { name = "OCI_TENANCY_OCID", secret_id = local.OCI_TENANCY_OCID },
    { name = "OCI_USER_OCID", secret_id = local.OCI_USER_OCID },
    { name = "PG_CONN_STR", secret_id = local.PG_CONN_STR },
    { name = "PAT", secret_id = local.PAT },
    { name = "SSH_PUB_KEY", secret_id = local.SSH_PUB_KEY },
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

module "image-builder" {
  source      = "./modules/repository"
  name        = "image-builder"
  description = "Tool for building linuxkit images in Kubernetes"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubernetes", "linuxkit"]
  enable_pages = true
  homepage_url = "anza-labs.github.io/image-builder"

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

module "linuxkit-modules" {
  source      = "./modules/repository"
  name        = "linuxkit-modules"
  description = "Modules for linuxkit and containers"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubernetes", "linuxkit"]

  required_status_checks = [
    "DCO",
    "pr-title",
  ]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
  ]
}
