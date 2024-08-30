#!/bin/bash

# Fetch the content of the air quality page
content=$(curl -s https://www.iqair.com/germany/baden-wuerttemberg/wiesloch)

# Check for "Open your windows" or "Moderate"
if echo "$content" | grep -q "Open your windows"; then
    echo "Good air outside"
elif echo "$content" | grep -q "Moderate"; then
    echo "Moderate air outside"
else
    echo "Bad air outside"
fi
