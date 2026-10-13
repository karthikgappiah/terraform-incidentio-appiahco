#!/usr/bin/env python3
"""Fire one scenario from alerts.json, wait, then resolve it with the SAME dedup key.

send_alerts.py makes a new dedup key on every send, so its "resolve" never
matches the alert it should close. This script keeps the key, so you can see
the route cancel the escalation and decline the triage incident.

    uv run --env-file .env --with requests scripts/fire_and_resolve.py 3 --wait 90
"""

import argparse
import json
import os
import sys
import time
import uuid
from pathlib import Path

import requests

ALERTS = json.loads((Path(__file__).parent / "alerts.json").read_text())

parser = argparse.ArgumentParser()
parser.add_argument("scenario", choices=sorted(ALERTS))
parser.add_argument("--wait", type=int, default=90, help="seconds between firing and resolving")
args = parser.parse_args()

url = os.environ.get("INCIDENT_IO_ALERT_SOURCE_URL")
token = os.environ.get("INCIDENT_IO_API_TOKEN")
if not url or not token:
    sys.exit("Set INCIDENT_IO_ALERT_SOURCE_URL and INCIDENT_IO_API_TOKEN (see .env).")

scenario = ALERTS[args.scenario]
payload = json.loads(json.dumps(scenario["data"]))
payload["deduplication_key"] = f"netflix-{payload['metadata']['service']}-{uuid.uuid4().hex[:8]}"


def send(status):
    payload["status"] = status
    resp = requests.post(url, json=payload, headers={"Authorization": f"Bearer {token}"}, timeout=10)
    print(f"{time.strftime('%H:%M:%S')}  {status:8}  {resp.status_code}  dedup={payload['deduplication_key']}")
    if not resp.ok:
        sys.exit(resp.text)


print(f"Scenario {args.scenario}: {scenario['name']}")
send("firing")
print(f"Waiting {args.wait}s. Watch the escalation and incident appear...")
time.sleep(args.wait)
send("resolved")
print("Resolved. The escalation should now be cancelled and the triage incident declined.")
