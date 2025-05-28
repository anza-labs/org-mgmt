variable "name" {
  description = "Name of the repository"
  type        = string
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = ""
}

variable "homepage_url" {
  description = "URL of the repository's homepage, if any"
  type        = string
  default     = ""
}

variable "archived" {
  description = "Whether the repository should be archived (true) or active (false)"
  type        = bool
}

variable "archive_on_destroy" {
  description = "Whether the repository should be archived when destroying."
  default     = true
  type        = bool
}

variable "is_public" {
  description = "Whether the repository is public (true) or private (false)"
  type        = bool
  default     = false
}

variable "enable_pages" {
  description = "Enable GitHub Pages for the repository (true to enable, false to disable)"
  type        = bool
  default     = false
}

variable "enable_issues" {
  description = "Enable issues for the repository (true to enable, false to disable)"
  type        = bool
  default     = true
}

variable "required_status_checks" {
  description = "List of required status checks for pull request merges"
  type        = list(string)
  default = [
    "DCO",
    "pr-title",
  ]
}

variable "topics" {
  description = "Topics associated with the repository for discoverability"
  type        = list(string)
  default = [
    "hacktoberfest",
  ]
}

variable "milestones" {
  description = "Milestones to be tracked within the repository"
  type        = set(string)
  default     = []
}

variable "labels" {
  description = "List of labels that are assigned to the repository for categorizing issues and pull requests"
  type = list(object({
    name        = string
    color       = string
    description = string
  }))
  default = []
}

variable "secrets" {
  description = "List of secrets with Bitwarden secret IDs and names for GitHub Actions secrets"
  type = list(object({
    secret_id = string
    name      = string
  }))
  default = []
}
