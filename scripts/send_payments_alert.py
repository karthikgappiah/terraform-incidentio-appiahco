#!/usr/bin/env python3
"""Send one critical alert for the Payments team, which exists only in Terraform.

Nothing about Payments is configured in the dashboard: if this alert pages
Payments on-call and opens a Major incident, the Terraform change worked.

    uv run --env-file .env --with requests scripts/send_payments_alert.py
"""

import os
import sys
import uuid

import requests

url = os.environ.get("INCIDENT_IO_ALERT_SOURCE_URL")
token = os.environ.get("INCIDENT_IO_API_TOKEN")
if not url or not token:
    sys.exit("Set INCIDENT_IO_ALERT_SOURCE_URL and INCIDENT_IO_API_TOKEN (see .env).")

payload = {
    "title": "Critical: Payment authorisations failing in US-EAST-1",
    "status": "firing",
    "description": "Card authorisations through the payments gateway are failing. New sign-ups and plan changes cannot be charged.",
    "source_url": "https://datadog.netflix.com/alerts/payments-gateway-auth-failures",
    "deduplication_key": f"netflix-payments-gateway-{uuid.uuid4().hex[:8]}",
    "metadata": {
        "service": "payments-gateway",
        "severity": "critical",
        "environment": "production",
        "region": "us-east-1",
        "team_owner": "payments-platform",
        "runbook_url": "https://runbooks.netflix.com/payments/gateway-auth-failures",
    },
}

resp = requests.post(url, json=payload, headers={"Authorization": f"Bearer {token}"}, timeout=10)
print(f"{resp.status_code} {'SUCCESS' if resp.ok else 'FAILED'}  dedup={payload['deduplication_key']}")
if not resp.ok:
    print(resp.text)
    sys.exit(1)
