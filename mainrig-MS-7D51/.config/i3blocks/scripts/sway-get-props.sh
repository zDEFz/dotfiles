#!/bin/sh
swaymsg -t subscribe '["window"]' |
  jq --unbuffered -r '
    # 1) Only care about focus events on containers with a valid id
    select(.change == "focus" and .container != null and .container.id != null) |

    # 2) Build an array of “Label: Value” pairs, skipping any empty ones
    [
      ("Type: \(.container.type // empty)"),
      ("App ID: \(.container.app_id // empty)"),
      ("Name: \(.container.name // empty)"),
      ("Con_ID: \(.container.id)")
    ]
    | map(select(length > 0))
    # 3) Join into a single comma‑separated string
    | join(", ")
  '
