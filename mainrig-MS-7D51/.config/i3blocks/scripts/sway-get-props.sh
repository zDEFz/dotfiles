#!/bin/sh

# Continuously listen for window focus events using swaymsg and process them with jq
while true; do
  swaymsg -t subscribe '["window"]' |
    jq --unbuffered -r '
      # Only focus events on containers with a valid id
      select(.change == "focus" and .container != null and .container.id != null) |

      . as $e |

      # Determine shell type: Wayland or xwayland
      (
        if $e.container.app_id then "Shell: xdg_shell"
        elif $e.container.window_properties then "Shell: xwayland"
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
done
