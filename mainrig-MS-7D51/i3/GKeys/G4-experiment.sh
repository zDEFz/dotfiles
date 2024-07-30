#!/bin/bash

# Send Down arrow key 10 times
for i in {1..1200}
do
  xdotool key Down
  sleep .8
done
