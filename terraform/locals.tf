locals {
  teams = yamldecode(file("${path.module}/teams.yaml"))

  # Every person named in teams.yaml, looked up once.
  emails = toset(flatten([for t in local.teams : t.members]))
}

data "incident_user" "by_email" {
  for_each = local.emails
  email    = each.value
}
