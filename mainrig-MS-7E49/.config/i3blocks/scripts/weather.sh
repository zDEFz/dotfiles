/#!/bin/bash
# weather.sh - Display current weather conditions with caching to minimize API calls, including air quality index and sunrise/sunset times
[ -f /home/blu/.secure_env ] && source /home/blu/.secure_env

CACHE_DIR="/dev/shm/weather_cache"
CACHE_FILE="$CACHE_DIR/weather.txt"
mkdir -p "$CACHE_DIR"

# 1. Check Cache - Only exit if the file actually has content
if [[ -s "$CACHE_FILE" ]]; then
    AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if (( AGE < 300 )); then
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# 2. Fetch Data
URL="https://api.openweathermap.org/data/2.5/weather?zip=${ZIP_CODE},${COUNTRY_CODE}&appid=${OPENWEATHERMAP_API_KEY}&units=metric"
DATA=$(curl -s "$URL")

if [[ "$DATA" != *'"cod":200'* ]]; then
    echo "Weather: API/Connection Error"
    exit 1
fi

# 3. Extraction logic
# We use a slightly different sed pattern to ensure we don't get empty strings
TEMP=$(echo "$DATA" | sed -n 's/.*"temp":\([0-9.]*\).*/\1/p')
DESC=$(echo "$DATA" | sed -n 's/.*"description":"\([^"]*\)".*/\1/p')
HUM=$(echo "$DATA" | sed -n 's/.*"humidity":\([0-9]*\).*/\1/p')
WIND_S=$(echo "$DATA" | sed -n 's/.*"speed":\([0-9.]*\).*/\1/p')
WIND_D=$(echo "$DATA" | sed -n 's/.*"deg":\([0-9]*\).*/\1/p')
LAT=$(echo "$DATA" | sed -n 's/.*"lat":\([0-9.-]*\).*/\1/p')
LON=$(echo "$DATA" | sed -n 's/.*"lon":\([0-9.-]*\).*/\1/p')
RISE=$(echo "$DATA" | sed -n 's/.*"sunrise":\([0-9]*\).*/\1/p')
SET=$(echo "$DATA" | sed -n 's/.*"sunset":\([0-9]*\).*/\1/p')

# 4. Air Quality Call
AQI_DATA=$(curl -s "https://api.openweathermap.org/data/2.5/air_pollution?lat=${LAT}&lon=${LON}&appid=${OPENWEATHERMAP_API_KEY}")
AQI=$(echo "$AQI_DATA" | sed -n 's/.*"aqi":\([0-9]\).*/\1/p')
AQI=${AQI:-0}

# 5. Icons & Formatting
DIRS=(↑ ↗ → ↘ ↓ ↙ ← ↖)
WIND_DIR=${DIRS[$(( (WIND_D + 22) / 45 % 8 ))]}
AQI_ICONS=(⚪ 🟢 🟡 🟠 🔴 🟣)
AQI_TEXTS=(N/A Good Fair Moderate Poor "Very Poor")

case "${DESC,,}" in 
    *clear*) I="☀" ;; *cloud*) I="☁" ;; *rain*) I="🌧" ;; 
    *storm*) I="⛈" ;; *snow*) I="❄" ;; *mist*|*fog*) I="🌫" ;; *) I="🌤" ;;
esac

# Ensure TEMP is an integer for rounding
TEMP_INT=${TEMP%.*}

# Final check: if TEMP_INT is empty, something went wrong with sed
if [[ -z "$TEMP_INT" ]]; then
    echo "Weather: Parsing Error"
    exit 1
fi

OUTPUT="$I ${TEMP_INT}°C | $DESC | 💧$HUM% | 🌬$WIND_S m/s $WIND_DIR | ${AQI_ICONS[$AQI]} Air: ${AQI_TEXTS[$AQI]} | 🌅$(date -d "@$RISE" +%H:%M) 🌇$(date -d "@$SET" +%H:%M)"

# 6. Save and Display
echo "$OUTPUT" > "$CACHE_FILE"
cat "$CACHE_FILE"
