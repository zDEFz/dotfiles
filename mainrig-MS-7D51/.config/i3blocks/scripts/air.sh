#!/bin/bash

# Fetch the content of the air quality page
content=$(curl -s https://www.iqair.com/germany/baden-wuerttemberg/wiesloch)

# Check for different air quality levels
if echo "$content" | grep -q "Open your windows"; then
    echo "Good air"
elif echo "$content" | grep -q "Moderate"; then
    echo "Moderate air"
elif echo "$content" | grep -q "Unhealthy for sensitive groups"; then
    echo "Unhealthy for sensitive groups"
elif echo "$content" | grep -q "Unhealthy"; then
    echo "Unhealthy air"
elif echo "$content" | grep -q "Very unhealthy"; then
    echo "Very unhealthy air"
elif echo "$content" | grep -q "Hazardous"; then
    echo "Hazardous air"
else
    echo "Bad air"
fi
