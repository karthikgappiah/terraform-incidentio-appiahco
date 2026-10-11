# AGENTS.md

Netflix alert routing on incident.io (workspace `appiahcompany`), managed by Terraform in `terraform/`.

## Conventions

- **Atomic**: every issue, commit and PR covers one concern. Never bundle unrelated changes.
- **Conventional Commits**: every issue title, commit message and PR title follows the [Conventional Commits](https://www.conventionalcommits.org) spec (`type(scope)!: description`).

## Secrets

- Secrets live in `.env` (mode 600, gitignored). Use them by reference only: `uv run --env-file .env`, `make plan`. Keep values out of output, and out of chat.
- Never commit state. `terraform/*.tfstate*` is gitignored; it holds resolved IDs and is a secret in practice.
