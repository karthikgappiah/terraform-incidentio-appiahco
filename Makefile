# check runs offline. plan, drift and apply call incident.io, with secrets read from .env.
.PHONY: check plan drift apply

TF = cd terraform && set -a && . ../.env && set +a && terraform

check:
	terraform -chdir=terraform fmt -check -recursive
	terraform -chdir=terraform validate -no-color

# Leaves the account untouched: imports don't claim (lock) dashboard objects.
plan:
	$(TF) plan -var claim_on_import=false

# Exit 0 when the workspace matches the code, 2 when it has drifted.
drift:
	$(TF) plan -var claim_on_import=false -detailed-exitcode -no-color > /dev/null && echo "No drift."

apply:
	$(TF) apply
