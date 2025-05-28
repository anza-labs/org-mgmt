resource "github_repository" "repo" {
  name               = var.name
  description        = var.description
  visibility         = var.is_public ? "public" : "private"
  archived           = var.archived
  topics             = var.topics
  homepage_url       = var.homepage_url
  archive_on_destroy = var.archive_on_destroy
  has_issues         = var.enable_issues

  has_discussions = false
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

locals {
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
    { name = "Review effort 1/5", color = "d1bcf9", description = "qodo-merge: auto-labels" },
    { name = "Review effort 2/5", color = "d1bcf9", description = "qodo-merge: auto-labels" },
    { name = "Review effort 3/5", color = "d1bcf9", description = "qodo-merge: auto-labels" },
    { name = "Review effort 4/5", color = "d1bcf9", description = "qodo-merge: auto-labels" },
    { name = "Review effort 5/5", color = "d1bcf9", description = "qodo-merge: auto-labels" },
  ]
}

resource "github_issue_labels" "labels" {
  repository = github_repository.repo.name
  depends_on = [github_repository.repo]

  dynamic "label" {
    for_each = distinct(concat(var.labels, local.labels))
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
