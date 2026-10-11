# One block per team in teams.yaml. Adding a team adds all three.

resource "incident_schedule" "team" {
  for_each = local.teams

  name     = "${each.value.name} on-call"
  timezone = local.timezone
  team_ids = [incident_catalog_entries.team.entries[each.key].id]

  holidays_public_config = {
    country_codes = local.holiday_country
  }
}

resource "incident_schedule_rotation" "team" {
  for_each = local.teams

  schedule_id              = incident_schedule.team[each.key].id
  name                     = "Rotation"
  users                    = [for e in each.value.on_call : data.incident_user.by_email[e].id]
  first_interval_starts_at = local.rotation_start
  concurrent_shifts        = 1

  handovers = [{
    interval      = 1
    interval_type = "weekly"
  }]
}

# Each product team's path is the shared template with its own schedule
# plugged in. Change the template once and every team's path follows.
resource "incident_escalation_path" "team" {
  for_each = local.product_teams

  name        = each.value.name
  kind        = "templated"
  template_id = incident_escalation_path_template.team_then_sre.id
  team_ids    = [incident_catalog_entries.team.entries[each.key].id]

  param_bindings = {
    (local.schedule_param) = {
      value = { literal = incident_schedule.team[each.key].id }
    }
  }
}
