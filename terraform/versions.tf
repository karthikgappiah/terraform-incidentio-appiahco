terraform {
  required_version = ">= 1.7"

  required_providers {
    incident = {
      source  = "incident-io/incident"
      version = "7.6.1"
    }
  }
}

# Importing a resource marks it "managed by Terraform", which locks it in the
# dashboard. That happens during plan, not apply. Pass
# -var claim_on_import=false for a plan that leaves the account untouched.
variable "claim_on_import" {
  type    = bool
  default = true
}

# The API key comes from the INCIDENT_API_KEY environment variable,
# loaded from ../.env at run time. It is never written in this folder.
provider "incident" {
  mark_imported_resources_as_managed = var.claim_on_import
}
