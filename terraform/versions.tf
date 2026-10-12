terraform {
  required_version = ">= 1.7"

  required_providers {
    incident = {
      source  = "incident-io/incident"
      version = "7.6.1"
    }
  }
}

# The API key comes from the INCIDENT_API_KEY environment variable,
# loaded from ../.env at run time. It is never written in this folder.
provider "incident" {}
