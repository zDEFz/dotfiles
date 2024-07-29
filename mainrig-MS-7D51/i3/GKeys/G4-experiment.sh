#!/bin/bash

# Send Down arrow key 10 times
for i in {1..30}
do
  xdotool key Down
  sleep .5
done
