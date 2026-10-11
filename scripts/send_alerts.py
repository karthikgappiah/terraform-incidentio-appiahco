#!/usr/bin/env python3
"""
Netflix Alert Simulator
Sends realistic alerts to incident.io HTTP Alert Source endpoint
"""

import requests
import json
import sys
import os
import uuid
from pathlib import Path

# ========================================
# CONFIGURATION
# ========================================
# Set these as environment variables, or edit the fallback values below

ALERT_SOURCE_URL = os.environ.get(
    "INCIDENT_IO_ALERT_SOURCE_URL",
    "https://api.incident.io/v2/alert_events/http/YOUR_ALERT_SOURCE_ID_HERE",
)

API_TOKEN = os.environ.get("INCIDENT_IO_API_TOKEN", "YOUR_API_TOKEN_HERE")

# Load alerts from JSON file
SCRIPT_DIR = Path(__file__).parent
with open(SCRIPT_DIR / "alerts.json") as f:
    ALERTS = json.load(f)


def check_config():
    """Verify configuration is set up correctly."""
    if "YOUR_ALERT_SOURCE_ID_HERE" in ALERT_SOURCE_URL:
        print("\n" + "=" * 50)
        print("Your ALERT_SOURCE_URL hasn't been configured!")
        print("=" * 50)
        print()
        print("Option 1 - Set environment variables:")
        print("  export INCIDENT_IO_ALERT_SOURCE_URL='your-url-here'")
        print("  export INCIDENT_IO_API_TOKEN='your-token-here'")
        print()
        print("Option 2 - Edit this script and update the fallback values")
        print()
        print("Get these from: incident.io → Settings → Alert Sources → HTTP Alert Source")
        sys.exit(1)

    if API_TOKEN == "YOUR_API_TOKEN_HERE":
        print("\n" + "=" * 50)
        print("Your API_TOKEN hasn't been configured!")
        print("=" * 50)
        print("Set INCIDENT_IO_API_TOKEN environment variable or edit this script.")
        sys.exit(1)


# ========================================
# Script functions
# ========================================

def send_alert(scenario_id, resolve=False):
    """Send an alert to incident.io."""
    scenario = ALERTS[scenario_id]
    payload = json.loads(json.dumps(scenario["data"]))  # Deep copy

    # Generate unique deduplication key for each send
    dedup_base = payload["metadata"]["service"]
    payload["deduplication_key"] = f"netflix-{dedup_base}-{uuid.uuid4().hex[:8]}"

    if resolve:
        payload["status"] = "resolved"
        payload["description"] = f"RESOLVED: {payload['description']}"

    headers = {"Authorization": f"Bearer {API_TOKEN}", "Content-Type": "application/json"}

    print(f"\nSending: {scenario['name']}")
    print(f"  Status: {payload['status']}")
    print(f"  Team: {scenario['team']}")
    print(f"  Dedup Key: {payload['deduplication_key']}")

    try:
        response = requests.post(
            ALERT_SOURCE_URL,
            headers=headers,
            json=payload,
            timeout=10,
        )

        if response.status_code in [200, 202]:
            print("  Result: SUCCESS")
            return True
        else:
            print(f"  Result: FAILED ({response.status_code})")
            print(f"  Response: {response.text}")
            return False

    except requests.exceptions.RequestException as e:
        print(f"  Result: ERROR - {e}")
        return False


def show_menu():
    """Display the interactive menu."""
    print("\n" + "=" * 50)
    print("Netflix Alert Simulator")
    print("=" * 50)
    print("\nSelect an alert scenario to send:\n")

    for key, scenario in ALERTS.items():
        print(f"  {key}. {scenario['name']}")
        print(f"     → Routes to: {scenario['team']}")

    print()
    print("  a. Send ALL scenarios (tests full routing)")
    print("  q. Quit")
    print()


def main():
    """Main entry point."""
    check_config()

    # If command line arg provided, send that scenario directly
    if len(sys.argv) > 1:
        arg = sys.argv[1]
        if arg == "all":
            for scenario_id in ALERTS:
                send_alert(scenario_id)
            print("\nAll alerts sent! Check your incident.io workspace.")
        elif arg in ALERTS:
            send_alert(arg)
        else:
            print(f"Unknown scenario: {arg}")
            print(f"Valid options: {', '.join(ALERTS.keys())}, all")
            sys.exit(1)
        return

    # Interactive mode
    while True:
        show_menu()
        choice = input("Enter choice: ").strip().lower()

        if choice == "q":
            print("Goodbye!")
            break
        elif choice == "a":
            print("\nSending all scenarios...")
            for scenario_id in ALERTS:
                send_alert(scenario_id)
            print("\nAll alerts sent! Check your incident.io workspace.")
        elif choice in ALERTS:
            send_alert(choice)
            print("\nAlert sent! Check your incident.io workspace.")
        else:
            print("Invalid choice. Please try again.")


if __name__ == "__main__":
    main()
