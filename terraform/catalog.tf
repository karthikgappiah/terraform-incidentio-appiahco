# The Catalog: who owns what. Alerts are matched to these entries, and the
# route reads the owning team's escalation path from them.

resource "incident_catalog_type" "team" {
  name                   = "Team"
  description            = "All teams within Appiah & Company."
  categories             = ["team"]
  type_name              = "Custom[\"Team\"]"
  source_repo_url        = ""
  use_name_as_identifier = true
}

resource "incident_catalog_type" "service" {
  name                   = "Service"
  description            = "Netflix production services and their owning team."
  categories             = ["service"]
  type_name              = "Custom[\"Service\"]"
  source_repo_url        = ""
  use_name_as_identifier = true
}

resource "incident_catalog_type_attribute" "service_owner" {
  catalog_type_id = incident_catalog_type.service.id
  name            = "Owner"
  type            = incident_catalog_type.team.type_name
  array           = false
  schema_only     = true
}

# Terraform owns team names, aliases and members.
resource "incident_catalog_entries" "team" {
  id                 = incident_catalog_type.team.id
  managed_attributes = ["members"]

  entries = {
    for k, t in local.teams : k => {
      name    = t.name
      aliases = t.aliases
      attribute_values = {
        members = {
          array_value = [for e in t.members : data.incident_user.by_email[e].id]
        }
      }
    }
  }
}

resource "incident_catalog_entries" "service" {
  id = incident_catalog_type.service.id

  # A service's owner must exist before the service can point at it.
  depends_on = [incident_catalog_entries.team]

  entries = {
    for k, s in local.services : k => {
      name    = k
      aliases = try(s.aliases, [])
      attribute_values = {
        (incident_catalog_type_attribute.service_owner.id) = { value = s.owner }
      }
    }
  }
}
