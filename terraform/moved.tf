# The resources used to be declared in this folder. They now live in the module,
# and these blocks tell Terraform it is the same objects, so the plan shows no
# changes and nothing is destroyed or recreated.

moved {
  from = incident_alert_source.netflix_monitoring
  to   = module.alert_routing.incident_alert_source.source
}

moved {
  from = incident_alert_attribute.service
  to   = module.alert_routing.incident_alert_attribute.service
}

moved {
  from = incident_alert_attribute.runbook
  to   = module.alert_routing.incident_alert_attribute.runbook
}

moved {
  from = incident_alert_source_attribute.service
  to   = module.alert_routing.incident_alert_source_attribute.service
}

moved {
  from = incident_alert_source_attribute.team
  to   = module.alert_routing.incident_alert_source_attribute.team
}

moved {
  from = incident_alert_source_attribute.runbook
  to   = module.alert_routing.incident_alert_source_attribute.runbook
}

moved {
  from = incident_alert_route.netflix_production
  to   = module.alert_routing.incident_alert_route.this
}

moved {
  from = incident_incident_template.netflix_alert_incident
  to   = module.alert_routing.incident_incident_template.alert_incident
}

moved {
  from = incident_escalation_path_template.team_then_sre
  to   = module.alert_routing.incident_escalation_path_template.team_then_backstop
}

moved {
  from = incident_escalation_path.sre
  to   = module.alert_routing.incident_escalation_path.backstop
}

moved {
  from = incident_escalation_path.team
  to   = module.alert_routing.incident_escalation_path.team
}

moved {
  from = incident_schedule.team
  to   = module.alert_routing.incident_schedule.team
}

moved {
  from = incident_schedule_rotation.team
  to   = module.alert_routing.incident_schedule_rotation.team
}

moved {
  from = incident_catalog_type.team
  to   = module.alert_routing.incident_catalog_type.team
}

moved {
  from = incident_catalog_type.service
  to   = module.alert_routing.incident_catalog_type.service
}

moved {
  from = incident_catalog_type_attribute.service_owner
  to   = module.alert_routing.incident_catalog_type_attribute.service_owner
}

moved {
  from = incident_catalog_type_attribute.service_tier
  to   = module.alert_routing.incident_catalog_type_attribute.service_tier
}

moved {
  from = incident_catalog_type_attribute.service_lifecycle
  to   = module.alert_routing.incident_catalog_type_attribute.service_lifecycle
}

moved {
  from = incident_catalog_entries.team
  to   = module.alert_routing.incident_catalog_entries.team
}

moved {
  from = incident_catalog_entries.service
  to   = module.alert_routing.incident_catalog_entries.service
}
