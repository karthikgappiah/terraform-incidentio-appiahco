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
