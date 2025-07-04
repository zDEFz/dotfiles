#!/bin/bash
# SAP Stock Price Scraper with i3blocks pango markup
# Fetches current SAP SE stock price with color coding
URL="https://www.boerse.de/empfehlungen/SAP-Aktie/DE0007164600"

# Check if it's blackout period (earnings season)
# SAP 2025 Earnings Schedule:
# Q1 2025: April 22, 2025 (already reported)
# Q2 2025: July 22, 2025
# Q3 2025: Expected late October 2025
# Q4 2025: Expected late January 2026

current_month=$(date +%m)
current_day=$(date +%d)
current_year=$(date +%Y)

is_blackout_period() {
    # Blackout periods: 2 weeks before earnings announcement
    # Using typical SAP earnings pattern based on 2025 schedule
    
    case $current_month in
        01) # January - Q4 blackout period
            # Q4 earnings typically end of January
            if [ "$current_day" -ge 15 ]; then
                return 0
            fi
            ;;
        02) # February - Q4 blackout continuation
            if [ "$current_day" -le 5 ]; then
                return 0
            fi
            ;;
        04) # April - Q1 blackout (already passed for 2025)
            if [ "$current_year" -gt 2025 ]; then
                # For future years, assume mid-April
                if [ "$current_day" -ge 8 ] && [ "$current_day" -le 22 ]; then
                    return 0
                fi
            fi
            ;;
        07) # July - Q2 blackout
            # Q2 2025 earnings: July 22
            # Extended blackout period: July 1-22, 2025 (full month approach)
            if [ "$current_day" -ge 1 ] && [ "$current_day" -le 22 ]; then
                return 0
            fi
            ;;
        10) # October - Q3 blackout
            # Q3 earnings typically late October
            if [ "$current_day" -ge 15 ]; then
                return 0
            fi
            ;;
        11) # November - Q3 blackout continuation
            if [ "$current_day" -le 5 ]; then
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
    
    # Debug: Check current date and blackout status
    # Uncomment the next line for debugging
    # echo "Debug: Month=$current_month, Day=$current_day, Year=$current_year" >&2
    
    # Determine color and emoji based on conditions
    # Check blackout period FIRST before checking price changes
    if is_blackout_period; then
        # Red for blackout period with blackout emoji
        echo '<span color="#ff0000">🚫SAP SE: €'"${formatted_price}"' (BLACKOUT)</span>'
    elif [[ "$change" == +* ]]; then
        # Green for positive change
        echo '<span color="#00ff00">✅SAP SE: €'"${formatted_price}"'</span>'
    elif [[ "$change" == -* ]]; then
        # Red for negative change
        echo '<span color="#ff4444">❌SAP SE: €'"${formatted_price}"'</span>'
    else
        # White/default for no change data
        echo '<span color="#ffffff">⚪SAP SE: €'"${formatted_price}"'</span>'
    fi
else
    echo '<span color="#ff0000">SAP SE: N/A</span>'
fi
