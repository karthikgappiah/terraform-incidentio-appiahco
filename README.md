# terraform-incidentio-appiahco

Netflix alert routing on incident.io (workspace `appiahcompany`), managed by Terraform. This is the Terraform behind the Solutions Engineer take-home demo.

## What it does

An alert from Netflix's monitoring tool takes one path:

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

There is one source, one route and one path template. A team or a service is a row in YAML.

The resources are declared in [terraform-incidentio-alert-routing](https://github.com/karthikgappiah/terraform-incidentio-alert-routing). This repo is the Netflix call to it:

| File | Holds |
| --- | --- |
| `terraform/teams.yaml` | Every team: name, aliases, members, who is on call |
| `terraform/services.yaml` | Every service: owner, tier, lifecycle |
| `terraform/main.tf` | The module call: names, timezone, rotation start |
| `terraform/moved.tf` | Maps the old inline resources into the module, so nothing is recreated |
| `terraform/imports.tf` | Objects first built in the dashboard, adopted into state |
| `terraform/versions.tf` | Provider pin and `claim_on_import` |

### Onboarding a team

Add a block to `teams.yaml` and its services to `services.yaml`, then `make apply`. Ads and Payments were onboarded this way, with no change to the route, source or templates.

## Running it

Needs Terraform 1.7 or later and an incident.io API key in `.env` as `INCIDENT_API_KEY` (gitignored, never printed).

```bash
make check    # offline lint, no API calls
make plan     # compares code to the workspace, leaves it untouched
make drift    # exit 0 when matching, 2 when drifted
make apply    # the only target that changes the account
```

`make plan` passes `claim_on_import=false` so reviewing a plan never locks dashboard objects. `scripts/` fires the six take-home scenarios plus Payments and Ads alerts; those post to Slack and page people.

## How it was built

The workspace was first built by hand in the dashboard, one lesson at a time, then adopted into Terraform. The history re-tells that build-up as one reviewed change per step, in the order the pieces were learned:

1. **Foundations**: provider pin, `make check`, the HTTP alert source, the six scenarios
2. **The on-call model**: Team catalog, schedules and rotations, the SRE path, the team-then-SRE template
3. **Catalog and one dynamic route**: Service type, Team and Service attributes, the route
4. **Priority and urgency**: priority from severity, urgency decided by the path
5. **Ownership on the source**: Tier and Lifecycle, the deprecated service, Owner fallback
6. **Incidents and grouping**: runbook attribute, incident template, incident creation, grouping by Service
7. **Terraform the workspace**: `claim_on_import`, import blocks, then Payments and Ads as YAML-only changes
8. **A module**: the design extracted to its own repo and called from here, with `moved` blocks so the plan stays empty

Each step is an issue, a PR and one Conventional Commit. See `AGENTS.md`.

## Provenance

`scripts/send_alerts.py` and `scripts/alerts.json` come unchanged from the incident.io take-home kit.
