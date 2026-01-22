#!/bin/bash

cd ~/broadlink || exit
python3 -m venv venv
# shellcheck disable=SC1091
source venv/bin/activate
# If the flag file exists, send the second command
broadlink_cli --device @/home/blu/broadlink/BEDROOM.device --send @/home/blu/broadlink/ezcoo/EZ-SW24-U3L/ezcoo-usb-hub-pc-1
