variable "name" {
  description = "Name of the repository"
  type        = string
}

variable "description" {
  description = ""
  type        = string
  default     = ""
}

variable "homepage_url" {
  description = ""
  type        = string
  default     = ""
}

variable "archived" {
  description = ""
  type        = bool
}

variable "is_public" {
  description = ""
  type        = bool
  default     = false
}

variable "enable_pages" {
  description = ""
  type        = bool
  default     = false
}

variable "required_status_checks" {
  description = ""
  type        = list(string)
  default = [
    "DCO",
    "pr-title",
  ]
}

variable "topics" {
  description = ""
  type        = list(string)
  default = [
    "hacktoberfest",
  ]
}

variable "milestones" {
  description = ""
  type        = set(string)
  default     = []
}

variable "labels" {
  description = "List of labeles that are assigned to repository"
  type = list(object({
    name        = string
    color       = string
    description = string
  }))
  default = [
    { name = "area/dependency", color = "0052cc", description = "Issues or PRs related to dependency changes." },
    { name = "do-not-merge", color = "e11d21", description = "Indicates that a PR should not merge." },
    { name = "kind/bug", color = "e11d21", description = "Categorizes issue or PR as related to a bug." },
    { name = "kind/documentation", color = "c7def8", description = "Categorizes issue or PR as related to documentation." },
    { name = "kind/feature", color = "c7def8", description = "Categorizes issue or PR as related to a new feature." },
    { name = "good first issue", color = "7057ff", description = "Denotes an issue ready for a new contributor, according to the \"help wanted\" guidelines." },
    { name = "help wanted", color = "006b75", description = "Denotes an issue that needs help from a contributor. Must meet \"help wanted\" guidelines." },
  ]
}
