#!/bin/bash
#cd /home/blu/git/python-broadlink
#python3 -m venv venv
#source venv/bin/activate
echo "hum. bedroom: $(broadlink_cli --device @/home/blu/broadlink/BEDROOM.device --humid)"
