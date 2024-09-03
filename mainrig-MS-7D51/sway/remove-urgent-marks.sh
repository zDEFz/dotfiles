#!/bin/bash

while true; do
    sleep 60
    wmctrl -l | cut -d " " -f1 | xargs -I {} wmctrl -i -r {} -b remove,demands_attention
done
