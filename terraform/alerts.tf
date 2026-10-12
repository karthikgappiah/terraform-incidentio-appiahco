# Where alerts come in, what we read from them, and where they go.

resource "incident_alert_source" "netflix_monitoring" {
  name                         = "Netflix Monitoring"
  source_type                  = "http"
  is_private                   = false
  auto_resolve_incident_alerts = true

  title       = { literal = "{{title}}" }
  description = { literal = "{{description}}" }
}

resource "incident_alert_attribute" "service" {
  name     = "Service"
  type     = "CatalogEntry[\"${incident_catalog_type.service.id}\"]"
  array    = false
  required = false
}

locals {
  # The built-in Team alert attribute.
  team_attribute_id = "01M4MXHV3FB9PK0GPN2VKXFRGH"
}

# Service: metadata.service, matched against the Service Catalog.
resource "incident_alert_source_attribute" "service" {
  alert_source_id    = incident_alert_source.netflix_monitoring.id
  alert_attribute_id = incident_alert_attribute.service.id
  merge_strategy     = "first_wins"
  expression_ref     = "880f720d"

  named_expression {
    name       = "880f720d"
    label      = "Service"
    start_from = "payload"
    operation {
      parse = {
        function = "$.metadata.service"
        as       = incident_alert_attribute.service.type
      }
    }
  }
}

# Team: metadata.team_owner, matched against the Team Catalog (names or
# aliases).
resource "incident_alert_source_attribute" "team" {
  alert_source_id    = incident_alert_source.netflix_monitoring.id
  alert_attribute_id = local.team_attribute_id
  merge_strategy     = "first_wins"
  expression_ref     = "eda36efa"

  named_expression {
    name       = "eda36efa"
    label      = "Team"
    start_from = "payload"
    operation {
      parse = {
        function = "$.metadata.team_owner"
        as       = "CatalogEntry[\"${incident_catalog_type.team.id}\"]"
      }
    }
  }
}

# One route for every team. It never names a team: it follows the alert's
# Team to that team's escalation path, and falls back to SRE.
resource "incident_alert_route" "netflix_production" {
  name            = "Netflix production"
  enabled         = true
  is_private      = false
  owning_team_ids = [incident_catalog_entries.team.entries["sre"].id]

  alert_sources = [{
    alert_source_id  = incident_alert_source.netflix_monitoring.id
    condition_groups = []
  }]
  condition_groups = []

  expressions = [{
    label          = "Alert → Attributes → Team  → Escalation paths"
    reference      = "01M4N8BWY2C6H2S6JD6EKCTC9F"
    root_reference = "alert.attributes.${local.team_attribute_id}"
    operations = [{
      operation_type = "navigate"
      navigate       = { reference = "catalog_attribute[\"escalation_paths\"]" }
    }]
    else_branch = {
      result = { array_value = [{ literal = incident_escalation_path.sre.id }] }
    }
  }]

  escalation_config = {
    auto_cancel_escalations = true
    escalation_targets = [{
      escalation_paths = {
        array_value = [{ reference = "expressions[\"01M4N8BWY2C6H2S6JD6EKCTC9F\"]" }]
      }
    }]
    when_alert_joins_group = { mode = "on_priority_increase" }
  }

  message_config = {}
}
