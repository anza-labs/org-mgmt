resource "github_repository" "repo" {
  name               = var.name
  description        = var.description
  visibility         = var.is_public ? "public" : "private"
  archived           = var.archived
  topics             = var.topics
  homepage_url       = var.homepage_url
  auto_init          = var.auto_init
  archive_on_destroy = var.archive_on_destroy

  has_discussions = false
  has_issues      = true
  has_wiki        = false
  has_projects    = true

  allow_update_branch         = true
  allow_auto_merge            = true
  allow_squash_merge          = true
  allow_merge_commit          = false
  allow_rebase_merge          = false
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"

  dynamic "pages" {
    for_each = var.enable_pages ? [1] : []
    content {
      cname = !strcontains(var.homepage_url, "github.io") ? var.homepage_url : null
      source {
        branch = "gh-pages"
        path   = "/"
      }
    }
  }
}

resource "github_issue_labels" "labels" {
  repository = github_repository.repo.name
  depends_on = [github_repository.repo]

  dynamic "label" {
    for_each = var.labels
    content {
      name        = label.value.name
      description = label.value.description
      color       = label.value.color
    }
  }
}

resource "github_branch_protection_v3" "protection" {
  count      = var.is_public ? 1 : 0
  repository = github_repository.repo.name
  branch     = "main"

  enforce_admins                  = false
  require_signed_commits          = true
  require_conversation_resolution = true

  required_status_checks {
    strict = true
    checks = var.required_status_checks
  }

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    require_last_push_approval      = false
  }
}

resource "github_repository_milestone" "milestone" {
  for_each = var.milestones

  owner      = "anza-labs"
  repository = github_repository.repo.name
  title      = each.value
}

data "bitwarden_secret" "secrets" {
  for_each = { for s in var.secrets : s.name => s }
  id       = each.value.secret_id
}

resource "github_actions_secret" "secrets" {
  for_each        = data.bitwarden_secret.secrets
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = each.value.value
}
