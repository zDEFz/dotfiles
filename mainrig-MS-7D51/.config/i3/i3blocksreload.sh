#!/bin/bash
killall i3bar
i3-msg "exec --no-startup-id i3bar --bar_id=bar-1"
i3-msg "exec --no-startup-id  i3bar --bar_id=bar-2"