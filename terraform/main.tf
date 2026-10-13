# Every resource below lives in the module. This file is the whole call:
# teams and services are data, and the module turns them into the Catalog,
# on-call schedules, escalation paths, the alert source, the route and the
# incident template.

module "alert_routing" {
  source = "github.com/karthikgappiah/terraform-incidentio-alert-routing?ref=v0.1.1"

  teams    = yamldecode(file("${path.module}/teams.yaml"))
  services = yamldecode(file("${path.module}/services.yaml"))

  # A Monday, 09:00 Pacific, in the past so the first person is on call now.
  rotation_start        = "2026-10-05T16:00:00Z"
  timezone              = "America/Los_Angeles"
  holiday_country_codes = ["US"]

  alert_source_name        = "Netflix Monitoring"
  route_name               = "Netflix production"
  incident_template_name   = "Netflix alert incident"
  team_type_description    = "All teams within Appiah & Company."
  service_type_description = "Netflix production services and their owning team."

  affected_teams_custom_field_name = "Affected teams"
}
