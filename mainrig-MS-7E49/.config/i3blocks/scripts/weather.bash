#!/bin/bash
[ -f /home/blu/.secure_env ] && source /home/blu/.secure_env

CACHE_DIR="/tmp/weather_cache"
CACHE_FILE="$CACHE_DIR/weather.txt"
CACHE_AGE=300  # 5 minutes

mkdir -p "$CACHE_DIR"

# Check cache age
if [ -f "$CACHE_FILE" ]; then
    AGE=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    if [ $AGE -lt $CACHE_AGE ]; then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Fetch weather data
WEATHER_URL="https://api.openweathermap.org/data/2.5/weather?zip=${ZIP_CODE},${COUNTRY_CODE}&appid=${OPENWEATHERMAP_API_KEY}&units=metric"
WEATHER_DATA=$(curl -s "$WEATHER_URL")

# Quick fail check
if ! echo "$WEATHER_DATA" | grep -q "\"cod\":200"; then
    echo "Weather N/A"
    exit 1
fi

# Parse with simple grep (more reliable than complex parsing)
TEMP=$(echo "$WEATHER_DATA" | grep -o '"temp":[^,]*' | cut -d':' -f2 | cut -d'.' -f1)
DESCRIPTION=$(echo "$WEATHER_DATA" | grep -o '"description":"[^"]*' | cut -d'"' -f4)
HUMIDITY=$(echo "$WEATHER_DATA" | grep -o '"humidity":[0-9]*' | cut -d':' -f2)
WIND_SPEED=$(echo "$WEATHER_DATA" | grep -o '"speed":[0-9.]*' | cut -d':' -f2)
WIND_DEG=$(echo "$WEATHER_DATA" | grep -o '"deg":[0-9]*' | cut -d':' -f2)
LAT=$(echo "$WEATHER_DATA" | grep -o '"lat":[0-9.-]*' | cut -d':' -f2)
LON=$(echo "$WEATHER_DATA" | grep -o '"lon":[0-9.-]*' | cut -d':' -f2)

# Wind direction with array lookup
WIND_DEG=${WIND_DEG:-0}
DIRS=(↑ ↗ → ↘ ↓ ↙ ← ↖)
WIND_DIR=${DIRS[$(( (WIND_DEG + 22) / 45 % 8 ))]}

# Get air quality
AQI=0
if [ -n "$LAT" ] && [ -n "$LON" ]; then
    AIR_DATA=$(curl -s "https://api.openweathermap.org/data/2.5/air_pollution?lat=${LAT}&lon=${LON}&appid=${OPENWEATHERMAP_API_KEY}")
    AQI=$(echo "$AIR_DATA" | grep -o '"aqi":[0-9]*' | cut -d':' -f2)
fi

# AQI lookup with arrays
AQI_ICONS=(⚪ 🟢 🟡 🟠 🔴 🟣)
AQI_TEXTS=(N/A Good Fair Moderate Poor "Very Poor")
AQI=${AQI:-0}
AQI_ICON=${AQI_ICONS[$AQI]}
AQI_TEXT=${AQI_TEXTS[$AQI]}

# Weather icon
case "${DESCRIPTION,,}" in
    *clear*|*sunny*) ICON="☀" ;;
    *cloud*) ICON="☁" ;;
    *rain*|*drizzle*) ICON="🌧" ;;
    *storm*|*thunder*) ICON="⛈" ;;
    *snow*) ICON="❄" ;;
    *fog*|*mist*) ICON="🌫" ;;
    *) ICON="🌤" ;;
esac

# Output
OUTPUT="$ICON ${TEMP}°C | $DESCRIPTION | 💧${HUMIDITY}% | 🌬${WIND_SPEED}m/s $WIND_DIR | $AQI_ICON Air: $AQI_TEXT"
echo "$OUTPUT" | tee "$CACHE_FILE"
