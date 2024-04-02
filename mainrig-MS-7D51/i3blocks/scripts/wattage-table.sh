#!/bin/bash
cd /home/blu/plugp100
source venv/bin/activate
#python3 turn-off-turn-on.py 192.168.178.22 watt 2> /dev/null | awk -F '[=)]' '{print $2}' | tr -d '\n'; echo
#python3 turn-off-turn-on.py 192.168.178.22 watt 2> /dev/null | awk -F '[=)]' '{print $2}' | tr -d '\n'
#python3 turn-off-turn-on.py 192.168.178.22 watt 2> /dev/null | awk -F '[=)]' '{print $2}' | tr -d '\n'
#python3 turn-off-turn-on.py 192.168.178.22 watt 2> /dev/null | awk -F '[=)]' '{print $2}' | tr -d '\n'
#python3 turn-off-turn-on.py 192.168.178.22 watt 2> /dev/null | awk -F '[=)]' '{print $2}' | tr -d '\n'; echo W
python3 plugp100-helper.py 192.168.178.22 watt 2> /dev/null | awk -F '[=)]' '{print $2}' | tr -d '\n'; echo W




