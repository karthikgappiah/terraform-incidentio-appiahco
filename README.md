# terraform-incidentio-appiahco

[![CI](https://github.com/karthikgappiah/terraform-incidentio-appiahco/actions/workflows/ci.yml/badge.svg)](https://github.com/karthikgappiah/terraform-incidentio-appiahco/actions/workflows/ci.yml)

Infrastructure as code for Netflix alert routing on [incident.io](https://incident.io) (workspace `appiahcompany`). It declares the alert source, the on-call model, the Catalog, the route and the incident template, so the whole path from monitoring alert to page can be reviewed, planned and applied like any other change.

## Overview

An alert from the monitoring tool takes one path:

```
Netflix Monitoring (HTTP source)
  → attributes   Team ← metadata.team_owner, else the Service's Owner
                 Service ← metadata.service
                 Priority ← metadata.severity, unknown means Urgent
  → one route    Alert → Team → Escalation paths, else SRE
  → path         Urgent: team on-call at high urgency, 5m, then SRE
                 lower:  team on-call at low urgency
  → incident     Urgent only; severity from the Service's Tier; grouped by Service for 30m
```

There is one source, one route and one escalation path template. A team or a service is a row in YAML.

The resources are defined in the reusable module [terraform-incidentio-alert-routing](https://github.com/karthikgappiah/terraform-incidentio-alert-routing). This repository is the Netflix configuration that calls it.

## Repository layout

| Path | Purpose |
| --- | --- |
| `terraform/teams.yaml` | Every team: name, aliases, members, who is on call |
| `terraform/services.yaml` | Every service: owner, tier, lifecycle |
| `terraform/main.tf` | The module call: names, timezone, rotation start |
| `terraform/moved.tf` | `moved` blocks mapping earlier inline resources into the module, so nothing is recreated |
| `terraform/imports.tf` | `import` blocks adopting objects first created in the dashboard |
| `terraform/versions.tf` | Provider pin and the `claim_on_import` variable |
| `scripts/` | Test alert senders and workspace inspection helpers |
| `Makefile` | `check`, `plan`, `drift`, `apply`, `status` |

## Prerequisites

- Terraform 1.7 or later
- An incident.io API key with permission to manage the resources above, exported as `INCIDENT_API_KEY` or stored in a gitignored `.env`
- Python 3 with [uv](https://docs.astral.sh/uv/) to run the test alert scripts (optional)

## Usage

```bash
make check    # fmt and validate; offline, no API calls
make plan     # compare code to the workspace; changes nothing
make drift    # exit 0 when matching, 2 when drifted
make apply    # the only target that changes the workspace
```

`make plan` runs with `claim_on_import=false`, so reviewing a plan never locks objects that are still managed in the dashboard.

## Configuration

### Onboard a team

Add the team to `terraform/teams.yaml` and its services to `terraform/services.yaml`, then run `make plan` and `make apply`. The route, source and templates are not touched.

```yaml
# teams.yaml
payments:
  name: Payments
  aliases: [payments-platform]
  members: [oncall@example.com]
  on_call: [oncall@example.com]
```

```yaml
# services.yaml
checkout-api:
  owner: payments
  tier: tier-1
  lifecycle: production
```

### Change behaviour

Names, timezone, rotation start and holiday calendars are inputs of the module call in `terraform/main.tf`. See the module's [input reference](https://github.com/karthikgappiah/terraform-incidentio-alert-routing#inputs) for the rest.

### Upgrade the module

Change the `ref` in the module `source` to a newer tag, run `make plan`, and review the diff before applying.

## Testing alerts

`scripts/` contains senders for sample alert scenarios, including Payments and Ads. They post to the real alert source, so each one notifies Slack and pages the on-call engineer. Run them against a workspace where that is acceptable.

```bash
uv run --env-file .env --with requests scripts/send_alerts.py
```

## Continuous integration

Every push and pull request runs `make check` through GitHub Actions. Applies are run manually with `make apply`.

## Contributing

Changes are made by pull request. Issue titles, commit messages and PR titles follow [Conventional Commits](https://www.conventionalcommits.org), and each covers one concern. See [AGENTS.md](AGENTS.md) for the working conventions.

## Notes

`scripts/send_alerts.py` and `scripts/alerts.json` are the vendor-provided sample alert sender and payloads, kept unchanged.
