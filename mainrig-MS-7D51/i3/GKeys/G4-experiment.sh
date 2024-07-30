#!/bin/bash

# Send Down arrow key 10 times
for i in {1..12542}
do
  xdotool key Page_Up
  sleep .3
  xdotool key Down
  sleep .8
  xdotool key Page_Down
done
