# AGENTS.md

Netflix alert routing on incident.io (workspace `appiahcompany`), managed by Terraform in `terraform/`.

## Conventions

- **Atomic**: every issue, commit and PR covers one concern. Never bundle unrelated changes.
- **Conventional Commits**: every issue title, commit message and PR title follows the [Conventional Commits](https://www.conventionalcommits.org) spec (`type(scope)!: description`).

## Secrets

- Secrets live in `.env` (mode 600, gitignored). Use them by reference only: `uv run --env-file .env`, `make plan`. Keep values out of output, and out of chat.
- Never commit state. `terraform/*.tfstate*` is gitignored; it holds resolved IDs and is a secret in practice.

## Commands

- `make check`: offline lint (Terraform fmt and validate).
- `make plan` / `make drift` / `make apply`: Terraform with `.env` loaded. `plan` and `drift` leave the account untouched.
- `scripts/send_alerts.py`: fire the six Netflix scenarios at the alert source. Each one posts to Slack and pages people. Run it with `uv run --env-file .env --with requests scripts/send_alerts.py`.
