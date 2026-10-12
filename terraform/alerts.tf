# Where alerts come in, what we read from them, and where they go.

resource "incident_alert_source" "netflix_monitoring" {
  name                         = "Netflix Monitoring"
  source_type                  = "http"
  is_private                   = false
  auto_resolve_incident_alerts = true

  title       = { literal = "{{title}}" }
  description = { literal = "{{description}}" }
}
