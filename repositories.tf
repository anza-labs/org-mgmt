locals {
  BITWARDEN_TOKEN           = "0a3da8e6-41e3-4c40-9883-b23c00af72ee"
  BW_ACCESS_TOKEN           = "f94c94d7-7a61-41c4-ac63-b2ba01004c9c"
  DISCORD_WEBHOOK_FLUX_EU_1 = "693e8bd4-4cb4-4a5b-9ab7-b25601604439"
  DISCORD_WEBHOOK_SYSTEMS   = "bbd73241-1602-4a22-b2be-b2ff006f02b2"
  GOOGLE_CREDENTIALS        = "bf265967-3ca4-470f-96ca-b2b900dd1e7f"
  GOOGLE_PROJECT_ID         = "b9d45273-8595-4b9c-bdca-b2b900dcfe84"
  GPG_KEYRING_BASE64        = "568fd648-901a-4161-85e4-b1c500b3cb94"
  GPG_PASSPHRASE            = "ffb60bb8-8422-4d3b-95a1-b20700fb5232"
  COMMIT_SIGNING            = "4c5c18b1-5412-4b71-85e1-b29e009d6cbd"
  LINODE_TOKEN              = "1c579b93-ac50-47a9-85e1-b1c500b40dd5"
  OCI_FINGERPRINT           = "fdc9cf76-3eed-4173-9e66-b1d400b74aaf"
  OCI_PEM_PRV               = "8c29761d-9f79-44f1-97a1-b1d400b70984"
  OCI_TENANCY_OCID          = "f65d2583-7fe2-4ead-a4fa-b1d400b72191"
  OCI_USER_OCID             = "be76a461-2f01-49b8-a106-b1d400b735f4"
  PAT                       = "a288b2ae-a336-4425-9b07-b1f100cd05ec"
  PG_CONN_STR               = "b7d22a8b-8185-4d62-8bf6-b1d400b87552"
  SSH_PUB_KEY               = "b2b149a9-1a9c-4a45-b3c6-b1d400b48405"
  TAILSCALE_OAUTH_CLIENT_ID = "6577c828-7802-4246-8762-b27000f030e9"
  TAILSCALE_OAUTH_SECRET    = "ce78265d-a7b9-4fbf-958b-b27000f04bef"
  TAILSCALE_TAILNET         = "05f7568d-67a7-43c3-b91a-b27001095440"
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

module "infra" {
  source      = "./modules/repository"
  description = "Infrastructure as a code"
  name        = "infra"
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubernetes", "flux", "gitops"]

  secrets = [
    { name = "BITWARDEN_TOKEN", secret_id = local.BITWARDEN_TOKEN },
    { name = "BW_ACCESS_TOKEN", secret_id = local.BW_ACCESS_TOKEN },
    { name = "DISCORD_WEBHOOK_FLUX_EU_1", secret_id = local.DISCORD_WEBHOOK_FLUX_EU_1 },
    { name = "DISCORD_WEBHOOK_SYSTEMS", secret_id = local.DISCORD_WEBHOOK_SYSTEMS },
    { name = "GOOGLE_CREDENTIALS", secret_id = local.GOOGLE_CREDENTIALS },
    { name = "GOOGLE_PROJECT_ID", secret_id = local.GOOGLE_PROJECT_ID },
    { name = "LINODE_TOKEN", secret_id = local.LINODE_TOKEN },
    { name = "OCI_FINGERPRINT", secret_id = local.OCI_FINGERPRINT },
    { name = "OCI_PEM_PRV", secret_id = local.OCI_PEM_PRV },
    { name = "OCI_TENANCY_OCID", secret_id = local.OCI_TENANCY_OCID },
    { name = "OCI_USER_OCID", secret_id = local.OCI_USER_OCID },
    { name = "PG_CONN_STR", secret_id = local.PG_CONN_STR },
    { name = "PAT", secret_id = local.PAT },
    { name = "SSH_PUB_KEY", secret_id = local.SSH_PUB_KEY },
    { name = "TAILSCALE_OAUTH_CLIENT_ID", secret_id = local.TAILSCALE_OAUTH_CLIENT_ID },
    { name = "TAILSCALE_OAUTH_SECRET", secret_id = local.TAILSCALE_OAUTH_SECRET },
    { name = "TAILSCALE_TAILNET", secret_id = local.TAILSCALE_TAILNET },
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

  required_status_checks = [
    "DCO",
    "pr-title",
    "linters",
    "chart-testing",
    "unittest",
    "e2e",
  ]

  labels = [
    { name = "area/dependency", color = "0052cc", description = "Issues or PRs related to dependency changes." },
    { name = "do-not-merge", color = "e11d21", description = "Indicates that a PR should not merge." },
    { name = "kind/bug", color = "e11d21", description = "Categorizes issue or PR as related to a bug." },
    { name = "kind/documentation", color = "c7def8", description = "Categorizes issue or PR as related to documentation." },
    { name = "kind/feature", color = "c7def8", description = "Categorizes issue or PR as related to a new feature." },
    { name = "kind/security", color = "e11d21", description = "Categorizes issue or PR as related to a security." },
    { name = "kind/support", color = "c7def8", description = "Categorizes issue or PR as support-related." },
    { name = "good first issue", color = "7057ff", description = "Denotes an issue ready for a new contributor, according to the \"help wanted\" guidelines." },
    { name = "help wanted", color = "006b75", description = "Denotes an issue that needs help from a contributor. Must meet \"help wanted\" guidelines." },
    { name = "autorelease: pending", color = "ffdd66", description = "Indicates that a release is pending." },
    { name = "autorelease: tagged", color = "ffdd66", description = "Indicates that a release has been tagged." },
    { name = "autorelease: snapshot", color = "ffdd66", description = "Indicates that a snapshot release is available." },
    { name = "autorelease: published", color = "ffdd66", description = "Indicates that a release has been published." },
  ]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
    { name = "GPG_KEYRING_BASE64", secret_id = local.GPG_KEYRING_BASE64 },
    { name = "GPG_PASSPHRASE", secret_id = local.GPG_PASSPHRASE },
    { name = "COMMIT_SIGNING", secret_id = local.COMMIT_SIGNING },
  ]
}

module "kubelet-device-plugins" {
  source      = "./modules/repository"
  name        = "kubelet-device-plugins"
  description = "Minimal device plugins integrating linux devices into Kubernetes."
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "kubelet", "kvm", "tap", "tun"]

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

module "docker-library" {
  source      = "./modules/repository"
  name        = "docker-library"
  description = ""
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "docker"]

  required_status_checks = [
    "DCO",
    "pr-title",
  ]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
  ]
}

module "website" {
  source       = "./modules/repository"
  name         = "anza-labs.github.io"
  description  = ""
  archived     = false
  is_public    = true
  topics       = ["blog"]
  enable_pages = true
  homepage_url = "anza-labs.dev"

  required_status_checks = [
    "DCO",
    "pr-title",
  ]

  labels = [
    { name = "area/dependency", color = "0052cc", description = "Issues or PRs related to dependency changes." },
    { name = "content/page", color = "f658b8", description = "Issues or PRs related to page content updates." },
    { name = "content/blog-post", color = "f658b8", description = "Issues or PRs related to blog post content." },
  ]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
  ]
}

module "cosi-sample-app" {
  source      = "./modules/repository"
  name        = "cosi-sample-app"
  description = ""
  archived    = false
  is_public   = true
  topics      = ["hacktoberfest", "container-object-storage-interface", "object-storage"]

  labels = [
    { name = "area/dependency", color = "0052cc", description = "Issues or PRs related to dependency changes." },
    { name = "do-not-merge", color = "e11d21", description = "Indicates that a PR should not merge." },
  ]

  required_status_checks = [
    "DCO",
    "pr-title",
    "lint",
    "hadolint",
  ]

  secrets = [
    { name = "PAT", secret_id = local.PAT },
  ]
}
