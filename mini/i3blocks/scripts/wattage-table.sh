#!/bin/bash
cd /home/blu/git/plugp100
source venv/bin/activate
python3 plugp100-helper.py 192.168.178.22 watt 2> /dev/null | awk -F '[=)]' '{print $2}' | tr -d '\n'; echo W



