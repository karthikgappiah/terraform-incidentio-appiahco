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

# Urgent: page the team's on-call schedule at high urgency, then hand to SRE
# after 5 minutes. Anything lower: notify whoever is on call at low urgency.
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
      nodes = [{
        id = "01M4P1QDPZ8VR9K427G8HF4KNZ"
        branch = {
          if   = { priority_one_of = [local.priority_urgent] }
          then = "main_then"
          else = "main_else"
        }
      }]
    }

    main_then = {
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

    main_else = {
      nodes = [{
        id = "01M4P1TXR99MA80A239KMSZHEF"
        level = {
          ack_mode            = "first"
          time_to_ack_seconds = 300
          targets = [{
            type    = "user"
            urgency = "low"
            binding = {
              array_value = [{ reference = "${local.schedule_param}.catalog_attribute[\"currently_on_call\"]" }]
            }
          }]
        }
      }]
    }
  }
}

# Urgent: page SRE on-call at high urgency, and repeat twice if nobody acks.
# Anything lower: page SRE on-call at low urgency.
resource "incident_escalation_path" "sre" {
  name          = "SRE"
  kind          = "standalone"
  team_ids      = [incident_catalog_entries.team.entries["sre"].id]
  start         = "main"
  working_hours = local.working_hours

  sequences = {
    main = {
      nodes = [{
        id = "01M4P226Q6WVKRMPFJ5K34DGK8"
        branch = {
          if   = { priority_one_of = [local.priority_urgent] }
          then = "main_then"
          else = "main_else"
        }
      }]
    }

    main_then = {
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
          loop = { back_to = "01M4P226Q6WVKRMPFJ5K34DGK8", times = 2 }
        },
      ]
    }

    main_else = {
      nodes = [{
        id = "01M4P22EJ606MFRZT8Z501514W"
        level = {
          ack_mode            = "first"
          time_to_ack_seconds = 300
          targets = [{
            type          = "schedule"
            id            = incident_schedule.team["sre"].id
            schedule_mode = "currently_on_call"
            urgency       = "low"
          }]
        }
      }]
    }
  }
}
