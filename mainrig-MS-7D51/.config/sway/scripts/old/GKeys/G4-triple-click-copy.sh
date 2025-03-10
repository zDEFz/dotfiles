#!/bin/bash

# Start or stop dotoold
dotoold &

# Simulate three left clicks with a short delay
#for i in 1 2 3; do echo click left; sleep 0.05; done | dotoolc

# Simulate Ctrl+C key press
for i in 1 2; do
for i in 1 2 3; do echo click left; sleep 0.05; done | dotoolc

  echo key ctrl+c | dotoolc
  swaymsg '[class="code-oss"] focus'
  sleep 0.1
  echo key ctrl+v | dotoolc
  echo key enter | dotoolc
done

#echo key ctrl+t | dotoolc
#echo key ctrl+l | dotoolc
#echo key ctrl+v | dotoolc
#echo key enter  | dotoolc
