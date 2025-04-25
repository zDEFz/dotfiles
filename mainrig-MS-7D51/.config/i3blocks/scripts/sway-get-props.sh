#!/bin/sh

swaymsg -t subscribe '["window"]' |
  jq --unbuffered -r '
    # Only focus events on containers with a valid id
    select(.change == "focus" and .container != null and .container.id != null) |

    . as $e |

    # Determine shell type: Wayland or XWayland
    (
      if $e.container.app_id then "Shell: Wayland"
      elif $e.container.window_properties then "Shell: XWayland"
      else "Shell: Unknown"
      end
    ) as $shell_type |

    # Build array of label-value strings
    [
      $shell_type,
      ("Type: \($e.container.type // empty)"),
      ("App ID: \($e.container.app_id // empty)"),
      ("Name: \($e.container.name // empty)"),
      ("Con_ID: \($e.container.id)")
    ]
    | map(select(length > 0))
    | join(", ")
  '



