resource "github_team" "team" {
  name = var.name
}

resource "github_team_members" "members" {
  team_id = github_team.team.id
  count   = length(var.members) == 0 ? 0 : 1

  dynamic "members" {
    for_each = var.members
    content {
      username = members.value.username
      role     = members.value.role
    }
  }
}
