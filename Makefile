# check runs offline (and in the pre-commit hook, .githooks/pre-commit).
# plan, drift, apply and status call incident.io, with secrets read from .env.
.PHONY: check plan drift apply status hooks

TF = cd terraform && set -a && . ../.env && set +a && terraform

check:
	terraform -chdir=terraform fmt -check -recursive
	terraform -chdir=terraform validate -no-color
	bash -n scripts/inspect.sh
	python3 -m py_compile scripts/*.py

# Leaves the account untouched: imports don't claim (lock) dashboard objects.
plan:
	$(TF) plan -var claim_on_import=false

# Exit 0 when the workspace matches the code, 2 when it has drifted.
drift:
	$(TF) plan -var claim_on_import=false -detailed-exitcode -no-color > /dev/null && echo "No drift."

apply:
	$(TF) apply

# Firing alerts, live escalations, open incidents: all 0 when the workspace is clean.
status:
	scripts/inspect.sh status

hooks:
	git config core.hooksPath .githooks
