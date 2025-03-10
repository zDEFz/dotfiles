#!/bin/bash

# Get the process with the highest CPU usage in the last 5 seconds
top_process=$(ps -e --sort=-%cpu --no-headers | head -n 1 | awk '{print $4}')

# Print the result
echo "$top_process"
