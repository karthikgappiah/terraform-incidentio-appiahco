#!/usr/bin/env bash
# Read-only summaries of the workspace, so you never dump raw route JSON.
#
#   scripts/inspect.sh status   # firing alerts, live escalations, open incidents (is it clean?)
#   scripts/inspect.sh firing   # firing alerts as JSON [{title, deduplication_key}], for resolving
#   scripts/inspect.sh route    # each alert route: sources, conditions, targets, fallback, incidents
#   scripts/inspect.sh source   # each alert source: which attribute each field binds to
#
# Needs INCIDENT_API_KEY (inc is already authed) and jq.
set -euo pipefail

firing() {
  # page_size is capped at 50 on alerts and routes.
  inc api GET /v2/alerts --paginate --field page_size=50 --field 'status[one_of]=firing' \
    --jq '.alerts[] | {title, deduplication_key}' | jq -s .
}

attribute_names() {
  inc api GET /v2/alert_attributes | jq 'reduce .alert_attributes[] as $a ({}; .[$a.id] = $a.name)'
}

case "${1:-status}" in
status)
  echo "Firing alerts:    $(firing | jq length)"
  # Escalations in a terminal state still show in the list.
  echo "Live escalations: $(inc escalations list --output json \
    | jq '[.[] | select(.status | IN("cancelled", "expired", "resolved") | not)] | length')"
  echo "Open incidents:   $(for c in triage live; do inc incidents list --status-category "$c" --output json; done \
    | jq -s 'add | length')"
  ;;
firing)
  firing
  ;;
route)
  names=$(attribute_names)
  for id in $(inc api GET /v2/alert_routes --field page_size=50 | jq -r '.alert_routes[].id'); do
    inc api GET "/v2/alert_routes/$id" | jq --argjson names "$names" '.alert_route | {
      name, enabled,
      sources: [.alert_sources[].alert_source_id],
      conditions: [.condition_groups[].conditions[] | "\(.subject.label) \(.operation.label) \([.param_bindings[].value.label] | join(", "))"],
      auto_cancel: .escalation_config.auto_cancel_escalations,
      targets: [.escalation_config.escalation_targets[][] | .array_value[]?.label // .value.label],
      expressions: [.expressions[] | {label, ops: [.operations[].operation_type], fallback: [.else_branch.result.array_value[]?.label]}],
      incidents: .incident_config | {
        enabled, auto_decline_enabled, defer_time_seconds, grouping_window_seconds,
        when: [.condition_groups[].conditions[] | "\(.subject.label) \(.operation.label) \([.param_bindings[].value.label] | join(", "))"],
        grouping_keys: [.grouping_keys[].reference | ltrimstr("alert.attributes.") | $names[.] // .]
      }
    }'
  done
  ;;
source)
  names=$(attribute_names)
  for id in $(inc api GET /v2/alert_sources --field page_size=50 | jq -r '.alert_sources[].id'); do
    # Each attribute as its expression chain: "$.path → Navigate || fallback chain".
    inc api GET "/v2/alert_sources/$id" | jq --argjson names "$names" '.alert_source
      | (.template.expressions | map({(.reference): .}) | add) as $exprs
      | def chain($ref): $exprs[$ref | ltrimstr("expressions[\"") | rtrimstr("\"]")] as $e
          | ([$e.operations[] | .parse.source // .navigate.reference_label // .operation_type] | join(" → "))
            + (if $e.else_branch.result.value.reference then " || " + chain($e.else_branch.result.value.reference)
               elif $e.else_branch then " || " + ([$e.else_branch.result.array_value[]?.label, $e.else_branch.result.value.label] | map(select(.)) | join(", "))
               else "" end);
      {id, name, source_type,
       attributes: [.template.attributes[] | {($names[.alert_attribute_id] // .alert_attribute_id):
         (if .binding.value.reference then chain(.binding.value.reference) else .binding.value.label // .binding end)}] | add}'
  done
  ;;
*)
  sed -n '2,8p' "$0"
  exit 1
  ;;
esac
