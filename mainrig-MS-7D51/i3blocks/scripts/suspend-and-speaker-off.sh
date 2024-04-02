#!/bin/bash
    source ~/.aliases
    cd ~/broadlink || exit
    python3 -m venv venv
    # shellcheck disable=SC1091
    source venv/bin/activate
    control_speakers off both
    # if ADI-2 is connected, turn it off
    lsusb | grep -q "ADI-2" && control_dac off
    systemctl suspend
