variable "name" {
  description = "Name of the team"
  type        = string
}

variable "privacy" {
  description = "Privacy setting"
  type        = string
  default     = "secret"
}

variable "members" {
  description = "List of team members, each with a specified username and optional role"
  type = list(object({
    username = string
    role     = optional(string, "member")
  }))
  default = []
}
