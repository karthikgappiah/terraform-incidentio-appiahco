# How a page climbs. Product teams share one template; SRE, the backstop,
# has its own path.

locals {
  working_hours = [{
    id       = "default"
    name     = "Working hours"
    timezone = local.timezone
    weekday_intervals = [
      for day in ["monday", "tuesday", "wednesday", "thursday", "friday"] : {
        weekday    = day
        start_time = "09:00"
        end_time   = "17:00"
      }
    ]
  }]
}

# Page SRE on-call at high urgency, and repeat twice if nobody acks.
resource "incident_escalation_path" "sre" {
  name          = "SRE"
  kind          = "standalone"
  team_ids      = [incident_catalog_entries.team.entries["sre"].id]
  start         = "main"
  working_hours = local.working_hours

  sequences = {
    main = {
      nodes = [
        {
          id = "01M4N3F7T61CQGZTGW9QDM3M0Z"
          level = {
            ack_mode            = "first"
            time_to_ack_seconds = 300
            targets = [{
              type          = "schedule"
              id            = incident_schedule.team["sre"].id
              schedule_mode = "currently_on_call"
              urgency       = "high"
            }]
          }
        },
        {
          id   = "01M4N3F7T6ZD63PWY3E04ZNFX6"
          loop = { back_to = "01M4N3F7T61CQGZTGW9QDM3M0Z", times = 2 }
        },
      ]
    }
  }
}
