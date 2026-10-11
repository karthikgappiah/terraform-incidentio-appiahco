# check runs offline: no API calls, no secrets needed.
.PHONY: check

check:
	terraform -chdir=terraform fmt -check -recursive
	terraform -chdir=terraform validate -no-color
