#!/bin/bash

# Start or stop dotoold
dotoold &

# Simulate three left clicks with a short delay
for i in 1 2 3; do echo click left; sleep 0.05; done | dotoolc

# Simulate Ctrl+C key press
echo key ctrl+c | dotoolc
echo key ctrl+t | dotoolc
echo key ctrl+l | dotoolc
echo key ctrl+v | dotoolc
echo key enter  | dotoolc