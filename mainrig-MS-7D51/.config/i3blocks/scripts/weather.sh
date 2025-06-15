#!/bin/bash
[ -f /home/blu/.secure_env ] && source /home/blu/.secure_env
# Current weather API call
WEATHER_URL="https://api.openweathermap.org/data/2.5/weather?zip=${ZIP_CODE},${COUNTRY_CODE}&appid=${OPENWEATHERMAP_API_KEY}&units=metric"
# Fetch weather data
WEATHER_DATA=$(curl -s "$WEATHER_URL")
# Check if API call was successful
if echo "$WEATHER_DATA" | grep -q "\"cod\":200"; then
    # Parse JSON response
    TEMP=$(echo "$WEATHER_DATA" | grep -o '"temp":[^,]*' | cut -d':' -f2 | cut -d'.' -f1)
    DESCRIPTION=$(echo "$WEATHER_DATA" | grep -o '"description":"[^"]*' | cut -d'"' -f4)
    HUMIDITY=$(echo "$WEATHER_DATA" | grep -o '"humidity":[0-9]*' | cut -d':' -f2)
    
    # Parse wind data
    WIND_SPEED=$(echo "$WEATHER_DATA" | grep -o '"speed":[0-9.]*' | cut -d':' -f2)
    WIND_DEG=$(echo "$WEATHER_DATA" | grep -o '"deg":[0-9]*' | cut -d':' -f2)
    
    # Convert wind direction degrees to compass direction arrow
    if [ -n "$WIND_DEG" ]; then
        if [ "$WIND_DEG" -ge 0 ] && [ "$WIND_DEG" -lt 23 ]; then
            WIND_DIR="↑"
        elif [ "$WIND_DEG" -ge 23 ] && [ "$WIND_DEG" -lt 68 ]; then
            WIND_DIR="↗"
        elif [ "$WIND_DEG" -ge 68 ] && [ "$WIND_DEG" -lt 113 ]; then
            WIND_DIR="→"
        elif [ "$WIND_DEG" -ge 113 ] && [ "$WIND_DEG" -lt 158 ]; then
            WIND_DIR="↘"
        elif [ "$WIND_DEG" -ge 158 ] && [ "$WIND_DEG" -lt 203 ]; then
            WIND_DIR="↓"
        elif [ "$WIND_DEG" -ge 203 ] && [ "$WIND_DEG" -lt 248 ]; then
            WIND_DIR="↙"
        elif [ "$WIND_DEG" -ge 248 ] && [ "$WIND_DEG" -lt 293 ]; then
            WIND_DIR="←"
        elif [ "$WIND_DEG" -ge 293 ] && [ "$WIND_DEG" -lt 338 ]; then
            WIND_DIR="↖"
        else
            WIND_DIR="↑"
        fi
    else
        WIND_DIR="⚬"
    fi

    # Get coordinates for air quality - clean up the parsing
    LAT=$(echo "$WEATHER_DATA" | grep -o '"lat":[0-9.-]*' | cut -d':' -f2)
    LON=$(echo "$WEATHER_DATA" | grep -o '"lon":[0-9.-]*' | cut -d':' -f2)
    
    # Debug: print coordinates
    # echo "DEBUG: LAT=$LAT LON=$LON" >&2
    
    # Get air quality data (only if we have coordinates)
    if [ -n "$LAT" ] && [ -n "$LON" ]; then
        AIR_QUALITY_URL="https://api.openweathermap.org/data/2.5/air_pollution?lat=${LAT}&lon=${LON}&appid=${OPENWEATHERMAP_API_KEY}"
        # echo "DEBUG: URL=$AIR_QUALITY_URL" >&2
        AIR_DATA=$(curl -s "$AIR_QUALITY_URL")
        
        # Debug: print air quality response
        # echo "DEBUG: AIR_DATA=$AIR_DATA" >&2
        
        # Parse air quality index (1=Good, 2=Fair, 3=Moderate, 4=Poor, 5=Very Poor)
        AQI=$(echo "$AIR_DATA" | grep -o '"aqi":[0-9]*' | cut -d':' -f2)
        # echo "DEBUG: AQI=$AQI" >&2
    fi
    
    case "$AQI" in
        1) AQI_TEXT="Good"; AQI_ICON="🟢" ;;
        2) AQI_TEXT="Fair"; AQI_ICON="🟡" ;;
        3) AQI_TEXT="Moderate"; AQI_ICON="🟠" ;;
        4) AQI_TEXT="Poor"; AQI_ICON="🔴" ;;
        5) AQI_TEXT="Very Poor"; AQI_ICON="🟣" ;;
        *) AQI_TEXT="N/A"; AQI_ICON="⚪" ;;
    esac
    
    # Get weather icon based on description
    case "$DESCRIPTION" in
        *clear*|*sunny*) ICON="☀" ;;
        *cloud*) ICON="☁" ;;
        *rain*|*drizzle*) ICON="🌧" ;;
        *storm*|*thunder*) ICON="⛈" ;;
        *snow*) ICON="❄" ;;
        *fog*|*mist*) ICON="🌫" ;;
        *) ICON="🌤" ;;
    esac
    
    # One line output for i3blocks with humidity and wind
    echo "$ICON ${TEMP}°C | $DESCRIPTION | 💧${HUMIDITY}% | 🌬${WIND_SPEED}m/s $WIND_DIR | $AQI_ICON Air: $AQI_TEXT"
    
else
    echo "Weather N/A"
fi
