#!/usr/bin/env python3
"""Send one critical alert for the Ads team, which exists only in Terraform.

Nothing about Ads is configured in the dashboard, and the alert has no team_owner:
the Catalog says Ads owns ads-delivery-service. If this pages Ads on-call
and opens a Major incident, the Terraform change worked.

    uv run --env-file .env --with requests scripts/send_ads_alert.py
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
    "title": "Critical: Ad insertion failing for ad-supported plans in EU-WEST-1",
    "status": "firing",
    "description": "Ad decisioning is timing out, so ad breaks are skipped on the Standard with Ads plan. Ad revenue is being lost.",
    "source_url": "https://datadog.netflix.com/alerts/ads-delivery-timeouts",
    "deduplication_key": f"netflix-ads-delivery-service-{uuid.uuid4().hex[:8]}",
    "metadata": {
        "service": "ads-delivery-service",
        "severity": "critical",
        "environment": "production",
        "region": "eu-west-1",
        "runbook_url": "https://runbooks.netflix.com/ads/delivery-timeouts",
    },
}

resp = requests.post(url, json=payload, headers={"Authorization": f"Bearer {token}"}, timeout=10)
print(f"{resp.status_code} {'SUCCESS' if resp.ok else 'FAILED'}  dedup={payload['deduplication_key']}")
if not resp.ok:
    print(resp.text)
    sys.exit(1)
