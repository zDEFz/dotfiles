#!/bin/bash
HOSTNAME=$(hostname)
cat > ~/.config/wireplumber/wireplumber.conf.d/node-rename.conf << EOF
monitor.alsa.rules = [
  {
    matches = [
      {
        node.name = "alsa_output.usb-Generic_USB_Audio-00.pro-output-3"
      }
    ],
    actions = {
      update-props = {
        node.name = "${HOSTNAME}-Toslink-Out",
        node.nick = "${HOSTNAME}-Toslink Out",
        node.description = "${HOSTNAME} Toslink Out"
      }
    }
  },
  {
    matches = [
      {
        node.name = "alsa_output.usb-Generic_USB_Audio-00.pro-output-0"
      }
    ],
    actions = {
      update-props = {
        node.name = "${HOSTNAME}-Front-Out",
        node.nick = "${HOSTNAME}-Front Out",
        node.description = "${HOSTNAME} Front Out"
      }
    }
  }
]
EOF
