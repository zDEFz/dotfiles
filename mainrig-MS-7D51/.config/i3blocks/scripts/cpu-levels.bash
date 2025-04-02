#!/bin/sh

# Define the CPU ramp array (8 levels)
ramp_arr=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

# Function to select color based on CPU usage
choose_color() {
    usage="$1"
    if [ $(echo "$usage >= 80" | bc -l) -eq 1 ]; then
        echo "#DC322F"  # Red for high usage
    elif [ $(echo "$usage >= 50" | bc -l) -eq 1 ]; then
        echo "#B58900"  # Yellow for moderate usage
    else
        echo "#2AA198"  # Cyan for low usage
    fi
}

output=""

# Calculate the scale step: 100% divided by the number of steps (7 intervals for 8 levels)
scale=$(echo "scale=4; 100/7" | bc -l)

# Process each line of sar output in the current shell
while read -r line; do
    # Extract CPU usage from the third field (adjust if needed)
    val=$(echo "$line" | awk '{print $3}')
    # Skip if value is not numeric
    if ! echo "$val" | grep -Eq '^[0-9]+(\.[0-9]+)?$'; then
        continue
    fi
    # Compute the index based on the step size
    idx=$(echo "scale=4; $val / $scale" | bc -l)
    intidx=$(printf "%.0f" "$idx")
    # Clamp index to the valid range (0 to 7)
    if [ "$intidx" -lt 0 ]; then
        intidx=0
    elif [ "$intidx" -gt 7 ]; then
        intidx=7
    fi
    # Select a color based on the current CPU usage
    color=$(choose_color "$val")
    # Append this bar with Pango markup
    output="${output}<span foreground='${color}'>${ramp_arr[$intidx]}</span> "
done < <(sar -P ALL 1 1 | grep -E 'Average:\s+[0-9]+')

# Output a single line for i3blocks
echo "$output"

