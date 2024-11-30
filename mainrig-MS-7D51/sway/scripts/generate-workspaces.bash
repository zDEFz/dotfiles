#!/bin/bash
# Function to generate workspace settings for 7 screens (LL, L, M, R, RR, TAIKO, MON_KB)
generate_workspace() {
    local ws_name="$1"
    local ws_value="$2"

    # LL
    echo "set \$${ws_name}-LL \"$ws_value\""
    echo -e "\tworkspace \$${ws_name}-LL output \$LL"

    # L
    echo "set \$${ws_name}-L \"$((ws_value+1))\""
    echo -e "\tworkspace \$${ws_name}-L output \$L"

    # M
    echo "set \$${ws_name}-M \"$((ws_value+2))\""
    echo -e "\tworkspace \$${ws_name}-M output \$M"

    # R
    echo "set \$${ws_name}-R \"$((ws_value+3))\""
    echo -e "\tworkspace \$${ws_name}-R output \$R"

    # RR
    echo "set \$${ws_name}-RR \"$((ws_value+4))\""
    echo -e "\tworkspace \$${ws_name}-RR output \$RR"

    # TAIKO
    echo "set \$${ws_name}-TAIKO \"$((ws_value+5))\""
    echo -e "\tworkspace \$${ws_name}-TAIKO output \$TAIKO"

    # MON_KB
    echo "set \$${ws_name}-MON_KB \"$((ws_value+6))\""
    echo -e "\tworkspace \$${ws_name}-MON_KB output \$MON_KB"
}

# Loop to generate the code for 200 workspaces with zero-padded names
for i in {1..70}; do
    generate_workspace "ws$(printf "%02d" $i)" "$((7*i-6))"
done
