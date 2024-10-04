variable "name" {
  description = "Name of the team"
  type        = string
}

variable "members" {
  type = list(object({
    username = string
    role     = optional(string, "member")
  }))
  default = []
}
