# How a page climbs. Product teams share one template; SRE, the backstop,
# has its own path.

locals {
  # The template's one setting: which schedule to page.
  schedule_param = "schedule_01m4n42r29dag1txftfx21x0jq"

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

# Page the team's on-call schedule at high urgency, then hand to SRE after
# 5 minutes. Use for every product team.
resource "incident_escalation_path_template" "team_then_sre" {
  name        = "Team on-call, then SRE backstop"
  description = "Pages owning team's on-call; if no ack within 5m, hands over to SRE. Use for every product team."

  params = {
    (local.schedule_param) = {
      label    = "Team schedule"
      type     = "CatalogEntry[\"Schedule\"]"
      array    = false
      optional = false
    }
  }

  start         = "main"
  working_hours = local.working_hours

  sequences = {
    main = {
      nodes = [
        {
          id = "01M4N3VABBR6MQJ01H8XVSTE71"
          level = {
            ack_mode            = "first"
            time_to_ack_seconds = 300
            targets = [{
              type          = "schedule"
              schedule_mode = "currently_on_call"
              urgency       = "high"
              binding       = { value = { reference = local.schedule_param } }
            }]
          }
        },
        {
          id              = "01M4N46PX0HM4NJ65TJZWJ7E7K"
          escalation_path = { escalation_path_id = incident_escalation_path.sre.id }
        },
      ]
    }
  }
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
