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
generate_workspace() {
    local ws_name="$1"
    local ws_value="$2"

    echo "set \$${ws_name}-LL \"$ws_value\""
    echo -e "\tworkspace \$${ws_name}-LL output \$LL"

    echo "set \$${ws_name}-L \"$((ws_value+1))\""
    echo -e "\tworkspace \$${ws_name}-L output \$L"

    echo "set \$${ws_name}-M \"$((ws_value+2))\""
    echo -e "\tworkspace \$${ws_name}-M output \$M"

    echo "set \$${ws_name}-R \"$((ws_value+3))\""
    echo -e "\tworkspace \$${ws_name}-R output \$R"
}

# Loop to generate the code for 200 workspaces
for i in {1..200}; do
    generate_workspace "ws$i" "$((4*i-3))"
done
