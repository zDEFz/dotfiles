#!/bin/bash

function control_dac() {
    cd ~/broadlink || exit
    python3 -m venv venv
    # shellcheck disable=SC1091
    source venv/bin/activate 
    if ! pip show broadlink &> /dev/null; then
        echo "broadlink not installed, installing..."
        pip install broadlink
    fi

    local command
    case $1 in
        on)
            command="power-held"
            ;;
        off)
            command="power"
            ;;
        input-opt)
            command="input-opt"
            ;;
        input-usb)
            command="input-usb"
            ;;
        input-coax)
            command="input-coax"
            ;;
        toggle-speakers-headphone)
            command="toggle-speakers-headphone"
            ;;
        *)
            echo "Invalid action: $1"
            return 1
            ;;
    esac
    broadlink_cli --device @/home/blu/broadlink/BEDROOM.device --send @"/home/blu/broadlink/RME/ADI2-DAC-FS/$command"
}

control_dac "$1"
   