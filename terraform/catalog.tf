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
