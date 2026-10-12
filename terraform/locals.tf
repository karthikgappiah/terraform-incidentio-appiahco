locals {
  teams    = yamldecode(file("${path.module}/teams.yaml"))
  services = yamldecode(file("${path.module}/services.yaml"))

  # Product teams get their escalation path from the shared template.
  product_teams = { for k, t in local.teams : k => t if !try(t.backstop, false) }

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
