variable "username" {
  description = "Username of the team member"
  type        = string
}

variable "role" {
  description = "Role assigned to the user, such as 'member' or 'admin'"
  type        = string
  default     = "member"
}
