locals {
  teams = yamldecode(file("${path.module}/teams.yaml"))

  # Every person named in teams.yaml, looked up once.
  emails = toset(flatten([for t in local.teams : concat(t.members, t.on_call)]))

  # Shared defaults for every on-call schedule.
  timezone        = "America/Los_Angeles"
  rotation_start  = "2026-10-05T16:00:00Z" # a Monday, 09:00 Pacific
  holiday_country = ["US"]
}

data "incident_user" "by_email" {
  for_each = local.emails
  email    = each.value
}
