#!/bin/sh
# Use stdbuf to reduce buffering overhead and LC_ALL=C for faster text processing
LC_ALL=C stdbuf -o0 sar -P ALL 1 1 | 
  awk 'BEGIN {
    # Predefine constants to avoid recalculation
    symbols="▁▂▃▄▅▆▇█"
    red="#DC322F"
    yellow="#B58900"
    cyan="#2AA198"
    divisor=14.28571
    output=""
  }
  
  # Process only Average lines with CPU numbers - more precise pattern matching
  /Average:.*[0-9]/ && $3 ~ /^[0-9]+(\.[0-9]+)?$/ {
    val = $3
    
    # Calculate index with minimal operations
    idx = int((val / divisor) + 0.5)
    
    # Clamp index in one step with ternary operations
    idx = (idx < 0) ? 0 : ((idx > 7) ? 7 : idx)
    
    # Determine color with minimal comparisons
    color = (val >= 80) ? red : ((val >= 50) ? yellow : cyan)
    
    # Append to output string
    output = output sprintf("<span foreground=%s>%s</span> ", "\047" color "\047", substr(symbols, idx+1, 1))
  }
  
  # Print final result only at the end to ensure complete output
  END { print output }'






