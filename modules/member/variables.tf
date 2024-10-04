variable "username" {
  type = string
}

variable "role" {
  type        = string
  description = "Role assigned to the user"
  default     = "member"
}
