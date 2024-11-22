#!/bin/bash

# # Function to generate workspace settings
# generate_workspace() {
#     local ws_name="$1"
#     local ws_value="$2"
#     echo "set \$${ws_name}-L \"$ws_value\""
#     echo -e "\tworkspace \$${ws_name}-L output \$L"
#     echo "set \$${ws_name}-R \"$((ws_value+1))\""
#     echo -e "\tworkspace \$${ws_name}-R output \$R"
# }

# # Loop to generate the code
# for i in {1..200}; do
#     generate_workspace "ws$i" "$((2*i-1))"
# done

# # set $ws1-L "1"
# # 	workspace $ws1-L output $L
# # set $ws1-R "2"
# # 	workspace $ws1-R output $R
# # set $ws2-L "3"
# # 	workspace $ws2-L output $L
# # set $ws2-R "4"
# # 	workspace $ws2-R output $R
# # set $ws3-L "5"
# # 	workspace $ws3-L output $L

#!/bin/bash
# Function to generate workspace settings for 4 screens
# generate_workspace() {
#     local ws_name="$1"
#     local ws_value="$2"

#     echo "set \$${ws_name}-LL \"$ws_value\""
#     echo -e "\tworkspace \$${ws_name}-LL output \$LL"

#     echo "set \$${ws_name}-L \"$((ws_value+1))\""
#     echo -e "\tworkspace \$${ws_name}-L output \$L"

#     echo "set \$${ws_name}-M \"$((ws_value+2))\""
#     echo -e "\tworkspace \$${ws_name}-M output \$M"

#     echo "set \$${ws_name}-R \"$((ws_value+3))\""
#     echo -e "\tworkspace \$${ws_name}-R output \$R"
# }

# # Loop to generate the code for 200 workspaces with zero-padded names
# for i in {1..200}; do
#     generate_workspace "ws$(printf "%02d" $i)" "$((4*i-3))"
# done



#!/bin/bash

# Define the starting values
start_num=1
end_num=500

# Loop to generate the sequence for 6 outputs (LL, L, M, R, TAIKO, MON_KB)
for ((i = "$start_num"; i <= "$end_num"; i++)); do
    # LL
    echo "### ws$(printf "%02d" $i)-LL ($(($i * 4 - 3)))"
    echo -e "\t"

    # L
    echo "### ws$(printf "%02d" $i)-L ($(($i * 4 - 2)))"
    echo -e "\t"

    # M
    echo "### ws$(printf "%02d" $i)-M ($(($i * 4 - 1)))"
    echo -e "\t"

    # R
    echo "### ws$(printf "%02d" $i)-R ($(($i * 4)))"
    echo -e "\t"

    # TAIKO
    echo "### ws$(printf "%02d" $i)-TAIKO ($(($i * 4 + 1)))"
    echo -e "\t"

    # MON_KB
    echo "### ws$(printf "%02d" $i)-MON_KB ($(($i * 4 + 2)))"
    echo -e "\t"
done
