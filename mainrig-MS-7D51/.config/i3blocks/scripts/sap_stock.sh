#!/bin/bash

# SAP Stock Price Scraper with i3blocks pango markup
# Fetches current SAP SE stock price with color coding

URL="https://www.boerse.de/empfehlungen/SAP-Aktie/DE0007164600"

# Check if it's blackout period (earnings season - typically around quarterly reports)
# SAP reports: Q1 (Apr), Q2 (Jul), Q3 (Oct), Q4 (Jan)
current_month=$(date +%m)
current_day=$(date +%d)

is_blackout_period() {
    # Blackout periods: 2 weeks before earnings (rough estimate)
    # Q1: Mid-March to mid-April
    # Q2: Mid-June to mid-July  
    # Q3: Mid-September to mid-October
    # Q4: Mid-December to mid-January
    
    case $current_month in
        01) # January - Q4 blackout
            if [ $current_day -le 15 ]; then
                return 0
            fi
            ;;
        03) # March - Q1 blackout starts
            if [ $current_day -ge 15 ]; then
                return 0
            fi
            ;;
        04) # April - Q1 blackout ends
            if [ $current_day -le 15 ]; then
                return 0
            fi
            ;;
        06) # June - Q2 blackout starts
            if [ $current_day -ge 15 ]; then
                return 0
            fi
            ;;
        07) # July - Q2 blackout ends
            if [ $current_day -le 15 ]; then
                return 0
            fi
            ;;
        09) # September - Q3 blackout starts
            if [ $current_day -ge 15 ]; then
                return 0
            fi
            ;;
        10) # October - Q3 blackout ends
            if [ $current_day -le 15 ]; then
                return 0
            fi
            ;;
        12) # December - Q4 blackout starts
            if [ $current_day -ge 15 ]; then
                return 0
            fi
            ;;
    esac
    return 1
}

# Fetch the webpage
html=$(curl -s --max-time 10 -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" "$URL")

if [ $? -ne 0 ] || [ -z "$html" ]; then
    echo '<span color="#ff0000">SAP SE: Error</span>'
    exit 1
fi

# Extract current price
current_price=$(echo "$html" | grep -oP 'data-price="[0-9,.]+"' | head -1 | grep -oP '[0-9,.]+'| tr ',' '.')

# Alternative extraction methods
if [ -z "$current_price" ]; then
    current_price=$(echo "$html" | grep -oP 'class="[^"]*price[^"]*"[^>]*>[^<]*[0-9]+[,.]?[0-9]*' | head -1 | grep -oP '[0-9]+[,.]?[0-9]*' | tr ',' '.')
fi

if [ -z "$current_price" ]; then
    current_price=$(echo "$html" | grep -oP '[0-9]+[,.]?[0-9]*\s*EUR' | head -1 | grep -oP '[0-9]+[,.]?[0-9]*' | tr ',' '.')
fi

# Extract change to determine color
change=$(echo "$html" | grep -oP '[+\-][0-9,.]+ *%' | head -1)

if [ -n "$current_price" ] && [ "$current_price" != "0" ]; then
    # Clean and format price
    clean_price=$(echo "$current_price" | tr -cd '0-9.')
    formatted_price=$(printf "%.2f" "$clean_price" 2>/dev/null || echo "$clean_price")
    
    # Determine color and emoji based on conditions
    if is_blackout_period; then
        # Red for blackout period with blackout emoji
        color="#ff0000"
        emoji="🚫"
    elif [[ "$change" == +* ]]; then
        # Green for positive change
        color="#00ff00"
        emoji="✅"
    elif [[ "$change" == -* ]]; then
        # Red for negative change
        color="#ff4444"
        emoji="❌"
    else
        # White/default for no change data
        color="#ffffff"
        emoji="⚪"
    fi
    
    echo "<span color=\"$color\">${emoji}SAP SE: €${formatted_price}</span>"
else
    echo '<span color="#ff0000">SAP SE: N/A</span>'
fi
