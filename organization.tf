resource "github_organization_settings" "anza_labs" {
  billing_email = "mateusz.urbanek.98@gmail.com"
  name          = "anza-labs"

  default_repository_permission = "read"
  has_organization_projects     = true
  has_repository_projects       = true
  web_commit_signoff_required   = false

  members_can_create_pages                 = true
  members_can_create_public_pages          = true
  members_can_create_private_pages         = false
  members_can_create_repositories          = false
  members_can_create_public_repositories   = false
  members_can_create_internal_repositories = false
  members_can_create_private_repositories  = false
  members_can_fork_private_repositories    = false

  dependabot_alerts_enabled_for_new_repositories           = true
  dependabot_security_updates_enabled_for_new_repositories = true
  dependency_graph_enabled_for_new_repositories            = true

  secret_scanning_enabled_for_new_repositories                 = true
  secret_scanning_push_protection_enabled_for_new_repositories = true
}

