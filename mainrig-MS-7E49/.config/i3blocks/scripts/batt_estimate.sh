#!/bin/bash
# batt_estimate.sh - Estimate remaining battery time and percentage using apcaccess output for UPS monitoring

while IFS=': ' read -r key val; do
    case "$key" in
        *TIMELEFT*) 
            m="${val%% *}"
            # Use bc for the floating point division only
            w=$(echo "scale=0; 11336 / $m + 40" | bc) ;;
        *BCHARGE*) 
            c="${val//[^0-9.]/}" ;;
    esac
done < <(apcaccess)
printf "%.0fW|%.1fmin|%.1f%%chg\n" "$w" "$m" "$c"